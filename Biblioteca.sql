\c ramonmiranda
CREATE DATABASE bibliotecadata;
\c bibliotecadata
--Parte 1 - Creación del modelo conceptual, lógico y físico [modelamiento.drawio]
--(01)Realizar el modelo conceptual, considerando las entidades y relaciones entre ellas.
--Entidades:
--[FUERTE]libros (isbn, título, número de páginas, {código del autor, nombre y apellido del autor, fecha de nacimiento y muerte del autor, tipo de autor {principal, coautor}})
--[DEBIL]historial_préstamos (fecha de inicio, fecha esperada de devolución y fecha real de devolución)
--[FUERTE]socios (rut, nombre, apellido, dirección y teléfono)
--[DONE] Diagrama 01
--(02)Realizar el modelo lógico, considerando todas las entidades y las relaciones entre ellas, los atributos, normalización y creación de tablas intermedias de ser necesario.
--FN1:
--[FUERTE]libros (#isbn, título, número de páginas, tiempo de prestamo)
--[FUERTE]autor (#código del autor, nombre, apellido, fecha de nacimiento, fecha defunción, tipo de autor {principal, coautor})
--[DEBIL]historial_préstamos (#id, fecha de inicio, fecha real de devolución)
--[FUERTE]socios (#rut, nombre, apellido, dirección y teléfono)
--FN2:
--[FUERTE]libros (#isbn, título, número de páginas, tiempo de prestamo, stock)
--[FUERTE]autor (#código del autor, nombre, apellido, fecha nacimiento, fecha defunción)
--[DEBIL]tipo_autor(#isbn, #código del autor, principal/coautor)
--[DEBIL]hisorial_préstamo (#id, socio.rut, libro.isbn, fecha de inicio, fecha real de devolución)
--[FUERTE]socios (#rut, nombre, apellido, dirección, teléfono, prestamo activo)
--[DONE] Diagrama 02 y trancición a Diagrama 03
--(03)Realizar el modelo físico, considerando la especificación de tablas y columnas, además de las claves externas.
--[DONE] Tipo de datos indicados en el UML llamado 'Diagrama 03'

--Parte 2 - Creando el modelo en la base de datos
--(01)Crear el modelo en una base de datos llamada 'biblioteca', considerando las tablas definidas y sus atributos.

CREATE TABLE autor(
    id_autor SERIAL,
    nombre VARCHAR(20),
    apellido VARCHAR(20),
    fecha_nac SMALLINT,
    fecha_def SMALLINT,
    PRIMARY KEY (id_autor)
);

CREATE TABLE libros(
    isbn BIGINT,
    titulo VARCHAR(40),
    paginas SMALLINT,
    limite_prestamo SMALLINT,
    existencia SMALLINT CHECK (existencia >= 0),
    PRIMARY KEY (isbn)
);
--La tabla autoria bloquea la combinación libro-escritor, esto debido a que un escritor puede participar en muchos libros PERO sólo una vez por libro y ejerciendo un tipo, lo mismo ocurre con los libros.
CREATE TABLE tipo_autor(
    isbn BIGINT,
    id_autor SMALLINT,
    tipo VARCHAR(10), -- PRINCIPAL || COAUTOR
    PRIMARY KEY (isbn,id_autor),
    FOREIGN KEY (isbn) REFERENCES libros,
    FOREIGN KEY (id_autor) REFERENCES autor
);

CREATE TABLE socios( --Se declara el tipado NOT NULL unicamente a esta tabla, debido a que es lo único que explicitamente se indica en el desafio que: cada socio debe tener si o si una informacion en dirección y telefono. Lo cual se interpreto como un requerimiento de "NOT NULL"
    rut INT,
    nombre VARCHAR(20),
    apellido VARCHAR(20),
    direccion VARCHAR(20) NOT NULL,
    telefono INT NOT NULL,
    prestamo BOOLEAN, --Posibilitando el poder mantener el límite de prestamo por socio, pese a que aumenten su Stock
    PRIMARY KEY (rut)
);
--En el caso de la tabla prestamo, es diferente al caso anterior, ya que no se desea 'bloquear' la tabla con las referencias, sino, sólo referenciarlas ya que el mismo socio puede solicitar el mismo libro más de una vez.
CREATE TABLE historial_prestamos(
    id_prestamo SERIAL,
    rut INT,
    isbn BIGINT,
    fecha_ini DATE,
    fecha_dev DATE,
    PRIMARY KEY (id_prestamo),
    FOREIGN KEY (rut) REFERENCES socios,
    FOREIGN KEY (isbn) REFERENCES libros
);

--(02) Se deben insertar los registros en las tablas correspondientes

INSERT INTO socios (rut,nombre,apellido,direccion,telefono,prestamo) VALUES
(11111111,'JUAN','SOTO','AVENIDA 1, SANTIAGO',911111111,FALSE),
(22222222,'ANA', 'PEREZ',' PASAJE 2, SANTIAGO',922222222,FALSE),
(33333333,'SANDRA', 'AGUILAR',' AVENIDA 2, SANTIAGO',933333333,FALSE),
(44444444,'ESTEBAN', 'JEREZ',' AVENIDA 3, SANTIAGO',944444444,FALSE),
(55555555,'SILVANA', 'MUNOZ',' PASAJE 3, SANTIAGO',955555555,FALSE);

INSERT INTO autor (nombre,apellido,fecha_nac,fecha_def) VALUES
('ANDRES', 'ULLOA',1982,null),
('SERGIO', 'MARDONES', 1950,2012),
('JOSE', 'SALGADO', 1968,2020),
('ANA', 'SALGADO',1972,null),
('MARTIN', 'PORTA',1976,null);

INSERT INTO libros (isbn,titulo,paginas,limite_prestamo,existencia) VALUES
(1111111111111, 'CUENTOS DE TERROR',344,7,1),
(2222222222222, 'POESIAS CONTEMPORANEAS',167,7,1),
(3333333333333, 'HISTORIA DE ASIA',511,14,1),
(4444444444444, 'MANUAL DE MECANICA',298,14,1);

INSERT INTO tipo_autor (isbn,id_autor,tipo) VALUES
(1111111111111,3, 'PRINCIPAL'),
(1111111111111,4, 'COAUTOR'),
(2222222222222,1, 'PRINCIPAL'),
(3333333333333,2, 'PRINCIPAL'),
(4444444444444,5, 'PRINCIPAL');

INSERT INTO historial_prestamos (rut,isbn,fecha_ini,fecha_dev) VALUES
(11111111,1111111111111,'2020-01-20','2020-01-27'),
(55555555,2222222222222,'2020-01-20','2020-01-30'),
(33333333,3333333333333,'2020-01-22','2020-01-30'),
(44444444,4444444444444,'2020-01-23','2020-01-30'),
(22222222,1111111111111,'2020-01-27','2020-02-04'),
(11111111,4444444444444,'2020-01-31','2020-02-12'),
(33333333,2222222222222,'2020-01-31','2020-02-12');

--(03) Realizar las siguientes consultas:
--[a] Mostrar todos los libros que posean menos de 300 páginas.
SELECT titulo, paginas FROM libros WHERE paginas < 300;

--[b] Mostrar todos los autores que hayan nacido después del 01-01-1970.
SELECT nombre, apellido, fecha_nac FROM autor WHERE fecha_nac > 1970;

--[c] ¿Cuál es el libro más solicitado?
SELECT titulo, COUNT(libros.isbn) AS demanda 
FROM libros 
INNER JOIN historial_prestamos ON libros.isbn = historial_prestamos.isbn 
GROUP BY titulo 
ORDER BY demanda DESC;

--[d] Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto debería pagar cada usuario que entregue el préstamo después de 7 días.
SELECT 
    historial_prestamos.id_prestamo,
    historial_prestamos.rut,
    socios.nombre,
    socios.apellido,
    (historial_prestamos.fecha_dev - historial_prestamos.fecha_ini) as dias_prestamo, 
    libros.limite_prestamo, 
    (libros.limite_prestamo - (historial_prestamos.fecha_dev - historial_prestamos.fecha_ini)) AS dias_multa,
    ((libros.limite_prestamo - (historial_prestamos.fecha_dev - historial_prestamos.fecha_ini))*100) AS multa_total
FROM (historial_prestamos INNER JOIN socios ON historial_prestamos.rut=socios.rut)
INNER JOIN libros ON historial_prestamos.isbn=libros.isbn
WHERE (fecha_dev - fecha_ini)>7
--AND (libro.limite_prestamo - (prestamo.fecha_dev - prestamo.fecha_ini))>0   --Descomentar en cuyo caso sólo se deseen obtener los valores de multa positivos.
;


--Comando reservado para vaciar DDBB
DROP TABLE historial_prestamos;
DROP TABLE socios;
DROP TABLE tipo_autor;
DROP TABLE libros;
DROP TABLE autor;