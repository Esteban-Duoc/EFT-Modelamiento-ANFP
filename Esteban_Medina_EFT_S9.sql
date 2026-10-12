BEGIN
  FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN (
              'JUGADOR_IDIOMA','JUGADOR_CLUB','PERSONAL_PLANTA','JUGADOR',
              'TRABAJADOR','COMUNA','CLUB_FUTBOL','IDIOMA','PUESTO',
              'ESCUELA_FUTBOL','ASOCIACION','NACIONALIDAD','ESTADO_CIVIL','REGION'))
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
  FOR s IN (SELECT sequence_name FROM user_sequences WHERE sequence_name = 'SEQ_CLUB_FUTBOL')
  LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
  END LOOP;
END;
/

CREATE TABLE region (
    id_region   NUMBER(2)     NOT NULL,
    nombre      VARCHAR2(50)  NOT NULL,
    CONSTRAINT region_pk PRIMARY KEY (id_region)
);

CREATE TABLE estado_civil (
    id_estado_civil  NUMBER(2)     NOT NULL,
    descripcion      VARCHAR2(20)  NOT NULL,
    CONSTRAINT estado_civil_pk PRIMARY KEY (id_estado_civil),
    CONSTRAINT estado_civil_desc_un UNIQUE (descripcion)
);

CREATE TABLE nacionalidad (
    id_nacion    NUMBER(4) GENERATED ALWAYS AS IDENTITY (START WITH 210 INCREMENT BY 2) NOT NULL,
    descripcion  VARCHAR2(30) NOT NULL,
    CONSTRAINT nacionalidad_pk PRIMARY KEY (id_nacion),
    CONSTRAINT nacionalidad_desc_un UNIQUE (descripcion)
);

CREATE TABLE asociacion (
    id_asociacion      NUMBER(3)     NOT NULL,
    nombre_asociacion  VARCHAR2(60)  NOT NULL,
    fecha_creacion     DATE          NOT NULL,
    tipo_asociacion    CHAR(1)       DEFAULT 'P' NOT NULL,
    CONSTRAINT asociacion_pk PRIMARY KEY (id_asociacion),
    CONSTRAINT asociacion_tipo_ck CHECK (tipo_asociacion IN ('P','A'))
);

CREATE TABLE escuela_futbol (
    id_escuela       NUMBER(4)     NOT NULL,
    nombre_escuela   VARCHAR2(50)  NOT NULL,
    capacidad        NUMBER(5)     NOT NULL,
    fecha_fundacion  DATE          NOT NULL,
    CONSTRAINT escuela_futbol_pk PRIMARY KEY (id_escuela),
    CONSTRAINT escuela_futbol_capacidad_ck CHECK (capacidad > 0)
);

CREATE TABLE puesto (
    id_puesto    NUMBER(2)     NOT NULL,
    descripcion  VARCHAR2(30)  NOT NULL,
    CONSTRAINT puesto_pk PRIMARY KEY (id_puesto),
    CONSTRAINT puesto_desc_un UNIQUE (descripcion)
);

CREATE TABLE idioma (
    id_idioma      NUMBER(3)     NOT NULL,
    nombre_idioma  VARCHAR2(30)  NOT NULL,
    CONSTRAINT idioma_pk PRIMARY KEY (id_idioma),
    CONSTRAINT idioma_nombre_un UNIQUE (nombre_idioma)
);

CREATE TABLE club_futbol (
    id_club          NUMBER(5)      NOT NULL,
    nombre_club      VARCHAR2(50)   NOT NULL,
    patrimonio       NUMBER(15)     NOT NULL,
    ubicacion_calle  VARCHAR2(100)  NOT NULL,
    tipo_club        VARCHAR2(15)   DEFAULT 'Profesional' NOT NULL,
    CONSTRAINT club_futbol_pk PRIMARY KEY (id_club),
    CONSTRAINT club_futbol_patrimonio_ck CHECK (patrimonio >= 0),
    CONSTRAINT club_futbol_tipo_ck CHECK (tipo_club IN ('Profesional','Amateur'))
);

CREATE TABLE comuna (
    id_comuna  NUMBER(4)     NOT NULL,
    id_region  NUMBER(2)     NOT NULL,
    nombre     VARCHAR2(50)  NOT NULL,
    CONSTRAINT comuna_pk PRIMARY KEY (id_comuna),
    CONSTRAINT comuna_region_fk FOREIGN KEY (id_region) REFERENCES region (id_region)
);

