from flask import Flask, render_template, request, redirect, url_for, jsonify, session
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import Image
from datetime import datetime
 
from email.message import EmailMessage
import psycopg2
from flask import send_file
from io import BytesIO
from openpyxl import Workbook
from openpyxl.styles import Font
from collections import defaultdict
from openpyxl.styles import Font, Alignment, Border, Side
from openpyxl.drawing.image import Image as XLImage
from collections import defaultdict
from io import BytesIO
from flask import send_file
from datetime import datetime
from flask import session, redirect, url_for 
import threading
from dotenv import load_dotenv
import os
import json
from flask import make_response

import qrcode
from io import BytesIO
import base64

load_dotenv("llave.env")
try:
    import resend
    resend.api_key = os.getenv("RESEND_API_KEY")

    if not resend.api_key:
        print("❌ RESEND_API_KEY no definida")
        resend = None

except Exception as e:
    print("❌ Error importando resend:", str(e))
    resend = None

from openai import OpenAI
client = OpenAI()

app = Flask(__name__)
app.secret_key = "clave_secreta_super_segura"

from modules.sqlstudio import sqlstudio_bp
app.register_blueprint(sqlstudio_bp)

# Usuario de prueba
USUARIO_TEST = "admin"
PASSWORD_TEST = "1234"
EMAIL_REMITENTE = "pardoalf@gmail.com"
EMAIL_PASSWORD = "pxvr oyrf uhgb xugj"
 
@app.context_processor
def inject_version():
    return dict(version=get_version())

def get_version():
    try:
        with open("version.txt") as f:
            return f.read().strip()
    except:
        return "v1.0"
    
@app.route('/splash')
def splash():
    return render_template('splash.html')

@app.route('/')
def home():

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔹 individuales
    cur.execute("""
        SELECT id, nombre, precio, admins, profesores, alumnos, quizzes,orden
        FROM planes
        WHERE tipo = 'individual' AND activo = TRUE
        ORDER BY orden
    """)
    planes_individual = cur.fetchall()

    # 🔹 empresariales
    cur.execute("""
        SELECT id, nombre, precio, admins, profesores, alumnos, quizzes,orden
        FROM planes
        WHERE tipo = 'empresarial' AND activo = TRUE
        ORDER BY orden
    """)
    planes_empresarial = cur.fetchall()
    
    # ==========================
    # KPIs
    # ==========================

    cur.execute("SELECT COUNT(*) FROM quiz")
    total_quizzes = cur.fetchone()[0]

    cur.execute("SELECT COUNT(*) FROM respuestas_alumno")
    total_respuestas = cur.fetchone()[0]

    cur.execute("SELECT COUNT(*) FROM usuarios WHERE rol='profesor'")
    total_profesores = cur.fetchone()[0]

    cur.execute("SELECT COUNT(*) FROM alumnos")
    total_alumnos = cur.fetchone()[0]

    cur.execute("SELECT COUNT(*) FROM empresa")
    total_empresas = cur.fetchone()[0]

    cur.close()
    conn.close()

    return render_template(
        'index.html',
        planes_individual=planes_individual,
        planes_empresarial=planes_empresarial,
        total_quizzes=total_quizzes,
        total_respuestas=total_respuestas,
        total_profesores=total_profesores,
        total_alumnos=total_alumnos,
        total_empresas=total_empresas
    )

def es_admin():
    return session.get('rol') == 'admin'

def es_profesor():
    return session.get('rol') == 'profesor'

from werkzeug.security import check_password_hash

@app.route('/login', methods=['GET', 'POST'])
def login():

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT dempre FROM empresa ORDER BY dempre")
    empresas = cur.fetchall()

    if request.method == 'POST':

        usuario = request.form['usuario']
        password = request.form['password']

        cur.execute("""
            SELECT id, usuario, password, rol, cempre
            FROM usuarios
            WHERE usuario = %s
        """, (usuario,))

        user = cur.fetchone()

        if user:
            db_password = user[2]

            # 🔐 validar hash (si aún no usas hash, temporalmente deja ==)
            if db_password == password or check_password_hash(db_password, password):

                session['user_id'] = user[0]
                session['usuario'] = user[1]
                session['rol'] = user[3]
                session['cempre'] = user[4]

                cur.close(); conn.close()
                return redirect(url_for('splash'))

        cur.close(); conn.close()
        return render_template("login.html", empresas=empresas, error="Credenciales incorrectas")

    cur.close()
    conn.close()

    return render_template("login.html", empresas=empresas)

#def get_db_connection():
#    conn = psycopg2.connect(
#       dbname="BDTeacherAssesment",
#        user="postgres",
##        password="1234",   # ⚠️ usa algo simple temporalmente
#        host="127.0.0.1",
#        port="5432"
#   )
#   return conn

def require_admin():
    if 'user_id' not in session or session.get('rol') != 'admin':
        return False
    return True
 
def get_db_connection():
    database_url = os.getenv("DATABASE_URL")

    print("DATABASE_URL =", database_url)

    if database_url:
        print("👉 CONECTANDO A RENDER")
        return psycopg2.connect(database_url, sslmode='require')
    else:
        print("👉 CONECTANDO A LOCAL (SIN SSL)")
        return psycopg2.connect(
            dbname="BDTeacherAssesment",
            user="postgres",
            password="1234",
            host="127.0.0.1",
            port="5432",
            sslmode='disable'   # 👈 🔥 FORZAR SIN SSL
        )

@app.route('/init-db')
def init_db():

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔥 crear tabla planes
    cur.execute("""
    CREATE TABLE IF NOT EXISTS planes (
        id SERIAL PRIMARY KEY,
        nombre TEXT,
        precio INTEGER,
        admins INTEGER,
        profesores INTEGER,
        alumnos INTEGER,
        quizzes INTEGER,
        orden INTEGER
    );
    """)
    
    # 🔥 agregar columnas faltantes
    cur.execute("ALTER TABLE planes ADD COLUMN IF NOT EXISTS tipo TEXT;")
    cur.execute("ALTER TABLE planes ADD COLUMN IF NOT EXISTS activo BOOLEAN DEFAULT TRUE;")

    conn.commit()
    cur.close()
    conn.close()

    return "DB inicializada"

@app.route('/restore-db')
def restore_db():

    conn = get_db_connection()
    cur = conn.cursor()

    with open('backup.sql', 'r', encoding='utf-8') as f:
        sql = f.read()

    # 🔥 dividir en comandos simples
    statements = sql.split(';')

    for statement in statements:
        statement = statement.strip()
        if statement:
            try:
                cur.execute(statement)
            except Exception as e:
                print("Error en:", statement[:100], e)

    conn.commit()
    cur.close()
    conn.close()

    return "DB restaurada (parcial si hubo errores)"

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        usuario = request.form['usuario']
        password = request.form['password']
        rol = request.form['rol']

        conn = get_db_connection()
        cur = conn.cursor()

        try:
            cur.execute(
                "INSERT INTO usuarios (usuario, password, rol) VALUES (%s, %s, %s)",
                (usuario, password, rol)
            )
            conn.commit()
        except:
            return "El usuario ya existe ❌"

        conn.commit()
        cur.close()
        conn.close()

        return redirect('/login')

    return render_template('register.html')

@app.route('/dashboard_profesor')
def dashboard_profesor():
    
    if 'user_id' not in session:
            return redirect(url_for('login'))

    if session['rol'] == 'admin':
        # lógica admin
        pass
    
    conn = get_db_connection()
    cur = conn.cursor()

    if session['rol'] == 'admin':
        cur.execute("""
            SELECT 
                z.id,
                u.usuario,
                z.titulo, 
                COUNT(DISTINCT r.alumno_id) AS alumnos,
                (select count(distinct p.id)  
                    from preguntas p
                    where p.quiz_id=z.id) AS preguntas,
                z.codigo,
                z.publico,
                COALESCE(
                    (z.config_json::json->>'tiempo_minutos')::int,
                    0
                ) AS tiempo_minutos,
                z.multiple_intentos,
                z.enviar_solucionario
                FROM quiz z
                INNER JOIN usuarios u on u.id=z.usuario_id
                LEFT JOIN preguntas p ON p.quiz_id = z.id
                LEFT JOIN respuestas_alumno r ON r.pregunta_id = p.id
                WHERE z.estado = 'A'
                AND z.cempre= %s
                GROUP BY z.id,u.usuario, z.titulo, z.codigo, z.publico,z.multiple_intentos,z.enviar_solucionario
                ORDER BY z.id DESC
            """, (session['cempre'], ))
    else:
        cur.execute("""
            SELECT 
                z.id,
                z.titulo, 
                COUNT(DISTINCT r.alumno_id) AS alumnos,
                (select count(distinct p.id)  
                    from preguntas p
                    where p.quiz_id=z.id) AS preguntas,
                z.codigo,
                z.publico,
                COALESCE(
                    (z.config_json::json->>'tiempo_minutos')::int,
                    0
                ) AS tiempo_minutos,
                z.multiple_intentos,
                z.enviar_solucionario
                FROM quiz z
                LEFT JOIN preguntas p ON p.quiz_id = z.id
                LEFT JOIN respuestas_alumno r ON r.pregunta_id = p.id
                WHERE z.estado = 'A'
                AND z.cempre= %s
                AND z.usuario_id = %s
                GROUP BY z.id, z.titulo, z.codigo, z.publico,z.multiple_intentos,z.enviar_solucionario
                ORDER BY z.id DESC
            """, (session['cempre'], session['user_id']))
        
    quizzes = cur.fetchall()
    
    cur.execute("""
        SELECT id
        FROM cola_ia
        WHERE estado IN ('pendiente', 'procesando')
        ORDER BY id DESC
    """)

    cola = cur.fetchall()


    cur.close()
    conn.close()

    return render_template('dashboard_profesor.html', quizzes=quizzes,cola=cola)

@app.route('/profesores')
def profesores():

    if 'rol' not in session or session['rol'] != 'admin':
        return "Acceso no autorizado", 403

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT id, dni, nombre, apellido, usuario,password,correo,fecha_creacion
        FROM usuarios
        WHERE rol = 'profesor' AND cempre = %s
        ORDER BY nombre
    """, (session['cempre'],))

    profesores = cur.fetchall()

    cur.close()
    conn.close()

    return render_template('profesores.html', profesores=profesores)

@app.route('/reporte_alumno/<int:quiz_id>/<int:alumno_id>')
def reporte_alumno(quiz_id, alumno_id):

    intento = request.args.get('intento', 1)

    examen = obtener_examen_alumno(alumno_id, quiz_id, intento)
    fecha = datetime.now().strftime("%d/%m/%Y %H:%M")

    # 🔥 generar archivo usando tu función existente
    generar_y_enviar_reporte(
        examen["detalle"],
        examen["nota"],
        examen["correo"],
        examen["nombre"],
        alumno_id,
        examen["titulo"],
        examen["dni"],
        fecha,
        False  # ❌ no enviar correo
    )

    import os

    if os.name == "nt":
        ruta_pdf = f"reporte_{alumno_id}.pdf"
    else:
        ruta_pdf = f"/tmp/reporte_{alumno_id}.pdf"

    return send_file(
        ruta_pdf,
        as_attachment=True,
        download_name=f"{examen['nombre']}_reporte.pdf",
        mimetype='application/pdf'
    )
    
@app.route('/obtener_intentos/<int:alumno_id>/<int:quiz_id>')
def obtener_intentos(alumno_id, quiz_id):

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT q.id, q.titulo, iq.intento_numero
        FROM intentos_quiz iq
        JOIN quiz q ON q.id = iq.quiz_id
        WHERE iq.alumno_id = %s
          AND iq.quiz_id = %s
        ORDER BY iq.intento_numero
    """, (alumno_id, quiz_id))

    rows = cur.fetchall()

    cur.close()
    conn.close()

    data = [
        {
            "quiz_id": r[0],
            "quiz": r[1],
            "intento": r[2]
        }
        for r in rows
    ]

    return jsonify(data)

@app.route('/reporte_quiz/<int:quiz_id>')
def reporte_quiz(quiz_id):
    
    con_sol = request.args.get("solucion", "true").lower() == "true"

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔹 obtener preguntas y opciones
    cur.execute("""
        SELECT
            p.id,
            p.texto,
            p.tipo,
            p.explicacion,
            o.texto,
            o.es_correcta
        FROM preguntas p
        JOIN opciones o ON o.pregunta_id = p.id
        WHERE p.quiz_id = %s
        ORDER BY p.id, o.id
    """, (quiz_id,))
    

    data = cur.fetchall()
    
    cur.execute("""
        SELECT titulo
        FROM quiz
        WHERE id = %s
    """, (quiz_id,))

    titulo_quiz = cur.fetchone()[0]

    cur.close()
    conn.close()

    # 🚀 GENERAR PDF
    from io import BytesIO
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image
    from reportlab.lib.styles import getSampleStyleSheet
    from reportlab.lib import colors
    from reportlab.lib.pagesizes import letter
    from datetime import datetime

    buffer = BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter)
    styles = getSampleStyleSheet()
    elements = []

    # 🔹 HEADER
    logo = Image("static/img/logo.png", width=80, height=50)

    header = [[logo, Paragraph(f"""
    <b>ACAASO</b><br/>
    <b>Reporte:</b> Solucionario<br/>
    <b>Usuario:</b> {session.get('usuario')}<br/>
    <b>Fecha:</b> {datetime.now().strftime("%d/%m/%Y %H:%M")}
    """, styles['Normal'])]]

    tabla_header = Table(header, colWidths=[100, 350])
    tabla_header.setStyle(TableStyle([
        ('BOX', (0,0), (-1,-1), 1.5, colors.black),
        ('BACKGROUND', (0,0), (-1,-1), colors.whitesmoke),
    ]))

    elements.append(tabla_header)
    elements.append(Spacer(1, 15))

    elements.append(Paragraph("<b>SOLUCIONARIO</b>", styles['Title']))
    elements.append(Spacer(1, 10))

   # 🔹 AGRUPAR POR PREGUNTA
    preguntas = {}

    for p_id, p_texto, p_tipo, p_explicacion, o_texto, correcta in data:

        if p_id not in preguntas:
            preguntas[p_id] = {
                "texto": p_texto,
                "tipo": p_tipo,
                "explicacion": p_explicacion,
                "opciones": []
            }

        preguntas[p_id]["opciones"].append((o_texto, correcta))

   # 🔹 CONTENIDO
    for i, pregunta in enumerate(preguntas.values(), start=1):

        elements.append(
            Paragraph(f"{i}. {pregunta['texto']}", styles['Heading3'])
        )
        elements.append(Spacer(1, 5))

        tabla_data = []

        for op_texto, correcta in pregunta["opciones"]:
    
            if correcta and con_sol:
                texto = f"✔ {op_texto}"
            else:
                texto = op_texto

            tabla_data.append([Paragraph(texto, styles['Normal'])])

        tabla = Table(tabla_data)

        tabla.setStyle(TableStyle([
            ('GRID', (0,0), (-1,-1), 0.5, colors.grey),
            ('BOX', (0,0), (-1,-1), 1, colors.black),
        ]))

        elements.append(tabla)

        # 🔹 EXPLICACIÓN
        if con_sol and pregunta["explicacion"]:
            elements.append(Spacer(1, 4))
            elements.append(
            Paragraph(
                f"<b>Explicación:</b> {pregunta['explicacion']}",
                styles["Normal"]
            )
        )

        elements.append(Spacer(1, 10))

    doc.build(elements)
    buffer.seek(0)

    #return send_file(buffer, as_attachment=False,
    #            download_name="reporte.pdf",
    #            mimetype='application/pdf')
        
    return send_file(buffer,
    as_attachment=False,
    download_name=f"{titulo_quiz}.pdf",
    mimetype='application/pdf')

@app.route('/alumno')
def alumno():
    if 'usuario' in session:
        return f"Bienvenido alumno {session['usuario']} 🎓"
    return redirect('/login')

@app.route('/registrar_admin', methods=['POST'])
def registrar_admin():

    data = request.get_json()

    codigo = data.get("codigo")

    # 🔐 VALIDACIÓN (temporal)
    CODIGO_VALIDO = "VCX234"

    if codigo != CODIGO_VALIDO:
        return jsonify({
            "mensaje": "Código de verificación inválido"
        }), 400

    conn = get_db_connection()
    cur = conn.cursor()

    empresa_nombre = data.get("empresa")

    # 🔍 buscar empresa
    cur.execute("""
        SELECT cempre FROM empresa
        WHERE dempre = %s
    """, (empresa_nombre,))

    row = cur.fetchone()

    if row:
        cempre = row[0]
    else:
        # crear empresa
        cur.execute("""
            INSERT INTO empresa (dempre)
            VALUES (%s)
            RETURNING cempre
        """, (empresa_nombre,))
        
        cempre = cur.fetchone()[0]

    usuario = data.get("usuario")
    password = data.get("password")
    dni = data.get("dni")
    nombre = data.get("nombre")
    apellido = data.get("apellido")
    correo = data.get("correo")

    # 🔍 validar si ya existe usuario
    cur.execute("""
        SELECT id FROM usuarios
        WHERE usuario = %s
    """, (usuario,))

    if cur.fetchone():
        return jsonify({
            "mensaje": "El usuario ya existe"
        }), 400

    # 🔥 INSERT COMPLETO
    cur.execute("""
        INSERT INTO usuarios (
            usuario, password, rol, dni, nombre, apellido, correo, cempre
        )
            VALUES (%s, %s, 'admin', %s, %s, %s, %s, %s)
        """, (usuario, password, dni, nombre, apellido, correo, cempre))

    conn.commit()
    
    return jsonify({
        "mensaje": "Usuario administrador creado correctamente"
    })


@app.route('/admin')
def admin():
    if 'usuario' in session:
        return f"Panel admin {session['usuario']} ⚙️"
    return redirect('/login')

@app.route('/logout')
def logout():
    session.clear()
    return redirect('/')

# PASO 1: ingresar código
@app.route('/ingresar_codigo', methods=['GET', 'POST'])
def ingresar_codigo():
    if request.method == 'POST':
        codigo = request.form['codigo']

        # guardamos el código en sesión
        session['codigo_quiz'] = codigo
        session['modo'] = 'local'  # 🔥 AQUÍ

        return redirect('/ingresar_dni')

    return render_template('ingresar_codigo.html')


