CREATE SCHEMA laboratorio_clinico;
SET search_path TO laboratorio_clinico;

-- =============== TABLAS ===============
-- 1. TABLA PACIENTE
CREATE TABLE paciente (
    id_paciente BIGSERIAL PRIMARY KEY,
    nro_documento TEXT NOT NULL UNIQUE CHECK (nro_documento ~ '^[0-9]{8}$'),
    nombres TEXT NOT NULL,
    apellidos TEXT NOT NULL,
    fecha_nacimiento DATE NOT NULL CHECK (fecha_nacimiento <= CURRENT_DATE),
    sexo CHAR(1) NOT NULL CHECK (sexo IN ('M','F'))
);

-- 2. TABLA MEDICO
CREATE TABLE medico (
    id_medico BIGSERIAL PRIMARY KEY,
    nombres TEXT NOT NULL,
    apellidos TEXT NOT NULL
);

-- 3. TABLA BIOQUIMICO
CREATE TABLE bioquimico (
    id_bioquimico BIGSERIAL PRIMARY KEY,
    nombres TEXT NOT NULL,
    apellidos TEXT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 4. TABLA AREA DE LABORATORIO
CREATE TABLE area_laboratorio (
    id_area_laboratorio BIGSERIAL PRIMARY KEY,
    nombre_area TEXT NOT NULL UNIQUE
);

-- 5. TABLA EQUIPO
CREATE TABLE equipo (
    id_equipo BIGSERIAL PRIMARY KEY,
    nombre TEXT NOT NULL UNIQUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 6. TABLA EXAMEN
CREATE TABLE examen (
    id_examen BIGSERIAL PRIMARY KEY,
    nombre TEXT NOT NULL UNIQUE,
    id_area_laboratorio BIGINT NOT NULL
        REFERENCES area_laboratorio(id_area_laboratorio)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    unidad_medida TEXT NOT NULL,
    valor_referencia TEXT NOT NULL
);

-- 7. TABLA ORDEN DE ANALISIS
CREATE TABLE orden_analisis (
    id_orden BIGSERIAL PRIMARY KEY,
    id_paciente BIGINT NOT NULL
        REFERENCES paciente(id_paciente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    id_medico BIGINT NOT NULL
        REFERENCES medico(id_medico)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    fecha_emision TIMESTAMP NOT NULL DEFAULT NOW(),
    estado TEXT NOT NULL CHECK (estado IN ('PENDIENTE','COMPLETADA','CANCELADA'))
);

-- 8. TABLA ORDEN_EXAMEN (N:M entre orden_analisis y examen)
CREATE TABLE orden_examen (
    id_orden BIGINT NOT NULL REFERENCES orden_analisis(id_orden)
        ON UPDATE CASCADE ON DELETE CASCADE,
    id_examen BIGINT NOT NULL REFERENCES examen(id_examen)
        ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (id_orden, id_examen)
);

-- 9. TABLA EQUIPO_EXAMEN (N:M entre equipo y examen)
CREATE TABLE equipo_examen (
    id_equipo BIGINT NOT NULL REFERENCES equipo(id_equipo)
        ON UPDATE CASCADE ON DELETE CASCADE,
    id_examen BIGINT NOT NULL REFERENCES examen(id_examen)
        ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (id_equipo, id_examen)
);

-- 10. TABLA RESULTADO_EXAMEN
CREATE TABLE resultado_examen (
    id_resultado BIGSERIAL PRIMARY KEY,
    id_orden BIGINT NOT NULL,
    id_examen BIGINT NOT NULL,
    id_bioquimico BIGINT NOT NULL REFERENCES bioquimico(id_bioquimico)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    valor_obtenido TEXT NOT NULL,
    fecha_validacion TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_orden_examen
        FOREIGN KEY (id_orden, id_examen)
        REFERENCES orden_examen(id_orden, id_examen)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ====== INSERTAMOS DATOS EN LAS TABLAS ======
INSERT INTO paciente (nro_documento, nombres, apellidos, fecha_nacimiento, sexo)
VALUES
('12345678', 'Carlos', 'Torres', '2004-07-12', 'M'),
('23456789', 'María', 'López', '1999-03-22', 'F'),
('34567890', 'Josué', 'García', '1985-01-15', 'M'),
('45678901', 'Ana', 'Cruz', '2001-11-05', 'F');

INSERT INTO medico (nombres, apellidos)
VALUES
('Luis', 'Salazar'),
('Victoria', 'Mendoza'),
('Pedro', 'Ortega');

INSERT INTO bioquimico (nombres, apellidos, activo)
VALUES
('Ricardo', 'Pérez', TRUE),
('Lucía', 'Ramírez', TRUE),
('Jorge', 'Huamán', FALSE);

INSERT INTO area_laboratorio (nombre_area)
VALUES
('Hematología'),
('Bioquímica'),
('Inmunología'),
('Microbiología');

INSERT INTO equipo (nombre, activo)
VALUES
('Analizador Hematológico Sysmex', TRUE),
('Centrífuga Eppendorf 5702', TRUE),
('Analizador de Química Roche', TRUE),
('Microscopio Nikon E200', TRUE);

INSERT INTO examen (nombre, id_area_laboratorio, unidad_medida, valor_referencia)
VALUES
('Hemograma Completo', 1, 'cel/µL', '4500-11000'),
('Glucosa', 2, 'mg/dL', '70-110'),
('Proteína C Reactiva', 3, 'mg/L', '0-5'),
('Cultivo Bacteriano', 4, 'N/A', 'Negativo'),
('Colesterol Total', 2, 'mg/dL', '<200'),
('Urea', 2, 'mg/dL', '15-40');

INSERT INTO orden_analisis (id_paciente, id_medico, fecha_emision, estado)
VALUES
(1, 1, '2025-01-10 09:00:00', 'PENDIENTE'),
(2, 2, '2025-01-11 10:30:00', 'COMPLETADA'),
(3, 1, '2025-01-12 14:20:00', 'PENDIENTE'),
(4, 3, '2025-01-13 08:15:00', 'PENDIENTE');

INSERT INTO orden_examen (id_orden, id_examen)
VALUES
(1, 1),  -- Orden 1 → Hemograma
(1, 2),  -- Orden 1 → Glucosa
(2, 3),  -- Orden 2 → PCR
(2, 2),  -- Orden 2 → Glucosa
(3, 4),  -- Orden 3 → Cultivo
(3, 1),  -- Orden 3 → Hemograma
(4, 2),  -- Orden 4 → Glucosa
(4, 6);  -- Orden 4 → Urea

INSERT INTO equipo_examen (id_equipo, id_examen)
VALUES
(1, 1), -- Hemograma usa analizador hematológico
(3, 2), -- Glucosa usa analizador químico
(3, 5), -- Colesterol usa analizador químico
(3, 6), -- Urea usa analizador químico
(4, 4); -- Cultivo usa microscopio

INSERT INTO resultado_examen (id_orden, id_examen, id_bioquimico, valor_obtenido, fecha_validacion)
VALUES
(2, 3, 1, '2.1', '2025-01-12 09:00:00'),
(2, 2, 2, '98', '2025-01-12 09:10:00'),
(1, 1, 1, '8000', '2025-01-11 11:00:00');

--  TEMA 2 – ADMINISTRACIÓN DE BD: USUARIOS, ROLES Y PRIVILEGIOS
--  Basado en la Sesión 03: Administración de BD (UPCH)

-- ============================================
-- 1. CREACIÓN DE ROLES (GRUPOS DE PERMISOS)
-- Roles sin LOGIN → sirven para agrupar privilegios
-- ============================================

-- Rol administrador: controla el esquema y todos sus objetos
CREATE ROLE rol_admin_datos NOLOGIN;

-- Rol operador / registrador: inserta y actualiza datos
CREATE ROLE rol_operador NOLOGIN;

-- Rol de solo consulta: únicamente lectura
CREATE ROLE rol_consulta NOLOGIN;


-- ============================================
-- 2. USUARIOS (ROLES CON LOGIN)
-- ============================================

CREATE ROLE usuario_admin LOGIN PASSWORD 'admin123';
GRANT rol_admin_datos TO usuario_admin;

CREATE ROLE usuario_operador LOGIN PASSWORD 'operador123';
GRANT rol_operador TO usuario_operador;

CREATE ROLE usuario_lector LOGIN PASSWORD 'lector123';
GRANT rol_consulta TO usuario_lector;


-- ============================================
-- 3. SEGURIDAD EN EL ESQUEMA PUBLIC
-- (basado en Sesión 03 – buenas prácticas)
-- Evitar que cualquier usuario cree objetos allí
-- ============================================

REVOKE CREATE ON SCHEMA public FROM PUBLIC;


-- ============================================
-- 4. PRIVILEGIOS SOBRE EL ESQUEMA PRIVADO
-- (laboratorio_clinico)
-- ============================================

-- ADMIN → control total sobre el esquema
GRANT USAGE, CREATE ON SCHEMA laboratorio_clinico TO rol_admin_datos;
GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA laboratorio_clinico TO rol_admin_datos;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA laboratorio_clinico TO rol_admin_datos;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA laboratorio_clinico TO rol_admin_datos;

-- OPERADOR → inserta, actualiza, consulta
GRANT USAGE ON SCHEMA laboratorio_clinico TO rol_operador;

GRANT SELECT, INSERT, UPDATE ON paciente TO rol_operador;
GRANT SELECT ON medico TO rol_operador;
GRANT SELECT ON bioquimico TO rol_operador;
GRANT SELECT ON area_laboratorio TO rol_operador;
GRANT SELECT ON equipo TO rol_operador;
GRANT SELECT ON examen TO rol_operador;

GRANT SELECT, INSERT, UPDATE ON orden_analisis TO rol_operador;
GRANT SELECT, INSERT ON orden_examen TO rol_operador;
GRANT SELECT, INSERT ON resultado_examen TO rol_operador;

-- Procedimientos permitidos
GRANT EXECUTE ON FUNCTION registrar_orden_analisis(TEXT, BIGINT, BIGINT[]) TO rol_operador;
GRANT EXECUTE ON FUNCTION cancelar_orden_analisis(BIGINT) TO rol_operador;

-- CONSULTA → solo SELECT
GRANT USAGE ON SCHEMA laboratorio_clinico TO rol_consulta;
GRANT SELECT ON ALL TABLES IN SCHEMA laboratorio_clinico TO rol_consulta;


-- ============================================
-- 5. DOCUMENTACIÓN DE ROLES Y PRIVILEGIOS
-- ============================================

CREATE TABLE admin_documentacion_roles (
    id_doc BIGSERIAL PRIMARY KEY,
    usuario TEXT NOT NULL,
    roles_asignados TEXT NOT NULL,
    privilegios_efectivos TEXT NOT NULL,
    fecha_registro TIMESTAMP DEFAULT NOW()
);

INSERT INTO admin_documentacion_roles (usuario, roles_asignados, privilegios_efectivos)
VALUES
('usuario_admin', 'rol_admin_datos', 'Control total del esquema y objetos'),
('usuario_operador', 'rol_operador', 'SELECT, INSERT, UPDATE, ejecutar procedimientos'),
('usuario_lector', 'rol_consulta', 'Solo SELECT en todas las tablas');




-- =============== Procedimientos almacenados, transacciones y triggers ===============
-- =========================================================
-- 1) PROCEDIMIENTO: registrar_orden_analisis
CREATE OR REPLACE FUNCTION registrar_orden_analisis(
    p_nro_documento TEXT,
    p_id_medico BIGINT,
    p_id_examenes BIGINT[]
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_paciente BIGINT;
    v_id_orden BIGINT;
    v_examen BIGINT;
BEGIN
    -- Buscar paciente por documento
    SELECT id_paciente
    INTO v_id_paciente
    FROM paciente
    WHERE nro_documento = p_nro_documento;

    IF v_id_paciente IS NULL THEN
        RAISE EXCEPTION 'No existe paciente con documento %', p_nro_documento;
    END IF;

    -- Verificar médico
    IF NOT EXISTS (SELECT 1 FROM medico WHERE id_medico = p_id_medico) THEN
        RAISE EXCEPTION 'No existe médico con id %', p_id_medico;
    END IF;

    -- Crear la orden (estado por defecto PENDIENTE)
    INSERT INTO orden_analisis (id_paciente, id_medico, estado)
    VALUES (v_id_paciente, p_id_medico, 'PENDIENTE')
    RETURNING id_orden INTO v_id_orden;

    -- Insertar exámenes asociados
    FOREACH v_examen IN ARRAY p_id_examenes LOOP
        IF NOT EXISTS (SELECT 1 FROM examen WHERE id_examen = v_examen) THEN
            RAISE EXCEPTION 'El examen % no existe', v_examen;
        END IF;

        INSERT INTO orden_examen (id_orden, id_examen)
        VALUES (v_id_orden, v_examen);
    END LOOP;

    RETURN v_id_orden;
END;
$$;

-- =========================================================
-- 2) PROCEDIMIENTO: registrar_resultado_examen

CREATE OR REPLACE FUNCTION registrar_resultado_examen(
    p_id_orden BIGINT,
    p_id_examen BIGINT,
    p_id_bioquimico BIGINT,
    p_valor_obtenido TEXT,
    OUT p_id_resultado BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar que la orden tenga ese examen
    IF NOT EXISTS (
        SELECT 1
        FROM orden_examen
        WHERE id_orden = p_id_orden
          AND id_examen = p_id_examen
    ) THEN
        RAISE EXCEPTION 'La orden % no tiene asociado el examen %',
            p_id_orden, p_id_examen;
    END IF;

    -- Evitar registrar dos resultados para el mismo examen de la misma orden
    IF EXISTS (
        SELECT 1
        FROM resultado_examen
        WHERE id_orden = p_id_orden
          AND id_examen = p_id_examen
    ) THEN
        RAISE EXCEPTION 'Ya existe un resultado para orden % y examen %',
            p_id_orden, p_id_examen;
    END IF;

    -- Validar que el bioquímico exista y esté activo
    IF NOT EXISTS (
        SELECT 1
        FROM bioquimico
        WHERE id_bioquimico = p_id_bioquimico
          AND activo = TRUE
    ) THEN
        RAISE EXCEPTION 'El bioquímico % no existe o está inactivo',
            p_id_bioquimico;
    END IF;

    -- Insertar resultado
    INSERT INTO resultado_examen (id_orden, id_examen, id_bioquimico, valor_obtenido)
    VALUES (p_id_orden, p_id_examen, p_id_bioquimico, p_valor_obtenido)
    RETURNING id_resultado INTO p_id_resultado;
END;
$$;

-- =========================================================
-- 3) PROCEDIMIENTO: cancelar_orden_analisis
CREATE OR REPLACE FUNCTION cancelar_orden_analisis(
    p_id_orden BIGINT,
    OUT p_se_cancelo BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_estado_actual TEXT;
BEGIN
    SELECT estado
    INTO v_estado_actual
    FROM orden_analisis
    WHERE id_orden = p_id_orden;

    IF v_estado_actual IS NULL THEN
        RAISE EXCEPTION 'No existe la orden %', p_id_orden;
    END IF;

    IF v_estado_actual = 'COMPLETADA' THEN
        p_se_cancelo := FALSE;
        RAISE NOTICE 'No se puede cancelar una orden COMPLETADA';
        RETURN;
    ELSIF v_estado_actual = 'CANCELADA' THEN
        p_se_cancelo := FALSE;
        RAISE NOTICE 'La orden % ya estaba cancelada', p_id_orden;
        RETURN;
    ELSE
        UPDATE orden_analisis
        SET estado = 'CANCELADA'
        WHERE id_orden = p_id_orden;

        p_se_cancelo := TRUE;
        RETURN;
    END IF;
END;
$$;

-- Transacciones 
-- =========================================================
-- TRANSACCIÓN 1: creación de una orden con varios exámenes
-- Muestra uso de BEGIN y COMMIT
-- =========================================================
BEGIN;

SELECT registrar_orden_analisis(
    p_nro_documento := '12345678',   -- paciente existente
    p_id_medico := 1,            -- médico existente
    p_id_examenes := ARRAY[1,2]    -- exámenes existentes
) AS nueva_orden;

COMMIT;

-- =========================================================
-- TRANSACCIÓN 2: ejemplo con ROLLBACK
-- =========================================================
BEGIN;

-- Intentar registrar un resultado para probar validaciones
SELECT registrar_resultado_examen(
    p_id_orden := 2,
    p_id_examen := 3,
    p_id_bioquimico := 1,
    p_valor_obtenido := '2.5'
);

-- Supongamos que luego detectas que la orden era incorrecta:
ROLLBACK;
-- Trigers 
--1 
-- =========================================================
-- TABLA DE AUDITORÍA PARA ORDENES
-- Registra cambios de estado en orden_analisis
-- =========================================================
CREATE TABLE orden_analisis_auditoria (
    id_auditoria BIGSERIAL PRIMARY KEY,
    id_orden BIGINT NOT NULL,
    estado_anterior TEXT,
    estado_nuevo TEXT,
    usuario TEXT,
    fecha_cambio TIMESTAMP NOT NULL DEFAULT NOW()
);
-- =========================================================
-- TRIGGER 1: Auditoría de cambios de estado de orden_analisis

CREATE OR REPLACE FUNCTION trg_auditar_estado_orden()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Solo registramos cuando cambie realmente el estado
    IF NEW.estado IS DISTINCT FROM OLD.estado THEN
        INSERT INTO orden_analisis_auditoria(
            id_orden,
            estado_anterior,
            estado_nuevo,
            usuario,
            fecha_cambio
        )
        VALUES (
            OLD.id_orden,
            OLD.estado,
            NEW.estado,
            current_user,
            NOW()
        );
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER tg_auditar_estado_orden
AFTER UPDATE OF estado ON orden_analisis
FOR EACH ROW
EXECUTE FUNCTION trg_auditar_estado_orden();

-- 

-- 2 
CREATE OR REPLACE FUNCTION trg_validar_resultado_examen()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_estado TEXT;
    v_fecha_emision TIMESTAMP;
BEGIN
    SELECT estado, fecha_emision
    INTO v_estado, v_fecha_emision
    FROM orden_analisis
    WHERE id_orden = NEW.id_orden;

    IF v_estado IS NULL THEN
        RAISE EXCEPTION 'No existe la orden %', NEW.id_orden;
    END IF;

    IF v_estado = 'CANCELADA' THEN
        RAISE EXCEPTION 'No se pueden registrar resultados para una orden CANCELADA (orden %)',
            NEW.id_orden;
    END IF;

    IF NEW.fecha_validacion < v_fecha_emision THEN
        RAISE EXCEPTION 'La fecha de validación (%) no puede ser menor que la fecha de emisión (%)',
            NEW.fecha_validacion, v_fecha_emision;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER tg_validar_resultado_examen
BEFORE INSERT OR UPDATE ON resultado_examen
FOR EACH ROW
EXECUTE FUNCTION trg_validar_resultado_examen();

-- 3: 
-- =========================================================
-- TRIGGER 3: Actualización automática del estado de la orden
-- =========================================================
CREATE OR REPLACE FUNCTION trg_actualizar_estado_orden()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_orden BIGINT;
    v_cantidad_pedidos INTEGER;
    v_cantidad_resultados INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_id_orden := NEW.id_orden;
    ELSE
        v_id_orden := OLD.id_orden;
    END IF;

    -- Cuántos exámenes tiene la orden
    SELECT COUNT(*)
    INTO v_cantidad_pedidos
    FROM orden_examen
    WHERE id_orden = v_id_orden;

    -- Cuántos resultados registrados
    SELECT COUNT(*)
    INTO v_cantidad_resultados
    FROM resultado_examen
    WHERE id_orden = v_id_orden;

    -- Si no hay exámenes, no hacemos nada
    IF v_cantidad_pedidos = 0 THEN
        IF TG_OP = 'INSERT' THEN
            RETURN NEW;
        ELSE
            RETURN OLD;
        END IF;
    END IF;

    IF v_cantidad_resultados = v_cantidad_pedidos THEN
        UPDATE orden_analisis
        SET estado = 'COMPLETADA'
        WHERE id_orden = v_id_orden;
    ELSE
        UPDATE orden_analisis
        SET estado = 'PENDIENTE'
        WHERE id_orden = v_id_orden
          AND estado <> 'CANCELADA'; -- no tocar si está cancelada
    END IF;

    IF TG_OP = 'INSERT' THEN
        RETURN NEW;
    ELSE
        RETURN OLD;
    END IF;
END;
$$;

CREATE TRIGGER tg_actualizar_estado_orden
AFTER INSERT OR DELETE ON resultado_examen
FOR EACH ROW
EXECUTE FUNCTION trg_actualizar_estado_orden();