CREATE TABLE trabajador (
    cod_inscripcion   NUMBER(9)      NOT NULL,
    rut               NUMBER(8)      NOT NULL,
    dv                CHAR(1)        NOT NULL,
    nombres           VARCHAR2(50)   NOT NULL,
    apellido_paterno  VARCHAR2(30)   NOT NULL,
    apellido_materno  VARCHAR2(30),
    sueldo_base       NUMBER(10)     NOT NULL,
    fecha_nacimiento  DATE           NOT NULL,
    genero            CHAR(1)        NOT NULL,
    fono_movil        VARCHAR2(15),
    email             VARCHAR2(80),
    direccion         VARCHAR2(100)  NOT NULL,
    id_comuna         NUMBER(4)      NOT NULL,
    id_estado_civil   NUMBER(2)      NOT NULL,
    id_nacion         NUMBER(4)      NOT NULL,
    tipo_trabajador   CHAR(1)        NOT NULL,
    CONSTRAINT trabajador_pk PRIMARY KEY (cod_inscripcion),
    CONSTRAINT trabajador_rut_un UNIQUE (rut),
    CONSTRAINT trabajador_dv_ck CHECK (dv IN ('0','1','2','3','4','5','6','7','8','9','K')),
    CONSTRAINT trabajador_sueldo_ck CHECK (sueldo_base > 0),
    CONSTRAINT trabajador_genero_ck CHECK (genero IN ('M','F')),
    CONSTRAINT trabajador_tipo_ck CHECK (tipo_trabajador IN ('J','P')),
    CONSTRAINT trabajador_comuna_fk FOREIGN KEY (id_comuna) REFERENCES comuna (id_comuna),
    CONSTRAINT trabajador_estado_civil_fk FOREIGN KEY (id_estado_civil) REFERENCES estado_civil (id_estado_civil),
    CONSTRAINT trabajador_nacionalidad_fk FOREIGN KEY (id_nacion) REFERENCES nacionalidad (id_nacion)
);

CREATE TABLE jugador (
    cod_inscripcion      NUMBER(9)   NOT NULL,
    id_puesto            NUMBER(2)   NOT NULL,
    monto_premios        NUMBER(12)  DEFAULT 0 NOT NULL,
    id_asociacion        NUMBER(3)   NOT NULL,
    id_escuela           NUMBER(4),
    anio_fin_amateur     NUMBER(4),
    CONSTRAINT jugador_pk PRIMARY KEY (cod_inscripcion),
    CONSTRAINT jugador_premios_ck CHECK (monto_premios >= 0),
    CONSTRAINT jugador_trabajador_fk FOREIGN KEY (cod_inscripcion) REFERENCES trabajador (cod_inscripcion),
    CONSTRAINT jugador_puesto_fk FOREIGN KEY (id_puesto) REFERENCES puesto (id_puesto),
    CONSTRAINT jugador_asociacion_fk FOREIGN KEY (id_asociacion) REFERENCES asociacion (id_asociacion),
    CONSTRAINT jugador_escuela_fk FOREIGN KEY (id_escuela) REFERENCES escuela_futbol (id_escuela)
);

CREATE TABLE personal_planta (
    cod_inscripcion   NUMBER(9)  NOT NULL,
    id_club           NUMBER(5)  NOT NULL,
    horas_trabajadas  NUMBER(3),
    valor_hora_extra  NUMBER(8),
    CONSTRAINT personal_planta_pk PRIMARY KEY (cod_inscripcion),
    CONSTRAINT personal_planta_horas_ck CHECK (horas_trabajadas >= 0),
    CONSTRAINT personal_planta_valor_ck CHECK (valor_hora_extra >= 0),
    CONSTRAINT personal_planta_trabajador_fk FOREIGN KEY (cod_inscripcion) REFERENCES trabajador (cod_inscripcion),
    CONSTRAINT personal_planta_club_fk FOREIGN KEY (id_club) REFERENCES club_futbol (id_club)
);

CREATE TABLE jugador_club (
    cod_inscripcion      NUMBER(9)  NOT NULL,
    id_club              NUMBER(5)  NOT NULL,
    fecha_incorporacion  DATE       NOT NULL,
    fecha_fin_contrato   DATE,
    CONSTRAINT jugador_club_pk PRIMARY KEY (cod_inscripcion, id_club, fecha_incorporacion),
    CONSTRAINT jugador_club_fechas_ck CHECK (fecha_fin_contrato IS NULL OR fecha_fin_contrato > fecha_incorporacion),
    CONSTRAINT jugador_club_jugador_fk FOREIGN KEY (cod_inscripcion) REFERENCES jugador (cod_inscripcion),
    CONSTRAINT jugador_club_club_fk FOREIGN KEY (id_club) REFERENCES club_futbol (id_club)
);

CREATE TABLE jugador_idioma (
    cod_inscripcion  NUMBER(9)     NOT NULL,
    id_idioma        NUMBER(3)     NOT NULL,
    nivel_dominio    VARCHAR2(15)  NOT NULL,
    CONSTRAINT jugador_idioma_pk PRIMARY KEY (cod_inscripcion, id_idioma),
    CONSTRAINT jugador_idioma_nivel_ck CHECK (nivel_dominio IN ('BASICO','INTERMEDIO','AVANZADO','NATIVO')),
    CONSTRAINT jugador_idioma_jugador_fk FOREIGN KEY (cod_inscripcion) REFERENCES jugador (cod_inscripcion),
    CONSTRAINT jugador_idioma_idioma_fk FOREIGN KEY (id_idioma) REFERENCES idioma (id_idioma)
);

