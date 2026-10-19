/* =====================================================================
   SEGUNDA ENTREGA - SEMANA 12: CONSTRUCCION Y MANIPULACION
   Asignatura: Base de Datos
   Caso de estudio: Reserva de libros (biblioteca institucional)
   
   ===================================================================== */


USE master;
GO

-- Borra la base si ya existia, para poder ejecutar el script varias veces.
IF DB_ID('biblioteca_reservas') IS NOT NULL
BEGIN
    ALTER DATABASE biblioteca_reservas SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE biblioteca_reservas;
END
GO

CREATE DATABASE biblioteca_reservas;
GO

USE biblioteca_reservas;
GO

-- Tabla USUARIO: lectores de la biblioteca
CREATE TABLE usuario (
    id_usuario  INT IDENTITY(1,1),
    nombres     NVARCHAR(60)  NOT NULL,
    apellidos   NVARCHAR(60)  NOT NULL,
    documento   NVARCHAR(15)  NOT NULL,
    correo      NVARCHAR(100) NOT NULL,
    telefono    NVARCHAR(15)  NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_documento UNIQUE (documento),
    CONSTRAINT uq_usuario_correo UNIQUE (correo)
);

-- Tabla AUTOR
CREATE TABLE autor (
    id_autor   INT IDENTITY(1,1),
    nombres    NVARCHAR(60) NOT NULL,
    apellidos  NVARCHAR(60) NOT NULL,
    CONSTRAINT pk_autor PRIMARY KEY (id_autor),
    CONSTRAINT uq_autor_nombre UNIQUE (nombres, apellidos)
);

-- Tabla CATEGORIA
CREATE TABLE categoria (
    id_categoria INT IDENTITY(1,1),
    nombre       NVARCHAR(60) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre)
);

-- Tabla LIBRO: titulo del catalogo (no es la copia fisica)
CREATE TABLE libro (
    id_libro         INT IDENTITY(1,1),
    titulo           NVARCHAR(150) NOT NULL,
    isbn             NVARCHAR(13)  NOT NULL,
    anio_publicacion INT           NOT NULL,
    id_autor         INT           NOT NULL,
    id_categoria     INT           NOT NULL,
    CONSTRAINT pk_libro PRIMARY KEY (id_libro),
    CONSTRAINT uq_libro_isbn UNIQUE (isbn),
    CONSTRAINT fk_libro_autor FOREIGN KEY (id_autor)
        REFERENCES autor (id_autor),
    CONSTRAINT fk_libro_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria)
);

-- Tabla EJEMPLAR: cada copia fisica de un libro
CREATE TABLE ejemplar (
    id_ejemplar INT IDENTITY(1,1),
    id_libro    INT          NOT NULL,
    estado      NVARCHAR(20) NOT NULL DEFAULT 'Disponible',
    CONSTRAINT pk_ejemplar PRIMARY KEY (id_ejemplar),
    CONSTRAINT fk_ejemplar_libro FOREIGN KEY (id_libro)
        REFERENCES libro (id_libro)
);

-- Tabla PRESTAMO: historial de reservas y prestamos
CREATE TABLE prestamo (
    id_prestamo      INT IDENTITY(1,1),
    id_usuario       INT          NOT NULL,
    id_ejemplar      INT          NOT NULL,
    fecha_prestamo   DATE         NOT NULL,
    fecha_devolucion DATE         NULL,
    estado           NVARCHAR(20) NOT NULL DEFAULT 'Activo',
    CONSTRAINT pk_prestamo PRIMARY KEY (id_prestamo),
    CONSTRAINT fk_prestamo_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario),
    CONSTRAINT fk_prestamo_ejemplar FOREIGN KEY (id_ejemplar)
        REFERENCES ejemplar (id_ejemplar)
);
GO

-- ---------------------------------------------------------------------
-- 1.1 ALTER TABLE: ajustes a la estructura despues de crearla
-- ---------------------------------------------------------------------

