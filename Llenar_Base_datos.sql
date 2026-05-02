--#Creamos tabla usuarios
CREATE TABLE if not exists usuarios (
    id SERIAL PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    rol VARCHAR(20) NOT NULL
);

INSERT INTO usuarios (usuario, password, rol)
VALUES ('admin', '1234', 'admin');

select * from usuarios

--#Creamos tabla alumnos

CREATE TABLE alumnos (
    id SERIAL PRIMARY KEY,
    dni VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100),
    apellido VARCHAR(100)
);


CREATE TABLE quiz (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(100),
    codigo VARCHAR(50)
);

ALTER TABLE quiz 
ADD COLUMN universidad_id INTEGER,
ADD COLUMN curso_id INTEGER,
ADD COLUMN salon VARCHAR(50),
ADD COLUMN fcreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN fmodificacion TIMESTAMP,
ADD COLUMN usuario VARCHAR(50),
ADD COLUMN estado CHAR(1) DEFAULT 'A';

select * from quiz

drop table preguntas
CREATE TABLE preguntas (
    id SERIAL PRIMARY KEY,
    quiz_id INT,
    texto TEXT,
    tipo VARCHAR(20), -- 'vf' o 'multiple'
	explicacion TEXT
);
 

CREATE TABLE opciones (
    id SERIAL PRIMARY KEY,
    pregunta_id INT,
    texto TEXT,
    es_correcta BOOLEAN
);

CREATE TABLE respuestas_alumno (
    id SERIAL PRIMARY KEY,
    alumno_id INT,
    pregunta_id INT,
    opcion_id INT
);

select * from preguntas
select * from opciones
select * from quiz
select * from respuestas_alumno

INSERT INTO quiz (titulo, codigo) VALUES ('Quiz Demo', 'ABC123');

INSERT INTO preguntas (quiz_id, texto, tipo)
VALUES (1, '¿Python es un lenguaje?', 'vf');

INSERT INTO opciones (pregunta_id, texto, es_correcta)
VALUES 
(1, 'Verdadero', true),
(1, 'Falso', false);

select * from preguntas
--delete from preguntas
where quiz_id=4

--insertamos el quiz 1
INSERT INTO preguntas (quiz_id, texto, tipo, explicacion) VALUES
(4,'El software libre siempre es gratuito.','vf','Puede ser de pago, lo importante es la libertad de uso.'),
(4,'El software libre permite modificar el código.','vf','Una de sus libertades es poder estudiar y modificar el código.'),
(4,'Open source y software libre son exactamente lo mismo.','vf','Comparten características, pero difieren en filosofía.'),
(4,'La GPL permite cerrar el código modificado.','vf','La GPL obliga a mantener el código abierto (copyleft).'),
(4,'Linux es un ejemplo de software libre.','vf','Su código es abierto y modificable.'),
(4,'Red Hat vende licencias del software.','vf','Vende soporte y servicios, no el software en sí.'),
(4,'El kernel es el núcleo del sistema operativo.','vf','Controla el hardware y recursos del sistema.'),
(4,'Open source se enfoca en la ética principalmente.','vf','Se enfoca más en desarrollo y colaboración.'),
(4,'Software libre garantiza 4 libertades.','vf','Uso, estudio, modificación y distribución.'),
(4,'Android usa Linux.','vf','Está basado en el kernel Linux.'),
(4,'MIT es una licencia restrictiva.','vf','Es permisiva, permite casi cualquier uso.'),
(4,'BSD permite uso comercial.','vf','Es una licencia permisiva.'),
(4,'Open source obliga a compartir cambios.','vf','Depende de la licencia, no siempre es obligatorio.'),
(4,'GPL es copyleft.','vf','Obliga a mantener el software libre.'),
(4,'Red Hat contribuye a la comunidad.','vf','Participa activamente en proyectos open source.'),
(4,'Linux nació en 1980.','vf','Fue creado en 1991.'),
(4,'FSF promueve software propietario.','vf','Promueve el software libre.'),
(4,'GNU es un sistema operativo libre.','vf','Es un proyecto para crear un sistema libre.'),
(4,'Open source siempre es gratis.','vf','Puede tener costos asociados.'),
(4,'El software libre puede venderse.','vf','Se puede cobrar por distribución o servicios.'),

