from flask import Blueprint, render_template, request, jsonify, session
from xml.dom import minidom
from flask import send_file
from datetime import datetime
from flask import request
import xml.etree.ElementTree as ET
import xml.etree.ElementTree as ET
import os
import xml.etree.ElementTree as ET
import io   
import psycopg2
import os
import xml.etree.ElementTree as ET
import time
 

sqlstudio_bp = Blueprint("sqlstudio", __name__)

def get_db_connection():
    database_url = os.getenv("DATABASE_URL")

    if database_url:
        return psycopg2.connect(database_url, sslmode="require")
    else:
        return psycopg2.connect(
            dbname="BDTeacherAssesment",
            user="postgres",
            password="1234",
            host="127.0.0.1",
            port="5432",
            sslmode="disable"
        ) 

    
@sqlstudio_bp.route("/sqlstudio")
def sqlstudio():

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            q.id,
            q.nombre,
            q.descripcion,
            q.categoria,
            q.consulta,
            q.fecha_modificacion,
            q.ultima_ejecucion,
            q.activa,
            COALESCE(u.nombre || ' ' || u.apellido, '') AS creado_por,
            q.fecha_creacion
        FROM sqlstudio_queries q
        LEFT JOIN usuarios u
            ON u.id = q.creado_por
        WHERE q.activa = TRUE
        ORDER BY q.fecha_modificacion desc;
            """)

    consultas = cur.fetchall()  
    
    cur.execute("""
        SELECT DISTINCT INITCAP(TRIM(categoria)) AS categoria
            FROM sqlstudio_queries
            WHERE activa = TRUE
            AND categoria IS NOT NULL
            AND TRIM(categoria) <> ''
            ORDER BY INITCAP(TRIM(categoria));
    """)

    categorias = [x[0] for x in cur.fetchall()]

    cur.close()
    conn.close()

    return render_template(
        "sqlstudio.html",
        consultas=consultas,
        categorias=categorias,
        full_width=True
    )
    
@sqlstudio_bp.route("/sqlstudio/guardar", methods=["POST"])
def guardar_consulta():

    data = request.get_json()

    categoria = " ".join(data["categoria"].split()).capitalize()

    conn = get_db_connection()
    cur = conn.cursor()

    if data.get("id"):

        cur.execute("""
            UPDATE sqlstudio_queries
            SET nombre=%s,
                categoria=%s,
                consulta=%s,
                modificado_por=%s,
                fecha_modificacion=CURRENT_TIMESTAMP
                
            WHERE id=%s
        """, (
                data["nombre"],
                categoria,
                data["consulta"],
                session["user_id"],
                data["id"]
            ))

    else:

        cur.execute("""
           INSERT INTO sqlstudio_queries
            (
                nombre,
                categoria,
                consulta,
                creado_por
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s
            )
           """, (
                data["nombre"],
                categoria,
                data["consulta"],
                session["user_id"]
            ))

    conn.commit()

    cur.close()
    conn.close()

    return jsonify({"ok": True})

@sqlstudio_bp.route("/sqlstudio/eliminar", methods=["POST"])
def eliminar_consulta():

    data = request.get_json()

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        UPDATE sqlstudio_queries
        SET
            activa = FALSE,
            modificado_por = %s,
            fecha_modificacion = CURRENT_TIMESTAMP
        WHERE id = %s
    """, (
        session["user_id"],
        data["id"]
    ))

    conn.commit()

    cur.close()
    conn.close()

    return jsonify({"ok": True})