# PASO 2: ingresar DNI
@app.route('/ingresar_dni', methods=['GET', 'POST'])
def ingresar_dni():
    if request.method == 'POST':
        dni = request.form['dni']
         

        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute("SELECT id, nombre, apellido, correo FROM alumnos WHERE dni=%s  ", (dni, ))
        alumno = cur.fetchone()

        if alumno:
            alumno_id = alumno[0]
            correo_db = alumno[3]
            correo_form = request.form.get('correo')

            # 🔥 si no tiene correo → actualizar
            if not correo_db or not str(correo_db).strip():
    
                correo_form = request.form.get('correo')

                print("📩 correo recibido:", correo_form)

                if not correo_form or not correo_form.strip():
                    return render_template(
                        "ingresar_dni.html",
                        dni=dni,
                        mostrar_campos=True,
                        error="Debes ingresar tu correo"
                    )

                cur.execute(
                    "UPDATE alumnos SET correo=%s WHERE dni=%s",
                    (correo_form.strip(), dni)
                )
                conn.commit()
        else:
            cur.close()
            conn.close()
            return redirect(f"/registro_alumno?dni={dni}")

        # 🔥 obtener quiz
        codigo = session.get('codigo_quiz', '').strip().upper()

        # 🔍 primero buscar en salon_quiz
        cur.execute("""
            SELECT id, quiz_id
            FROM salon_quiz
            WHERE UPPER(TRIM(codigo)) = %s
        """, (codigo,))

        row = cur.fetchone()

        if row:
            salon_quiz_id = row[0]
            quiz_id = row[1]

            cur.close()
            conn.close()

            return redirect(url_for(
                'resolver_quiz_salon',
                salon_quiz_id=salon_quiz_id,
                alumno_id=alumno_id
            ))

        # 🔍 si no está en salon, usar lógica original
        cur.execute("SELECT id FROM quiz WHERE codigo=%s", (codigo,))
        quiz = cur.fetchone()

        if quiz:
            quiz_id = quiz[0]
            
            cur.execute("""
                SELECT multiple_intentos
                FROM quiz
                WHERE id = %s
            """, (quiz_id,))

            multiple_intentos = cur.fetchone()[0]
            
            if not multiple_intentos:
    
                cur.execute("""
                    SELECT COUNT(*)
                    FROM intentos_quiz
                    WHERE alumno_id = %s
                    AND quiz_id = %s
                    AND nota_final IS NOT NULL
                """, (alumno_id, quiz_id))

                ya_rindio = cur.fetchone()[0] > 0

                if ya_rindio:
    
                    cur.execute("""
                        SELECT
                            nota_final,
                            fecha_fin,
                            tiempo_total_segundos
                        FROM intentos_quiz
                        WHERE alumno_id = %s
                        AND quiz_id = %s
                        AND nota_final IS NOT NULL
                        ORDER BY intento_numero DESC
                        LIMIT 1
                    """, (alumno_id, quiz_id))

                    ultimo = cur.fetchone()

                    nota = ultimo[0] if ultimo else 0
                    fecha = ultimo[1].strftime("%d/%m/%Y %H:%M") if ultimo and ultimo[1] else "-"

                    if ultimo and ultimo[2]:
                        minutos = ultimo[2] // 60
                        segundos = ultimo[2] % 60
                        tiempo = f"{minutos:02}:{segundos:02}"
                    else:
                        tiempo = "--:--"

                    cur.execute("""
                        SELECT nombre, apellido
                        FROM alumnos
                        WHERE id = %s
                    """, (alumno_id,))

                    alumno = cur.fetchone()
                    nombre = f"{alumno[0]} {alumno[1]}" if alumno else "Alumno"

                    cur.close()
                    conn.close()

                    return render_template(
                        "quiz_bloqueado.html",
                        alumno=nombre,
                        nota=nota,
                        fecha=fecha,
                        tiempo=tiempo
                    )

            cur.close()
            conn.close()

            return redirect(url_for(
                'resolver_quiz',
                quiz_id=quiz_id,
                alumno_id=alumno_id
            ))
            
            

        # ❌ código inválido
        cur.close()
        conn.close()
        return "Código inválido", 404 

    return render_template('ingresar_dni.html')

@app.route('/resolver_quiz_salon/<int:salon_quiz_id>/<int:alumno_id>')
def resolver_quiz_salon(salon_quiz_id, alumno_id):
   

    conn = get_db_connection()
    cur = conn.cursor()
    
    # 🔍 obtener quiz_id (robusto)
    quiz_id = None

    if salon_quiz_id:
        cur.execute("""
            SELECT quiz_id
            FROM salon_quiz
            WHERE id = %s
        """, (salon_quiz_id,))
        
        row = cur.fetchone()
        
        if row:
            quiz_id = row[0]

    # 🔥 fallback (por si no viene de salón)
    if not quiz_id:
        quiz_id = request.args.get("quiz_id")

    # 🔥 última defensa
    if not quiz_id:
        return "No se pudo determinar el quiz", 400

    cur.execute("""
        SELECT COALESCE(MAX(intento_numero), 0)
        FROM intentos_quiz
        WHERE alumno_id = %s AND quiz_id = %s
    """, (alumno_id, quiz_id))

    ultimo = cur.fetchone()[0]
    nuevo_intento = ultimo + 1

    cur.execute("""
        INSERT INTO intentos_quiz (
            alumno_id,
            quiz_id,
            intento_numero,
            fecha_inicio
        )
        VALUES (
            %s,
            %s,
            %s,
            NOW()
        )
        RETURNING id
    """, (alumno_id, quiz_id, nuevo_intento))

    intento_id = cur.fetchone()[0]

    print("INTENTO CREADO:", intento_id)

    conn.commit()

    # 👇 AGREGA ESTO AQUÍ
    cur.execute("""
        SELECT id
        FROM intentos_quiz
        WHERE id = %s
    """, (intento_id,))

    print("VERIFICACION:", cur.fetchone())

    # luego continúa con:
    # obtener preguntas
    cur.execute("""
        SELECT id, texto, tipo, explicacion
        FROM preguntas
        WHERE quiz_id = %s
    """, (quiz_id,))

    row = cur.fetchone()

    if not row:
        return "Error", 404

    quiz_id = row[0]

    # 🔍 obtener preguntas (igual que resolver_quiz)
    cur.execute("""
        SELECT id, texto, tipo, explicacion
        FROM preguntas
        WHERE quiz_id = %s
    """, (quiz_id,))

    preguntas = cur.fetchall()

    data = []

    for p in preguntas:
        cur.execute("""
            SELECT id, texto
            FROM opciones
            WHERE pregunta_id = %s
        """, (p[0],))

        opciones_db = cur.fetchall()

        opciones = []
        for op in opciones_db:
            opciones.append({
                "id": op[0],
                "texto": op[1]
            })

        data.append({
            'id': p[0],
            'texto': p[1],
            'tipo': p[2],
            'explicacion': p[3],
            'opciones': opciones
        })

    cur.close()
    conn.close()
    
    print("DATA DEBUG:", data)

    return render_template(
        'resolver_quiz.html',
        preguntas=data,
        quiz_id=quiz_id,
        alumno_id=alumno_id,
        salon_quiz_id=salon_quiz_id , # 🔥 clave
        intento_id=intento_id
    )
 

@app.route('/obtener_asignaciones/<int:salon_id>')
def obtener_asignaciones(salon_id):

    if 'user_id' not in session:
        return jsonify({"error": "No autenticado"}), 401

    conn = get_db_connection()
    cur = conn.cursor()

    if session["rol"] == "admin":

        cur.execute("""
            SELECT
                sq.id,
                q.titulo,
                q.codigo
            FROM salon_quiz sq
            JOIN quiz q ON q.id = sq.quiz_id
            WHERE sq.salon_id = %s
              AND q.cempre = %s
            ORDER BY sq.id DESC
        """, (
            salon_id,
            session["cempre"]
        ))

    else:   # profesor

        cur.execute("""
            SELECT
                sq.id,
                q.titulo,
                q.codigo
            FROM salon_quiz sq
            JOIN quiz q ON q.id = sq.quiz_id
            WHERE sq.salon_id = %s
              AND q.usuario_id = %s
            ORDER BY sq.id DESC
        """, (
            salon_id,
            session["user_id"]
        ))

    data = cur.fetchall()

    cur.close()
    conn.close()

    resultado = [
        {
            "id": r[0],
            "titulo": r[1],
            "codigo": r[2]
        }
        for r in data
    ]

    return jsonify(resultado)

@app.route('/completar_correo', methods=['GET', 'POST'])
def completar_correo():
    dni = request.args.get('dni')

    if request.method == 'POST':
        correo = request.form['correo']

        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute(
            "UPDATE alumnos SET correo=%s WHERE dni=%s",
            (correo, dni)
        )

        # 🔥 ahora buscamos alumno y redirigimos
        cur.execute("SELECT id FROM alumnos WHERE dni=%s", (dni,))
        alumno = cur.fetchone()

        codigo = session.get('codigo_quiz')

        cur.execute("SELECT id FROM quiz WHERE codigo=%s", (codigo,))
        quiz = cur.fetchone()

        conn.commit()
        cur.close()
        conn.close()

        return redirect(url_for(
            'resolver_quiz',
            quiz_id=quiz[0],
            alumno_id=alumno[0]
        ))

    return render_template('completar_correo.html', dni=dni)

@app.route('/registro_alumno', methods=['GET', 'POST'])
def registro_alumno():
    dni = request.args.get('dni')  # viene desde la URL

    if request.method == 'POST':
        nombre = request.form['nombre']
        apellido = request.form['apellido']
        correo = request.form['correo']

        conn = get_db_connection()
        cur = conn.cursor()

        # 🔥 INSERT y obtener ID
        cur.execute("""
            INSERT INTO alumnos (dni, nombre, apellido, correo)
            VALUES (%s, %s, %s, %s)
            RETURNING id
        """, (dni, nombre, apellido, correo))

        alumno_id = cur.fetchone()[0]

        conn.commit()

        codigo = session.get('codigo_quiz')

        # 🔍 buscar en salon_quiz
        cur.execute("""
            SELECT id, quiz_id
            FROM salon_quiz
            WHERE codigo = %s
        """, (codigo,))

        row = cur.fetchone()

        if row:
            salon_quiz_id = row[0]

            cur.close()
            conn.close()

            return redirect(url_for(
                'resolver_quiz_salon',
                salon_quiz_id=salon_quiz_id,
                alumno_id=alumno_id
            ))

        # 🔍 fallback quiz normal
        cur.execute("SELECT id FROM quiz WHERE codigo=%s", (codigo,))
        quiz = cur.fetchone()

        if quiz:
            quiz_id = quiz[0]

            cur.close()
            conn.close()

            return redirect(url_for(
                'resolver_quiz',
                quiz_id=quiz_id,
                alumno_id=alumno_id
            ))

        cur.close()
        conn.close()

    return render_template('registro_alumno.html', dni=dni)

@app.route('/quiz')
def quiz():

    codigo = session.get('codigo_quiz')

    if not codigo:
        return "No hay código en sesión"

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔥 obtener quiz_id desde código
    cur.execute("SELECT id FROM quiz WHERE codigo=%s", (codigo,))
    quiz = cur.fetchone()

    if not quiz:
        return "Código inválido"

    quiz_id = quiz[0]

    # 🔥 ahora sí traer preguntas correctas
    cur.execute("""
        SELECT id, texto, tipo, explicacion
        FROM preguntas
        WHERE quiz_id = %s
    """, (quiz_id,))
    preguntas = cur.fetchall()

    data = []

    for p in preguntas:
        cur.execute("SELECT id, texto FROM opciones WHERE pregunta_id=%s", (p[0],))
        opciones_db = cur.fetchall()

        opciones = []
        for op in opciones_db:
            opciones.append({
                "id": op[0],
                "texto": op[1]
            })

        data.append({
            'id': p[0],
            'texto': p[1],
            'tipo': p[2],
            'explicacion': p[3],
            'opciones': opciones
        })

    cur.close()
    conn.close()

    return render_template('quiz.html', preguntas=data)

    
@app.route('/crear_quiz', methods=['GET', 'POST'])
def crear_quiz():
    if request.method == 'POST':
        titulo = request.form['titulo']
        config_json = request.form.get("config_json") or "{}"
        print("CONFIG JSON RECIBIDO:", config_json)
        usuario = session.get('usuario')
        multiple_intentos = request.form.get('multiple_intentos') in ['true', 'on', '1']
        enviar_solucionario = request.form.get("enviar_solucionario") in ['true', 'on', '1']
        publico = not (request.form.get("privado") in ['true', 'on', '1'])
        
        
        if not usuario:
            return redirect('/login')

        conn = get_db_connection()
        cur = conn.cursor()

        # crear quiz
        cur.execute(
            "INSERT INTO quiz (titulo,cempre,usuario_id, usuario, estado, multiple_intentos,enviar_solucionario,publico, config_json) VALUES (%s,%s,%s, %s, %s, %s, %s, %s) RETURNING id",
            (titulo,session['cempre'],session['user_id'], usuario, 'A', multiple_intentos,enviar_solucionario,publico, config_json)
        )
        quiz_id = cur.fetchone()[0]
        
        # recorrer preguntas
        orden = 1
        for key, texto in request.form.items():
            if key.startswith("pregunta_"):

                if not texto.strip():
                    continue

                num = key.split("_")[1]
                tipo = request.form.get(f"tipo_{num}")

                cur.execute(
                "INSERT INTO preguntas (quiz_id, texto, tipo, norden) VALUES (%s, %s, %s, %s) RETURNING id",
                (quiz_id, texto, tipo, orden)
                )
                orden += 1
                pregunta_id = cur.fetchone()[0]

                if tipo == "vf":
                    correcta = request.form.get(f"correcta_{num}")
                    explicacion = request.form.get(f"explicacion_{num}")

                    cur.execute(
                        "INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES (%s, %s, %s)",
                        (pregunta_id, "Verdadero", correcta == "Verdadero")
                    )

                    cur.execute(
                        "INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES (%s, %s, %s)",
                        (pregunta_id, "Falso", correcta == "Falso")
                    )

                    cur.execute(
                        "UPDATE preguntas SET explicacion=%s WHERE id=%s",
                        (explicacion, pregunta_id)
                    )

                else:
                    correcta = request.form.get(f"correcta_{num}")
                    print("CORRECTA RECIBIDA:", correcta)
                    explicacion = request.form.get(f"explicacion_{num}")
                    print("EXPLICACION RECIBIDA:", explicacion)
                    for i in range(1, 6):
                        opcion = request.form.get(f"opcion_{num}_{i}")
                        if opcion:
                            es_correcta = str(i) == correcta

                            cur.execute(
                                "INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES (%s, %s, %s)",
                                (pregunta_id, opcion, es_correcta)
                            )
                    # 🔥 FALTABA ESTO
                    cur.execute(
                        "UPDATE preguntas SET explicacion=%s WHERE id=%s",
                        (explicacion, pregunta_id)
                    )
                            

        conn.commit()
        cur.close()
        conn.close()

        return redirect('/dashboard_profesor')

    return render_template('crear_quiz.html')


@app.route('/generar_quiz_ia', methods=['POST'])
def generar_quiz_ia():
    data = request.get_json()
    print("JSON RECIBIDO:", data)
    prompt_usuario = data.get('prompt')
    cantidad = data.get('cantidad')
    tipo = data.get('tipo')
    titulo = data.get("titulo")
    config_json = data.get("config_json", "{}")
    origen = data.get('origen', 'prompt')
    contenido_extra = data.get('contenido_extra')  # aquí irá texto del archivo o quiz
    
    # 🔥 NUEVO — leer configuración m
    multiple_intentos = str(data.get("multiple_intentos")).lower() in ["true", "1", "on"] 
    enviar_solucionario = str(data.get("enviar_solucionario")).lower() in ["true", "1", "on"] 
    publico = str(data.get("publico")).lower() in ["true", "1", "on"]

    if origen == "prompt":
        base = prompt_usuario

    elif origen == "archivo":
        base = f"Basado EXCLUSIVAMENTE en el siguiente texto:\n{contenido_extra}"

    elif origen == "quiz_previo":
        base = f"Convierte el siguiente contenido en un quiz estructurado con respuestas:\n{contenido_extra}"

    else:
        base = prompt_usuario

    prompt = f"""
    {base} 
    
    Genera un quiz con estas condiciones:
    - Cantidad total de preguntas: {cantidad}
    - Tipo de preguntas: {tipo}

    Devuelve SOLO JSON válido en este formato:
    [
      {{
        "tipo": "vf",
        "texto": "...",
        "correcta": "Verdadero" ,
        "explicacion": "..."
      }},
      {{
        "tipo": "multiple",
        "texto": "...",
        "opciones": [
            "opcion 1",
            "opcion 2",
            "opcion 3",
            "opcion 4",
            "opcion 5"
        ],
        "correcta": "A",
        "explicacion": "..."
      }}
    ]
    
    - Siempre generar exactamente 5 opciones.
    - El contenido de las opciones debe ser texto real, NO letras.
    - El campo "correcta" debe contener ÚNICAMENTE una letra: A, B, C, D o E.
    - Nunca devolver el texto de la respuesta en el campo "correcta".
    - Nunca devolver dos respuestas correctas.

    Genera EXACTAMENTE lo que el usuario pide .
    la explicacion es un breve refuerzo de por que la opcion elegida en (opcion) o en (VF) es la correcta
    No expliques nada mas. Solo JSON puro.
     
    """

    conn = get_db_connection()
    cur = conn.cursor()

    usuario_id = session.get("user_id")
    usuario = session.get("usuario")
    cempre = session.get("cempre")

    cur.execute(""" 
        INSERT INTO cola_ia ( prompt, cantidad, tipo, estado, usuario_id, 
                            usuario, cempre, multiple_intentos, enviar_solucionario, publico,
                            titulo, origen, contenido_extra,config_json ) 
        VALUES (%s, %s, %s, 'pendiente', %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) 
        RETURNING id 
    """, ( 
        prompt, cantidad, tipo, usuario_id, usuario, 
        cempre, multiple_intentos, enviar_solucionario, publico,
        titulo, origen, contenido_extra,config_json
    ))
    cola_id = cur.fetchone()[0]

    conn.commit()
    cur.close()
    conn.close()

    return jsonify({
        "status": "encolado",
        "cola_id": cola_id
    })

@app.route('/procesar_examen', methods=['POST'])
def procesar_examen():

    archivo = request.files.get('archivo')  
    
    titulo = request.form.get("titulo")

    multiple_intentos = str(request.form.get("multiple_intentos")).lower() in ["true", "1", "on"]
    enviar_solucionario = str(request.form.get("enviar_solucionario")).lower() in ["true", "1", "on"]
    publico = str(request.form.get("publico")).lower() in ["true", "1", "on"]

    if not archivo:
        return jsonify({"error": "No se envió archivo"}), 400

    # 🔥 LEER COMO TEXTO (IMPORTANTE)
    try:
        contenido = archivo.read().decode("utf-8")
    except:
        contenido = archivo.read().decode("latin-1")

    prompt = f"""
    Convierte este examen en preguntas tipo quiz:

    {contenido}

    Devuelve SOLO JSON en este formato:
    [
      {{
        "tipo": "vf",
        "texto": "...",
        "correcta": "Verdadero",
        "explicacion": ""
      }},
      {{
        "tipo": "multiple",
        "texto": "...",
        "opciones": ["A","B","C","D","E"],
        "correcta": "A"
      }}
    ]

    No expliques nada. Solo JSON válido.
    No olvidar cada respuesta debe estar precedida con las letras A - E (opcion multiple)
    """
    conn = get_db_connection()
    cur = conn.cursor()

    usuario_id = session.get("user_id")
    usuario = session.get("usuario")
    cempre = session.get("cempre")

    cur.execute("""
        INSERT INTO cola_ia (
            prompt,
            contenido_extra,
            origen,
            estado,
            usuario_id,
            usuario,
            cempre,
            multiple_intentos,
            enviar_solucionario,
            publico,
            titulo
        )
        VALUES (
            %s, %s, %s, 'pendiente',
            %s, %s, %s, %s,
            %s, %s, %s
        )
        RETURNING id
    """, (
        prompt,
        contenido,
        "importar",
        usuario_id,
        usuario,
        cempre,
        multiple_intentos,
        enviar_solucionario,
        publico,
        titulo
    ))

    cola_id = cur.fetchone()[0]

    conn.commit()
    cur.close()
    conn.close()

    return jsonify({
        "status": "encolado",
        "cola_id": cola_id
    })
    

     