(4,'¿Quién creó el movimiento de software libre?','multiple','Fue el fundador del movimiento y del proyecto GNU.'),
(4,'¿Qué es el kernel?','multiple','Es la parte central del sistema operativo.'),
(4,'¿Linux es?','multiple','Linux es el núcleo, no el sistema completo.'),
(4,'¿Qué licencia usa copyleft?','multiple','Obliga a mantener el software libre.'),
(4,'¿Red Hat gana dinero con?','multiple','Su modelo es basado en servicios.'),
(4,'Open source se enfoca en:','multiple','Prioriza el desarrollo y acceso al código.'),
(4,'Software libre garantiza:','multiple','Son las 4 libertades fundamentales.'),
(4,'FSF significa:','multiple','Organización que promueve el software libre.'),
(4,'GNU fue creado en:','multiple','Iniciado por Stallman.'),
(4,'Linux nació en:','multiple','Creado por Linus Torvalds.'),
(4,'¿Qué empresa compró Red Hat?','multiple','Demuestra el valor comercial del open source.'),
(4,'¿Qué tipo de licencia es MIT?','multiple','Permite uso libre incluso comercial.'),
(4,'¿Qué hace Red Hat?','multiple','No vende software, vende servicios.'),
(4,'¿Qué es OpenShift?','multiple','Herramienta de Red Hat.'),
(4,'¿Qué es Ansible?','multiple','Permite automatizar tareas.'),
(4,'¿Qué es la GPL?','multiple','Protege las libertades del usuario.'),
(4,'¿Qué significa copyleft?','multiple','Obliga a compartir cambios.'),
(4,'¿Qué promueve el software libre?','multiple','Enfocado en derechos del usuario.'),
(4,'¿Qué promueve open source?','multiple','Enfocado en desarrollo.'),
(4,'¿Qué demuestra Red Hat?','multiple','Modelo de negocio basado en servicios.');

select * from opciones

INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES
(7,'Verdadero',FALSE),(7,'Falso',TRUE),
(8,'Verdadero',TRUE),(8,'Falso',FALSE),
(9,'Verdadero',FALSE),(9,'Falso',TRUE),
(10,'Verdadero',FALSE),(10,'Falso',TRUE),
(11,'Verdadero',TRUE),(11,'Falso',FALSE),
(12,'Verdadero',FALSE),(12,'Falso',TRUE),
(13,'Verdadero',TRUE),(13,'Falso',FALSE),
(14,'Verdadero',FALSE),(14,'Falso',TRUE),
(15,'Verdadero',TRUE),(15,'Falso',FALSE),
(16,'Verdadero',TRUE),(16,'Falso',FALSE),
(17,'Verdadero',FALSE),(17,'Falso',TRUE),
(18,'Verdadero',TRUE),(18,'Falso',FALSE),
(19,'Verdadero',FALSE),(19,'Falso',TRUE),
(20,'Verdadero',TRUE),(20,'Falso',FALSE),
(21,'Verdadero',TRUE),(21,'Falso',FALSE),
(22,'Verdadero',FALSE),(22,'Falso',TRUE),
(23,'Verdadero',FALSE),(23,'Falso',TRUE),
(24,'Verdadero',TRUE),(24,'Falso',FALSE),
(25,'Verdadero',FALSE),(25,'Falso',TRUE),
(26,'Verdadero',TRUE),(26,'Falso',FALSE);

INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES
(27,'Bill Gates',FALSE),(27,'Richard Stallman',TRUE),(27,'Linus Torvalds',FALSE),(27,'Steve Jobs',FALSE),
(28,'Programa',FALSE),(28,'Núcleo del sistema',TRUE),(28,'App',FALSE),(28,'Navegador',FALSE),
(29,'Navegador',FALSE),(29,'Lenguaje',FALSE),(29,'Kernel',TRUE),(29,'Base de datos',FALSE),
(30,'MIT',FALSE),(30,'BSD',FALSE),(30,'GPL',TRUE),(30,'Apache',FALSE),
(31,'Vender código',FALSE),(31,'Soporte',TRUE),(31,'Juegos',FALSE),(31,'Hardware',FALSE),
(32,'Ética',FALSE),(32,'Negocio',FALSE),(32,'Código',TRUE),(32,'Diseño',FALSE),
(33,'Precio bajo',FALSE),(33,'Libertades',TRUE),(33,'Seguridad',FALSE),(33,'Velocidad',FALSE),
(34,'Free Software Foundation',TRUE),(34,'Fast System File',FALSE),(34,'Free System Format',FALSE),(34,'File System Free',FALSE),
(35,'1983',TRUE),(35,'1991',FALSE),(35,'2000',FALSE),(35,'1970',FALSE),
(36,'1991',TRUE),(36,'2000',FALSE),(36,'1980',FALSE),(36,'1995',FALSE),
(37,'Google',FALSE),(37,'Microsoft',FALSE),(37,'IBM',TRUE),(37,'Amazon',FALSE),
(38,'Restrictiva',FALSE),(38,'Permisiva',TRUE),(38,'Comercial',FALSE),(38,'Cerrada',FALSE),
(39,'Vende software',FALSE),(39,'Ofrece soporte',TRUE),(39,'Fabrica hardware',FALSE),(39,'Diseña juegos',FALSE),
(40,'Navegador',FALSE),(40,'Plataforma en la nube',TRUE),(40,'Sistema operativo',FALSE),(40,'Antivirus',FALSE),
(41,'Base de datos',FALSE),(41,'Automatización',TRUE),(41,'Navegador',FALSE),(41,'Editor',FALSE),
(42,'Lenguaje',FALSE),(42,'Licencia libre',TRUE),(42,'Sistema operativo',FALSE),(42,'App',FALSE),
(43,'Copiar libre',FALSE),(43,'Mantener libertad',TRUE),(43,'Código cerrado',FALSE),(43,'Licencia privada',FALSE),
(44,'Precio',FALSE),(44,'Libertad',TRUE),(44,'Publicidad',FALSE),(44,'Diseño',FALSE),
(45,'Colaboración',TRUE),(45,'Privacidad',FALSE),(45,'Venta',FALSE),(45,'Control',FALSE),
(46,'Software gratis',FALSE),(46,'Que open source es rentable',TRUE),(46,'Que Linux es malo',FALSE),(46,'Que no sirve',FALSE);


select * from respuestas_alumno
delete from  respuestas_alumno
select * from alumnos
select * 
--delete 
from preguntas 
where quiz_id=5

INSERT INTO preguntas (quiz_id, texto, tipo, explicacion) VALUES
(5,'Goku fue enviado a la Tierra cuando era un bebé.','vf','Fue enviado por su padre Bardock para sobrevivir.'),
(5,'Vegeta es el príncipe de los Saiyajin.','vf','Es el príncipe de la raza Saiyajin.'),
(5,'Gohan es hijo de Vegeta.','vf','Gohan es hijo de Goku.'),
(5,'Freezer destruyó el planeta Vegeta.','vf','Freezer destruyó el planeta por miedo a los Saiyajin.'),
(5,'Piccolo es originalmente un Namekiano.','vf','Pertenece a la raza Namekiana.'),
(5,'Goku puede transformarse en Super Saiyajin.','vf','Es una de sus transformaciones principales.'),
(5,'Krillin es un Saiyajin.','vf','Krillin es humano.'),
(5,'Cell fue creado por el Dr. Gero.','vf','Fue creado con células de los guerreros más fuertes.'),
(5,'Majin Buu tiene múltiples formas.','vf','Tiene varias transformaciones a lo largo de la saga.'),
(5,'Trunks viene del futuro.','vf','Viaja al pasado para advertir sobre los androides.');

INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES

(48,'Verdadero',TRUE),(48,'Falso',FALSE),
(49,'Verdadero',TRUE),(49,'Falso',FALSE),
(50,'Verdadero',FALSE),(50,'Falso',TRUE),
(51,'Verdadero',TRUE),(51,'Falso',FALSE),
(52,'Verdadero',TRUE),(52,'Falso',FALSE),
(53,'Verdadero',TRUE),(53,'Falso',FALSE),
(54,'Verdadero',FALSE),(54,'Falso',TRUE),
(55,'Verdadero',TRUE),(55,'Falso',FALSE),
(56,'Verdadero',TRUE),(56,'Falso',FALSE),
(57,'Verdadero',TRUE),(57,'Falso',FALSE);

select * from quiz
update quiz
set titulo='Dragon Ball'
where id=5
select * from opciones
--update opciones set es_correcta=false
where pregunta_id in (48,49) and id=138

select * from opciones
delete from opciones
where pregunta_id>=48
select * from quiz
INSERT INTO quiz (titulo)
VALUES ('Sabes de Dragon Ball Z experto');

