import time
import json
from app import get_db_connection, client  # ajusta si tu app se llama diferente

def procesar_cola():
    
    conn = get_db_connection()
    cur = conn.cursor() 

    # 🔥 tomar 1 pendiente
    cur.execute("""
        SELECT id, prompt, cantidad, tipo, usuario_id, usuario, cempre, multiple_intentos, 
                enviar_solucionario,titulo
        FROM cola_ia
        WHERE estado = 'pendiente'
        ORDER BY id
        LIMIT 1
    """)

    tarea = cur.fetchone()

    if tarea:
        cola_id, prompt, cantidad, tipo, usuario_id, usuario, cempre, multiple_intentos,enviar_solucionario,titulo = tarea

        print(f"Procesando cola ID: {cola_id}")
        multiple_intentos = True if multiple_intentos is True else False
        enviar_solucionario = True if enviar_solucionario is True else False

        print("DEBUG NORMALIZADO:", multiple_intentos, enviar_solucionario)

        # marcar como procesando
        cur.execute("""
            UPDATE cola_ia
            SET estado = 'procesando'
            WHERE id = %s
        """, (cola_id,))
        conn.commit()

        try:
            # 🔥 LLAMADA REAL A IA
            response = client.chat.completions.create(
                model="gpt-4.1-mini",
                messages=[{"role": "user", "content": prompt}]
            )

            contenido = response.choices[0].message.content

            if contenido.startswith("```"):
                contenido = contenido.replace("```json", "").replace("```", "").strip()

            preguntas = json.loads(contenido)

            # cortar por cantidad
            try:
                cantidad_int = int(cantidad)
                preguntas = preguntas[:cantidad_int]
            except:
                pass
            
            # 🔥 CREAR QUIZ AUTOMÁTICO
            titulo = titulo if titulo else f"Quiz IA #{cola_id}"

            # 🔥 guardar resultado
            cur.execute("""
                INSERT INTO quiz (titulo, cempre, usuario_id, usuario, estado, multiple_intentos, enviar_solucionario, config_json)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
            """, (titulo, cempre, usuario_id, usuario, 'A', multiple_intentos, enviar_solucionario, "{}")
            )
            quiz_id = cur.fetchone()[0]

            orden = 1

            for p in preguntas:

                cur.execute("""
                    INSERT INTO preguntas (quiz_id, texto, tipo, norden, explicacion)
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING id
                """, (
                    quiz_id,
                    p.get("texto"),
                    p.get("tipo"),
                    orden,
                    p.get("explicacion", "")
                ))

                pregunta_id = cur.fetchone()[0]
                orden += 1

                # 🔹 VF
                if p.get("tipo") == "vf":

                    correcta = p.get("correcta")

                    cur.execute("""
                        INSERT INTO opciones (pregunta_id, texto, es_correcta)
                        VALUES (%s, %s, %s)
                    """, (pregunta_id, "Verdadero", correcta == "Verdadero"))

                    cur.execute("""
                        INSERT INTO opciones (pregunta_id, texto, es_correcta)
                        VALUES (%s, %s, %s)
                    """, (pregunta_id, "Falso", correcta == "Falso"))

                # 🔹 MULTIPLE
                else:

                    correcta = p.get("correcta")
                    opciones = p.get("opciones", [])
                    
                    print("---- DEBUG PREGUNTA ----")
                    print("CORRECTA:", correcta)
                    print("OPCIONES:", opciones)
                    for i, op in enumerate(opciones):
                        
                        print("Comparando:", op, "==", correcta)

                        es_correcta = (op.strip().lower() == str(correcta).strip().lower())

                        print("Resultado:", es_correcta)

                        cur.execute("""
                            INSERT INTO opciones (pregunta_id, texto, es_correcta)
                            VALUES (%s, %s, %s)
                        """, (pregunta_id, op, es_correcta))


            # 🔥 marcar cola como terminada
            cur.execute("""
                UPDATE cola_ia
                SET estado = 'terminado',
                    fecha_proceso = NOW()
                WHERE id = %s
            """, (cola_id,))

            conn.commit()

            print(f"✔ Cola {cola_id} terminada")

        except Exception as e:
            import traceback
            print("ERROR IA:")
            traceback.print_exc()

            cur.execute("""
                UPDATE cola_ia
                SET estado = 'error',
                    error = %s
                WHERE id = %s
            """, (str(e), cola_id))

            conn.commit()

    cur.close()
    conn.close()

    # 🔥 esperar antes de revisar otra vez
    time.sleep(5)


if __name__ == "__main__":
    procesar_cola()