@app.route('/generar_quiz_desde_archivo', methods=['POST'])
def generar_quiz_desde_archivo():

    archivo = request.files.get('archivo')
    cantidad = request.form.get('cantidad')
    tipo = request.form.get('tipo')

    if not archivo:
        return jsonify({"error": "No se envió archivo"}), 400

    try:
        contenido = archivo.read().decode("utf-8")
    except:
        contenido = archivo.read().decode("latin-1")

    prompt = f"""
    Basado en el siguiente contenido:

    {contenido}

    Genera un quiz con estas condiciones:
    - Cantidad total: {cantidad}
    - Tipo: {tipo}

    REGLAS OBLIGATORIAS:

    1. Si tipo = "vf":
    - TODAS las preguntas deben ser Verdadero/Falso
    - Alternar respuestas: Verdadero, Falso, Verdadero, Falso...

    2. Si tipo = "multiple":
    - TODAS deben ser opción múltiple (5 opciones, A-E)
    - La respuesta correctas deben ROTAR así:
        A, B, C, D, E, A, B, C...

    3. Si tipo = "mixto":
    - Mezclar VF y múltiple
    - Mantener reglas anteriores en cada tipo

    4. Las respuestas NO deben ser todas iguales
    5. No repetir patrones obvios
    6. Generar preguntas coherentes con el contenido
    7. Las opciones deben ser textos reales (ej: "Egipto", "Roma", etc.)
   NO usar letras como contenido de opciones
   Las letras A–E son solo referenciales para la respuesta correcta

    FORMATO (SOLO JSON):
    [
    {{
        "tipo": "vf",
        "texto": "...",
        "correcta": "Verdadero",
        "explicacion": "..."
    }},
    {{
        "tipo": "multiple",
        "texto": "...",
        "opciones": ["opcion 1", "opcion 2", "opcion 3", "opcion 4", "opcion 5"]
        "correcta": "A",
        "explicacion": "..."
    }}
    ]
    La explicacion es una reseña breve de por que esa opcion es verdader o correcta
    No expliques nada. Solo JSON válido.
    """
    conn = get_db_connection()
    cur = conn.cursor()

    usuario_id = session.get("user_id")
    usuario = session.get("usuario")
    cempre = session.get("cempre")

    # puedes ajustar defaults si quieres
    multiple_intentos = str(request.form.get("multiple_intentos")).lower() in ["true", "1", "on"]
    enviar_solucionario = str(request.form.get("enviar_solucionario")).lower() in ["true", "1", "on"]
    publico = str(request.form.get("publico")).lower() in ["true", "1", "on"]
    titulo = request.form.get("titulo") or "Quiz desde archivo"

    cur.execute(""" 
        INSERT INTO cola_ia (
            prompt, cantidad, tipo, estado, usuario_id, 
            usuario, cempre, multiple_intentos, enviar_solucionario, publico,
            titulo, origen, contenido_extra
        ) 
        VALUES (%s, %s, %s, 'pendiente', %s, %s, %s, %s, %s, %s, %s, %s, %s) 
        RETURNING id 
    """, ( 
        prompt, cantidad, tipo, usuario_id, usuario, 
        cempre, multiple_intentos, enviar_solucionario,publico, 
        titulo, "archivo", contenido
    ))

    cola_id = cur.fetchone()[0]

    conn.commit()
    cur.close()
    conn.close()

    return jsonify({
        "status": "encolado",
        "cola_id": cola_id
    })

@app.route('/editar_quiz/<int:quiz_id>', methods=['GET', 'POST'])
def editar_quiz(quiz_id):

    conn = get_db_connection()
    cur = conn.cursor()

    if request.method == 'POST':

        titulo = request.form['titulo']
        multiple_intentos = request.form.get("multiple_intentos") == "on"
        enviar_solucionario = bool(request.form.get("enviar_solucionario"))
        publico = not (request.form.get("privado") == "on")
        config_json = request.form.get("config_json")
        
        # actualizar título
        cur.execute(
            """
            UPDATE quiz
            SET titulo=%s,
                multiple_intentos=%s,
                enviar_solucionario=%s,
                publico=%s,
                config_json=%s
            WHERE id=%s
            """,
            (
                titulo,
                multiple_intentos,
                enviar_solucionario,
                publico,
                config_json,
                quiz_id
            )
        )

        # 🔥 borrar todo
#       cur.execute("DELETE FROM opciones WHERE pregunta_id IN (SELECT id FROM preguntas WHERE quiz_id=%s)", (quiz_id,))
#        cur.execute("DELETE FROM preguntas WHERE quiz_id=%s", (quiz_id,))

        # 🔥 volver a insertar (igual que crear_quiz)
        print(request.form)   # ← ponlo aquí temporalmente
        
        for key, texto in request.form.items():
            if key.startswith("pregunta_") and not key.startswith("pregunta_id_"):

                if not texto.strip():
                    continue

                num = key.split("_")[1]
                tipo = request.form.get(f"tipo_{num}")
                
                pregunta_id = request.form.get(f"pregunta_id_{num}")

                if pregunta_id:

                    cur.execute("""
                        UPDATE preguntas
                        SET texto=%s,
                            tipo=%s,
                            explicacion=%s
                        WHERE id=%s
                    """, (
                        texto,
                        tipo,
                        request.form.get(f"explicacion_{num}"),
                        pregunta_id
                    ))

                else:

                    cur.execute("""
                        INSERT INTO preguntas (quiz_id, texto, tipo, explicacion)
                        VALUES (%s, %s, %s, %s)
                        RETURNING id
                    """, (
                        quiz_id,
                        texto,
                        tipo,
                        request.form.get(f"explicacion_{num}")
                    ))

                    pregunta_id = cur.fetchone()[0]

                if tipo == "vf":
                    correcta = request.form.get(f"correcta_{num}")
                    explicacion = request.form.get(f"explicacion_{num}")
                    
                    opcion_id_v = request.form.get(f"opcion_id_{num}_verdadero")
                    opcion_id_f = request.form.get(f"opcion_id_{num}_falso")

                    if opcion_id_v:
    
                        cur.execute("""
                            UPDATE opciones
                            SET texto=%s,
                                es_correcta=%s
                            WHERE id=%s
                        """, (
                            "Verdadero",
                            correcta == "Verdadero",
                            opcion_id_v
                        ))

                    else:

                        cur.execute("""
                            INSERT INTO opciones (pregunta_id, texto, es_correcta)
                            VALUES (%s, %s, %s)
                        """, (
                            pregunta_id,
                            "Verdadero",
                            correcta == "Verdadero"
                        ))

                    if opcion_id_f:
    
                        cur.execute("""
                            UPDATE opciones
                            SET texto=%s,
                                es_correcta=%s
                            WHERE id=%s
                        """, (
                            "Falso",
                            correcta == "Falso",
                            opcion_id_f
                        ))

                    else:

                        cur.execute("""
                            INSERT INTO opciones (pregunta_id, texto, es_correcta)
                            VALUES (%s, %s, %s)
                        """, (
                            pregunta_id,
                            "Falso",
                            correcta == "Falso"
                        ))

                    cur.execute(
                        "UPDATE preguntas SET explicacion=%s WHERE id=%s",
                        (explicacion, pregunta_id)
                    )

                else:
                    correcta = request.form.get(f"correcta_{num}")

                    for i in range(1, 6):
                        
                        opcion_id = request.form.get(f"opcion_id_{num}_{i}")
                        
                        opcion = request.form.get(f"opcion_{num}_{i}")
                        if opcion:
                            es_correcta = (opcion == correcta) or (str(i) == correcta)

                            if opcion_id:
    
                                cur.execute("""
                                    UPDATE opciones
                                    SET texto=%s,
                                        es_correcta=%s
                                    WHERE id=%s
                                """, (
                                    opcion,
                                    es_correcta,
                                    opcion_id
                                ))

                            else:

                                cur.execute("""
                                    INSERT INTO opciones (pregunta_id, texto, es_correcta)
                                    VALUES (%s, %s, %s)
                                """, (
                                    pregunta_id,
                                    opcion,
                                    es_correcta
                                ))

        conn.commit()
        cur.close()
        conn.close()

        return redirect(url_for('dashboard_profesor'))

    # 🔹 GET (lo que ya tenías)
    cur.execute("""
        SELECT titulo,
        multiple_intentos,
        enviar_solucionario,
        publico,
        config_json
    FROM quiz
    WHERE id=%s
    """, (quiz_id,))

    row = cur.fetchone()

    quiz = {
        "titulo": row[0],
        "multiple_intentos": row[1],
        "enviar_solucionario": row[2],
        "publico": row[3],
        "config_json": json.loads(row[4]) if row[4] else {}
    }

    cur.execute("""
        SELECT id, texto, tipo,explicacion
        FROM preguntas
        WHERE quiz_id=%s
    """, (quiz_id,))
    preguntas = cur.fetchall()

    data = []

    for p in preguntas:
        cur.execute("""
            SELECT id, texto, es_correcta
            FROM opciones
            WHERE pregunta_id=%s
            ORDER BY id
        """, (p[0],))

        opciones = cur.fetchall()

        data.append({
            'id': p[0],
            'texto': p[1],
            'tipo': p[2],
            'explicacion': p[3],
            'opciones': opciones
        })

    cur.close()
    conn.close()

    return render_template('editar_quiz.html', quiz=quiz, preguntas=data)
    
import random
import string

def generar_codigo_unico(cur):
    while True:
        codigo = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
        
        cur.execute("SELECT 1 FROM quiz WHERE codigo=%s", (codigo,))
        existe = cur.fetchone()
        
        if not existe:
            return codigo


@app.route("/usuarios")
def usuarios():

    if "usuario" not in session:
        return redirect("/login")

    if session["rol"] != "root":
        return redirect("/")

    return render_template("usuarios.html")   

@app.route("/api/empresas")
def api_empresas():

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            cempre,
            dempre
        FROM empresa
        WHERE estado = true
        ORDER BY dempre
    """)

    filas = cur.fetchall()

    cur.close()
    conn.close()

    empresas = []

    for fila in filas:
        empresas.append({
            "id": fila[0],
            "nombre": fila[1]
        })

    return jsonify(empresas)

@app.route("/api/usuarios/guardar", methods=["POST"])
def api_guardar_usuario():

    datos = request.get_json()

    conn = get_db_connection()
    cur = conn.cursor()

    try:

        if not datos["id"]:

            cur.execute("""
                INSERT INTO usuarios
                (
                    usuario,
                    nombre,
                    apellido,
                    correo,
                    password,
                    rol,
                    cempre
                )
                VALUES (%s,%s,%s,%s,%s,%s,%s)
            """, (
                datos["usuario"],
                datos["nombre"],
                datos["apellido"],
                datos["correo"],
                datos["password"],
                datos["rol"],
                datos["cempre"]
            ))

        conn.commit()

        return jsonify({
            "ok": True
        })

    except Exception as e:

        conn.rollback()

        mensaje = "Ocurrió un error al guardar el usuario."

        if "usuarios_usuario_key" in str(e):
            mensaje = "El nombre de usuario ya existe."

        return jsonify({
            "ok": False,
            "mensaje": mensaje
        }), 400

    finally:

        cur.close()
        conn.close()
@app.route("/api/usuarios")
def api_usuarios():

    # if "usuario" not in session:
    #     return jsonify([])

    # if session["rol"] != "root":
    #     return jsonify([])
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            id,
            usuario,
            nombre,
            apellido,
            correo,
            rol,
            cempre
        FROM usuarios
        ORDER BY usuario
    """)

    filas = cur.fetchall()

    cur.close()
    conn.close()

    usuarios = []

    for fila in filas:
        usuarios.append({
            "id": fila[0],
            "usuario": fila[1],
            "nombre": fila[2],
            "apellido": fila[3],
            "correo": fila[4],
            "rol": fila[5],
            "cempre": fila[6]
        })

    return jsonify(usuarios)
        
@app.route('/generar_codigo_unico/<int:id>')
def generar_codigo(id):

    conn = get_db_connection()
    cur = conn.cursor()

    codigo = generar_codigo_unico(cur)

    cur.execute("UPDATE quiz SET codigo=%s WHERE id=%s", (codigo, id))
    conn.commit()

    cur.close()
    conn.close()

    # 🔥 devolver JSON (NO redirect)
    return jsonify({"codigo": codigo})

@app.route('/eliminar_asignacion/<int:id>', methods=['DELETE'])
def eliminar_asignacion(id):

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("DELETE FROM salon_quiz WHERE id = %s", (id,))

    conn.commit()
    cur.close()
    conn.close()

    return jsonify({"status": "ok"})


@app.route('/buscar_alumnos')
def buscar_alumnos():

    texto = request.args.get('q', '').strip()

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id,
               dni,
               nombre,
               apellido,
               correo
        FROM alumnos
        WHERE
            dni ILIKE %s
            OR nombre ILIKE %s
            OR apellido ILIKE %s
        ORDER BY apellido, nombre
        LIMIT 20
    """, (
        f"%{texto}%",
        f"%{texto}%",
        f"%{texto}%"
    ))

    return jsonify(cursor.fetchall())

@app.route('/buscar_alumnos_por_salon')
def buscar_alumnos_por_salon():

    texto = request.args.get('q')

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT DISTINCT a.id, a.dni, a.nombre, a.apellido, a.correo
        FROM salon s
        JOIN salon_quiz sq ON s.id = sq.salon_id
        JOIN respuestas_alumno ra ON sq.quiz_id = ra.quiz_id
        JOIN alumnos a ON a.id = ra.alumno_id
        WHERE s.descripcion ILIKE %s
    """, (f"%{texto}%",))

    return jsonify(cursor.fetchall())

@app.route('/buscar_salones')
def buscar_salones():

    q = request.args.get('q')

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, descripcion
        FROM salon
        WHERE descripcion ILIKE %s
        LIMIT 10
    """, (f"%{q}%",))

    return jsonify(cursor.fetchall())



@app.route('/enviar_quiz/<int:quiz_id>')
def vista_enviar_quiz(quiz_id):

    salon_id = request.args.get('salon_id')

    conn = get_db_connection()
    cursor = conn.cursor()

    # 🔹 quiz
    cursor.execute("""
        SELECT titulo, codigo
        FROM quiz
        WHERE id = %s
    """, (quiz_id,))
    quiz = cursor.fetchone()

    titulo_quiz, codigo_quiz = quiz

    # 🔥 lógica con o sin filtro
    if salon_id:

        cursor.execute("""
            SELECT DISTINCT a.id, a.nombre, a.apellido, a.dni, a.correo
            FROM alumnos a
            JOIN respuestas_alumno r ON r.alumno_id = a.id
            JOIN salon_quiz sq ON sq.quiz_id = r.quiz_id
            WHERE sq.salon_id = %s
              AND r.quiz_id = %s
            ORDER BY a.apellido, a.nombre
        """, (salon_id, quiz_id))

    else:
        # sin filtro → como ya lo tienes
        cursor.execute("""
            SELECT DISTINCT a.id, a.nombre, a.apellido, a.dni, a.correo
            FROM alumnos a
            JOIN respuestas_alumno r ON r.alumno_id = a.id
            WHERE r.quiz_id = %s
            ORDER BY a.apellido, a.nombre
        """, (quiz_id,))

    alumnos = cursor.fetchall()

    # 🔹 lista de salones (para combo)
    cursor.execute("""
        SELECT id, descripcion
        FROM salon
        ORDER BY descripcion
    """)
    salones = cursor.fetchall()

    return render_template(
        'enviar_quiz.html',
        alumnos=alumnos,
        quiz_id=quiz_id,
        titulo_quiz=titulo_quiz,
        codigo_quiz=codigo_quiz,
        salones=salones,
        salon_id_actual=salon_id
    )
    
@app.route('/buscar_alumnos_por_salon_id')
def alumnos_por_salon_id():

    salon_id = request.args.get('id')

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT DISTINCT a.id, a.dni, a.nombre, a.apellido, a.correo
        FROM salon_quiz sq
        INNER JOIN respuestas_alumno ra ON sq.quiz_id = ra.quiz_id
        INNER JOIN alumnos a ON a.id = ra.alumno_id
        WHERE sq.salon_id = %s
    """, (salon_id,))

    return jsonify(cursor.fetchall())
    
@app.route('/buscar_alumno/<dni>')
def buscar_alumno(dni):
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT nombre, apellido,correo FROM alumnos WHERE dni=%s", (dni,))
    alumno = cur.fetchone()

    cur.close()
    conn.close()

    if alumno:
        return {"existe": True, "nombre": alumno[0], "apellido": alumno[1], "correo": alumno[2]}
    else:
        return {"existe": False}

@app.route('/ingresar_quiz', methods=['GET', 'POST'])
def ingresar_quiz():
    if request.method == 'POST':
        codigo = request.form['codigo']
        dni = request.form['dni']

        conn = get_db_connection()
        cur = conn.cursor()

        # buscar quiz por código
        cur.execute("SELECT id FROM quiz WHERE codigo=%s", (codigo,))
        quiz = cur.fetchone()

        if not quiz:
            return "❌ Código inválido"

        quiz_id = quiz[0]

        # buscar alumno por dni
        cur.execute("SELECT id, nombre, apellido,correo FROM alumnos WHERE dni=%s", (dni,))
        alumno = cur.fetchone()

        if alumno:
            alumno_id = alumno[0]
            return redirect(url_for('resolver_quiz', quiz_id=quiz_id, alumno_id=alumno_id))
        else:
            return redirect(url_for('registro_alumno', codigo=codigo, dni=dni))

    return render_template('ingresar_quiz.html')