ALTER TABLE club_futbol
  ADD CONSTRAINT club_futbol_nombre_un UNIQUE (nombre_club);

ALTER TABLE asociacion
  ADD CONSTRAINT asociacion_fecha_ck CHECK (fecha_creacion >= DATE '1980-12-31');

CREATE SEQUENCE seq_club_futbol
  START WITH 703
  INCREMENT BY 4
  NOCACHE;

INSERT INTO region (id_region, nombre) VALUES (1,  'ARICA Y PARINACOTA Y TARAPACA');
INSERT INTO region (id_region, nombre) VALUES (2,  'ANTOFAGASTA');
INSERT INTO region (id_region, nombre) VALUES (3,  'ATACAMA Y COQUIMBO');
INSERT INTO region (id_region, nombre) VALUES (5,  'VALPARAISO');
INSERT INTO region (id_region, nombre) VALUES (13, 'METROPOLITANA');
INSERT INTO region (id_region, nombre) VALUES (8,  'BIOBIO');
INSERT INTO region (id_region, nombre) VALUES (16, 'ÑUBLE');

INSERT INTO comuna (id_comuna, id_region, nombre) VALUES (101, 13, 'Santiago');
INSERT INTO comuna (id_comuna, id_region, nombre) VALUES (102, 5,  'Valparaíso');
INSERT INTO comuna (id_comuna, id_region, nombre) VALUES (103, 8,  'Concepción');
INSERT INTO comuna (id_comuna, id_region, nombre) VALUES (104, 2,  'Antofagasta');
INSERT INTO comuna (id_comuna, id_region, nombre) VALUES (105, 16, 'Chillán');

INSERT INTO asociacion VALUES (25, 'Asociación de Fútbol de Santiago',       TO_DATE('15-05-2001','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (26, 'Asociación Nacional de Fútbol Amateur',  TO_DATE('10-03-1998','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (27, 'Asociación de Fútbol de Valparaíso',     TO_DATE('21-07-1987','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (28, 'Asociación de Fútbol de Concepción',     TO_DATE('30-11-1995','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (29, 'Asociación de Fútbol de Antofagasta',    TO_DATE('25-06-2003','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (30, 'Asociación de Fútbol de Temuco',         TO_DATE('12-01-2010','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (31, 'Asociación de Fútbol de Rancagua',       TO_DATE('08-09-1999','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (32, 'Asociación de Fútbol de Puerto Montt',   TO_DATE('20-04-2005','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (33, 'Asociación de Fútbol de La Serena',      TO_DATE('14-08-2012','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (34, 'Asociación de Fútbol de Chillán',        TO_DATE('01-12-2018','DD-MM-YYYY'), 'A');

INSERT INTO nacionalidad (descripcion) VALUES ('Chilena');
INSERT INTO nacionalidad (descripcion) VALUES ('Argentina');
INSERT INTO nacionalidad (descripcion) VALUES ('Peruana');
INSERT INTO nacionalidad (descripcion) VALUES ('Boliviana');
INSERT INTO nacionalidad (descripcion) VALUES ('Brasileña');

INSERT INTO club_futbol VALUES (seq_club_futbol.NEXTVAL, 'Colo-Colo',            500000000, 'Av. Marathon 5300',               'Profesional');
INSERT INTO club_futbol VALUES (seq_club_futbol.NEXTVAL, 'Universidad de Chile', 450000000, 'Av. El Parrón 0931',              'Profesional');
INSERT INTO club_futbol VALUES (seq_club_futbol.NEXTVAL, 'Deportes Antofagasta', 180000000, 'Avenida Angamos 01606',           'Profesional');
INSERT INTO club_futbol VALUES (seq_club_futbol.NEXTVAL, 'Huachipato',           220000000, 'Avenida Desiderio García 909',    'Profesional');
INSERT INTO club_futbol VALUES (seq_club_futbol.NEXTVAL, 'Ñublense',             170000000, 'Avenida Pedro Aguirre Cerda 1003','Profesional');

COMMIT;

SELECT 'ID:' || id_asociacion || ' * ' || nombre_asociacion AS "ASOCIACION",
       TO_CHAR(fecha_creacion, 'DD-MM-YYYY')                AS "CREADA",
       tipo_asociacion                                       AS "TIPO"
FROM   asociacion
WHERE  tipo_asociacion = 'P'
AND    EXTRACT(YEAR FROM fecha_creacion) > 2000
ORDER  BY fecha_creacion DESC;

SELECT id_club            AS "CLUB",
       nombre_club        AS "NOMBRE CLUB",
       patrimonio         AS "PATRIMONIO EN PESOS",
       patrimonio / 955   AS "PATRIMONIO EN DOLARES"
FROM   club_futbol
WHERE  nombre_club LIKE '%a%'
AND    patrimonio > 200000000
AND    tipo_club = 'Profesional'
ORDER  BY id_club DESC;
