-- ============================================================
-- Sistema de Lecturas y Simulación de Consumo Energético
-- Corpoelec | Maoruso Electric
-- Base de Datos: PostgreSQL
-- Autor: Mauricio Hernández
-- ============================================================

-- Eliminar tablas si existen (útil al reiniciar en desarrollo)
DROP TABLE IF EXISTS dispositivos CASCADE;
DROP TABLE IF EXISTS simulaciones CASCADE;
DROP TABLE IF EXISTS sustituciones CASCADE;
DROP TABLE IF EXISTS lecturas CASCADE;
DROP TABLE IF EXISTS medidores CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

-- ============================================================
-- TABLA: usuarios
-- Técnicos y administradores del sistema
-- ============================================================
CREATE TABLE usuarios (
    id               SERIAL PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    apellido         VARCHAR(100) NOT NULL,
    nacionalidad     VARCHAR(1)   NOT NULL DEFAULT 'V' CHECK (nacionalidad IN ('V', 'E')),
    username         VARCHAR(20)  NOT NULL UNIQUE,
    password_hash    VARCHAR(255) NOT NULL,
    rol              VARCHAR(20)  NOT NULL CHECK (rol IN ('tecnico', 'admin')),
    activo           BOOLEAN      DEFAULT TRUE,
    fecha_creacion   TIMESTAMP    DEFAULT NOW()
);

-- ============================================================
-- TABLA: clientes
-- Abonados residenciales y comerciales de Corpoelec
-- ============================================================
CREATE TABLE clientes (
    id               SERIAL PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    apellido         VARCHAR(100) NOT NULL,
    cedula_rif       VARCHAR(20)  NOT NULL UNIQUE,
    telefono         VARCHAR(20),
    tipo             VARCHAR(20)  NOT NULL CHECK (tipo IN ('residencial', 'comercial')),
    zona             VARCHAR(100) NOT NULL,
    direccion        TEXT         NOT NULL,
    fecha_registro   TIMESTAMP    DEFAULT NOW()
);

-- ============================================================
-- TABLA: medidores
-- Equipos físicos instalados en los clientes
-- ============================================================
CREATE TABLE medidores (
    id                  SERIAL PRIMARY KEY,
    id_cliente          INTEGER      NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
    codigo              VARCHAR(50)  NOT NULL UNIQUE,
    tipo                VARCHAR(50)  NOT NULL CHECK (tipo IN ('monofasico', 'bifasico', 'trifasico')),
    marca               VARCHAR(100),
    fecha_instalacion   DATE         NOT NULL,
    estado              VARCHAR(20)  NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'sustituido', 'dañado'))
);

-- ============================================================
-- TABLA: lecturas
-- Mediciones registradas por los técnicos
-- ============================================================
CREATE TABLE lecturas (
    id                  SERIAL PRIMARY KEY,
    id_medidor          INTEGER      NOT NULL REFERENCES medidores(id) ON DELETE RESTRICT,
    id_tecnico          INTEGER      NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    fecha_lectura       DATE         NOT NULL,
    valor_kwh           NUMERIC(10,2) NOT NULL CHECK (valor_kwh >= 0),
    consumo_periodo     NUMERIC(10,2) CHECK (consumo_periodo >= 0),
    es_sustitucion      BOOLEAN      DEFAULT FALSE,
    observaciones       TEXT,
    fecha_registro      TIMESTAMP    DEFAULT NOW()
);

-- ============================================================
-- TABLA: sustituciones
-- Registro de reemplazos de medidores
-- ============================================================
CREATE TABLE sustituciones (
    id                      SERIAL PRIMARY KEY,
    id_medidor_anterior     INTEGER   NOT NULL REFERENCES medidores(id) ON DELETE RESTRICT,
    id_medidor_nuevo        INTEGER   NOT NULL REFERENCES medidores(id) ON DELETE RESTRICT,
    id_tecnico              INTEGER   NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    fecha_sustitucion       DATE      NOT NULL,
    motivo                  TEXT      NOT NULL,
    fecha_registro          TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABLA: simulaciones
-- Evaluaciones de consumo ante reclamos o instalaciones
-- ============================================================
CREATE TABLE simulaciones (
    id                  SERIAL PRIMARY KEY,
    id_medidor          INTEGER       NOT NULL REFERENCES medidores(id) ON DELETE RESTRICT,
    id_tecnico          INTEGER       NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    fecha_simulacion    DATE          NOT NULL,
    consumo_simulado    NUMERIC(10,2) NOT NULL CHECK (consumo_simulado >= 0),
    consumo_real        NUMERIC(10,2),
    diferencia          NUMERIC(10,2),
    resultado           TEXT,
    fecha_registro      TIMESTAMP     DEFAULT NOW()
);

-- ============================================================
-- TABLA: dispositivos
-- Equipos eléctricos registrados en una simulación
-- ============================================================
CREATE TABLE dispositivos (
    id                  SERIAL PRIMARY KEY,
    id_simulacion       INTEGER       NOT NULL REFERENCES simulaciones(id) ON DELETE CASCADE,
    nombre              VARCHAR(150)  NOT NULL,
    potencia_w          NUMERIC(10,2) NOT NULL CHECK (potencia_w > 0),
    horas_dia           NUMERIC(5,2)  NOT NULL CHECK (horas_dia > 0 AND horas_dia <= 24),
    dias_mes            INTEGER       NOT NULL DEFAULT 30 CHECK (dias_mes > 0 AND dias_mes <= 31),
    consumo_mensual_kwh NUMERIC(10,2)
);