-- El contexto del problema indica que el usuario tiene un rol dentro de la
-- institucion; se agrega la columna con valor por defecto.
ALTER TABLE usuario
    ADD rol NVARCHAR(20) NOT NULL CONSTRAINT df_usuario_rol DEFAULT 'Estudiante';

-- Para controlar devoluciones fuera de plazo se agrega la fecha limite.
-- Queda NULL por ahora; se calcula con UPDATE despues de insertar los datos.
ALTER TABLE prestamo
    ADD fecha_vencimiento DATE NULL;

-- Indice para acelerar la busqueda de libros por titulo.
CREATE INDEX idx_libro_titulo ON libro (titulo);
GO

/* =====================================================================
   2. SCRIPT DE POBLACION (DML - INSERT)
   ===================================================================== */


-- ---- USUARIO (20 registros) ----
INSERT INTO usuario (nombres, apellidos, documento, correo, telefono, rol) VALUES
(N'Laura Valentina', N'Gómez Restrepo', N'1037612345', N'laura.gomez@institucion.edu.co', N'3104567821', N'Estudiante'),
(N'Carlos Andrés', N'Pérez Montoya', N'1017245890', N'carlos.perez@institucion.edu.co', N'3115678932', N'Estudiante'),
(N'María Fernanda', N'Ríos Cardona', N'1020345671', N'maria.rios@institucion.edu.co', N'3126789043', N'Estudiante'),
(N'Juan David', N'Hernández Ospina', N'1001987654', N'juan.hernandez@institucion.edu.co', N'3137890154', N'Estudiante'),
(N'Sofía Alejandra', N'Marín Duque', N'1036543210', N'sofia.marin@institucion.edu.co', N'3148901265', N'Estudiante'),
(N'Santiago', N'Londoño Vélez', N'1017890123', N'santiago.londono@institucion.edu.co', N'3159012376', N'Estudiante'),
(N'Daniela', N'Cano Zapata', N'1044321098', N'daniela.cano@institucion.edu.co', N'3160123487', N'Estudiante'),
(N'Andrés Felipe', N'Castaño Giraldo', N'1020789456', N'andres.castano@institucion.edu.co', N'3171234598', N'Estudiante'),
(N'Valeria', N'Arias Henao', N'1001234987', N'valeria.arias@institucion.edu.co', N'3182345609', N'Estudiante'),
(N'Mateo', N'Salazar Builes', N'1037098765', N'mateo.salazar@institucion.edu.co', N'3193456710', N'Estudiante'),
(N'Camila', N'Ocampo Arango', N'1017654321', N'camila.ocampo@institucion.edu.co', N'3204567821', N'Estudiante'),
(N'Sebastián', N'Jaramillo Mejía', N'1020112233', N'sebastian.jaramillo@institucion.edu.co', N'3215678932', N'Estudiante'),
(N'Isabella', N'Toro Quintero', N'1036778899', N'isabella.toro@institucion.edu.co', N'3226789043', N'Estudiante'),
(N'Nicolás', N'Restrepo Álvarez', N'1001556677', N'nicolas.restrepo@institucion.edu.co', N'3237890154', N'Estudiante'),
(N'Mariana', N'Úsuga Correa', N'1044889900', N'mariana.usuga@institucion.edu.co', N'3248901265', N'Estudiante'),
(N'Julián', N'Berrío Muñoz', N'1017334455', N'julian.berrio@institucion.edu.co', N'3259012376', N'Estudiante'),
(N'Paula Andrea', N'Osorio Franco', N'43987654', N'paula.osorio@institucion.edu.co', N'3003456789', N'Docente'),
(N'Ricardo', N'Villa Escobar', N'71456789', N'ricardo.villa@institucion.edu.co', N'3014567890', N'Docente'),
(N'Luz Marina', N'Agudelo Torres', N'32654987', N'luz.agudelo@institucion.edu.co', N'3025678901', N'Administrativo'),
(N'Hernán Darío', N'Zuluaga Pino', N'98123456', N'hernan.zuluaga@institucion.edu.co', N'3036789012', N'Docente');

