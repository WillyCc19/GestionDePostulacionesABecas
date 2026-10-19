-- ============================================================================
-- SISTEMA DE GESTIÓN DE LABORATORIO CLÍNICO
-- BASES DE DATOS II | CONSULTAS SQL Y VISTAS
-- Motor: PostgreSQL
-- ============================================================================

-- ====================== PARTE 1: VISTAS ================================

-- Vista 1: muestra las órdenes pendientes junto con los datos de sus pacientes.
CREATE OR REPLACE VIEW vw_pacientes_ordenes_pendientes AS
SELECT p.id_paciente, p.nombre, p.apellido, o.id_orden, o.fecha_emision, o.estado
FROM paciente AS p
INNER JOIN orden_analisis AS o ON o.id_paciente = p.id_paciente
WHERE o.estado = 'PENDIENTE';

-- Vista 2: muestra cada examen junto con el área clínica a la que pertenece.
CREATE OR REPLACE VIEW vw_examenes_por_area AS
SELECT e.id_examen, e.nombre AS examen, a.id_area_laboratorio,
       a.nombre AS area
FROM examen AS e
INNER JOIN area_laboratorio AS a
  ON a.id_area_laboratorio = e.id_area_laboratorio;

-- Vista 3: cuenta cuántos exámenes están registrados en cada área.
-- LEFT JOIN conserva áreas que todavía no tienen exámenes.
CREATE OR REPLACE VIEW vw_cantidad_examenes_por_area AS
SELECT a.id_area_laboratorio, a.nombre AS area,
       COUNT(e.id_examen) AS cantidad_examenes
FROM area_laboratorio AS a
LEFT JOIN examen AS e ON e.id_area_laboratorio = a.id_area_laboratorio
GROUP BY a.id_area_laboratorio, a.nombre;

-- Vista 4: cuenta cuántas órdenes ha emitido cada médico.
-- LEFT JOIN también incluye médicos sin órdenes.
CREATE OR REPLACE VIEW vw_medicos_cantidad_ordenes AS
SELECT m.id_medico, m.nombre, m.apellido,
       COUNT(o.id_orden) AS cantidad_ordenes
FROM medico AS m
LEFT JOIN orden_analisis AS o ON o.id_medico = m.id_medico
GROUP BY m.id_medico, m.nombre, m.apellido;

-- ===================== PARTE 2: CONSULTAS SQL ============================
-- FILTROS: WHERE / LIKE / BETWEEN

-- 2.1. Pacientes cuyo nombre empieza con la letra «A».
SELECT * FROM paciente
WHERE nombre LIKE 'A%';

-- 2.2. Órdenes emitidas durante un intervalo de fechas.
-- Cambia las fechas de ejemplo según la búsqueda deseada.
SELECT * FROM orden_analisis
WHERE fecha_emision >= DATE '2025-01-01'
  AND fecha_emision < DATE '2025-02-01';

-- 2.3. Bioquímicos que actualmente están activos.
SELECT * FROM bioquimico
WHERE activo = TRUE;


-- ============================================================================
-- JOINS: INNER JOIN / LEFT JOIN

-- 2.4. Muestra cada orden con el paciente que la solicitó.
SELECT o.id_orden, o.fecha_emision, o.estado,
       p.id_paciente, p.nombre, p.apellido
FROM paciente AS p
INNER JOIN orden_analisis AS o ON o.id_paciente = p.id_paciente;

-- 2.5. Lista todos los exámenes, incluso si no tienen equipos asociados.
SELECT e.id_examen, e.nombre AS examen, ee.id_equipo
FROM examen AS e
LEFT JOIN equipo_examen AS ee ON ee.id_examen = e.id_examen;

-- 2.6. Muestra los exámenes asociados a una orden concreta.
-- Cambia 1 por el ID de la orden que quieras consultar.
SELECT oe.id_orden, e.id_examen, e.nombre AS examen
FROM orden_examen AS oe
INNER JOIN examen AS e ON e.id_examen = oe.id_examen
WHERE oe.id_orden = 1;


