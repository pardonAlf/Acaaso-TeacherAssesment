from flask import Flask, render_template, request, redirect, url_for, jsonify, session
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import Image
from datetime import datetime
import smtplib
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
from flask import make_response
load_dotenv("llave.env")

from openai import OpenAI
client = OpenAI()

app = Flask(__name__)
app.secret_key = "clave_secreta_super_segura"

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

    cur.close()
    conn.close()

    return render_template(
        'index.html',
        planes_individual=planes_individual,
        planes_empresarial=planes_empresarial
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
                return redirect('/')

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

    if database_url:
        # 👉 PRODUCCIÓN (Render)
        conn = psycopg2.connect(database_url, sslmode='require')
    else:
        # 👉 LOCAL (tu PC)
        conn = psycopg2.connect(
            dbname="BDTeacherAssesment",
            user="postgres",
            password="1234",
            host="127.0.0.1",
            port="5432"
        )

    return conn

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
                z.codigo 
                FROM quiz z
                INNER JOIN usuarios u on u.id=z.usuario_id
                LEFT JOIN preguntas p ON p.quiz_id = z.id
                LEFT JOIN respuestas_alumno r ON r.pregunta_id = p.id
                WHERE z.estado = 'A'
                AND z.cempre= %s
                GROUP BY z.id,u.usuario, z.titulo, z.codigo
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
                z.codigo 
                FROM quiz z
                LEFT JOIN preguntas p ON p.quiz_id = z.id
                LEFT JOIN respuestas_alumno r ON r.pregunta_id = p.id
                WHERE z.estado = 'A'
                AND z.cempre= %s
                AND z.usuario_id = %s
                GROUP BY z.id, z.titulo, z.codigo
                ORDER BY z.id DESC
            """, (session['cempre'], session['user_id']))
        
    quizzes = cur.fetchall()
    cur.close()
    conn.close()

    return render_template('dashboard_profesor.html', quizzes=quizzes)

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


@app.route('/reporte_quiz/<int:quiz_id>')
def reporte_quiz(quiz_id):

    conn = get_db_connection()
    cur = conn.cursor()

    # 🔹 obtener preguntas y opciones
    cur.execute("""
        SELECT p.texto, o.texto, o.es_correcta
        FROM preguntas p
        JOIN opciones o ON o.pregunta_id = p.id
        WHERE p.quiz_id = %s
        ORDER BY p.id
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
    for p_texto, o_texto, correcta in data:
        if p_texto not in preguntas:
            preguntas[p_texto] = []
        preguntas[p_texto].append((o_texto, correcta))

    # 🔹 CONTENIDO
    for i, (pregunta, opciones) in enumerate(preguntas.items(), start=1):
        elements.append(Paragraph(f"{i}. {pregunta}", styles['Heading3']))
        elements.append(Spacer(1, 5))

        tabla_data = []

        for op_texto, correcta in opciones:
            if correcta:
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
        INSERT INTO intentos_quiz (alumno_id, quiz_id, intento_numero)
        VALUES (%s, %s, %s)
        RETURNING id
    """, (alumno_id, quiz_id, nuevo_intento))

    intento_id = cur.fetchone()[0]

    # 🔍 obtener quiz_id desde salon_quiz
    cur.execute("""
        SELECT quiz_id
        FROM salon_quiz
        WHERE id = %s 
    """, (salon_quiz_id,))

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
    
   

    cur.execute("""
        SELECT sq.id, q.titulo, q.codigo
        FROM salon_quiz sq
        JOIN quiz q ON q.id = sq.quiz_id
        WHERE sq.salon_id = %s
        AND q.usuario_id = %s
        ORDER BY sq.id DESC
    """, (salon_id,session['user_id'],))

    data = cur.fetchall()

    cur.close()
    conn.close()

    resultado = [
        {"id": r[0], "titulo": r[1], "codigo": r[2]}
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
        usuario = session.get('usuario')
        multiple_intentos = request.form.get('multiple_intentos') == 'on'
        enviar_solucionario = request.form.get("enviar_solucionario") == "on"
        
        if not usuario:
            return redirect('/login')

        conn = get_db_connection()
        cur = conn.cursor()

        # crear quiz
        cur.execute(
            "INSERT INTO quiz (titulo,cempre,usuario_id, usuario, estado, multiple_intentos,enviar_solucionario) VALUES (%s,%s,%s, %s, %s, %s, %s) RETURNING id",
            (titulo,session['cempre'],session['user_id'], usuario, 'A', multiple_intentos,enviar_solucionario)
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
    prompt_usuario = data.get('prompt')
    cantidad = data.get('cantidad')
    tipo = data.get('tipo')
    print("Cantidad de preguntas: ",cantidad)

    prompt = f"""
    Genera un quiz basado en esto: {prompt_usuario}
    
    Genera un quiz con estas condiciones:
    - Cantidad total de preguntas: {cantidad}
    - Tipo de preguntas: {tipo}

    Devuelve SOLO JSON válido en este formato:
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
        "opciones": ["A","B","C","D","E"],
        "correcta": "A",
        "explicacion": "..."
      }}
    ]

    Genera EXACTAMENTE lo que el usuario pide .
    la explicacion es un breve refuerzo de por que esa opcion es la verdadera
    No expliques nada mas. Solo JSON puro.
     
    """

    response = client.chat.completions.create(
        model="gpt-4.1-mini",
        messages=[
            {"role": "user", "content": prompt}
        ]
    )

    contenido = response.choices[0].message.content
    print("IA RAW:", contenido)

    import json
    preguntas = json.loads(contenido)
        # 🔥 FORZAR cantidad exacta
    try:
        cantidad_int = int(cantidad)
        preguntas = preguntas[:cantidad_int]
    except:
        pass    

    return jsonify(preguntas)

@app.route('/procesar_examen', methods=['POST'])
def procesar_examen():

    archivo = request.files.get('archivo')

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

    response = client.chat.completions.create(
        model="gpt-4.1-mini",
        messages=[
            {"role": "user", "content": prompt}
        ]
    )

    texto = response.choices[0].message.content

    import json
    # 🔥 limpiar posible basura
    texto = texto.strip()

    # si viene con ```json ... ```
    if texto.startswith("```"):
        texto = texto.replace("```json", "").replace("```", "").strip()

    # 🔥 intentar parsear seguro
    try:
        preguntas = json.loads(texto)
    except Exception as e:
        print("ERROR IA:", texto)
        return jsonify({
            "error": "La IA no devolvió JSON válido",
            "raw": texto
        }), 500

    return jsonify(preguntas)

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

    response = client.chat.completions.create(
        model="gpt-4.1-mini",
        messages=[{"role": "user", "content": prompt}]
    )

    texto = response.choices[0].message.content.strip()

    if texto.startswith("```"):
        texto = texto.replace("```json", "").replace("```", "").strip()

    import json
    preguntas = json.loads(texto)

    return jsonify(preguntas)

@app.route('/editar_quiz/<int:quiz_id>', methods=['GET', 'POST'])
def editar_quiz(quiz_id):

    conn = get_db_connection()
    cur = conn.cursor()

    if request.method == 'POST':

        titulo = request.form['titulo']
        multiple_intentos = request.form.get("multiple_intentos") == "on"
        enviar_solucionario = bool(request.form.get("enviar_solucionario"))

        # actualizar título
        cur.execute(
            "UPDATE quiz SET titulo=%s, multiple_intentos=%s, enviar_solucionario=%s WHERE id=%s",
            (titulo, multiple_intentos, enviar_solucionario, quiz_id)
        )

        # 🔥 borrar todo
        cur.execute("DELETE FROM opciones WHERE pregunta_id IN (SELECT id FROM preguntas WHERE quiz_id=%s)", (quiz_id,))
        cur.execute("DELETE FROM preguntas WHERE quiz_id=%s", (quiz_id,))

        # 🔥 volver a insertar (igual que crear_quiz)
        for key, texto in request.form.items():
            if key.startswith("pregunta_"):

                if not texto.strip():
                    continue

                num = key.split("_")[1]
                tipo = request.form.get(f"tipo_{num}")

                cur.execute(
                    "INSERT INTO preguntas (quiz_id, texto, tipo) VALUES (%s, %s, %s) RETURNING id",
                    (quiz_id, texto, tipo)
                )
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

                    for i in range(1, 6):
                        opcion = request.form.get(f"opcion_{num}_{i}")
                        if opcion:
                            es_correcta = (opcion == correcta) or (str(i) == correcta)

                            cur.execute(
                                "INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES (%s, %s, %s)",
                                (pregunta_id, opcion, es_correcta)
                            )

        conn.commit()
        cur.close()
        conn.close()

        return redirect(url_for('dashboard_profesor'))

    # 🔹 GET (lo que ya tenías)
    cur.execute("""
    SELECT titulo, multiple_intentos, enviar_solucionario
        FROM quiz
        WHERE id=%s
    """, (quiz_id,))

    row = cur.fetchone()

    quiz = {
        "titulo": row[0],
        "multiple_intentos": row[1],
        "enviar_solucionario": row[2]
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
            SELECT texto, es_correcta
            FROM opciones
            WHERE pregunta_id=%s
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


@app.route('/resolver_quiz/<int:quiz_id>/<int:alumno_id>')
def resolver_quiz(quiz_id, alumno_id):
    
    salon_quiz_id = None
 

    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute("""
        SELECT COALESCE(MAX(intento_numero), 0)
        FROM intentos_quiz
        WHERE alumno_id = %s AND quiz_id = %s
    """, (alumno_id, quiz_id))

    ultimo = cur.fetchone()[0]
    nuevo_intento = ultimo + 1

    cur.execute("""
        INSERT INTO intentos_quiz (alumno_id, quiz_id, intento_numero)
        VALUES (%s, %s, %s)
        RETURNING id
    """, (alumno_id, quiz_id, nuevo_intento))

    intento_id = cur.fetchone()[0]

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

    return render_template(
        'resolver_quiz.html',
        preguntas=data,
        quiz_id=quiz_id,
        alumno_id=alumno_id,
        salon_quiz_id = salon_quiz_id,  # 🔥 SIEMPRE DEFINIDO
        intento_id=intento_id
    )
    
@app.route('/guardar_respuestas', methods=['POST'])
def guardar_respuestas():

    data = request.get_json()

    alumno_id = data['alumno_id']
    respuestas = data['respuestas']
    salon_quiz_id = data.get('salon_quiz_id')

    conn = get_db_connection()
    cur = conn.cursor()

    correctas = 0
    total = len(respuestas)
    detalle = []
    valor_por_pregunta = 20 / total

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

        primera_pregunta = list(respuestas.keys())[0]

        cur.execute("""
            SELECT quiz_id
            FROM preguntas
            WHERE id = %s
        """, (int(primera_pregunta),))

        row = cur.fetchone()
        quiz_id = row[0] if row else None
        
    # 🔥 crear intento SIEMPRE en backend
    cur.execute("""
    SELECT COALESCE(MAX(intento_numero), 0) + 1
        FROM intentos_quiz
        WHERE quiz_id = %s AND alumno_id = %s
    """, (quiz_id, alumno_id))

    numero = cur.fetchone()[0]
    
    cur.execute("""
        INSERT INTO intentos_quiz (quiz_id, alumno_id, intento_numero)
        VALUES (%s, %s, %s)
        RETURNING id
    """, (quiz_id, alumno_id, numero))

    intento_id = cur.fetchone()[0]

    # 🔥 fallback de seguridad (NO rompe nada)
    if not quiz_id:
        print("⚠️ quiz_id no vino, usando pregunta")
        
        cur.execute("""
            SELECT quiz_id
            FROM preguntas
            WHERE id = %s
        """, (list(respuestas.keys())[0],))
        
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
            (alumno_id, pregunta_id, opcion_id, salon_quiz_id, quiz_id, intento_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (alumno_id, pregunta_id, opcion_id, salon_quiz_id, quiz_id, intento_id))
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
        SET nota_final = %s,
            fecha_fin = NOW()
        WHERE id = %s
    """, (nota, intento_id))
    
    cur.execute("""
        SELECT enviar_solucionario
        FROM quiz
        WHERE id = %s
    """, (quiz_id,))
    
    print("DEBUG quiz_id:", quiz_id)
    

    row = cur.fetchone()
    enviar_solucionario = row[0] if row else False
    
    print("DEBUG enviar_solucionario:", enviar_solucionario)

    cur.close()
    conn.close()

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
    