-- ---- AUTOR (20 registros) ----
INSERT INTO autor (nombres, apellidos) VALUES
(N'Gabriel', N'García Márquez'),
(N'Isabel', N'Allende'),
(N'Julio', N'Cortázar'),
(N'Jorge Luis', N'Borges'),
(N'Mario', N'Vargas Llosa'),
(N'Laura', N'Restrepo'),
(N'William', N'Ospina'),
(N'Eduardo', N'Galeano'),
(N'Carl', N'Sagan'),
(N'Stephen', N'Hawking'),
(N'Yuval Noah', N'Harari'),
(N'Robert C.', N'Martin'),
(N'Abraham', N'Silberschatz'),
(N'Andrew S.', N'Tanenbaum'),
(N'Thomas H.', N'Cormen'),
(N'Daniel', N'Kahneman'),
(N'Antoine', N'de Saint-Exupéry'),
(N'Miguel', N'de Cervantes'),
(N'George', N'Orwell'),
(N'Paulo', N'Coelho');

-- ---- CATEGORIA (20 registros) ----
INSERT INTO categoria (nombre) VALUES
(N'Novela'),
(N'Cuento'),
(N'Ensayo'),
(N'Poesía'),
(N'Divulgación científica'),
(N'Física'),
(N'Astronomía'),
(N'Historia'),
(N'Psicología'),
(N'Economía'),
(N'Programación'),
(N'Bases de datos'),
(N'Redes de computadores'),
(N'Algoritmos'),
(N'Ingeniería de software'),
(N'Filosofía'),
(N'Literatura clásica'),
(N'Distopía'),
(N'Literatura infantil'),
(N'Autoayuda');

-- ---- LIBRO (24 registros) ----
INSERT INTO libro (titulo, isbn, anio_publicacion, id_autor, id_categoria) VALUES
(N'Cien años de soledad', N'9789580000006', 1967, 1, 1),
(N'El amor en los tiempos del cólera', N'9789580079194', 1985, 1, 1),
(N'Crónica de una muerte anunciada', N'9789580158387', 1981, 1, 1),
(N'La casa de los espíritus', N'9789580237570', 1982, 2, 1),
(N'Rayuela', N'9789580316763', 1963, 3, 1),
(N'Ficciones', N'9789580395959', 1944, 4, 2),
(N'La ciudad y los perros', N'9789580475149', 1963, 5, 1),
(N'Delirio', N'9789580554332', 2004, 6, 1),
(N'Ursúa', N'9789580633525', 2005, 7, 1),
(N'Las venas abiertas de América Latina', N'9789580712718', 1971, 8, 8),
(N'Cosmos', N'9789580791904', 1980, 9, 7),
(N'Breve historia del tiempo', N'9789580871095', 1988, 10, 6),
(N'Sapiens: de animales a dioses', N'9789580950288', 2011, 11, 8),
(N'Código limpio', N'9789581029471', 2008, 12, 15),
(N'Fundamentos de bases de datos', N'9789581108664', 2019, 13, 12),
(N'Redes de computadoras', N'9789581187850', 2012, 14, 13),
(N'Introducción a los algoritmos', N'9789581267040', 2009, 15, 14),
(N'Pensar rápido, pensar despacio', N'9789581346233', 2011, 16, 9),
(N'El principito', N'9789581425426', 1943, 17, 19),
(N'Don Quijote de la Mancha', N'9789581504619', 1605, 18, 17),
(N'1984', N'9789581583805', 1949, 19, 18),
(N'Rebelión en la granja', N'9789581662999', 1945, 19, 18),
(N'El alquimista', N'9789581742189', 1988, 20, 20),
(N'Sistemas operativos modernos', N'9789581821372', 2015, 14, 11);