@app.route('/quiz/<codigo>', methods=['GET', 'POST'])
def acceso_quiz(codigo):

    conn = get_db_connection()
    cur = conn.cursor()
    session['modo'] = 'web'

    # buscar quiz
    cur.execute("SELECT id, titulo, multiple_intentos FROM quiz WHERE codigo=%s", (codigo,))
    quiz = cur.fetchone()    
    
    if not quiz:
        return "❌ Código inválido"

    quiz_id = quiz[0]
    titulo_quiz = quiz[1]
    multiple_intentos = quiz[2]

    if request.method == 'POST':
        dni = request.form['dni']
        nombre = request.form.get('nombre')
        apellido = request.form.get('apellido')
        correo = request.form.get('correo')

        # buscar alumno
        cur.execute("SELECT id, nombre, apellido,correo FROM alumnos WHERE dni=%s", (dni,))
        alumno = cur.fetchone()

        if alumno:
            alumno_id = alumno[0]
            correo_db = alumno[3]
            
            cur.execute("""
                SELECT COUNT(*) 
                FROM respuestas_alumno r
                INNER JOIN preguntas p ON p.id = r.pregunta_id
                WHERE r.alumno_id = %s AND p.quiz_id = %s
            """, (alumno_id, quiz_id))

            ya_respondio = cur.fetchone()[0] > 0
    
            if not multiple_intentos and ya_respondio:
                response = make_response(render_template("bloqueado.html", quiz_titulo=titulo_quiz))
                response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
                return response

            # 🔥 si no tiene correo → actualizar
            if not correo_db or not str(correo_db).strip():

                if not correo or not correo.strip():
                    return "❌ Debes ingresar tu correo"

                cur.execute(
                    "UPDATE alumnos SET correo=%s WHERE dni=%s",
                    (correo.strip(), dni)
                )
                conn.commit()
        else:
            if not nombre or not apellido or not correo:
                return "❌ Debes completar nombre, apellido y correo"

            cur.execute(
                "INSERT INTO alumnos (dni, nombre, apellido, correo) VALUES (%s, %s, %s, %s) RETURNING id",
                (dni, nombre, apellido, correo,)
            )
            alumno_id = cur.fetchone()[0]
            conn.commit()

        cur.close()
        conn.close()
        print("DEBUG alumno_id:", alumno_id)
        return redirect(url_for('resolver_quiz', quiz_id=quiz_id, alumno_id=alumno_id))

    return render_template('login_quiz.html', codigo=codigo)

@app.route('/iniciar_quiz', methods=['POST'])
def iniciar_quiz():

    data = request.get_json()

    quiz_id = data["quiz_id"]
    alumno_id = data["alumno_id"]

    conn = get_db_connection()
    cur = conn.cursor()

    # obtener siguiente intento
    cur.execute("""
        SELECT COALESCE(MAX(intento_numero),0)
        FROM intentos_quiz
        WHERE alumno_id=%s
          AND quiz_id=%s
    """, (alumno_id, quiz_id))

    ultimo = cur.fetchone()[0]
    nuevo_intento = ultimo + 1

    # crear intento
    cur.execute("""
        INSERT INTO intentos_quiz
            (alumno_id, quiz_id, intento_numero)
        VALUES
            (%s,%s,%s)
        RETURNING id
    """, (alumno_id, quiz_id, nuevo_intento))

    intento_id = cur.fetchone()[0]

    conn.commit()

    cur.close()
    conn.close()

    return jsonify({
        "status": "ok",
        "intento_id": intento_id
    })

@app.route('/resolver_quiz/<int:quiz_id>/<int:alumno_id>')
def resolver_quiz(quiz_id, alumno_id):
    
    salon_quiz_id = None
 

    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute("""
        select nombre||' '||apellido 
           from alumnos
           WHERE id=%s
        """, (alumno_id,))
    
    row = cur.fetchone()
    
    alumno_nombre=row[0] if row else "Alumno Prueba"
    
    cur.execute("""
        SELECT config_json, multiple_intentos,titulo
        FROM quiz
        WHERE id = %s
    """, (quiz_id,))

    row = cur.fetchone()

    config_json = json.loads(row[0]) if row and row[0] else {}
    multiple_intentos = row[1] if row else False
    titulo=row[2] if row else "Titulo del quiz"

    # obtener preguntas
    cur.execute("""
        SELECT id, texto, tipo,explicacion
        FROM preguntas
        WHERE quiz_id = %s
    """, (quiz_id,))
    preguntas = cur.fetchall()

    data = []

    for p in preguntas:
        cur.execute("""
            SELECT id, texto
            FROM opciones
            WHERE pregunta_id = %s
        """, (p[0],))

        opciones_raw = cur.fetchall()

        opciones = [
            {
                "id": op[0],       # 🔥 IMPORTANTE
                "texto": op[1]
            }
            for op in opciones_raw
        ]
        
        data.append({
            'id': p[0],
            'texto': p[1],
            'tipo': p[2],
            'explicacion': p[3],
            'opciones': opciones
        })

    cur.close()
    conn.close()
    
    print("quiz_id:", quiz_id)
    print("config_json:", config_json)
    print("tipo:", type(config_json))

    return render_template(
        'resolver_quiz.html',
        preguntas=data,
        quiz_id=quiz_id,
        alumno_id=alumno_id,
        salon_quiz_id=salon_quiz_id,
        config_json=config_json,
        multiple_intentos=multiple_intentos,
        titulo=titulo,
        alumno_nombre=alumno_nombre
    )
    
@app.route('/guardar_respuestas', methods=['POST'])
def guardar_respuestas():

    data = request.get_json()

    alumno_id = data['alumno_id']
    respuestas = data['respuestas']
    preguntas = data.get("preguntas", [])
    salon_quiz_id = data.get('salon_quiz_id')
    
    tiempo_por_pregunta = data.get("tiempo_por_pregunta", {})

    conn = get_db_connection()
    cur = conn.cursor()

    correctas = 0
    total = len(preguntas)
    detalle = []
     
    valor_por_pregunta = 20 / total if total > 0 else 0

    # 🔍 obtener quiz_id
    if salon_quiz_id:
        cur.execute("""
            SELECT quiz_id
            FROM salon_quiz
            WHERE id = %s
        """, (salon_quiz_id,))
        
        row = cur.fetchone()
        quiz_id = row[0] if row else None
    else:
        quiz_id = data.get("quiz_id")
        
    if not quiz_id:
        print("⚠️ reconstruyendo quiz_id desde preguntas")

        if preguntas:
    
            primera_pregunta = preguntas[0]

            cur.execute("""
                SELECT quiz_id
                FROM preguntas
                WHERE id = %s
            """, (int(primera_pregunta),))

            row = cur.fetchone()
            quiz_id = row[0] if row else None
        
    intento_id = data["intento_id"]
    print("INTENTO RECIBIDO:", intento_id)  

    # 🔥 fallback de seguridad (NO rompe nada)
    if preguntas:
    
        primera_pregunta = preguntas[0]

        cur.execute("""
            SELECT quiz_id
            FROM preguntas
            WHERE id = %s
        """, (int(primera_pregunta),))

        row = cur.fetchone()
        quiz_id = row[0] if row else None

    # 🔥 LOOP PRINCIPAL
    for pregunta_id, opcion_id in respuestas.items():

        cur.execute("SELECT texto FROM preguntas WHERE id = %s", (pregunta_id,))
        pregunta_texto = cur.fetchone()[0]

        cur.execute("""
            SELECT id, texto, es_correcta
            FROM opciones
            WHERE pregunta_id = %s
        """, (pregunta_id,))
        opciones = cur.fetchall()

        opciones_detalle = []
        puntaje = 0

        for op in opciones:
            marcada = (op[0] == int(opcion_id))

            if op[2] and marcada:
                puntaje = valor_por_pregunta

            opciones_detalle.append({
                "texto": op[1],
                "correcta": op[2],
                "marcada": marcada
            })

        detalle.append({
            "pregunta": pregunta_texto,
            "opciones": opciones_detalle,
            "puntaje": puntaje
        })

        cur.execute("""
            INSERT INTO respuestas_alumno
            (
                alumno_id,
                pregunta_id,
                opcion_id,
                salon_quiz_id,
                quiz_id,
                intento_id,
                tiempo_segundos
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            alumno_id,
            pregunta_id,
            opcion_id,
            salon_quiz_id,
            quiz_id,
            intento_id,
            tiempo_por_pregunta.get(str(pregunta_id), 0)
        ))
        if puntaje > 0:
            correctas += 1

    conn.commit()

    # 🔹 datos alumno
    cur.execute("""
        SELECT nombre, apellido, dni, correo
        FROM alumnos
        WHERE id = %s
    """, (alumno_id,))
    alumno = cur.fetchone()

    nombre_completo = f"{alumno[0]} {alumno[1]}"
    dni = alumno[2]
    correo = alumno[3]

    # 🔹 título quiz
    cur.execute("""
        SELECT titulo
        FROM quiz q
        JOIN salon_quiz sq ON sq.quiz_id = q.id
        WHERE sq.id = %s
    """, (salon_quiz_id,))
    quiz = cur.fetchone()

    titulo_quiz = quiz[0] if quiz else "Quiz"

    nota = round((correctas / total) * 20, 2)
    fecha_hora = datetime.now().strftime("%d/%m/%Y %H:%M")
    
    cur.execute("""
    UPDATE intentos_quiz
    SET
        nota_final = %s,
        fecha_fin = NOW(),
        tiempo_total_segundos = EXTRACT(EPOCH FROM (NOW() - fecha_inicio))::INTEGER
    WHERE id = %s
    """, (nota, intento_id))
    
    conn.commit()   # ← AGREGAR ESTA LÍNEA
    
    cur.execute("""
        SELECT enviar_solucionario
        FROM quiz
        WHERE id = %s
    """, (quiz_id,))
    
    print("DEBUG quiz_id:", quiz_id)
    

    row = cur.fetchone()
    valor = row[0] if row else False

    enviar_solucionario = True if valor in [True, 't', 'true', '1', 1] else False
    
    print("DEBUG enviar_solucionario:", enviar_solucionario)

    cur.close()
    conn.close()
    
    print("DEBUG RAW DB:", valor)
    print("DEBUG NORMALIZADO:", enviar_solucionario)

    # 🚀 BACKGROUND TASK
    threading.Thread(
        target=generar_y_enviar_reporte,
        args=(detalle, nota, correo, nombre_completo, alumno_id, titulo_quiz, dni, fecha_hora, enviar_solucionario)
    ).start()

    # ⚡ RESPUESTA RÁPIDA
    return jsonify({
        "status": "ok",
        "correctas": correctas,
        "total": total,
        "nota": nota
    })
    
    
@app.route('/enviar_reporte_manual', methods=['POST'])
def enviar_reporte_manual():

    data = request.get_json()

    alumno_id = data['alumno_id']
    quiz_id = data['quiz_id']
    intento_id = data['intento_id']

    try:
        examen = obtener_examen_alumno(alumno_id, quiz_id, intento_id)

        fecha = datetime.now().strftime("%d/%m/%Y %H:%M")

        generar_y_enviar_reporte(
            examen["detalle"],
            examen["nota"],
            examen["correo"],
            examen["nombre"],
            alumno_id,
            examen["titulo"],
            examen["dni"],
            fecha,
            True
        )

        return jsonify({"status": "ok"})

    except Exception as e:
        print("❌ ERROR INTERNO:", str(e))

        # 👇 ESTO ES CLAVE
        return jsonify({"status": "error", "mensaje": str(e)})
    
@app.route('/exportar_quiz_excel/<int:quiz_id>')
def exportar_quiz_excel(quiz_id):

    con_sol = request.args.get("solucion", "true").lower() == "true"
    titulo=""

    conn = get_db_connection()
    cur = conn.cursor()
    
    # 🔹 título
    cur.execute("SELECT titulo FROM quiz WHERE id = %s", (quiz_id,))
    titulo_quiz = cur.fetchone()[0]
    
    if con_sol:
        titulo = titulo_quiz + " - Con Solución"
    else:
        titulo = titulo_quiz + " - Sin Solución"

    # 🔹 preguntas + opciones
    cur.execute("""
        SELECT p.id, p.texto, o.texto, o.es_correcta
        FROM preguntas p
        JOIN opciones o ON p.id = o.pregunta_id
        WHERE p.quiz_id = %s
        ORDER BY p.id, o.id
    """, (quiz_id,))

    rows = cur.fetchall()

    cur.close()
    conn.close()

    # 🔹 agrupar preguntas
    preguntas = defaultdict(list)
    for r in rows:
        preguntas[(r[0], r[1])].append({
            "opcion": r[2],
            "correcta": r[3]
        })

    # 📊 Excel
    wb = Workbook()
    ws = wb.active
    ws.title = "Quiz"

    # 🔹 columnas
    ws.column_dimensions['A'].width = 60
    ws.column_dimensions['B'].width = 60

    # =========================
    # 🔥 HEADER
    # =========================

    # 🔹 LOGO en A1:B2
    try:
        logo = XLImage("static/img/logo.png")

        base_width = 70
        ratio = base_width / logo.width
        logo.width = base_width
        logo.height = int(logo.height * ratio)

        ws.add_image(logo, "A1")
    except:
        pass

    # 🔹 TÍTULO en A3:B3
    ws.merge_cells('A3:B3')
    celda_titulo = ws.cell(row=3, column=1, value=titulo_quiz)
    celda_titulo.font = Font(size=14, bold=True)
    celda_titulo.alignment = Alignment(horizontal="center", vertical="center")

    # 🔹 línea separadora (fila 4)
    thin = Side(style='thin')
    for col in range(1, 3):
        ws.cell(row=4, column=col).border = Border(bottom=thin)

    # =========================
    # 🔹 CONTENIDO
    # =========================

    fila = 5
    letras = ['a', 'b', 'c', 'd', 'e', 'f']
    contador = 1

    for (pid, texto_pregunta), opciones in preguntas.items():

        # 🔹 PREGUNTA
        ws.merge_cells(start_row=fila, start_column=1, end_row=fila, end_column=2)

        texto = f"{contador}. {texto_pregunta}"
        celda = ws.cell(row=fila, column=1, value=texto)
        celda.font = Font(bold=True)
        celda.alignment = Alignment(wrap_text=True)

        fila += 1

        # 🔹 OPCIONES
        for i, op in enumerate(opciones):
            letra = letras[i] if i < len(letras) else f"{i})"
            texto_op = f"   {letra}) {op['opcion']}"

            if con_sol and op["correcta"]:
                texto_op += "  ✔"

            ws.merge_cells(start_row=fila, start_column=1, end_row=fila, end_column=2)

            celda_op = ws.cell(row=fila, column=1, value=texto_op)
            celda_op.alignment = Alignment(wrap_text=True)

            fila += 1

        fila += 1
        contador += 1

    # 🔹 guardar
    buffer = BytesIO()
    wb.save(buffer)
    buffer.seek(0)

    return send_file(
        buffer,
        as_attachment=True,
        download_name=f"{titulo}.xlsx",
        mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    )   


    
@app.route('/salones')
def ver_salones():

    if 'user_id' not in session:
        return redirect(url_for('login'))

    user_id = session['user_id']
    rol = session['rol']
    cempre = session['cempre']

    conn = get_db_connection()
    cur = conn.cursor()

    # 🧠 lógica según rol
    if rol == 'admin':
        filtro = "WHERE s.estado='A' AND s.cempre = %s"
        params = (cempre,)
    else:
        # profesor
        filtro = "WHERE s.estado='A' AND s.cempre = %s AND s.usuario_id = %s"
        params = (cempre, user_id)

    query = f"""
        SELECT 
            s.id, 
            s.codigo, 
            s.descripcion, 
            s.fecha_creacion, 
            s.estado,
            COUNT(sq.id) as total_quizzes
        FROM salon s
        LEFT JOIN salon_quiz sq ON sq.salon_id = s.id
        {filtro}
        GROUP BY s.id
        ORDER BY s.id DESC
    """

    cur.execute(query, params)
    salones = cur.fetchall()

    cur.close()
    conn.close()

    return render_template("salones.html", salones=salones)

@app.route('/editar_salon/<int:id>', methods=['GET', 'POST'])
def editar_salon(id):

    conn = get_db_connection()
    cur = conn.cursor()

    if request.method == 'POST':
        codigo = request.form['codigo']
        descripcion = request.form['descripcion']
        estado = request.form['estado']

        cur.execute("""
            UPDATE salon
            SET codigo = %s,
                descripcion = %s,
                estado = %s
            WHERE id = %s
        """, (codigo, descripcion, estado, id))

        conn.commit()
        cur.close()
        conn.close()

        return redirect('/salones')

    # 🔍 cargar datos actuales
    cur.execute("""
        SELECT id, codigo, descripcion, estado
        FROM salon
        WHERE id = %s
    """, (id,))

    salon = cur.fetchone()

    cur.close()
    conn.close()

    return render_template("editar_salon.html", salon=salon)

@app.route('/eliminar_salon/<int:id>')
def eliminar_salon(id):

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        UPDATE salon
        SET estado = 'I'
        WHERE id = %s
    """, (id,))

    conn.commit()
    cur.close()
    conn.close()

    return redirect('/salones')

@app.route('/crear_salon')
def crear_salon():
    return render_template("crear_salon.html")    

@app.route('/guardar_salon', methods=['POST'])
def guardar_salon():

    if 'user_id' not in session:
        return redirect(url_for('login'))

    codigo = request.form['codigo']
    descripcion = request.form['descripcion']

    user_id = session['user_id']
    cempre = session['cempre']

    if not codigo or not descripcion:
        return "Campos obligatorios", 400

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        INSERT INTO salon (codigo, descripcion, usuario_id, cempre, estado)
        VALUES (%s, %s, %s, %s, 'A')
    """, (codigo, descripcion, user_id, cempre))

    conn.commit()
    cur.close()
    conn.close()

    return redirect('/salones')

@app.route('/asignar_quiz')
def asignar_quiz():

    if 'user_id' not in session:
        return redirect(url_for('login'))

    user_id = session['user_id']
    rol = session['rol']
    cempre = session['cempre']

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔹 SALONES
    if rol == 'admin':
        cur.execute("""
            SELECT id, codigo, descripcion
            FROM salon
            WHERE cempre = %s
            ORDER BY id DESC
        """, (cempre,))
    else:
        cur.execute("""
            SELECT id, codigo, descripcion
            FROM salon
            WHERE cempre = %s AND usuario_id = %s
            ORDER BY id DESC
        """, (cempre, user_id))

    salones = cur.fetchall()

    # 🔹 QUIZZES
    if rol == 'admin':
        cur.execute("""
            SELECT id, titulo
            FROM quiz
            WHERE cempre = %s
            ORDER BY id DESC
        """, (cempre,))
    else:
        cur.execute("""
            SELECT id, titulo
            FROM quiz
            WHERE cempre = %s AND usuario_id = %s
            ORDER BY id DESC
        """, (cempre, user_id))

    quizzes = cur.fetchall()

    cur.close()
    conn.close()

    return render_template("asignar_quiz.html", salones=salones, quizzes=quizzes)

from psycopg2 import errors

@app.route('/guardar_asignacion', methods=['POST'])
def guardar_asignacion():

    data = request.get_json()

    salon_id = data['salon_id']
    quiz_id = data['quiz_id']

    conn = get_db_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            INSERT INTO salon_quiz (salon_id, quiz_id, codigo, estado)
            VALUES (%s, %s, NULL, 'A')
        """, (salon_id, quiz_id))

        conn.commit()

    except Exception as e:
        conn.rollback()

        # 🔥 detectar duplicado
        if "uq_salon_quiz" in str(e):
            return jsonify({
                "status": "error",
                "message": "Este quiz ya fue asignado a este salón"
            })

        return jsonify({
            "status": "error",
            "message": "Error inesperado"
        })

    finally:
        cur.close()
        conn.close()

    return jsonify({"status": "ok"})