-- ============================================================================
-- FUNCIONES AGREGADAS: COUNT / MIN / MAX / SUM

-- 2.7. Cuenta el total de pacientes registrados.
SELECT COUNT(*) AS total_pacientes FROM paciente;

-- 2.8. Devuelve la fecha de la orden más antigua.
SELECT MIN(fecha_emision) AS primera_orden FROM orden_analisis;

-- 2.9. Busca el mayor ID de paciente (no necesariamente el más reciente).
SELECT MAX(id_paciente) AS mayor_id_paciente FROM paciente;

-- 2.10. Cuenta los equipos activos sumando 1 por cada equipo habilitado.
SELECT COALESCE(SUM(CASE WHEN activo THEN 1 ELSE 0 END), 0)
       AS total_equipos_activos
FROM equipo;


-- ============================================================================
-- AGRUPACIONES Y ORDENAMIENTO: GROUP BY / ORDER BY

-- 2.11. Cuenta las órdenes existentes para cada estado.
SELECT estado, COUNT(*) AS cantidad_ordenes
FROM orden_analisis
GROUP BY estado
ORDER BY estado;

-- 2.12. Ordena los pacientes alfabéticamente por apellido y nombre.
SELECT * FROM paciente
ORDER BY apellido ASC, nombre ASC;

-- 2.13. Identifica los exámenes más solicitados, de mayor a menor.
SELECT e.id_examen, e.nombre AS examen,
       COUNT(oe.id_orden) AS veces_solicitado
FROM examen AS e
INNER JOIN orden_examen AS oe ON oe.id_examen = e.id_examen
GROUP BY e.id_examen, e.nombre
ORDER BY veces_solicitado DESC, e.nombre ASC;


-- ============================================================================
-- SUBCONSULTAS: IN / NOT IN / EXISTS

-- 2.14. Busca exámenes que pertenecen al mismo área que «Glucosa».
SELECT * FROM examen
WHERE id_area_laboratorio IN (
    SELECT id_area_laboratorio FROM examen WHERE nombre = 'Glucosa'
);

-- 2.15. Médicos que emitieron al menos una orden el 12 de enero de 2025.
-- El informe menciona el día 12 de enero, pero no especifica el año;
-- se utiliza 2025 como ejemplo editable.
SELECT * FROM medico
WHERE id_medico IN (
    SELECT id_medico FROM orden_analisis
    WHERE fecha_emision >= TIMESTAMP '2025-01-12 00:00:00'
      AND fecha_emision < TIMESTAMP '2025-01-13 00:00:00'
);

-- 2.16. Áreas que tienen más de dos exámenes registrados.
SELECT * FROM area_laboratorio
WHERE id_area_laboratorio IN (
    SELECT id_area_laboratorio FROM examen
    GROUP BY id_area_laboratorio
    HAVING COUNT(*) > 2
);

-- 2.17. Exámenes que no tienen equipo asociado.
-- Se utiliza NOT IN según la técnica descrita en el informe.
SELECT * FROM examen
WHERE id_examen NOT IN (
    SELECT id_examen FROM equipo_examen WHERE id_examen IS NOT NULL
);

-- 2.18. Pacientes que tienen al menos una orden registrada.
SELECT * FROM paciente AS p
WHERE EXISTS (
    SELECT 1 FROM orden_analisis AS o
    WHERE o.id_paciente = p.id_paciente
);


-- ============================================================================
-- CONSULTAS BASADAS EN VISTAS

-- 2.19. Consulta pacientes con órdenes que aún están pendientes.
SELECT * FROM vw_pacientes_ordenes_pendientes;

-- 2.20. Consulta el catálogo de exámenes junto con sus áreas.
SELECT * FROM vw_examenes_por_area;

-- 2.21. Consulta cuántos exámenes hay por área clínica.
SELECT * FROM vw_cantidad_examenes_por_area
ORDER BY cantidad_examenes DESC;

-- 2.22. Consulta cuántas órdenes registró cada médico.
SELECT * FROM vw_medicos_cantidad_ordenes
ORDER BY cantidad_ordenes DESC;