@sqlstudio_bp.route("/sqlstudio/duplicar", methods=["POST"])
def duplicar_consulta():

    data = request.get_json()

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            nombre,
            descripcion,
            categoria,
            consulta
        FROM sqlstudio_queries
        WHERE id=%s
    """, (data["id"],))

    consulta = cur.fetchone()
    
    import re

    nombre_original = consulta[0]

    # Quita un posible " (n)" al final
    nombre_base = re.sub(r" \(\d+\)$", "", nombre_original)

    cur.execute("""
        SELECT nombre
        FROM sqlstudio_queries
        WHERE nombre LIKE %s
    """, (f"{nombre_base}%",))

    existentes = [r[0] for r in cur.fetchall()]

    numero = 0

    for nombre in existentes:

        if nombre == nombre_base:
            numero = max(numero, 1)
            continue

        m = re.match(rf"^{re.escape(nombre_base)} \((\d+)\)$", nombre)

        if m:
            numero = max(numero, int(m.group(1)) + 1)

    nuevo_nombre = (
        nombre_base
        if numero == 0
        else f"{nombre_base} ({numero})"
    )

    cur.execute("""
        INSERT INTO sqlstudio_queries
        (
            nombre,
            descripcion,
            categoria,
            consulta,
            creado_por,
            fecha_creacion,
            activa
        )
        VALUES
        (
            %s,
            %s,
            %s,
            %s,
            %s,
            CURRENT_TIMESTAMP,
            TRUE
        )
    """, (
        nuevo_nombre,
        consulta[1],   # descripcion
        consulta[2],   # categoria
        consulta[3],   # consulta
        session["user_id"]
    ))

    conn.commit()

    cur.close()
    conn.close()

    return jsonify({"ok": True})


@sqlstudio_bp.route("/sqlstudio/exportar/<int:consulta_id>")
def exportar_consulta(consulta_id):

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            nombre,
            descripcion,
            categoria,
            consulta
        FROM sqlstudio_queries
        WHERE id=%s
    """, (consulta_id,))

    consulta = cur.fetchone()

    cur.close()
    conn.close()

    if not consulta:
        return "Consulta no encontrada", 404
    
    version = "Desconocida"

    try:
        ruta_version = os.path.join(
            os.path.dirname(os.path.dirname(__file__)),
            "version.txt"
        )

        with open(ruta_version, "r", encoding="utf-8") as f:
            version = f.read().strip()

    except:
        pass


    nombre, descripcion, categoria, sql = consulta

    root = ET.Element("ACAASO-SQLStudio")
    root.set("FileVersion", "1.0")

    ET.SubElement(root, "Application").text = "TeacherAssessment"
    ET.SubElement(root, "ApplicationVersion").text = version
    ET.SubElement(root, "ExportDate").text = datetime.now().isoformat(timespec="seconds")
    ET.SubElement(root, "ExportedBy").text = session.get("user_name", "")

    query = ET.SubElement(root, "Query")

    ET.SubElement(query, "Name").text = nombre
    ET.SubElement(query, "Description").text = descripcion or ""
    ET.SubElement(query, "Category").text = categoria or ""
    ET.SubElement(query, "Sql").text = sql or ""
   
    xml = ET.tostring(root, encoding="utf-8")

    xml = minidom.parseString(xml).toprettyxml(
        indent="    ",
        encoding="utf-8"
    )

    archivo = io.BytesIO(xml)

    return send_file(
        archivo,
        mimetype="application/xml",
        as_attachment=True,
        download_name=f"{nombre}.sqlstudio"
    )
    
@sqlstudio_bp.route("/sqlstudio/importar", methods=["POST"])
def importar_consulta():

    if "archivo" not in request.files:
        return jsonify({
            "ok": False,
            "mensaje": "No se recibió ningún archivo."
        })

    archivo = request.files["archivo"]

    if archivo.filename == "":
        return jsonify({
            "ok": False,
            "mensaje": "Debe seleccionar un archivo."
        })

    try:

        tree = ET.parse(archivo)
        root = tree.getroot()

    except ET.ParseError:

        return jsonify({
            "ok": False,
            "mensaje": "El archivo no es un XML válido."
        })

    if root.tag != "ACAASO-SQLStudio":

        return jsonify({
            "ok": False,
            "mensaje": "El archivo seleccionado no corresponde a una consulta de SQL Studio."
        })
        
    file_version = root.attrib.get("FileVersion")

    if not file_version:

        return jsonify({
            "ok": False,
            "mensaje": "El archivo no indica la versión del formato (FileVersion)."
        })

    if file_version != "1.0":

        return jsonify({
            "ok": False,
            "mensaje": f"Formato SQL Studio no compatible.\n\nVersión encontrada: {file_version}\nVersión soportada: 1.0"
        })
        
    application = root.findtext("Application", "").strip()
    application_version = root.findtext("ApplicationVersion", "").strip()
    export_date = root.findtext("ExportDate", "").strip()
    exported_by = root.findtext("ExportedBy", "").strip()
    
    query = root.find("Query")

    if query is None:

        return jsonify({
            "ok": False,
            "mensaje": "El archivo no contiene la definición de la consulta."
        })
        
    nombre = query.findtext("Name", "").strip()
    descripcion = query.findtext("Description", "").strip()
    categoria = query.findtext("Category", "").strip()
    sql = query.findtext("Sql", "").strip()   
    
    
    return jsonify({
        "ok": True,
        "mensaje": "Consulta leída correctamente.",
        "nombre": nombre,
        "descripcion": descripcion,
        "categoria": categoria,
        "sql": sql,
        "application": application,
        "application_version": application_version,
        "export_date": export_date,
        "exported_by": exported_by,
    })
    