@app.route('/resultados_salon', methods=['GET', 'POST'])
def resultados_salon():

    if 'user_id' not in session:
        return redirect(url_for('login'))

    user_id = session['user_id']
    rol = session['rol']
    cempre = session['cempre']
    
    print("DEBUG user_id:", user_id)

    conn = get_db_connection()
    cur = conn.cursor()

    salon_id = request.form.get('salon_id') or request.args.get('salon_id')

    # 🔹 SALONES FILTRADOS
    if rol == 'admin':
        cur.execute("""
            SELECT id, codigo, descripcion
            FROM salon
            WHERE cempre = %s
            ORDER BY id DESC
        """, (cempre,))
    else:
        cur.execute("""
            SELECT id, codigo, descripcion
            FROM salon
            WHERE cempre = %s AND usuario_id = %s
            ORDER BY id DESC
        """, (cempre, user_id))

    salones = cur.fetchall()
    
    print("DEBUG salones:", salones)

    quizzes = []
    tabla = []
    notas = []
    nombres = []
    preguntas_top = []
    promedio_quiz = []
    aprobados = 0
    desaprobados = 0

    detalle_aprobados = {
        "Aprobados": [],
        "Desaprobados": []
    }
    distribucion= []
    distribucion_detalle = []

    # 🔐 VALIDAR SALON_ID (CLAVE)
    if salon_id:

        if rol == 'admin':
            cur.execute("""
                SELECT id FROM salon
                WHERE id = %s AND cempre = %s
            """, (salon_id, cempre))
        else:
            cur.execute("""
                SELECT id FROM salon
                WHERE id = %s AND cempre = %s AND usuario_id = %s
            """, (salon_id, cempre, user_id))

        if not cur.fetchone():
            cur.close()
            conn.close()
            return "No autorizado", 403

    # 🔹 PROCESO SOLO SI ES POST
    if request.method == 'POST' and salon_id:

        # 🔹 RESULTADOS
        cur.execute("""
            WITH ultimo_intento AS (
                SELECT 
                    alumno_id,
                    quiz_id,
                    MAX(intento_id) AS intento_id
                FROM respuestas_alumno
                GROUP BY alumno_id, quiz_id
            )

            SELECT 
                a.dni,
                a.id AS alumno_id,
                a.nombre,
                a.apellido,
                a.correo,
                q.id AS quiz_id,
                q.titulo,
                iq.intento_numero,
                ROUND(
                    (
                        COUNT(CASE WHEN o.es_correcta THEN 1 END)::decimal
                        / NULLIF(COUNT(*), 0)
                    ) * 20,
                2) AS nota,
                MAX(sq.fecha_asignacion) as fecha

            FROM respuestas_alumno ra

            JOIN ultimo_intento ui 
                ON ui.alumno_id = ra.alumno_id
                AND ui.quiz_id = ra.quiz_id
                AND ui.intento_id = ra.intento_id

            JOIN alumnos a ON a.id = ra.alumno_id
            JOIN opciones o ON o.id = ra.opcion_id
            JOIN quiz q ON q.id = ra.quiz_id
            JOIN salon_quiz sq ON sq.quiz_id = q.id
            JOIN salon s ON s.id = sq.salon_id
            LEFT JOIN intentos_quiz iq ON iq.id = ra.intento_id

            WHERE sq.salon_id = %s
            AND s.cempre = %s

            GROUP BY 
            a.id, a.dni, a.nombre, a.apellido, 
            q.id, q.titulo, iq.intento_numero

            ORDER BY a.nombre
        """, (salon_id, cempre ))

        data = cur.fetchall()

        # 🔹 QUIZZES DEL SALON
        cur.execute("""
            SELECT q.id, q.titulo,q.codigo
            FROM salon_quiz sq
            JOIN quiz q ON q.id = sq.quiz_id
            JOIN salon s ON s.id = sq.salon_id
            WHERE sq.salon_id = %s
              AND s.cempre = %s
        """, (salon_id, cempre))

        todos_quizzes = cur.fetchall()

        # 🔥 PIVOT (igual que ya lo tienes)
        resultado = {}

        for row in data:
    
            dni, alumno_id, nombre, apellido, correo, quiz_id, quiz, intento, nota,fecha = row

            if alumno_id not in resultado:
                resultado[alumno_id] = {
                    "alumno_id": alumno_id,
                    "dni": dni,
                    "alumno": f"{nombre} {apellido}",
                    "correo": correo
                }

            resultado[alumno_id][quiz_id] = {
                "nota": nota,
                "intento": intento,
                "fecha": fecha   # 👈 NUEVO
            }

        quizzes = [
            {
                "id": q[0],
                "titulo": q[1],
                "codigo": q[2]
            }
            for q in todos_quizzes
        ]

        tabla = []

        for alumno_id, fila in resultado.items():

            suma = 0
            count = 0

            for q in quizzes:
                data = fila.get(q["id"])

                if isinstance(data, dict):
                    fila[q["id"]] = data
                    if data["nota"] > 0:
                        suma += data["nota"]
                        count += 1
                else:
                    fila[q["id"]] = {"nota": 0, "intento": 0}


            fila["promedio"] = round(suma / count, 2) if count > 0 else 0
            tabla.append(fila)

        notas = [fila["promedio"] for fila in tabla]
        distribucion = [0, 0, 0, 0]

        distribucion_detalle = {
            "0-10": [],
            "11-13": [],
            "14-16": [],
            "17-20": []
        }

        for fila in tabla:

            promedio = fila["promedio"]
            alumno = f'{fila["alumno"]} ({promedio:.2f})'

            if promedio <= 10:
                distribucion[0] += 1
                distribucion_detalle["0-10"].append(alumno)

            elif promedio <= 13:
                distribucion[1] += 1
                distribucion_detalle["11-13"].append(alumno)

            elif promedio <= 16:
                distribucion[2] += 1
                distribucion_detalle["14-16"].append(alumno)

            else:
                distribucion[3] += 1
                distribucion_detalle["17-20"].append(alumno)
                
        aprobados = sum(1 for nota in notas if nota >= 11)
        desaprobados = sum(1 for nota in notas if nota < 11)
        
        detalle_aprobados = {
            "Aprobados": [],
            "Desaprobados": []
        }

        for fila in tabla:

            alumno = f'{fila["alumno"]} ({fila["promedio"]:.2f})'

            if fila["promedio"] >= 11:
                detalle_aprobados["Aprobados"].append(alumno)
            else:
                detalle_aprobados["Desaprobados"].append(alumno)
                
        nombres = [fila["alumno"] for fila in tabla]
        
        # ===============================
        # 📊 analisis de quizzes
        # ===============================
         
        cur.execute("""
            WITH ultimo_intento AS (
                SELECT
                    alumno_id,
                    quiz_id,
                    MAX(intento_id) AS intento_id
                FROM respuestas_alumno
                GROUP BY alumno_id, quiz_id
            ),

            notas_quiz AS (

                SELECT
                    ra.alumno_id,
                    ra.quiz_id,

                    ROUND(
                        (
                            COUNT(CASE WHEN o.es_correcta THEN 1 END)::decimal
                            / NULLIF(COUNT(*),0)
                        ) * 20,
                    2) AS nota

                FROM respuestas_alumno ra

                JOIN ultimo_intento ui
                    ON ui.alumno_id = ra.alumno_id
                AND ui.quiz_id = ra.quiz_id
                AND ui.intento_id = ra.intento_id

                JOIN opciones o
                    ON o.id = ra.opcion_id

                GROUP BY
                    ra.alumno_id,
                    ra.quiz_id
            )

            SELECT

                q.codigo,
                q.titulo,
                MAX(sq.fecha_asignacion),

                ROUND(AVG(nq.nota),2) AS promedio,

                COUNT(CASE WHEN nq.nota >= 11 THEN 1 END) AS aprobados,

                COUNT(CASE WHEN nq.nota < 11 THEN 1 END) AS desaprobados,

                MAX(nq.nota) AS maxima,

                MIN(nq.nota) AS minima

            FROM notas_quiz nq

            JOIN quiz q
                ON q.id = nq.quiz_id

            JOIN salon_quiz sq
                ON sq.quiz_id = q.id

            WHERE sq.salon_id = %s

            GROUP BY
                q.id,
                q.codigo,
                q.titulo

            ORDER BY promedio DESC
        """, (salon_id,))

       
        colores = [
            "#1D4ED8",  # Azul
            "#10B981",  # Verde
            "#8B5CF6",  # Morado
            "#F97316",  # Naranja
            "#EC4899",  # Rosa
            "#06B6D4",  # Cian
            "#84CC16",  # Lima
            "#F59E0B"   # Ámbar
        ]
        
        promedio_quiz = []

        filas = cur.fetchall()

        promedio_anterior = None

        for i, row in enumerate(filas):

            codigo = row[0]
            titulo = row[1]
            fecha = row[2]
            promedio = float(row[3])

            if fecha:
                fecha = fecha.strftime("%d/%m/%y")
            else:
                fecha = ""

            if promedio_anterior is None:
                variacion = None
            else:
                variacion = round(promedio - promedio_anterior, 2)

            promedio_anterior = promedio

            promedio_quiz.append({

                "codigo": codigo,
                "titulo": titulo,
                "fecha": fecha,

                "promedio": promedio,

                "variacion": variacion,

                "aprobados": row[4],
                "desaprobados": row[5],

                "maxima": float(row[6]),
                "minima": float(row[7]),

                "color": colores[i % len(colores)]

            })
    cur.close()
    conn.close()
    
    print(promedio_quiz)
     

    return render_template(
        "resultados_salon.html",
        salones=salones,
        quizzes=quizzes,
        resultado=tabla,
        salon_seleccionado=salon_id or "",
        notas=notas,
        aprobados=aprobados,
        desaprobados=desaprobados,
        detalle_aprobados=detalle_aprobados,
        nombres=nombres,
        distribucion=distribucion,
        promedio_quiz=promedio_quiz,
        distribucion_detalle=distribucion_detalle,
        preguntas_top=preguntas_top
    )

    
@app.route('/eliminar_respuestas', methods=['POST'])
def eliminar_respuestas():
    alumno_id = request.form.get('alumno_id')
    quiz_id = request.form.get('quiz_id')

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔥 borrar SOLO ese quiz del alumno
    cur.execute("""
        DELETE FROM respuestas_alumno
        WHERE alumno_id = %s
        AND (quiz_id = %s OR quiz_id IS NULL)
    """, (alumno_id, quiz_id))

    conn.commit()
    cur.close()
    conn.close()

    salon_id = request.form.get('salon_id')

    return '', 204