@app.route('/exportar_quiz_excel/<int:quiz_id>')
def exportar_quiz_excel(quiz_id):

    conn = get_db_connection()
    cur = conn.cursor()
    
    # 🔹 título
    cur.execute("SELECT titulo FROM quiz WHERE id = %s", (quiz_id,))
    titulo_quiz = cur.fetchone()[0]

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

            if op["correcta"]:
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
        download_name=f"quiz_{quiz_id}.xlsx",
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
        nombres = [fila["alumno"] for fila in tabla]
        
        # ===============================
        # 📊 TOP 5 PREGUNTAS MÁS ACERTADAS
        # ===============================
         
        cur.execute("""
            SELECT 
                p.texto,
                ROUND(
                    (COUNT(CASE WHEN o.es_correcta THEN 1 END)::decimal 
                    / NULLIF(COUNT(*),0)) * 100
                ,1) as porcentaje
            FROM respuestas_alumno ra
            JOIN preguntas p ON p.id = ra.pregunta_id
            JOIN opciones o ON o.id = ra.opcion_id
            JOIN salon_quiz sq ON sq.quiz_id = ra.quiz_id
            WHERE sq.salon_id = %s
            GROUP BY p.id, p.texto
            ORDER BY porcentaje DESC
            LIMIT 5
        """, (salon_id,))

        preguntas_top = [
            {
                "pregunta": (row[0] or "Pregunta")[:40],  # corto para gráfico
                "porcentaje": float(row[1])
            }
            for row in cur.fetchall()
        ]

    cur.close()
    conn.close()

    return render_template(
        "resultados_salon.html",
        salones=salones,
        quizzes=quizzes,
        resultado=tabla,
        salon_seleccionado=salon_id or "",
        notas=notas,
        nombres=nombres,
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
    Excelente = sum(1 for r in resultados if r[5] >=18)
    MuyBien = sum(1 for r in resultados if r[5] <18 and r[5]>=16)
    Bien = sum(1 for r in resultados if r[5] <16 and r[5]>=13)
    Regular =sum(1 for r in resultados if r[5] <13 and r[5]>=11)
    Mal =sum(1 for r in resultados if r[5] <11)

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
        nota = r[5]
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
            COUNT(*) AS errores
        FROM respuestas_alumno r
        JOIN preguntas p ON r.pregunta_id = p.id
        JOIN opciones o ON r.opcion_id = o.id
        WHERE o.es_correcta = false
        AND p.quiz_id = %s
        GROUP BY p.id, p.texto
        ORDER BY errores DESC
        LIMIT 10;
    """, (quiz_id,))

    preguntas = cur.fetchall()
     
    preguntas_labels = [f"P{p[0]}" for p in preguntas]
    preguntas_tooltips = [p[1] for p in preguntas]  # 👈 texto real
    preguntas_fallos = [p[2] for p in preguntas]
    
    cur.execute("SELECT titulo FROM quiz WHERE id = %s", (quiz_id,))
    resultado = cur.fetchone()

    if resultado is not None:
        titulo_quiz = resultado[0]
    else:
        titulo_quiz = "Quiz no encontrado"
        
    cur.execute("""
    SELECT alumno_id, COUNT(*) as total_intentos
        FROM intentos_quiz
        WHERE quiz_id = %s
        GROUP BY alumno_id
    """, (quiz_id,))

    intentos_por_alumno = cur.fetchall()

    intentos_dict = {row[0]: row[1] for row in intentos_por_alumno}

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

        preguntas_labels=preguntas_labels,
        preguntas_fallos=preguntas_fallos,
        preguntas_tooltips=preguntas_tooltips,
        intentos=intentos_dict,
        titulo_quiz=titulo_quiz
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
    
    from io import BytesIO
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image
    from reportlab.lib.styles import getSampleStyleSheet
    from reportlab.lib import colors
    from reportlab.lib.pagesizes import letter
    import smtplib
    from email.message import EmailMessage
    print("🔥 entrando a generar_y_enviar_reporte")
    buffer = BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter)
    styles = getSampleStyleSheet()
    elements = []

    logo = Image("static/img/logo.png", width=80, height=50)

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

    doc.build(elements)
    buffer.seek(0)

    msg = EmailMessage()
    msg['Subject'] = 'Resultado de tu Quiz'
    msg['From'] = "ACAASO <pardoalf@gmail.com>"
    msg['To'] = correo

    msg.set_content(f"""
    Hola {nombre_completo},

    Tu nota final es: {nota}
    """)
    
    print("VALOR enviar_solucionario:", enviar_solucionario)
    if enviar_solucionario:
        msg.add_attachment(buffer.getvalue(),
                        maintype='application',
                        subtype='pdf',
                        filename=f"reporte_{alumno_id}.pdf")

    if enviar_solucionario:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
            smtp.login(EMAIL_REMITENTE, EMAIL_PASSWORD)
            smtp.send_message(msg)

        print("✅ correo enviado en background")
    else:
        print("ℹ️ solucionario no enviado (configuración del quiz)")
        
    return buffer

from flask import request, jsonify


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

        enviar_codigo_quiz(
            correo,
            nombre_completo,
            titulo_quiz,
            codigo_quiz
        )

        enviados += 1

    return jsonify({
        "ok": True,
        "enviados": enviados
    })    
    
def enviar_codigo_quiz(correo, nombre_completo, titulo_quiz, codigo_quiz):
    
    import smtplib
    from email.message import EmailMessage

    msg = EmailMessage()
    msg['Subject'] = 'Acceso a evaluación – ACAASO Assessment'
    msg['From'] = "ACAASO <pardoalf@gmail.com>"
    msg['To'] = correo

    msg.set_content(f"""
Hola {nombre_completo},

Te informamos que tienes una evaluación disponible en la plataforma ACAASO Assessment.

Detalles del quiz:
- Título: {titulo_quiz}
- Código de acceso: {codigo_quiz}

Instrucciones:
1. Ingresa a la plataforma.
2. Introduce el código.
3. Resuelve el quiz.

Atentamente,
ACAASO Assessment
""")

    with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
        smtp.login(EMAIL_REMITENTE, EMAIL_PASSWORD)
        smtp.send_message(msg)

    print(f"✅ Código enviado a {correo}")
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
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT descripcion, usuario, fecha, estado, version, id
        FROM mejoras
        ORDER BY 
            CASE 
                WHEN estado = 'nuevo' THEN 1
                WHEN estado = 'revisado' THEN 2
                WHEN estado = 'realizado' THEN 3
            END,
            fecha DESC
    """) 
    mejoras = cur.fetchall()

    cur.close()
    conn.close()

    return render_template('mejoras.html', mejoras=mejoras)

@app.route('/mejoras/nueva')
def nueva_mejora():
    return render_template('nueva_mejora.html')

from datetime import datetime

@app.route('/mejoras/guardar', methods=['POST'])
def guardar_mejora():
    
    if session.get('rol') not in ['admin', 'profesor', 'root']:
        return "No autorizado", 403
    
    descripcion = request.form['descripcion']
    usuario = session.get('usuario', 'anonimo')

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        INSERT INTO mejoras (descripcion, usuario, fecha)
        VALUES (%s, %s, %s)
    """, (descripcion, usuario, datetime.now()))

    conn.commit()
    cur.close()
    conn.close()

    return redirect('/mejoras?ok=1')

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

    if not fila:
        cur.close()
        conn.close()
        return "No existe", 404

    usuario_creador, estado_actual = fila

    # 🔒 Reglas de seguridad
    puede_editar = False

    if rol == 'root':
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

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)