-- ---- EJEMPLAR (38 registros) ----
INSERT INTO ejemplar (id_libro, estado) VALUES
(1, N'En Préstamo'),
(1, N'Disponible'),
(1, N'Disponible'),
(2, N'Disponible'),
(2, N'En Préstamo'),
(3, N'Disponible'),
(4, N'Disponible'),
(4, N'Reservado'),
(5, N'Disponible'),
(5, N'Mantenimiento'),
(6, N'Disponible'),
(7, N'Disponible'),
(8, N'Disponible'),
(9, N'En Préstamo'),
(10, N'Disponible'),
(10, N'Disponible'),
(11, N'En Préstamo'),
(11, N'Disponible'),
(12, N'Disponible'),
(12, N'Mantenimiento'),
(13, N'Disponible'),
(13, N'En Préstamo'),
(14, N'Disponible'),
(14, N'Disponible'),
(15, N'Reservado'),
(15, N'Disponible'),
(16, N'Disponible'),
(17, N'Disponible'),
(17, N'En Préstamo'),
(18, N'Disponible'),
(19, N'Disponible'),
(19, N'Disponible'),
(20, N'Disponible'),
(21, N'Disponible'),
(21, N'Disponible'),
(22, N'Disponible'),
(23, N'Disponible'),
(24, N'Disponible');

-- ---- PRESTAMO (38 registros) ----
-- Nota: fecha_devolucion queda en NULL mientras el ejemplar no ha sido devuelto.
INSERT INTO prestamo (id_usuario, id_ejemplar, fecha_prestamo, fecha_devolucion, estado) VALUES
(1, 32, '2026-02-05', '2026-02-15', N'Devuelto'),
(1, 19, '2026-02-12', '2026-02-19', N'Devuelto'),
(1, 24, '2026-02-18', '2026-03-02', N'Devuelto'),
(2, 36, '2026-02-28', '2026-03-19', N'Devuelto'),
(2, 38, '2026-03-09', '2026-03-31', N'Devuelto'),
(3, 2, '2026-03-15', '2026-03-30', N'Devuelto'),
(3, 18, '2026-03-23', '2026-04-06', N'Devuelto'),
(4, 11, '2026-03-31', '2026-04-12', N'Devuelto'),
(4, 37, '2026-04-07', '2026-04-24', N'Devuelto'),
(4, 26, '2026-04-16', '2026-04-22', N'Devuelto'),
(5, 19, '2026-04-25', '2026-05-14', N'Devuelto'),
(5, 3, '2026-05-01', '2026-05-05', N'Devuelto'),
(6, 21, '2026-05-10', '2026-05-16', N'Devuelto'),
(7, 32, '2026-05-20', '2026-05-26', N'Devuelto'),
(8, 27, '2026-05-28', '2026-06-04', N'Devuelto'),
(9, 9, '2026-06-04', '2026-06-21', N'Devuelto'),
(9, 26, '2026-06-10', '2026-06-25', N'Devuelto'),
(10, 30, '2026-06-18', '2026-07-01', N'Devuelto'),
(11, 24, '2026-06-29', '2026-07-18', N'Devuelto'),
(12, 19, '2026-07-07', '2026-07-24', N'Devuelto'),
(13, 34, '2026-07-12', '2026-07-31', N'Devuelto'),
(14, 36, '2026-07-20', '2026-07-29', N'Devuelto'),
(15, 18, '2026-07-30', '2026-08-11', N'Devuelto'),
(16, 15, '2026-08-08', '2026-08-27', N'Devuelto'),
(17, 12, '2026-08-13', '2026-08-23', N'Devuelto'),
(18, 18, '2026-08-23', '2026-09-04', N'Devuelto'),
(19, 19, '2026-08-30', '2026-09-03', N'Devuelto'),
(20, 26, '2026-09-09', '2026-09-13', N'Devuelto'),
(6, 32, '2026-09-14', '2026-09-23', N'Devuelto'),
(7, 19, '2026-09-25', '2026-09-29', N'Devuelto'),
(3, 1, '2026-08-24', NULL, N'Vencido'),
(8, 14, '2026-09-01', NULL, N'Vencido'),
(12, 22, '2026-09-08', NULL, N'Vencido'),
(1, 5, '2026-10-06', NULL, N'Activo'),
(5, 17, '2026-10-09', NULL, N'Activo'),
(17, 29, '2026-10-12', NULL, N'Activo'),
(2, 8, '2026-10-14', NULL, N'Reservado'),
(10, 25, '2026-10-15', NULL, N'Reservado');