@app.route('/obtener_quizzes_alumno/<int:alumno_id>')
def obtener_quizzes_alumno(alumno_id):

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT DISTINCT ra.quiz_id, q.titulo
        FROM respuestas_alumno ra
        JOIN quiz q ON q.id = ra.quiz_id
        WHERE ra.alumno_id = %s
    """, (alumno_id,))

    data = cur.fetchall()

    cur.close()
    conn.close()

    return jsonify([
        {"quiz_id": r[0], "titulo": r[1]} for r in data
    ])
    

@app.route('/resultados/<int:quiz_id>')
def ver_resultados(quiz_id):

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔹 RESULTADOS GENERALES
    cur.execute("""
        SELECT 
            a.id,
            a.dni,
            a.nombre,
            a.apellido,
            COUNT(CASE WHEN o.es_correcta THEN 1 END) AS correctas,
            COUNT(r.id) AS total,
            ROUND((COUNT(CASE WHEN o.es_correcta THEN 1 END)::decimal / COUNT(r.id)) * 20, 2) AS nota

        FROM respuestas_alumno r
        JOIN alumnos a ON a.id = r.alumno_id
        JOIN opciones o ON o.id = r.opcion_id
        JOIN preguntas p ON p.id = r.pregunta_id

        WHERE p.quiz_id = %s

        GROUP BY a.id,a.dni,a.nombre, a.apellido
        ORDER BY nota DESC
    """, (quiz_id,))

    resultados = cur.fetchall()

    # 🔥 1. TOP 10
    top = resultados[:10]
    #top_nombres = [f"{r[1]} {r[2]}" for r in top]
    top_nombres = [f"{(r[1] + ' ' + r[2])[:10]}" for r in top]
    top_puntajes = [r[3] for r in top]

    # 🔥 2. APROBADOS VS DESAPROBADOS
    Excelente = sum(1 for r in resultados if r[6] >=18)
    MuyBien = sum(1 for r in resultados if r[6] <18 and r[6]>=16)
    Bien = sum(1 for r in resultados if r[6] <16 and r[6]>=13)
    Regular =sum(1 for r in resultados if r[6] <13 and r[6]>=11)
    Mal =sum(1 for r in resultados if r[6] <11)

    aprobados_data = [Excelente, MuyBien,Bien,Regular,Mal]

    # 🔥 3. DISTRIBUCIÓN DE NOTAS
    rangos = {
    "0-2": 0,
    "3-5": 0,
    "6-8": 0,
    "9-10":0,
    "11-12": 0,
    "13-14": 0,
    "15-17": 0,
    "18-20": 0
}

    for r in resultados:
        nota = r[6]
        if nota <= 2:
            rangos["0-2"] += 1
        elif nota <= 5:
            rangos["3-5"] += 1
        elif nota <= 8:
            rangos["6-8"] += 1
        elif nota <= 10:
            rangos["9-10"] += 1
        elif nota <= 12:
            rangos["11-12"] += 1
        elif nota <= 14:
            rangos["13-14"] += 1
        elif nota <= 17:
            rangos["15-17"] += 1
        else:
            rangos["18-20"] += 1

    notas_labels = list(rangos.keys())
    notas_data = list(rangos.values())

    # 🔥 4. PREGUNTAS MÁS FALLADAS (simple demo)
    cur.execute("""
        SELECT 
            p.id,
            p.texto,

            COUNT(DISTINCT CASE 
                WHEN o.es_correcta = false THEN r.alumno_id 
            END) AS alumnos_fallaron,

            COUNT(DISTINCT r.alumno_id) AS total_alumnos,

            ROUND(
                (
                    COUNT(DISTINCT CASE 
                        WHEN o.es_correcta = false THEN r.alumno_id 
                    END)::decimal
                    /
                    NULLIF(COUNT(DISTINCT r.alumno_id), 0)
                ) * 100
            ,1) AS porcentaje_error

        FROM respuestas_alumno r
        JOIN preguntas p ON r.pregunta_id = p.id
        JOIN opciones o ON r.opcion_id = o.id

        WHERE p.quiz_id = %s

        GROUP BY p.id, p.texto

        ORDER BY porcentaje_error DESC
        LIMIT 10;
    """, (quiz_id,))

    preguntas = cur.fetchall()
    preguntas = [p for p in preguntas if p[4] > 0] 
    preguntas_labels = [(p[1] or "Pregunta")[:30] for p in preguntas]
    preguntas_tooltips = [p[1] for p in preguntas]
    preguntas_fallos = [float(p[4]) for p in preguntas]  # 👈 ahora % no conteo
    
    # lista de alumnos
    promedio = round(
        sum(r[6] for r in resultados) / len(resultados),
        2
    ) if resultados else 0
    
    # mayor nota
    mayor_nota = max(r[6] for r in resultados) if resultados else 0
    
    cur.execute("SELECT titulo FROM quiz WHERE id = %s", (quiz_id,))
    resultado = cur.fetchone()

    if resultado is not None:
        titulo_quiz = resultado[0]
    else:
        titulo_quiz = "Quiz no encontrado"
        
    cur.execute("""
        SELECT
            alumno_id,
            COUNT(*)
        FROM intentos_quiz
        WHERE quiz_id = %s
        AND nota_final IS NOT NULL
        GROUP BY alumno_id
    """, (quiz_id,))

    intentos_por_alumno = cur.fetchall()

    intentos_dict = {row[0]: row[1] for row in intentos_por_alumno}
    
    cur.execute("""
        SELECT COUNT(*) 
        FROM preguntas 
        WHERE quiz_id = %s
    """, (quiz_id,))

    total_preguntas = cur.fetchone()[0]
    
    cur.execute("""
        SELECT
            alumno_id,
            ROUND(AVG(tiempo_total_segundos))
        FROM intentos_quiz
        WHERE quiz_id = %s
        AND tiempo_total_segundos IS NOT NULL
        AND nota_final IS NOT NULL
        GROUP BY alumno_id
    """, (quiz_id,))

    tiempos_promedio = {
        alumno_id: tiempo
        for alumno_id, tiempo in cur.fetchall()
    }
    
    cur.execute("""
        SELECT
            iq.alumno_id,
            iq.intento_numero,
            iq.nota_final,
            iq.tiempo_total_segundos,
            iq.fecha_fin,

            COUNT(CASE WHEN o.es_correcta THEN 1 END) AS correctas,
            COUNT(ra.id) AS total

        FROM intentos_quiz iq

        JOIN respuestas_alumno ra
            ON ra.intento_id = iq.id

        JOIN opciones o
            ON o.id = ra.opcion_id

        WHERE iq.quiz_id = %s

        GROUP BY
            iq.alumno_id,
            iq.intento_numero,
            iq.nota_final,
            iq.tiempo_total_segundos,
            iq.fecha_fin

        ORDER BY
            iq.alumno_id,
            iq.intento_numero
    """, (quiz_id,))

    intentos_detalle = {}

    for alumno_id, intento, nota, tiempo, fecha, correctas, total in cur.fetchall():
    
        if alumno_id not in intentos_detalle:
            intentos_detalle[alumno_id] = []

        intentos_detalle[alumno_id].append({
            "intento": intento,
            "nota": nota,
            "tiempo": tiempo,
            "fecha": fecha,
            "correctas": correctas,
            "total": total
        })
        
     # 🔥 4. KPI's de tiempo
    cur.execute("""
        SELECT
            ROUND(AVG(tiempo_total_segundos)),
            MIN(tiempo_total_segundos),
            MAX(tiempo_total_segundos)
        FROM intentos_quiz
        WHERE quiz_id = %s
          AND tiempo_total_segundos IS NOT NULL
          AND nota_final IS NOT NULL
    """, (quiz_id,))

    tiempo_promedio_examen, examen_mas_rapido, examen_mas_lento = cur.fetchone()

    tiempo_promedio_examen = tiempo_promedio_examen or 0
    examen_mas_rapido = examen_mas_rapido or 0
    examen_mas_lento = examen_mas_lento or 0 
    
    cur.execute("""
        SELECT
            COALESCE(SUM(tiempo_total_segundos),0)
        FROM intentos_quiz
        WHERE quiz_id = %s
          AND tiempo_total_segundos IS NOT NULL
          AND nota_final IS NOT NULL
    """, (quiz_id,))

    tiempo_total_examenes = cur.fetchone()[0] or 0
    
    cur.execute("""
        SELECT
            p.id,
            p.norden,
            p.texto,
            ROUND(AVG(ra.tiempo_segundos),1) AS promedio
        FROM preguntas p
        JOIN respuestas_alumno ra
            ON ra.pregunta_id = p.id
        WHERE p.quiz_id = %s
        AND ra.tiempo_segundos IS NOT NULL
        GROUP BY
            p.id,
            p.norden,
            p.texto
        ORDER BY promedio DESC;
    """, (quiz_id,))

    tiempo_preguntas = cur.fetchall()
    tiempo_labels = [f"P{p[1]}" for p in tiempo_preguntas]
    tiempo_promedios = [float(p[3]) for p in tiempo_preguntas]
    tiempo_tooltips = [p[2] for p in tiempo_preguntas]
    

    cur.execute("""
        SELECT
            p.norden,
            p.texto,
            COUNT(*) AS respuestas,
            SUM(CASE WHEN o.es_correcta THEN 1 ELSE 0 END) AS correctas,
            ROUND(
                100.0 * SUM(CASE WHEN o.es_correcta THEN 1 ELSE 0 END) / COUNT(*),
                1
            ) AS porcentaje
        FROM preguntas p
        JOIN respuestas_alumno ra
            ON ra.pregunta_id = p.id
        JOIN opciones o
            ON ra.opcion_id = o.id
        WHERE p.quiz_id = %s
        GROUP BY
            p.norden,
            p.texto
        ORDER BY porcentaje ASC;
    """, (quiz_id,))
    
    resultados_aciertos = cur.fetchall()

    aciertos_labels = [f"P{r[0]}" for r in resultados_aciertos]
    aciertos_tooltips = [r[1] for r in resultados_aciertos]
    aciertos_porcentaje = [float(r[4]) for r in resultados_aciertos]
    aciertos_respuestas = [int(r[2]) for r in resultados_aciertos]

    cur.close()
    conn.close()
    
     

    return render_template(
        "resultados.html",
        resultados=resultados,
        quiz_id=quiz_id,

        top_nombres=top_nombres,
        top_puntajes=top_puntajes,

        aprobados_data=aprobados_data,

        notas_labels=notas_labels,
        notas_data=notas_data,
        total_preguntas=total_preguntas,
        preguntas_labels=preguntas_labels,
        preguntas_fallos=preguntas_fallos,
        preguntas_tooltips=preguntas_tooltips,
        intentos=intentos_dict,
        titulo_quiz=titulo_quiz,
        tiempos_promedio=tiempos_promedio,
        promedio=promedio ,
        mayor_nota=mayor_nota,
        intentos_detalle=intentos_detalle,
        tiempo_promedio_examen=tiempo_promedio_examen,
        examen_mas_rapido=examen_mas_rapido,
        examen_mas_lento=examen_mas_lento,
        tiempo_total_examenes=tiempo_total_examenes ,
        tiempo_labels=tiempo_labels,
        tiempo_tooltips=tiempo_tooltips,
        tiempo_promedios=tiempo_promedios ,
        aciertos_labels=aciertos_labels,
        aciertos_porcentaje=aciertos_porcentaje,
        aciertos_tooltips=aciertos_tooltips,
        aciertos_respuestas=aciertos_respuestas 
    )
    
    
@app.route('/ver_quiz_alumno/<int:quiz_id>/<int:alumno_id>')
def ver_quiz_alumno(quiz_id, alumno_id):

    if 'user_id' not in session:
        return redirect(url_for('login'))

    conn = get_db_connection()
    cur = conn.cursor()
    
    intento = request.args.get('intento', 1)
    
    cur.execute("""
    SELECT id
        FROM intentos_quiz
        WHERE alumno_id = %s AND quiz_id = %s AND intento_numero = %s
    """, (alumno_id, quiz_id, intento))

    row = cur.fetchone()
    intento_id = row[0] if row else None

    # 🔹 Obtener preguntas + opciones + respuesta del alumno
    cur.execute("""
    SELECT 
        p.texto AS pregunta,
        o.texto AS opcion,
        o.es_correcta,
        o.id AS opcion_id,

        (
            SELECT ra.opcion_id
            FROM respuestas_alumno ra
            WHERE ra.pregunta_id = p.id
            AND ra.alumno_id = %s
            AND (
                ra.intento_id = %s
                OR ra.intento_id IS NULL
            )
            ORDER BY ra.id DESC
            LIMIT 1
        ) AS respuesta_alumno

    FROM preguntas p
    JOIN opciones o ON o.pregunta_id = p.id
    WHERE p.quiz_id = %s
    ORDER BY p.id, o.id
    """, (alumno_id, intento_id, quiz_id))

    data = cur.fetchall()

    # 🔥 AGRUPAR POR PREGUNTA
    preguntas = {}

    for row in data:
        pregunta = row[0]

        if pregunta not in preguntas:
            preguntas[pregunta] = []

        preguntas[pregunta].append({
            "opcion": row[1],
            "es_correcta": row[2],
            "opcion_id": row[3],
            "respuesta_alumno": row[4]
        })
        
    # 🔥 calcular nota
    cur.execute("""
        SELECT 
            ROUND(
                (
                    COUNT(CASE WHEN r.opcion_id = oc.id THEN 1 END)::decimal
                    / COUNT(p.id)
                ) * 20, 2
            )
        FROM preguntas p

        LEFT JOIN LATERAL (
            SELECT ra.opcion_id
            FROM respuestas_alumno ra
            WHERE ra.pregunta_id = p.id
            AND ra.alumno_id = %s
            AND (
                ra.intento_id = %s OR ra.intento_id IS NULL
            )
            ORDER BY ra.id DESC
            LIMIT 1
        ) r ON true

        LEFT JOIN opciones oc 
            ON oc.pregunta_id = p.id AND oc.es_correcta = true

        WHERE p.quiz_id = %s
    """, (alumno_id, intento_id, quiz_id))
    resultado_nota = cur.fetchone()
    nota = resultado_nota[0] if resultado_nota and resultado_nota[0] else 0

    cur.execute("""
        SELECT nombre, apellido
        FROM alumnos
        WHERE id = %s
    """, (alumno_id,))

    alumno = cur.fetchone()

    alumno_nombre = f"{alumno[0]} {alumno[1]}" if alumno else "Alumno"
    
    cur.close()
    conn.close()
    
    

    return render_template(
        "ver_quiz_alumno.html",
        preguntas=preguntas,
        alumno_nombre=alumno_nombre,
        fecha=datetime.now().strftime("%d/%m/%Y"),
        nota=nota
    )

    

from flask import session, redirect

@app.route('/salon/<codigo>', methods=['GET', 'POST'])
def acceso_salon(codigo):

    conn = get_db_connection()
    cur = conn.cursor()
    session['modo'] = 'web'

    # 🔍 buscar salon_quiz
    cur.execute("""
        SELECT sq.id, q.id, q.titulo, q.multiple_intentos
        FROM salon_quiz sq
        JOIN quiz q ON q.id = sq.quiz_id
        WHERE sq.codigo = %s
    """, (codigo,))

    row = cur.fetchone()
    
    print("Codigo: ",codigo)

    if not row:
        return "❌ Código inválido"

    salon_quiz_id = row[0]
    quiz_id = row[1]
    titulo_quiz = row[2]
    multiple_intentos = row[3]

    if request.method == 'POST':
        dni = request.form['dni']
        nombre = request.form.get('nombre')
        apellido = request.form.get('apellido')
        correo = request.form.get('correo')

        # 🔍 buscar alumno
        cur.execute("SELECT id, nombre, apellido, correo FROM alumnos WHERE dni=%s", (dni,))
        alumno = cur.fetchone()

        if alumno:
            alumno_id = alumno[0]
            nombre_db = alumno[1]
            apellido_db = alumno[2]
            correo_db = alumno[3]

            incompleto = (
                not nombre_db or not str(nombre_db).strip() or
                not apellido_db or not str(apellido_db).strip() or
                not correo_db or not str(correo_db).strip()
            )

            # 🔴 SI ESTÁ INCOMPLETO → MOSTRAR FORMULARIO
            if incompleto:
                return render_template(
                    "login_quiz.html",
                    codigo=codigo,
                    dni=dni,
                    nombre=nombre_db or "",
                    apellido=apellido_db or "",
                    correo=correo_db or "",
                    mostrar_form=True
                )
            # 🔥 VALIDACIÓN AQUÍ (ANTES)
            # 🔥 VALIDACIÓN INTENTOS (como ya tienes)
            cur.execute("""
                SELECT COUNT(DISTINCT pregunta_id)
                FROM respuestas_alumno
                WHERE alumno_id = %s AND salon_quiz_id = %s
            """, (alumno_id, salon_quiz_id))

            ya_respondio = cur.fetchone()[0] > 0

            if not multiple_intentos and ya_respondio:
                response = make_response(render_template("bloqueado.html", quiz_titulo=titulo_quiz))
                response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
                return response

            # correo
            if not correo_db or not str(correo_db).strip():

                if not correo or not correo.strip():
                    return "❌ Debes ingresar tu correo"

                cur.execute(
                    "UPDATE alumnos SET correo=%s WHERE dni=%s",
                    (correo.strip(), dni)
                )
                conn.commit()

        else:
            if not nombre or not apellido or not correo:
                return render_template(
                    "login_quiz.html",
                    codigo=codigo,
                    dni=dni,
                    nombre=nombre or "",
                    apellido=apellido or "",
                    correo=correo or "",
                    mostrar_form=True
                )

        # 🔍 verificar si ya existe
        # 🔥 SI NO EXISTE → CREAR
        if not alumno:
            cur.execute("""
                INSERT INTO alumnos (dni, nombre, apellido, correo)
                VALUES (%s, %s, %s, %s)
                RETURNING id
            """, (dni, nombre, apellido, correo))

            alumno_id = cur.fetchone()[0]
            conn.commit()

        cur.close()
        conn.close()

        print("Estoy en acceso_salon, no hay preguntas cargadas")
        return redirect(url_for(
            'resolver_quiz_salon',
            salon_quiz_id=salon_quiz_id,
            alumno_id=alumno_id
        ))

    return render_template('login_quiz.html', codigo=codigo)

    
@app.route('/eliminar_quiz/<int:quiz_id>')
def eliminar_quiz(quiz_id):

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        UPDATE quiz 
        SET estado='I', fmodificacion=NOW()
        WHERE id=%s
    """, (quiz_id,))

    conn.commit()
    cur.close()
    conn.close()

    return redirect(url_for('dashboard_profesor'))

def generar_y_enviar_reporte(detalle, nota, correo, nombre_completo, alumno_id, titulo_quiz, dni, fecha_hora, enviar_solucionario):
    
    import os
    import base64
    #import resend

    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image
    from reportlab.lib.styles import getSampleStyleSheet
    from reportlab.lib import colors
    from reportlab.lib.pagesizes import letter

    print("🔥 entrando a generar_y_enviar_reporte")

    # 📁 Ruta compatible local + Render
    if os.name == "nt":
        ruta_pdf = f"reporte_{alumno_id}.pdf"
    else:
        ruta_pdf = f"/tmp/reporte_{alumno_id}.pdf"

    doc = SimpleDocTemplate(ruta_pdf, pagesize=letter)
    styles = getSampleStyleSheet()
    elements = []

    # 🔹 Logo (por si falla en Render)
    try:
        logo = Image("static/img/logo.png", width=80, height=50)
    except:
        logo = Paragraph("ACAASO", styles['Normal'])

    info = [[logo, Paragraph(f"""
    <b>ACAASO</b><br/>
    <b>Quiz:</b> {titulo_quiz}<br/>
    <b>Alumno:</b> {nombre_completo}<br/>
    <b>DNI:</b> {dni}<br/>
    <b>Correo:</b> {correo}<br/>
    <b>Fecha:</b> {fecha_hora}
    """, styles['Normal'])]]

    tabla_header = Table(info, colWidths=[100, 350])
    tabla_header.setStyle(TableStyle([
        ('BOX', (0,0), (-1,-1), 1.5, colors.black),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.grey),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('BACKGROUND', (0,0), (-1,-1), colors.whitesmoke),
    ]))

    elements.append(tabla_header)
    elements.append(Spacer(1, 15))

    elements.append(Paragraph("<b>RESULTADO DEL QUIZ</b>", styles['Title']))
    elements.append(Spacer(1, 10))
    elements.append(Paragraph(f"<b>Nota final: {nota}</b>", styles['Heading2']))
    elements.append(Spacer(1, 10))

    letras = ['a', 'b', 'c', 'd', 'e']

    for i, item in enumerate(detalle, start=1):
        elements.append(Paragraph(f"{i}. {item['pregunta']}", styles['Heading3']))
        elements.append(Spacer(1, 5))

        data_tabla = []
        fila = []

        for j, op in enumerate(item["opciones"]):
            letra = letras[j]
            texto_base = op["texto"]

            if op["correcta"] and op["marcada"]:
                texto = f'<font color="green">({letra}) ✅ {texto_base}</font>'
            elif not op["correcta"] and op["marcada"]:
                texto = f'<font color="red">({letra}) ❌ {texto_base}</font>'
            elif op["correcta"]:
                texto = f'<font color="green">({letra}) ✔ {texto_base}</font>'
            else:
                texto = f'({letra}) {texto_base}'

            fila.append(Paragraph(texto, styles['Normal']))

            if len(fila) == 3:
                data_tabla.append(fila)
                fila = []

        if fila:
            data_tabla.append(fila)

        tabla = Table(data_tabla)
        tabla.setStyle(TableStyle([
            ('GRID', (0,0), (-1,-1), 0.5, colors.grey),
            ('BOX', (0,0), (-1,-1), 1, colors.black),
        ]))

        elements.append(tabla)
        elements.append(Spacer(1, 10))

    # 🔥 Generar PDF
    try:
        doc.build(elements)
        print("✅ PDF generado")
    except Exception as e:
        print("❌ ERROR GENERANDO PDF:", str(e))
        return

    print("VALOR enviar_solucionario:", enviar_solucionario)


    if resend is None:
        print("❌ Resend no disponible o sin API key")
        return
    
    if enviar_solucionario:
        try:
            # 📎 Leer PDF y convertir a base64
            with open(ruta_pdf, "rb") as f:
                pdf_bytes = f.read()

            pdf_base64 = base64.b64encode(pdf_bytes).decode("utf-8")
            print("Tamaño PDF (bytes):", len(pdf_bytes))
            print("Tamaño Base64:", len(pdf_base64))

            # 📧 Enviar con Resend
            import time

            t0 = time.time()
            print("📤 Enviando a Resend...")
            resend.Emails.send({
                
                "from": "ACAASO <pardoalf@acaaso.com>",
                "to": correo,
                "subject": "Resultado de tu Quiz",
                "html": f"""
                <div style="font-family: Arial, sans-serif; background-color:#f4f6f8; padding:20px;">
                    
                    <div style="max-width:600px; margin:auto; background:white; border-radius:8px; overflow:hidden; box-shadow:0 2px 8px rgba(0,0,0,0.1);">
                        
                        <!-- HEADER -->
                        <div style="text-align:center; padding:20px; background:#0d47a1;">
                            <span style="
                                font-size:42px;
                                font-weight:900;
                                color:#29b6f6;
                                letter-spacing:4px;
                                font-family: Arial Black, Arial, sans-serif;
                            ">
                                ACAASO
                            </span>
                        </div>

                        <!-- BODY -->
                        <div style="padding:25px; color:#333;">
                            
                            <p style="font-size:16px;">
                                Estimado(a) <b>{nombre_completo}</b>,
                            </p>

                            <p>
                                ACAASO Assessment le informa que ya se encuentra disponible el resultado de su evaluación.
                            </p>

                            <div style="background:#f1f5fb; padding:15px; border-radius:6px; margin:20px 0;">
                                <p style="margin:5px 0;"><b>Quiz:</b> {titulo_quiz}</p>
                                <p style="margin:5px 0;"><b>Fecha:</b> {fecha_hora}</p>
                            </div>

                            <div style="text-align:center; margin:25px 0;">
                                <p style="margin-bottom:5px;">Su nota final es:</p>
                                <span style="font-size:28px; font-weight:bold; color:#0d47a1;">
                                    {nota}
                                </span>
                            </div>

                            <p>
                                A continuación, se adjunta el reporte detallado de su evaluación para su revisión.
                            </p>

                            <p style="margin-top:30px;">
                                Cordial saludo,<br>
                                <b>ACAASO Assessment</b>
                            </p>

                        </div>

                        <!-- FOOTER -->
                        <div style="background:#f4f6f8; padding:15px; text-align:center; font-size:12px; color:#777;">
                            © {fecha_hora[:4]} ACAASO - Todos los derechos reservados
                        </div>

                    </div>

                </div>
                """,
                "attachments": [
                    {
                        "filename": f"reporte_{alumno_id}.pdf",
                        "content": pdf_base64
                    }
                ]
            })
            print("⏱ Tiempo:", round(time.time() - t0, 2), "segundos")
            print("✅ correo enviado con Resend")

            # 🧹 limpiar archivo
            try:
                os.remove(ruta_pdf)
            except:
                pass

        except Exception as e:
            print("❌ ERROR RESEND:", str(e))
    else:
        print("ℹ️ solucionario no enviado")
        