@sqlstudio_bp.route("/sqlstudio/importar_confirmar", methods=["POST"])
def importar_confirmar():

    data = request.get_json()

    nombre = data["nombre"].strip()
    categoria = data["categoria"].strip()
    sql = data["sql"].strip()

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        INSERT INTO sqlstudio_queries
        (
            nombre,
            categoria,
            consulta,
            descripcion,
            creado_por,
            fecha_creacion,
            activa
        )
        VALUES
        (
            %s,
            %s,
            %s,
            '',
            %s,
            NOW(),
            TRUE
        )
    """, (
        nombre,
        categoria,
        sql,
        session["user_id"]
    ))

    conn.commit()

    cur.close()
    conn.close()

    return jsonify({
        "ok": True,
        "mensaje": "Consulta importada correctamente."
    })
    
@sqlstudio_bp.route("/sqlstudio/revisar_sql", methods=["POST"])
def revisar_sql():

    datos = request.get_json()
    sql = datos.get("sql", "").strip()

    sql_upper = sql.upper()

    # Debe comenzar con SELECT o WITH
    if not (sql_upper.startswith("SELECT") or sql_upper.startswith("WITH")):
        return jsonify({
            "ok": False,
            "mensaje": "Solo se permiten consultas SELECT."
        })

    # Palabras prohibidas
    prohibidas = [
        "INSERT",
        "UPDATE",
        "DELETE",
        "DROP",
        "ALTER",
        "TRUNCATE",
        "CREATE",
        "MERGE",
        "CALL",
        "EXEC"
    ]

    for palabra in prohibidas:
        if palabra in sql_upper:
            return jsonify({
                "ok": False,
                "mensaje": f"La instrucción '{palabra}' no está permitida."
            })
            
    try:

        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute("EXPLAIN " + sql)

        cur.close()
        conn.close()

        return jsonify({
            "ok": True,
            "mensaje": "SQL revisado correctamente."
        })

    except Exception as ex:

        mensaje = str(ex)

        if "ERROR:" in mensaje:
            mensaje = mensaje.split("ERROR:")[-1].strip()

        if "LINE " in mensaje:
            mensaje = mensaje.split("LINE ")[0].strip()

        # Traducciones amigables
        if "column" in mensaje and "does not exist" in mensaje:

            columna = mensaje.split('"')[1]
            mensaje = f'La columna "{columna}" no existe.'

        elif "relation" in mensaje and "does not exist" in mensaje:

            tabla = mensaje.split('"')[1]
            mensaje = f'La tabla o vista "{tabla}" no existe.'

        elif "syntax error" in mensaje:

            mensaje = "La consulta contiene un error de sintaxis."

        return jsonify({
            "ok": False,
            "mensaje": mensaje
        })
@sqlstudio_bp.route("/sqlstudio/ejecutar", methods=["POST"])
def ejecutar_sql():

    data = request.get_json()
    sql = data.get("sql", "").strip()

    conn = get_db_connection()
    cur = conn.cursor()

    try:

        inicio = time.perf_counter()

        cur.execute(sql)

        columnas = [desc[0] for desc in cur.description]
        filas = cur.fetchall()

        tiempo = round((time.perf_counter() - inicio) * 1000)

        resultado = {
            "ok": True,
            "columnas": columnas,
            "filas": filas,
            "registros": len(filas),
            "tiempo": tiempo
        }

        return jsonify(resultado)

    except Exception as ex:

        return jsonify({
            "ok": False,
            "mensaje": str(ex)
        })

    finally:

        cur.close()
        conn.close()
    