INSERT INTO preguntas (quiz_id, texto, tipo, explicacion) VALUES
(6,'Goku es un Saiyajin.','vf','Pertenece a la raza Saiyajin enviada a la Tierra.'),
(6,'Vegeta siempre fue más fuerte que Goku.','vf','Goku lo supera en varias ocasiones.'),
(6,'Freezer puede sobrevivir en el espacio.','vf','Se ha demostrado que puede hacerlo.'),
(6,'Gohan derrotó a Cell.','vf','Lo derrotó en su forma Super Saiyajin 2.'),
(6,'Piccolo es un villano en toda la serie.','vf','Luego se convierte en aliado.'),
(6,'Trunks mató a Freezer.','vf','Lo derrota cuando llega del futuro.'),
(6,'Krillin es el humano más fuerte.','vf','Es considerado uno de los humanos más fuertes.'),
(6,'Majin Buu es invencible.','vf','Fue derrotado por la Genkidama.'),
(6,'Goku aprendió el Kamehameha solo.','vf','Lo aprendió observando a Roshi.'),
(6,'Vegeta se sacrifica contra Majin Buu.','vf','Se sacrifica en una de las escenas más épicas.');

select * from preguntas
where quiz_id=6

INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES

(58,'Verdadero',TRUE),(58,'Falso',FALSE),
(59,'Verdadero',FALSE),(59,'Falso',TRUE),
(60,'Verdadero',TRUE),(60,'Falso',FALSE),
(61,'Verdadero',TRUE),(61,'Falso',FALSE),
(62,'Verdadero',FALSE),(62,'Falso',TRUE),
(63,'Verdadero',TRUE),(63,'Falso',FALSE),
(64,'Verdadero',TRUE),(64,'Falso',FALSE),
(65,'Verdadero',FALSE),(65,'Falso',TRUE),
(66,'Verdadero',TRUE),(66,'Falso',FALSE),
(67,'Verdadero',TRUE),(67,'Falso',FALSE);

select * from respuestas_alumno



SELECT 
    a.id,
    a.nombre,
    a.apellido,
    COUNT(CASE WHEN o.es_correcta THEN 1 END) AS correctas,
    COUNT(r.id) AS total,
    ROUND((COUNT(CASE WHEN o.es_correcta THEN 1 END)::decimal / COUNT(r.id)) * 20, 2) AS nota

FROM respuestas_alumno r
JOIN alumnos a ON a.id = r.alumno_id
JOIN opciones o ON o.id = r.opcion_id
JOIN preguntas p ON p.id = r.pregunta_id

WHERE p.quiz_id = 5

GROUP BY a.id, a.nombre, a.apellido
ORDER BY nota DESC;


select * from alumnos
--update alumnos set nombre='Jeanluca',apellido='Pardon Dominguez'
where id=3

select * from quiz
insert into quiz(titulo) values ('Demon Slayer Basico')
select * from preguntas
where quiz_id=2

INSERT INTO preguntas (id, quiz_id, texto, tipo) VALUES
(68, 7, '¿Cómo se llama el protagonista?', 'multiple'),
(69, 7, '¿Qué le sucede a la familia de Tanjiro?', 'multiple'),
(70, 7, '¿Cómo se llama la hermana de Tanjiro?', 'multiple'),
(71, 7, '¿Qué tipo de respiración usa Tanjiro principalmente?', 'multiple'),
(72, 7, '¿Quién es el principal antagonista?', 'multiple'),
(73, 7, '¿Qué característica especial tiene Nezuko como demonio?', 'multiple'),
(74, 7, '¿Cómo se llama el grupo que caza demonios?', 'multiple'),
(75, 7, '¿Qué arma utilizan los cazadores de demonios?', 'multiple'),
(76, 7, '¿Qué pilar usa la respiración del insecto?', 'multiple'),
(77, 7, '¿Qué usa Zenitsu cuando pelea?', 'multiple');

select * from opciones
-- Pregunta 68
INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES
(68, 'Zenitsu Agatsuma', false),
(68, 'Tanjiro Kamado', true),
(68, 'Inosuke Hashibira', false),
(68, 'Giyu Tomioka', false);

-- Pregunta 69
INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES
(69, 'Se mudan', false),
(69, 'Son atacados por demonios', true),
(69, 'Desaparecen', false),
(69, 'Son arrestados', false);

-- Pregunta 70
INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES
(70, 'Mitsuri', false),
(70, 'Shinobu', false),
(70, 'Nezuko Kamado', true),
(70, 'Kanao', false);

-- Pregunta 71
INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES
(71, 'Respiración del Trueno', false),
(71, 'Respiración del Agua', true),
(71, 'Respiración del Viento', false),
(71, 'Respiración de la Piedra', false);

-- Pregunta 72
INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES
(72, 'Akaza', false),
(72, 'Muzan Kibutsuji', true),
(72, 'Rui', false),
(72, 'Kokushibo', false);