@app.route("/contactos", methods=["GET", "POST"])
def contactos():

    if request.method == "POST":

        nombre = request.form["nombre"].strip()
        institucion = request.form["institucion"].strip()
        cargo = request.form["cargo"].strip()
        correo = request.form["correo"].strip()
        whatsapp = request.form["whatsapp"].strip()
        pais = request.form["pais"].strip()
        mensaje = request.form["mensaje"].strip()

        desea_demo = "demo" in request.form

        fecha_demo = request.form.get("fecha_demo") or None
        horario = request.form.get("horario") or None

        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute("""
            INSERT INTO contactos_demo
            (
                nombre,
                institucion,
                cargo,
                correo,
                whatsapp,
                pais,
                mensaje,
                desea_demo,
                fecha_demo,
                horario
            )
            VALUES
            (
                %s,%s,%s,%s,%s,%s,%s,%s,%s,%s
            )
        """, (
            nombre,
            institucion,
            cargo,
            correo,
            whatsapp,
            pais,
            mensaje,
            desea_demo,
            fecha_demo,
            horario
        ))

        conn.commit()

        cur.close()
        conn.close()
        
        try:

            resend.Emails.send({

                "from": "ACAASO <pardoalf@acaaso.com>",

               "to": [
                    "pardoalf@acaaso.com",
                    "pardoalf@gmail.com"
                ],

                "reply_to": correo,

                "subject": f"🎯 Nueva solicitud de demostración - {institucion}",

                "html": f"""

                <div style="font-family:Arial;background:#f4f6f8;padding:25px;">

                    <div style="
                        max-width:700px;
                        margin:auto;
                        background:white;
                        border-radius:12px;
                        overflow:hidden;
                        box-shadow:0 4px 15px rgba(0,0,0,.15);
                    ">

                        <div style="
                            background:#0d47a1;
                            color:white;
                            padding:20px;
                            text-align:center;
                        ">

                            <h2 style="margin:0;">
                                Nueva solicitud de demostración
                            </h2>

                        </div>

                        <div style="padding:30px;">

                            <table style="width:100%;font-size:15px;">

                                <tr>
                                    <td style="font-weight:bold;width:180px;">Nombre</td>
                                    <td>{nombre}</td>
                                </tr>

                                <tr>
                                    <td style="font-weight:bold;">Institución</td>
                                    <td>{institucion}</td>
                                </tr>

                                <tr>
                                    <td style="font-weight:bold;">Cargo</td>
                                    <td>{cargo}</td>
                                </tr>

                                <tr>
                                    <td style="font-weight:bold;">Correo</td>
                                    <td>{correo}</td>
                                </tr>

                                <tr>
                                    <td style="font-weight:bold;">WhatsApp</td>
                                    <td>{whatsapp}</td>
                                </tr>

                                <tr>
                                    <td style="font-weight:bold;">País</td>
                                    <td>{pais}</td>
                                </tr>

                            </table>

                            <hr>

                            <h4>Mensaje</h4>

                            <div style="
                                background:#f7f7f7;
                                padding:15px;
                                border-radius:8px;
                            ">

                                {mensaje}

                            </div>

                            <br>

                            <table style="width:100%;">

                                <tr>
                                    <td><b>Solicita demostración</b></td>
                                    <td>{"Sí" if desea_demo else "No"}</td>
                                </tr>

                                <tr>
                                    <td><b>Fecha sugerida</b></td>
                                    <td>{fecha_demo or "-"}</td>
                                </tr>

                                <tr>
                                    <td><b>Horario</b></td>
                                    <td>{horario or "-"}</td>
                                </tr>

                            </table>

                        </div>

                    </div>

                </div>

                """

            })

            print("✅ Solicitud enviada por correo.")
            
            try:

                resend.Emails.send({

                    "from": "ACAASO <pardoalf@acaaso.com>",

                    "to": correo,

                    "subject": "Hemos recibido su solicitud - ACAASO Teacher Assessment",

                    "html": f"""

                    <div style="font-family:Arial,sans-serif;background:#f4f6f8;padding:20px;">

                        <div style="
                            max-width:650px;
                            margin:auto;
                            background:white;
                            border-radius:10px;
                            overflow:hidden;
                            box-shadow:0 2px 8px rgba(0,0,0,.12);
                        ">

                            <div style="
                                background:#0d47a1;
                                text-align:center;
                                padding:25px;
                            ">

                                <span style="
                                    font-size:40px;
                                    font-weight:900;
                                    color:#29b6f6;
                                    letter-spacing:4px;
                                    font-family:Arial Black,Arial,sans-serif;
                                ">
                                    ACAASO
                                </span>

                                <div style="
                                    color:white;
                                    font-size:15px;
                                    margin-top:8px;
                                ">
                                    Teacher Assessment
                                </div>

                            </div>

                            <div style="padding:35px;">

                                <p style="font-size:16px;">
                                    Estimado(a)
                                    <b>{nombre}</b>,
                                </p>

                                <p>
                                    Muchas gracias por comunicarse con
                                    <b>ACAASO Teacher Assessment</b>.
                                </p>

                                <p>
                                    Hemos recibido correctamente su solicitud de información.
                                </p>

                                <p>
                                    Uno de nuestros especialistas revisará la información enviada y
                                    se comunicará con usted a la brevedad para coordinar una
                                    demostración personalizada de nuestra plataforma.
                                </p>

                                <div style="
                                    background:#eef6ff;
                                    border-left:5px solid #0d47a1;
                                    padding:15px;
                                    margin:25px 0;
                                ">

                                    <b>Institución:</b> {institucion}<br>
                                    <b>Correo:</b> {correo}

                                </div>

                                <p>
                                    Mientras tanto puede visitar nuestro sitio web y conocer
                                    las principales funcionalidades de ACAASO Teacher Assessment.
                                </p>

                                <br>

                                <p>

                                    Cordialmente,

                                    <br><br>

                                    <b>Equipo ACAASO</b>

                                </p>

                            </div>

                            <div style="
                                background:#f1f5f9;
                                text-align:center;
                                padding:15px;
                                font-size:12px;
                                color:#666;
                            ">

                                Este es un correo automático.
                                No es necesario responder este mensaje.

                            </div>

                        </div>

                    </div>

                    """

                })

                print("✅ Correo de confirmación enviado al cliente.")

            except Exception as e:

                print("❌ Error enviando correo al cliente:", e)

        except Exception as e:

            print("❌ Error enviando correo:", e)

        return "", 200

    return render_template(
        "contactos.html",
        ok=request.args.get("ok")
    )

@app.route('/eliminar_intento', methods=['POST'])
def eliminar_intento():

    data = request.get_json()

    alumno_id = data['alumno_id']
    quiz_id = data['quiz_id']
    intento = int(data['intento'])  # 🔥 importante

    conn = get_db_connection()
    cur = conn.cursor()

    try:
        # 🔍 obtener intento_id real
        cur.execute("""
            SELECT id
            FROM intentos_quiz
            WHERE alumno_id = %s
              AND quiz_id = %s
              AND intento_numero = %s
        """, (alumno_id, quiz_id, intento))

        row = cur.fetchone()

        if not row:
            return jsonify({"ok": False, "error": "No encontrado"})

        intento_id = row[0]

        # 🔥 borrar respuestas
        cur.execute("""
            DELETE FROM respuestas_alumno
            WHERE intento_id = %s
        """, (intento_id,))

        # 🔥 borrar intento
        cur.execute("""
            DELETE FROM intentos_quiz
            WHERE id = %s
        """, (intento_id,))

        conn.commit()

        return jsonify({"ok": True})

    except Exception as e:
        print("❌ ERROR eliminar:", str(e))
        return jsonify({"ok": False, "error": str(e)})

    finally:
        cur.close()
        conn.close()


@app.route('/enviar_codigo_quiz', methods=['POST'])
def endpoint_enviar_codigo_quiz():

    data = request.json

    quiz_id = data.get('quiz_id')
    alumnos = data.get('alumnos')  # lista de IDs

    if not quiz_id or not alumnos:
        return jsonify({"error": "Datos incompletos"}), 400

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔹 obtener info del quiz
    cur.execute("""
        SELECT titulo, codigo
        FROM quiz
        WHERE id = %s
    """, (quiz_id,))
    quiz = cur.fetchone()

    if not quiz:
        return jsonify({"error": "Quiz no encontrado"}), 404

    titulo_quiz, codigo_quiz = quiz

    # 🔹 obtener alumnos
    cur.execute(f"""
        SELECT id, nombre, apellido, correo
        FROM alumnos
        WHERE id = ANY(%s)
    """, (alumnos,))

    alumnos_data = cur.fetchall()

    enviados = 0

    for a in alumnos_data:
        alumno_id, nombre, apellido, correo = a
        nombre_completo = f"{nombre} {apellido}"

        cur.execute("""
            INSERT INTO cola_email
            (
                destinatario,
                nombre,
                titulo_quiz,
                codigo_quiz
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s
            )
        """, (
            correo,
            nombre_completo,
            titulo_quiz,
            codigo_quiz
        ))

        enviados += 1
        
    conn.commit()

    cur.close()
    conn.close()    

    return jsonify({
        "ok": True,
        "enviados": enviados,
        "mensaje": f"{enviados} correos agregados a la cola de envío."
    })

    
def enviar_codigo_quiz(correo, nombre_completo, titulo_quiz, codigo_quiz):
    
    #import resend
    
    link_quiz = f"https://acaaso-teacherassesment.onrender.com/quiz/{codigo_quiz}"
    qr_png = generar_qr(link_quiz)
    #banner_url = "https://acaaso-teacherassesment.onrender.com/static/img/banner_enviar_quiz.png"
    #banner_url = "http://localhost:5000/static/img/banner_enviar_quiz.png"
    with open("static/img/banner_enviar3.png", "rb") as f:
        banner_png = f.read() 
    banner_base64 = base64.b64encode(banner_png).decode("utf-8")

    try:
        resend.Emails.send({
            "from": "ACAASO <pardoalf@acaaso.com>",
            "to": correo,
            "subject": "Acceso a evaluación – ACAASO Assessment",
            "html": f"""
                <div style="font-family: Arial, sans-serif; background-color:#f4f6f8; padding:20px;">

                <div style="max-width:600px; margin:auto; background:white; border-radius:8px; overflow:hidden; box-shadow:0 2px 8px rgba(0,0,0,0.1);">

                    <!-- HEADER -->
                    <div style="
                        position:relative;
                        height:120px;
                        overflow:hidden;
                    ">

                        <img src="cid:banner_quiz"
                            alt="ACAASO"
                            style="
                                width:100%;
                                height:120px;
                                object-fit:cover;
                                display:block;
                            ">
                    </div>

                    <div style="
                        text-align:center;
                        padding:18px 20px 12px 20px;
                        background:white;
                    ">

                        <div style="
                            font-size:42px;
                            font-weight:900;
                            color:#0d47a1;
                            letter-spacing:4px;
                            font-family:Arial Black, Arial, sans-serif;
                            line-height:1;
                        ">
                            ACAASO
                        </div>

                        <div style="
                            margin-top:6px;
                            font-size:16px;
                            letter-spacing:3px;
                            color:#666;
                            font-weight:600;
                        ">
                            Teacher Assessment
                        </div>

                    </div>

                    <!-- BODY -->
                    <div style="padding:25px; color:#333;">
                        <p style="font-size:16px;">
                            Hola <b>{nombre_completo}</b>,
                        </p>

                        <p>Te informamos que tienes una evaluación disponible en la plataforma <b>ACAASO Assessment</b>.</p>

                        <p><b>Detalles del quiz:</b></p>
                        <ul>
                            <li><b>Título:</b> {titulo_quiz}</li>
                            <div style="
                                background:#f1f5fb;
                                border:1px solid #d6e4ff;
                                border-radius:8px;
                                padding:18px;
                                margin:20px 0;
                                text-align:center;
                            ">

                                <div style="font-size:14px; color:#666;">
                                    Código de acceso
                                </div>

                                <div style="
                                    font-size:34px;
                                    font-weight:bold;
                                    color:#0d47a1;
                                    letter-spacing:4px;
                                    margin-top:8px;
                                ">
                                    {codigo_quiz}
                                </div>

                            </div>
                            <div style="text-align:center; margin:25px 0;">

                                <a href="{link_quiz}"
                                style="
                                        display:inline-block;
                                        background:#0d47a1;
                                        color:white;
                                        text-decoration:none;
                                        padding:14px 30px;
                                        border-radius:8px;
                                        font-size:16px;
                                        font-weight:bold;
                                ">
                                    Ingresar al Quiz
                                </a>

                            </div>
                            <p style="font-size:13px; color:#777; text-align:center; margin-top:15px;">
                                Si el botón no funciona, copie y pegue el siguiente enlace en su navegador:
                            </p>

                            <p style="text-align:center; word-break:break-all;">
                                <a href="{link_quiz}">{link_quiz}</a>
                            </p>
                        </ul>
                        <div style="text-align:center; margin:30px 0;">
                            <img src="cid:qr_quiz"
                                alt="Código QR"
                                style="width:220px; height:220px;">

                            <p style="margin-top:15px; font-size:15px; color:#555;">
                                Escanee este código QR para acceder directamente a la evaluación.
                            </p>
                        </div>

                        <p><b>Instrucciones:</b></p>
                        <ol>
                            <li>Ingresa a la plataforma.</li>
                            <li>Introduce el código.</li>
                            <li>Resuelve el quiz.</li>
                        </ol>

                        <p>Atentamente,<br>ACAASO Assessment</p>
                    </div>

                    <!-- FOOTER -->
                    <div style="background:#f4f6f8; padding:15px; text-align:center; font-size:12px; color:#777;">
                        © ACAASO Assessment
                    </div>

                </div>

            </div>
            """,
            "attachments": [
                {
                    "filename": "banner_enviar_quiz.png",
                    "content": banner_base64,
                    "content_type": "image/png",
                    "content_id": "banner_quiz"
                },
                {
                    "filename": "qr_quiz.png",
                    "content": base64.b64encode(qr_png).decode("utf-8"),
                    "content_type": "image/png",
                    "content_id": "qr_quiz"
                }
            ]
        })
         

    except Exception as e:
        print("❌ ERROR RESEND:", str(e))
        raise
        
def enviar_codigo_quiz_backup(correo, nombre_completo, titulo_quiz, codigo_quiz):
    
    #import resend
    
    link_quiz = f"https://acaaso-teacherassesment.onrender.com/quiz/{codigo_quiz}"
     
    try:
        resend.Emails.send({
            "from": "ACAASO <pardoalf@acaaso.com>",
            "to": correo,
            "subject": "Acceso a evaluación – ACAASO Assessment",
            "html": f"""
                <p>Hola {nombre_completo},</p>

                <p>Te informamos que tienes una evaluación disponible en la plataforma <b>ACAASO Assessment</b>.</p>

                <p><b>Detalles del quiz:</b></p>
                <ul>
                    <li><b>Título:</b> {titulo_quiz}</li>
                    <li><b>Código de acceso:</b> <span style="font-size:18px;"><b>{codigo_quiz}</b></span></li>
                     
                    <li><b>Acceso directo:</b><br>
                       <a href="{link_quiz}">{link_quiz}</a>
                    </li>
                </ul>

                <p><b>Instrucciones:</b></p>
                <ol>
                    <li>Ingresa a la plataforma.</li>
                    <li>Introduce el código.</li>
                    <li>Resuelve el quiz.</li>
                </ol>

                <p>Atentamente,<br>ACAASO Assessment</p>
            """
        })

        print(f"✅ Código enviado con Resend a {correo}")

    except Exception as e:
        print("❌ ERROR RESEND:", str(e))
        
        
def generar_qr(texto):
    
    qr = qrcode.QRCode(
        version=1,
        box_size=8,
        border=2
    )
    
    qr.add_data(texto)
    qr.make(fit=True)
    
    img = qr.make_image(fill_color="black", back_color="white")
    buffer = BytesIO()
    img.save(buffer, format="PNG")  
    
    buffer.seek(0)

    qr_base64 = base64.b64encode(buffer.getvalue()).decode("utf-8") 
    
    return buffer.getvalue()
    
    
    
    
#=======================================================
#
# PROFESOR
#
#=======================================================
@app.route('/crear_profesor', methods=['POST'])
def crear_profesor():

    if not require_admin():
        return redirect(url_for('login'))

    usuario = request.form['usuario']
    password = request.form['password']
    dni = request.form['dni']
    nombre = request.form['nombre']
    apellido = request.form['apellido']
    correo = request.form['correo']
    cempre = session['cempre']
    
    if not usuario or not password or not dni or not nombre or not apellido:
        return "Campos obligatorios vacíos", 400

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔍 validar usuario único
    cur.execute("""
        SELECT id FROM usuarios WHERE usuario = %s
    """, (usuario,))
    if cur.fetchone():
        return "Usuario ya existe", 400

    # 🔍 validar dni único
    cur.execute("""
        SELECT id FROM usuarios WHERE dni = %s
    """, (dni,))
    if cur.fetchone():
        return "DNI ya existe", 400

    # 🔐 insertar profesor
    cur.execute("""
        INSERT INTO usuarios 
        (usuario, password, rol, dni, nombre, apellido, correo, cempre)
        VALUES (%s, %s, 'profesor', %s, %s, %s, %s, %s)
    """, (usuario, password, dni, nombre, apellido, correo, cempre))

    conn.commit()
    cur.close()
    conn.close()

    return "OK", 200

@app.route('/editar_profesor', methods=['POST'])
def editar_profesor():

    if not require_admin():
        return redirect(url_for('login'))

    profesor_id = request.form['id']
    nombre = request.form['nombre']
    apellido = request.form['apellido']
    correo = request.form['correo']
    dni = request.form['dni']
    cempre = session['cempre']

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔒 validar pertenencia a empresa
    cur.execute("""
        SELECT id FROM usuarios 
        WHERE id = %s AND cempre = %s AND rol = 'profesor'
    """, (profesor_id, cempre))

    if not cur.fetchone():
        return "No autorizado", 403

    # 🔍 validar dni único (excluyendo actual)
    cur.execute("""
        SELECT id FROM usuarios 
        WHERE dni = %s AND id != %s
    """, (dni, profesor_id))

    if cur.fetchone():
        return "DNI duplicado", 400

    cur.execute("""
        UPDATE usuarios
        SET nombre = %s,
            apellido = %s,
            correo = %s,
            dni = %s
        WHERE id = %s AND cempre = %s
    """, (nombre, apellido, correo, dni, profesor_id, cempre))

    conn.commit()
    cur.close()
    conn.close()

    return "OK", 200

@app.route('/eliminar_profesor', methods=['POST'])
def eliminar_profesor():

    if not require_admin():
        return redirect(url_for('login'))

    profesor_id = request.form['id']
    cempre = session['cempre']

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔍 verificar quizzes asociados
    cur.execute("""
        SELECT id FROM quiz 
        WHERE usuario_id = %s AND cempre = %s
    """, (profesor_id, cempre))

    if cur.fetchone():
        return "Profesor tiene quizzes asociados", 400

    # 🔒 eliminar solo si pertenece a empresa
    cur.execute("""
        DELETE FROM usuarios
        WHERE id = %s AND cempre = %s AND rol = 'profesor'
    """, (profesor_id, cempre))

    conn.commit()
    cur.close()
    conn.close()

    return "OK", 200

@app.route('/importar_profesores', methods=['POST'])
def importar_profesores():

    if not require_admin():
        return redirect(url_for('login'))

    archivo = request.files['archivo']
    cempre = session['cempre']

    conn = get_db_connection()
    cur = conn.cursor()

    lineas = archivo.read().decode('utf-8').splitlines()

    insertados = 0
    ignorados = 0

    for linea in lineas:
        try:
            usuario, password, dni, nombre, apellido, correo = linea.split(',')

            # validar duplicados
            cur.execute("""
                SELECT id FROM usuarios 
                WHERE usuario = %s OR dni = %s
            """, (usuario, dni))

            if cur.fetchone():
                ignorados += 1
                continue

            cur.execute("""
                INSERT INTO usuarios
                (usuario, password, rol, dni, nombre, apellido, correo, cempre)
                VALUES (%s, %s, 'profesor', %s, %s, %s, %s, %s)
            """, (usuario, password, dni, nombre, apellido, correo, cempre))

            insertados += 1

        except:
            ignorados += 1

    conn.commit()
    cur.close()
    conn.close()

    return {
        "insertados": insertados,
        "ignorados": ignorados
    }
 
