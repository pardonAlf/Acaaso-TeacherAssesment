import time
import json
import os
import base64
from app import get_db_connection, client, obtener_config_default

    def procesar_cola():
        
        conn = get_db_connection()
        cur = conn.cursor() 

        # 🔥 tomar 1 pendiente
        cur.execute("""
            SELECT id, prompt, cantidad, tipo, usuario_id, usuario, cempre, multiple_intentos, 
                    enviar_solucionario, publico, titulo, origen, contenido_extra,origen,config_json
            FROM cola_ia
            WHERE estado = 'pendiente'
            ORDER BY id
            LIMIT 1
        """)

        tarea = cur.fetchone()

        if tarea:
            cola_id, prompt, cantidad, tipo, usuario_id, usuario, cempre, multiple_intentos, enviar_solucionario,publico, titulo, origen, contenido_extra,origen, config_json = tarea


            print("COLA:", cola_id)
            print("CONTENIDO_EXTRA BD:", repr(contenido_extra))
            print("🔥 ORIGEN:", origen)
            print(f"Procesando cola ID: {cola_id}")
            multiple_intentos = True if multiple_intentos is True else False
            enviar_solucionario = True if enviar_solucionario is True else False


            # marcar como procesando
            cur.execute("""
                UPDATE cola_ia
                SET estado = 'procesando'
                WHERE id = %s
            """, (cola_id,))
            conn.commit()   
            
            print("📄 PROMPT ENVIADO:")
            print(prompt[:500])  # solo los primeros 500 caracteres
            
            if origen == "archivo":
        
                prompt = f"""
                Basado en el siguiente contenido:

                {contenido_extra}

                Genera un quiz con estas condiciones:

                - Cantidad total de preguntas: {cantidad}
                - Tipo de preguntas: {tipo}

                REGLAS OBLIGATORIAS

                1. Si tipo = "vf":
                - TODAS las preguntas deben ser Verdadero/Falso.

                2. Si tipo = "multiple":
                - TODAS las preguntas deben ser de opción múltiple.
                - Cada pregunta debe tener EXACTAMENTE 5 opciones.
                - Las opciones deben contener texto real, NO letras.
                - El campo "correcta" debe contener únicamente una letra:
                    A, B, C, D o E.

                3. Si tipo = "mixto":
                - Mezclar preguntas Verdadero/Falso y opción múltiple.

                4. Nunca repetir opciones.

                5. Nunca devolver el texto de la respuesta en el campo "correcta".

                6. La explicación debe ser un breve refuerzo de por qué la respuesta es correcta.

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

                No expliques nada.
                Devuelve únicamente JSON válido.
                """

            elif origen == "importar":

                prompt = f"""
                Convierte este examen en preguntas tipo quiz:

                {contenido_extra}

                Devuelve SOLO JSON válido en este formato:

                [
                {{
                    "tipo":"multiple",
                    "texto":"...",
                    "opciones":["...","...","...","...","..."],
                    "correcta":"A",
                    "explicacion":"..."
                }}
                ]

                No expliques nada.
                Solo JSON.
                """
                
            elif origen == "imagen":
                
                print("RUTA:", contenido_extra)
                print("ABS:", os.path.abspath(contenido_extra))
                print("EXISTE:", os.path.exists(contenido_extra))
        
                with open(contenido_extra, "rb") as f:
                    imagen_base64 = base64.b64encode(f.read()).decode("utf-8")

                prompt = [
                    {"type": "text",
                        "text": f"""
                        {prompt}

                        Analiza la imagen y genera un cuestionario.

                        RESPONDE ÚNICAMENTE CON UN ARRAY JSON.

                        NO devuelvas un objeto.
                        NO uses:
                        - quiz
                        - questions
                        - answer
                        - question
                        - number

                        Cada elemento debe tener EXACTAMENTE esta estructura:

                        [
                        {{
                            "tipo":"multiple",
                            "texto":"Pregunta",
                            "opciones":[
                            "Opción A",
                            "Opción B",
                            "Opción C",
                            "Opción D",
                            "Opción E"
                            ],
                            "correcta":"A",
                            "explicacion":"Breve explicación."
                        }}
                        ]

                        REGLAS:

                        - Usa "texto", nunca "question".
                        - Usa "opciones", nunca "options".
                        - Usa "correcta", nunca "answer".
                        - No agregues un objeto "quiz".
                        - No agregues un objeto "questions".
                        - Devuelve SOLO el array JSON.
                        """
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{imagen_base64}"
                        }
                    }
                ]
            try:
                response = client.chat.completions.create(
                    model="gpt-4.1-mini",
                    messages=[
                        {
                        "role": "user", 
                        "content": prompt
                        }
                    ],
                    max_completion_tokens=12000
                )

                contenido = response.choices[0].message.content
                
                if origen == "imagen":
                    try:
                        os.remove(contenido_extra)
                        print("🗑 Imagen temporal eliminada:", contenido_extra)
                    except Exception as e:
                        print("No se pudo eliminar la imagen:", e)
                
                print("========== RESPUESTA IA ==========")
                print(contenido)
                print("==================================")

                if contenido.startswith("```"):
                    contenido = contenido.replace("```json", "").replace("```", "").strip()

                try:
                    preguntas = json.loads(contenido)
                    
                    if isinstance(preguntas, dict):
                        if "quiz" in preguntas and "questions" in preguntas["quiz"]:
                            preguntas = preguntas["quiz"]["questions"]
                            
                    print(type(preguntas))
                    print(type(preguntas[0]))
                    print(preguntas[0])
                    
                    
                except Exception as e:
                    if origen == "imagen":
                        try:
                            os.remove(contenido_extra)
                            print("🗑 Imagen temporal eliminada:", contenido_extra)
                        except Exception:
                            pass

                    cur.execute("""
                        UPDATE cola_ia
                        SET estado = 'error',
                            error = %s
                        WHERE id = %s
                    """, ("JSON inválido", cola_id))

                    conn.commit()
                    return

                # cortar por cantidad
                try:
                    cantidad_int = int(cantidad)
                    preguntas = preguntas[:cantidad_int]
                except:
                    pass
                
                # 🔥 CREAR QUIZ AUTOMÁTICO
                titulo = titulo if titulo else f"Quiz IA #{cola_id}"

                if not config_json:
                    config_json = json.dumps(obtener_config_default())

                print("CONFIG_JSON WORKER:", config_json)
                # 🔥 guardar resultado
                cur.execute("""
                    INSERT INTO quiz (titulo, cempre, usuario_id, usuario, estado, multiple_intentos, enviar_solucionario, publico, config_json)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING id
                """, (titulo, cempre, usuario_id, usuario, 'A', multiple_intentos, enviar_solucionario,publico, config_json)
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
                    print(f"🟢 NUEVA PREGUNTA: {pregunta_id}")
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
            
                        correcta = str(p.get("correcta", "")).strip().upper()
                        opciones = p.get("opciones", [])

                        letras = ["A", "B", "C", "D", "E"]

                        print("---- DEBUG PREGUNTA ----")
                        print("CORRECTA:", correcta)
                        print("OPCIONES:", opciones)

                        for i, op in enumerate(opciones):
                            print(f"➡️ Insertando {len(opciones)} opciones para pregunta {pregunta_id}")
                            letra = letras[i]
                            es_correcta = (letra == correcta)

                            print(f"{letra}) {op} -> {es_correcta}")

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
    print("🚀 Worker iniciado...")

    while True:
        print("🔥 buscando tareas...")
        procesar_cola()
        time.sleep(5)