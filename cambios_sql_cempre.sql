select * from quiz
CREATE TABLE IF NOT EXISTS empresa (
    cempre SERIAL PRIMARY KEY,
    dempre VARCHAR(100),
    fcreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    licencia BOOLEAN DEFAULT TRUE,
    estado BOOLEAN DEFAULT TRUE
);
INSERT INTO empresa (dempre)
VALUES ('TEST');

ALTER TABLE usuarios
ADD COLUMN IF NOT EXISTS cempre INTEGER;

UPDATE usuarios
SET cempre = 1
WHERE cempre IS NULL;

ALTER TABLE usuarios
ADD CONSTRAINT fk_usuarios_empresa
FOREIGN KEY (cempre) REFERENCES empresa(cempre);

ALTER TABLE quiz
ADD COLUMN IF NOT EXISTS cempre INTEGER;

UPDATE quiz
SET cempre = 1
WHERE cempre IS NULL;

ALTER TABLE quiz
ADD CONSTRAINT fk_quiz_empresa
FOREIGN KEY (cempre) REFERENCES empresa(cempre);

ALTER TABLE quiz
ADD COLUMN IF NOT EXISTS usuario_id INTEGER;

UPDATE quiz
SET usuario_id = 2
WHERE usuario_id IS NULL;

ALTER TABLE salon_quiz
ADD COLUMN IF NOT EXISTS cempre INTEGER;

UPDATE salon_quiz
SET cempre = 1
WHERE cempre IS NULL;

ALTER TABLE salon_quiz
ADD CONSTRAINT fk_salon_empresa
FOREIGN KEY (cempre) REFERENCES empresa(cempre);

ALTER TABLE alumnos
ADD COLUMN IF NOT EXISTS cempre INTEGER;

UPDATE alumnos
SET cempre = 1
WHERE cempre IS NULL;

ALTER TABLE alumnos
ADD CONSTRAINT fk_alumnos_empresa
FOREIGN KEY (cempre) REFERENCES empresa(cempre);

SELECT id, titulo, cempre, usuario_id FROM quiz;
SELECT id, usuario, cempre FROM usuarios;
SELECT * FROM salon_quiz;