@app.route('/crear_plan', methods=['GET', 'POST'])
def crear_plan():

    if session.get('rol') != 'root':
        return "Acceso denegado", 403

    if request.method == 'POST':

        tipo = request.form['tipo']
        nombre = request.form['nombre']
        precio = request.form['precio']
        admins = request.form['admins']
        profesores = request.form['profesores']
        alumnos = request.form['alumnos']
        quizzes = request.form['quizzes']
        orden = request.form['orden']

        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute("""
           INSERT INTO planes (tipo, nombre, precio, admins, profesores, alumnos, quizzes, orden)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
        """, (tipo, nombre, precio, admins, profesores, alumnos, quizzes,orden))

        conn.commit()
        cur.close()
        conn.close()

        return redirect('/mantenimiento_planes')

    return render_template('crear_plan.html')   
    
@app.route('/mantenimiento_planes')
def mantenimiento_planes():

    if session.get('rol') != 'root':
        return "Acceso denegado", 403

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT id, tipo, nombre, precio, admins, profesores, alumnos, quizzes,orden, activo
        FROM planes
        ORDER BY orden
    """)

    planes = cur.fetchall()

    cur.close()
    conn.close()

    return render_template('mantenimiento_planes.html', planes=planes)

@app.route('/actualizar_plan', methods=['POST'])
def actualizar_plan():

    if session.get('rol') != 'root':
        return {"ok": False}

    data = request.get_json()

    id = data['id']
    campo = data['campo']
    valor = data['valor']

    conn = get_db_connection()
    cur = conn.cursor()

    query = f"UPDATE planes SET {campo} = %s WHERE id = %s"
    cur.execute(query, (valor, id))

    conn.commit()
    cur.close()
    conn.close()

    return {"ok": True}

@app.route('/toggle_plan', methods=['POST'])
def toggle_plan():

    if session.get('rol') != 'root':
        return {"ok": False}

    data = request.get_json()

    id = data['id']
    activo = data['activo']

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("UPDATE planes SET activo = %s WHERE id = %s", (activo, id))

    conn.commit()
    cur.close()
    conn.close()

    return {"ok": True}

@app.route('/eliminar_plan', methods=['POST'])
def eliminar_plan():

    if session.get('rol') != 'root':
        return {"ok": False}

    data = request.get_json()
    id = data['id']

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("DELETE FROM planes WHERE id = %s", (id,))

    conn.commit()
    cur.close()
    conn.close()

    return {"ok": True}

@app.route('/metricas_db')
def metricas_db():

    if session.get('rol') != 'root':
        return "Acceso denegado", 403

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT 
            c.relname AS tabla,
            s.n_live_tup AS filas,
            pg_total_relation_size(c.oid) / 1024 AS size_kb
        FROM pg_class c
        JOIN pg_stat_user_tables s ON c.oid = s.relid
        ORDER BY size_kb DESC;
    """)

    datos = cur.fetchall()

    cur.close()
    conn.close()

    # calcular total
    total = sum([fila[1] for fila in datos])
    # 🔹 tabla más pesada
    tabla_mas_pesada = max(datos, key=lambda x: x[2])

    # 🔹 tabla con más filas
    tabla_mas_filas = max(datos, key=lambda x: x[1])

    # 🔹 promedio tamaño por tabla
    promedio_kb = total / len(datos) if datos else 0
    
    limite_kb = 250000  # ejemplo: 500 MB (ajústalo a tu plan real)
    porcentaje = (total / limite_kb) * 100 if limite_kb > 0 else 0
    if porcentaje < 60:
        estado = "ok"
    elif porcentaje < 85:
        estado = "warning"
    else:
        estado = "danger"

    return render_template(
        'metricas_db.html',
        datos=datos,
        total=total,
        tabla_mas_pesada=tabla_mas_pesada,
        tabla_mas_filas=tabla_mas_filas,
        promedio_kb=promedio_kb,
        porcentaje=porcentaje,
        estado=estado,
        limite_kb=limite_kb
    )
    
def obtener_examen_alumno(alumno_id, quiz_id, intento_id):
    
    conn = get_db_connection()
    cur = conn.cursor()
    
    print("DEBUG intento_id:", intento_id)
    
    cur.execute("""
        SELECT id, intento_numero, quiz_id
        FROM intentos_quiz
        WHERE alumno_id = %s AND quiz_id = %s
    """, (alumno_id, quiz_id))

    print("INTENTOS EN BD:", cur.fetchall())
    # 🔥 convertir intento_numero → intento_id real
    
    cur.execute("""
        SELECT id
        FROM intentos_quiz
        WHERE alumno_id = %s 
        AND quiz_id = %s 
        AND intento_numero = %s
    """, (alumno_id, quiz_id, intento_id))

    row = cur.fetchone()
    intento_id = row[0] if row else None

    print("INTENTO_ID REAL:", intento_id)
    
    # 🔹 obtener respuestas reales del alumno (CLAVE)
    cur.execute("""
        SELECT pregunta_id, opcion_id
        FROM respuestas_alumno
        WHERE alumno_id = %s
        AND intento_id = %s
    """, (alumno_id, intento_id))

    respuestas = cur.fetchall()

    # convertir a diccionario
    map_respuestas = {r[0]: r[1] for r in respuestas}

    # 🔹 preguntas + opciones + respuestas
    cur.execute("""
    SELECT 
        p.id,
        p.texto AS pregunta,
        o.texto AS opcion,
        o.es_correcta,
        o.id AS opcion_id,

        (
            SELECT ra.opcion_id
            FROM respuestas_alumno ra
            WHERE ra.pregunta_id = p.id
            AND ra.alumno_id = %s
            AND ra.intento_id = %s
            AND ra.quiz_id = %s
            ORDER BY ra.id DESC
            LIMIT 1
        ) AS respuesta_alumno

    FROM preguntas p
    JOIN opciones o ON o.pregunta_id = p.id
    WHERE p.quiz_id = %s
    ORDER BY p.id, o.id
    """, (alumno_id, intento_id, quiz_id, quiz_id))

    rows = cur.fetchall()

    detalle = []
    pregunta_actual = None
    correctas = 0
    total = 0

    for row in rows:
        pid, ptexto, otexto, ocorrecta, oid, respuesta_alumno = row

        if not pregunta_actual or pregunta_actual["pregunta"] != ptexto:
            pregunta_actual = {
                "pregunta": ptexto,
                "opciones": [],
                "puntaje": 0
            }
            detalle.append(pregunta_actual)
            total += 1

        marcada = (respuesta_alumno == oid)

        if ocorrecta and marcada:
            pregunta_actual["puntaje"] = 1
            correctas += 1

        pregunta_actual["opciones"].append({
            "texto": otexto,
            "correcta": ocorrecta,
            "marcada": marcada,
            "estado": (
                "correcta" if ocorrecta and marcada else
                "incorrecta" if not ocorrecta and marcada else
                "neutral"
            )
        })

    # 🔹 alumno
    cur.execute("""
        SELECT nombre, apellido, dni, correo
        FROM alumnos
        WHERE id = %s
    """, (alumno_id,))
    alumno = cur.fetchone()

    nombre = f"{alumno[0]} {alumno[1]}"
    dni = alumno[2]
    correo = alumno[3]

    # 🔹 quiz
    cur.execute("""
        SELECT titulo
        FROM quiz
        WHERE id = %s
    """, (quiz_id,))
    titulo = cur.fetchone()[0]

    nota = round((correctas / total) * 20, 2) if total > 0 else 0

    cur.close()
    conn.close()

    return {
        "detalle": detalle,
        "nota": nota,
        "correo": correo,
        "nombre": nombre,
        "dni": dni,
        "titulo": titulo
    }
    
from flask import send_file
from io import BytesIO

@app.route('/descargar_reporte/<int:quiz_id>/<int:alumno_id>')
def descargar_reporte(quiz_id, alumno_id):

    intento = request.args.get('intento', 1)

    # 🔹 obtener examen (YA FUNCIONA)
    examen = obtener_examen_alumno(alumno_id, quiz_id, intento)

    fecha = datetime.now().strftime("%d/%m/%Y %H:%M")

    # 🔥 reutilizar tu función pero SIN enviar correo
    buffer = generar_y_enviar_reporte(
        examen["detalle"],
        examen["nota"],
        examen["correo"],
        examen["nombre"],
        alumno_id,
        examen["titulo"],
        examen["dni"],
        fecha,
        False   # 🔴 clave: no enviar email
    )

    buffer.seek(0)

    return send_file(
        buffer,
        as_attachment=True,
        download_name=f"reporte_{alumno_id}.pdf",
        mimetype='application/pdf'
    )

#=========================================================  
# MEJORAS
#=========================================================   
@app.route('/mejoras')
def mejoras():
    
    if not session.get('usuario'):
        return redirect('/login')  # 🔥 redirige si no está logeado
    
    conn = get_db_connection()
    cur = conn.cursor()

    if session.get('rol') == 'root':
        # 🔥 ROOT solo ve enviados
        cur.execute("""
            SELECT descripcion, usuario, fecha, estado, version, id, tipo
            FROM mejoras
            WHERE estado in ('enviado','revisado','terminado')
            ORDER BY estado asc,fecha DESC
        """)
    else:
        # 🔥 usuarios normales ven todo
        cur.execute("""
            SELECT descripcion, usuario, fecha, estado, version, id, tipo
            FROM mejoras
            ORDER BY 
                CASE 
                    WHEN estado = 'nuevo' THEN 1
                    WHEN estado = 'enviado' THEN 2
                    WHEN estado = 'revisado' THEN 3
                    WHEN estado = 'terminado' THEN 4
                END,
                fecha DESC
        """)
    mejoras = cur.fetchall()

    cur.close()
    conn.close()
    
    try:
        with open("version.txt", "r") as f:
            version_actual = f.read().strip()
    except:
        version_actual = "v?"

    return render_template('mejoras.html', mejoras=mejoras, version_actual=version_actual)

@app.route('/mejoras/nueva')
def nueva_mejora():
    return render_template('nueva_mejora.html')

from datetime import datetime

@app.route('/mejoras/guardar', methods=['POST'])
def guardar_mejora():
    
    print("SESSION:", session)
    print("ROL:", session.get('rol'))
    
    if session.get('rol') not in ['admin', 'profesor', 'root']:
        return "No autorizado", 403
    
    descripcion = request.form['descripcion']
    usuario = session.get('usuario', 'anonimo')
    tipo = request.form.get('tipo', 'M')
    id_mejora = request.form.get('id')
    
    print("ID RECIBIDO:", request.form.get('id'))

    conn = get_db_connection()
    cur = conn.cursor()

    if id_mejora and id_mejora.strip() != "":

        # 🔍 obtener datos actuales
        cur.execute("SELECT descripcion, usuario, estado FROM mejoras WHERE id = %s", (id_mejora,))
        descripcion_actual, usuario_creador, estado_actual = cur.fetchone()
             
        # 🔒 bloqueo total si está terminado
        if estado_actual == 'terminado':
            cur.close()
            conn.close()
            return "No se puede editar un ticket terminado", 403
        
        # 🔥 si estaba enviado → volver a nuevo
        # 🔥 regla: si el usuario edita su ticket enviado → vuelve a nuevo
        if estado_actual == 'enviado' and usuario == usuario_creador:
           nuevo_estado = 'nuevo'
        else:
            nuevo_estado = estado_actual

        # 🔥 SI ES ROOT → agrega respuesta, no reemplaza
        if session.get('rol') == 'root':

            fecha = datetime.now().strftime("%d/%m/%Y %H:%M")

            nueva_descripcion = descripcion_actual + f"""
            <br><br>
            <b>Respuesta de Desarrollo - {fecha}</b><br>
            {descripcion}
            """
            cur.execute("""
                UPDATE mejoras
                SET descripcion = %s
                WHERE id = %s
            """, (nueva_descripcion, id_mejora))

        # 🔥 SI ES USUARIO NORMAL → comportamiento actual
        else:

            # regla enviado → nuevo
            if estado_actual == 'enviado' and usuario == usuario_creador:
                nuevo_estado = 'nuevo'
            else:
                nuevo_estado = estado_actual

            cur.execute("""
                UPDATE mejoras
                SET descripcion = %s,
                    tipo = %s,
                    estado = %s
                WHERE id = %s
            """, (descripcion, tipo, nuevo_estado, id_mejora))






        conn.commit()
        cur.close()
        conn.close()

        return jsonify({"id": id_mejora})

    else:  # 🔥 NUEVO

        cur.execute("""
            INSERT INTO mejoras (descripcion, usuario, fecha, tipo)
            VALUES (%s, %s, %s, %s)
            RETURNING id
        """, (descripcion, usuario, datetime.now(), tipo))

        nuevo_id = cur.fetchone()[0]

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({"id": nuevo_id})

     

@app.route('/mejoras/actualizar', methods=['POST'])
def actualizar_mejora():

    usuario = session.get('usuario')
    rol = session.get('rol')

    if not usuario:
        return "No autorizado", 403

    id_mejora = request.form.get('id')
    estado = request.form.get('estado')
    version = request.form.get('version')

    conn = get_db_connection()
    cur = conn.cursor()

    # Obtener datos actuales
    cur.execute("SELECT usuario, estado FROM mejoras WHERE id = %s", (id_mejora,))
    fila = cur.fetchone()
    
    estados_validos = ['nuevo', 'enviado', 'revisado', 'terminado']

    if estado not in estados_validos:
        return "Estado inválido", 400

    if not fila:
        cur.close()
        conn.close()
        return "No existe", 404

    usuario_creador, estado_actual = fila

    # 🔒 Reglas de seguridad
    puede_editar = False

    if rol == 'root':
        # 🔒 solo puede cambiar desde 'enviado'
        if estado_actual == 'enviado' and estado in ['revisado', 'terminado']:
            puede_editar = True
    elif estado_actual == 'nuevo' and usuario_creador == usuario:
        puede_editar = True

    if not puede_editar:
        cur.close()
        conn.close()
        return "No autorizado", 403

    # Actualizar
    cur.execute("""
        UPDATE mejoras
        SET estado = %s,
            version = %s
        WHERE id = %s
    """, (estado, version, id_mejora))

    conn.commit()
    cur.close()
    conn.close()

    return '', 204

@app.route('/mejoras/eliminar', methods=['POST'])
def eliminar_mejora():

    usuario = session.get('usuario')
    rol = session.get('rol')

    if not usuario:
        return "No autorizado", 403

    id_mejora = request.form.get('id')

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔍 obtener datos
    cur.execute("SELECT usuario, estado FROM mejoras WHERE id = %s", (id_mejora,))
    fila = cur.fetchone()

    if not fila:
        cur.close()
        conn.close()
        return "No existe", 404

    usuario_creador, estado_actual = fila
    
    # 🔒 bloqueo total si está terminado
    if estado_actual == 'terminado':
        cur.close()
        conn.close()
        return "No se puede eliminar un ticket terminado", 403

    # 🔒 reglas (igual que editar)
    puede_eliminar = False

    if rol == 'root':
        puede_eliminar = True
    elif estado_actual in ['nuevo', 'enviado'] and usuario_creador == usuario:
        puede_eliminar = True

    if not puede_eliminar:
        cur.close()
        conn.close()
        return "No autorizado", 403

    # 🗑 eliminar
    cur.execute("DELETE FROM mejoras WHERE id = %s", (id_mejora,))

    conn.commit()
    cur.close()
    conn.close()

    return '', 204

@app.route('/ayuda')
def ayuda():

    usuario_logeado = session.get('usuario')

    plan = None

    # 🔥 SOLO si está logeado consultamos plan
    if usuario_logeado:
        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute("""
            SELECT nombre, precio, profesores, alumnos, quizzes
            FROM planes
            ORDER BY orden
            LIMIT 1
        """)

        plan = cur.fetchone()

        cur.close()
        conn.close()

    return render_template(
        'ayuda.html',
        plan=plan,
        usuario_logeado=usuario_logeado
    )

@app.route('/estado_cola/<int:cola_id>')
def estado_cola(cola_id):

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT estado
        FROM cola_ia
        WHERE id = %s
    """, (cola_id,))

    fila = cur.fetchone()

    cur.close()
    conn.close()

    if not fila:
        return jsonify({"estado": "no_existe"})

    return jsonify({"estado": fila[0]})


@app.route("/eliminar_pregunta/<int:pregunta_id>", methods=["POST"])
def eliminar_pregunta(pregunta_id):

    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute("""
        SELECT COUNT(*)
        FROM respuestas_alumno
        WHERE pregunta_id = %s
    """, (pregunta_id,))

    tiene_respuestas = cur.fetchone()[0] > 0
    
    if tiene_respuestas and not request.json.get("forzar", False):
        cur.close()
        conn.close()
        return {
            "ok": False,
            "requiere_confirmacion": True,
            "mensaje": "Esta pregunta ya tiene respuestas de alumnos. Si la elimina también se eliminarán esas respuestas. ¿Desea continuar?"
        }

    # Borrar respuestas de esa pregunta
    cur.execute("""
        DELETE FROM respuestas_alumno
        WHERE pregunta_id = %s
    """, (pregunta_id,))

    # Borrar opciones
    cur.execute("""
        DELETE FROM opciones
        WHERE pregunta_id = %s
    """, (pregunta_id,))

    # Borrar pregunta
    cur.execute("""
        DELETE FROM preguntas
        WHERE id = %s
    """, (pregunta_id,))

    conn.commit()

    cur.close()
    conn.close()
    
    return {"ok": True}

@app.route('/logros_alumno')
def logros_alumno():

    if "alumno_id" not in session:
        return redirect(url_for("login_alumno"))

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            q.id,
            q.titulo,
            i.nota_final,
            i.fecha_fin,
            i.intento_numero
        FROM intentos_quiz i
        JOIN quiz q
            ON q.id = i.quiz_id
        WHERE i.alumno_id = %s
        AND i.nota_final IS NOT NULL
        ORDER BY i.fecha_fin DESC;
    """, (session["alumno_id"],))

    completados = cur.fetchall()
    
    cur.execute("""
        SELECT
            id,
            titulo
        FROM quiz
        WHERE publico = TRUE
        AND estado = 'A'
        ORDER BY titulo
    """)

    publicos = cur.fetchall()
    

    cur.close()
    conn.close()

    return render_template(
        "logros_alumno.html",
        nombre=session["nombre"],
        completados=completados,
        publicos=publicos
    )

@app.route('/login_alumno', methods=['GET', 'POST'])
def login_alumno():

    if request.method == 'POST':

        dni = request.form['dni'].strip()

        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute("""
            SELECT id, dni, nombre, apellido, correo, cempre
            FROM alumnos
            WHERE dni=%s
        """, (dni,))

        alumno = cur.fetchone()

        cur.close()
        conn.close()

        if alumno:

            session["alumno_id"] = alumno[0]
            session["dni"] = alumno[1]
            session["nombre"] = alumno[2]
            session["apellido"] = alumno[3]
            session["correo"] = alumno[4]
            session["cempre"] = alumno[5]

            return redirect(url_for("logros_alumno"))

        return render_template(
            "login_alumno.html",
            error="DNI no registrado"
        )

    return render_template("login_alumno.html")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)