-- Pregunta 73
INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES
(73, 'Puede volar', false),
(73, 'No necesita sangre humana constantemente y resiste el sol parcialmente', true),
(73, 'Es invisible', false),
(73, 'Puede controlar otros demonios', false);

-- Pregunta 74
INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES
(74, 'Guardia Nocturna', false),
(74, 'Cazadores de Sombras', false),
(74, 'Cuerpo de Exterminio de Demonios', true),
(74, 'Orden del Sol', false);

-- Pregunta 75
INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES
(75, 'Espadas normales', false),
(75, 'Espadas Nichirin', true),
(75, 'Lanzas', false),
(75, 'Arcos', false);

-- Pregunta 76
INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES
(76, 'Mitsuri Kanroji', false),
(76, 'Shinobu Kocho', true),
(76, 'Kyojuro Rengoku', false),
(76, 'Tengen Uzui', false);

-- Pregunta 77
INSERT INTO opciones (pregunta_id, texto, es_correcta) VALUES
(77, 'Respiración del Agua', false),
(77, 'Respiración del Trueno', true),
(77, 'Respiración de la Niebla', false),
(77, 'Respiración del Amor', false);

select * from  quiz
update quiz set id=7 where id=8

select * from preguntas

update preguntas set quiz_id=7
where quiz_id=8

select * from opciones
SELECT setval('preguntas_id_seq', (SELECT MAX(id) FROM preguntas));
SELECT setval('opciones_id_seq', (SELECT MAX(id) FROM opciones));
SELECT setval('preguntas_id_seq', COALESCE((SELECT MAX(id) FROM preguntas), 1));

select * from respuestas_alumno
select * from opciones

	SELECT p.id, COUNT(*) as errores
	        FROM respuestas_alumno r
	        JOIN preguntas p ON r.pregunta_id = p.id
			JOIN opciones o ON o.pregunta_id=p.id
	        WHERE o.es_correcta = false AND p.quiz_id=5
	        GROUP BY p.id
	        ORDER BY errores DESC
	        LIMIT 10

select * from preguntas
select * from opciones
_______________________________________________________________________
CREATE TABLE empresa (
    cempre SERIAL PRIMARY KEY,
    dempre VARCHAR(100),
    fcreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    licencia BOOLEAN DEFAULT TRUE,
    estado BOOLEAN DEFAULT TRUE
);
INSERT INTO empresa ( dempre)
VALUES ('ADEX');

ALTER TABLE usuarios
ADD COLUMN cempre INTEGER;

UPDATE usuarios
SET cempre = 1;

ALTER TABLE usuarios
ADD CONSTRAINT fk_usuarios_empresa
FOREIGN KEY (cempre) REFERENCES empresa(cempre);

ALTER TABLE quiz
ADD COLUMN cempre INTEGER;

UPDATE quiz
SET cempre = 1;

ALTER TABLE quiz
ADD CONSTRAINT fk_quiz_empresa
FOREIGN KEY (cempre) REFERENCES empresa(cempre);

ALTER TABLE salon_quiz
ADD COLUMN cempre INTEGER;

UPDATE salon_quiz
SET cempre = 1;

ALTER TABLE salon_quiz
ADD CONSTRAINT fk_salon_empresa
FOREIGN KEY (cempre) REFERENCES empresa(cempre);

select * from usuarios
select * from alumnos

ALTER TABLE alumnos
ADD COLUMN cempre INTEGER;

UPDATE alumnos
SET cempre = 1;

ALTER TABLE alumnos
ADD CONSTRAINT fk_salon_empresa
FOREIGN KEY (cempre) REFERENCES empresa(cempre);

SELECT id, titulo, cempre
FROM quiz
LIMIT 10;

SELECT id, usuario, rol, cempre
FROM usuarios;

ALTER TABLE quiz
ADD COLUMN usuario_id INTEGER;

select * from usuarios

UPDATE quiz
SET usuario_id = 2;

SELECT id, titulo, usuario_id
FROM quiz;

SELECT id, titulo, usuario_id
FROM quiz
ORDER BY id DESC;

SELECT sq.id, sq.quiz_id, q.usuario_id
FROM salon_quiz sq
JOIN quiz q ON q.id = sq.quiz_id;

select * from salon
select * from salon_quiz where salon_id=3
select * from quiz

SELECT sq.id, q.titulo, sq.codigo
        FROM salon_quiz sq
        JOIN quiz q ON q.id = sq.quiz_id
        WHERE sq.salon_id = 3
        AND q.usuario_id = 2
        ORDER BY sq.id DESC