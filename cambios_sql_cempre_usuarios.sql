select * from usuarios
DROP TABLE usuarios;

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,

    usuario VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    rol VARCHAR(20) NOT NULL default 'admin',
    dni VARCHAR(20),
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    correo VARCHAR(150),

    cempre INTEGER NOT NULL,
    
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_empresa
        FOREIGN KEY (cempre)
        REFERENCES empresa(cempre)
);
select * from empresa
select * from empresa
update empresa
set dempre='TEST'

INSERT INTO usuarios (
    usuario, password, rol, dni, nombre, apellido, correo, cempre
)
VALUES (
    'root',
    'Renault1234',
    'root',
    '00000000',
    'Luis',
    'Pardon',
    'pardoalf@gmail.com',
    1
);

select * from usuarios

INSERT INTO usuarios (
    usuario, password, rol, dni, nombre, apellido, correo, cempre
)
VALUES (
    'pardoalf',
    '1234',
    'admin',
    '06775568',
    'admin',
    'Test',
    'pardoalf@gmail.com',
    1
);

SELECT usuario, rol, cempre FROM usuarios;

ALTER TABLE usuarios DROP CONSTRAINT IF EXISTS unique_usuario;
ALTER TABLE usuarios DROP CONSTRAINT IF EXISTS unique_dni;

ALTER TABLE usuarios 
ADD CONSTRAINT unique_usuario_empresa UNIQUE (usuario, cempre);

ALTER TABLE usuarios 
ADD CONSTRAINT unique_dni_empresa UNIQUE (dni, cempre);

UNIQUE (usuario, cempre)
UNIQUE (dni, cempre)

select * from usuarios

DELETE FROM usuarios 
WHERE (usuario IS NULL OR usuario = '')
AND rol = 'profesor';

select * from salon