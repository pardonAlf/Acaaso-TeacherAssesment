import time
from app import enviar_codigo_quiz
from app import get_db_connection

print("Worker Email iniciado...")

while True:

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            id,
            destinatario,
            nombre,
            titulo_quiz,
            codigo_quiz,
            tipo_acceso
        FROM cola_email
        WHERE estado='PENDIENTE'
        OR (estado='ERROR' AND intentos < 3)
        ORDER BY id
        LIMIT 10
    """)

    correos = cur.fetchall()

    for correo in correos:
    
        id_email = correo[0]
        destinatario = correo[1]
        nombre = correo[2]
        titulo = correo[3]
        codigo = correo[4]
        tipo_acceso = correo[5]

        print(f"Enviando a {destinatario}")

        try:

            enviar_codigo_quiz(
                destinatario,
                nombre,
                titulo,
                codigo,
                tipo_acceso
            )

            cur.execute("""
                UPDATE cola_email
                SET estado='ENVIADO',
                    fecha_envio=NOW()
                WHERE id=%s
            """, (id_email,))

        except Exception as e:

            cur.execute("""
                UPDATE cola_email
                SET estado='ERROR',
                    error=%s,
                    intentos=intentos+1
                WHERE id=%s
            """, (
                str(e),
                id_email
            ))

        conn.commit()
        
    cur.close()
    conn.close()

    time.sleep(5)