GO

/* =====================================================================
   2.1 UPDATE: actualizacion de datos ya insertados
   ===================================================================== */

-- (a) Calcula la fecha de vencimiento: 15 dias despues del prestamo.
UPDATE prestamo
SET fecha_vencimiento = DATEADD(DAY, 15, fecha_prestamo);

-- (b) Un prestamo activo cuyo plazo ya paso pasa a estado 'Vencido'.
UPDATE prestamo
SET estado = 'Vencido'
WHERE estado = 'Activo'
  AND fecha_devolucion IS NULL
  AND fecha_vencimiento < CAST(GETDATE() AS DATE);

-- (c) Se reporta que una copia disponible del libro "Cosmos" esta danada.
UPDATE ejemplar
SET estado = 'Mantenimiento'
WHERE id_ejemplar = 18
  AND estado = 'Disponible';

-- (d) Correccion del numero de telefono de un usuario.
UPDATE usuario
SET telefono = '3105550199'
WHERE id_usuario = 1;
GO

-- Con los datos completos, la fecha de vencimiento pasa a ser obligatoria.
ALTER TABLE prestamo
    ALTER COLUMN fecha_vencimiento DATE NOT NULL;
GO

/* =====================================================================
   3. CONSULTAS DE NEGOCIO (DML - SELECT)
   ===================================================================== */

-- ---------------------------------------------------------------------
-- CONSULTA 1
-- Pregunta: Que usuarios han realizado 3 o mas prestamos o reservas y
-- cuantos tienen en total?
-- Usa: INNER JOIN, COUNT, GROUP BY, HAVING
-- ---------------------------------------------------------------------
SELECT u.id_usuario,
       CONCAT(u.nombres, ' ', u.apellidos) AS usuario,
       COUNT(p.id_prestamo) AS total_prestamos
FROM usuario u
INNER JOIN prestamo p ON p.id_usuario = u.id_usuario
GROUP BY u.id_usuario, u.nombres, u.apellidos
HAVING COUNT(p.id_prestamo) >= 3
ORDER BY total_prestamos DESC, usuario;

-- ---------------------------------------------------------------------
-- CONSULTA 2
-- Pregunta: Cuales son los libros mas solicitados, con su autor, y cuantas
-- veces se ha prestado cada uno? (solo libros con 2 o mas solicitudes)
-- Usa: INNER JOIN de cuatro tablas, COUNT, GROUP BY, HAVING
-- ---------------------------------------------------------------------
SELECT l.titulo,
       CONCAT(a.nombres, ' ', a.apellidos) AS autor,
       COUNT(p.id_prestamo) AS veces_prestado
FROM prestamo p
INNER JOIN ejemplar e ON e.id_ejemplar = p.id_ejemplar
INNER JOIN libro l    ON l.id_libro = e.id_libro
INNER JOIN autor a    ON a.id_autor = l.id_autor
GROUP BY l.id_libro, l.titulo, a.nombres, a.apellidos
HAVING COUNT(p.id_prestamo) >= 2
ORDER BY veces_prestado DESC, l.titulo;

-- ---------------------------------------------------------------------
-- CONSULTA 3
-- Pregunta: Cuantos ejemplares tiene cada categoria y cuantos estan
-- disponibles hoy? Se deben mostrar tambien las categorias sin ejemplares.
-- Usa: LEFT JOIN, COUNT, SUM con CASE, GROUP BY
-- ---------------------------------------------------------------------
SELECT c.nombre AS categoria,
       COUNT(e.id_ejemplar) AS total_ejemplares,
       SUM(CASE WHEN e.estado = 'Disponible' THEN 1 ELSE 0 END) AS disponibles
FROM categoria c
LEFT JOIN libro l    ON l.id_categoria = c.id_categoria
LEFT JOIN ejemplar e ON e.id_libro = l.id_libro
GROUP BY c.id_categoria, c.nombre
ORDER BY total_ejemplares DESC, categoria;

-- ---------------------------------------------------------------------
-- CONSULTA 4
-- Pregunta: Que usuarios han devuelto libros con retraso y cual fue el
-- promedio de dias de retraso? (solo promedios mayores a 2 dias)
-- Usa: INNER JOIN, AVG, COUNT, WHERE con fechas, DATEDIFF, GROUP BY, HAVING
-- Nota: en SQL Server DATEDIFF(DAY, fecha_inicial, fecha_final).
-- ---------------------------------------------------------------------
SELECT CONCAT(u.nombres, ' ', u.apellidos) AS usuario,
       COUNT(*) AS devoluciones_tardias,
       ROUND(AVG(CAST(DATEDIFF(DAY, p.fecha_vencimiento, p.fecha_devolucion) AS DECIMAL(10,2))), 1) AS promedio_dias_retraso
FROM prestamo p
INNER JOIN usuario u ON u.id_usuario = p.id_usuario
WHERE p.fecha_devolucion IS NOT NULL
  AND p.fecha_devolucion > p.fecha_vencimiento
GROUP BY u.id_usuario, u.nombres, u.apellidos
HAVING AVG(CAST(DATEDIFF(DAY, p.fecha_vencimiento, p.fecha_devolucion) AS DECIMAL(10,2))) > 2
ORDER BY promedio_dias_retraso DESC;

-- ---------------------------------------------------------------------
-- CONSULTA 5
-- Pregunta: Cuantos prestamos se hicieron por mes entre enero y septiembre
-- de 2026 y cuantos dias duro en promedio cada prestamo devuelto?
-- Usa: COUNT, AVG, WHERE con rango de fechas, MONTH, DATEDIFF, GROUP BY
-- ---------------------------------------------------------------------
SELECT MONTH(p.fecha_prestamo) AS mes,
       COUNT(*) AS total_prestamos,
       ROUND(AVG(CAST(DATEDIFF(DAY, p.fecha_prestamo, p.fecha_devolucion) AS DECIMAL(10,2))), 1) AS promedio_dias_prestamo
FROM prestamo p
WHERE p.fecha_prestamo BETWEEN '2026-01-01' AND '2026-09-30'
  AND p.fecha_devolucion IS NOT NULL
GROUP BY MONTH(p.fecha_prestamo)
ORDER BY mes;

-- ---------------------------------------------------------------------
-- CONSULTA 6
-- Pregunta: Que libros estan hoy sin devolver y con el plazo vencido, quien
-- los tiene y cuantos dias de atraso llevan?
-- Usa: INNER JOIN de cuatro tablas, WHERE con fechas, GETDATE, DATEDIFF
-- ---------------------------------------------------------------------
SELECT CONCAT(u.nombres, ' ', u.apellidos) AS usuario,
       u.correo,
       l.titulo,
       p.fecha_vencimiento,
       DATEDIFF(DAY, p.fecha_vencimiento, CAST(GETDATE() AS DATE)) AS dias_de_atraso
FROM prestamo p
INNER JOIN usuario u  ON u.id_usuario = p.id_usuario
INNER JOIN ejemplar e ON e.id_ejemplar = p.id_ejemplar
INNER JOIN libro l    ON l.id_libro = e.id_libro
WHERE p.fecha_devolucion IS NULL
  AND p.fecha_vencimiento < CAST(GETDATE() AS DATE)
ORDER BY dias_de_atraso DESC;
