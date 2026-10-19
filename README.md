## UNIVERSIDAD PERUANA CAYETANO HEREDIA

## Ingeniería informática

Curso:

Base de datos II

## Docente:

Ivan Omar Perez Masias

## Integrantes:

Ccatamayo Vasquez Willy Simeon - 71701284

Delerna Infantes Anderson Josue - 60915050

Lombaldi Quispe Joseph Manuel - 61190045

Mogollon Flores Josue - 74830435

## IV ciclo

## Tema 2:

Sistema de Gestión de Laboratorio Clínico

2025


## 1. Objetivos del proyecto:

## a. Objetivo general:

Desarrollar un sistema de gestión para un laboratorio clínico que permita administrar de manera eficiente la información de pacientes, médicos, bioquímicos, equipos y ordenes de análisis, garantizando la integridad, disponibilidad y confiabilidad de los datos mediante el uso de una base de datos.

## b. Objetivos específicos

- 1. Diseñar un modelo de base de datos que represente adecuadamente las entidades y procesos de un laboratorio clínico.

- 2. Implementar tablas con claves primarias, claves foráneas, restricciones y relaciones 1:N y N:M.

- 3. Insertar datos de prueba coherentes que permitan simular el funcionamiento de la base de datos.

- 4. Crear vistas lógicas y de reporte para facilitar la consulta y análisis de información relevante.

- 5. Gestionar roles, usuarios y privilegios para controlar el acceso a la información según niveles definidos.

- 6. Implementar procedimientos almacenados, transacciones y triggers que automaticen procesos y garanticen consistencia en las operaciones.

## 2. Enunciado del Proyecto

El presente proyecto consiste en el diseño e implementación de un Sistema de Gestión para un Laboratorio Clínico, cuyo objetivo es organizar y centralizar la información generada durante la atención de pacientes y la realización de exámenes médicos. Actualmente, los laboratorios manejan grandes volúmenes de datos relacionados con pacientes, órdenes médicas, exámenes solicitados, equipos utilizados y resultados validados por bioquímicos, lo que requiere una estructura de base de datos sólida que garantice integridad y accesibilidad.

El sistema permitirá registrar a los pacientes que acuden al laboratorio, los médicos que solicitan los exámenes, los bioquímicos encargados de validar los resultados, las áreas del laboratorio, los equipos disponibles y el catálogo de exámenes. Además, permitirá generar órdenes de análisis, asignar múltiples exámenes a cada orden y almacenar los resultados emitidos. Para asegurar el correcto funcionamiento del sistema se implementará un modelo relacional con claves primarias, claves foráneas y relaciones N:M, junto con roles, vistas, consultas avanzadas, procedimientos almacenados, transacciones y triggers. Esto permitirá simular el funcionamiento real de un laboratorio clínico y demostrar la aplicación de técnicas avanzadas de administración de bases de datos.


## 3. Ejercicio 1: Esquema y restricciones de integridad

- a. Tablas

- 1. Tabla “paciente”

```
CREATE TABLE
ERIAL PRIMARY KEY,
TEXT NOT NULL UNIQUE CHECK ( ~ 'Ale-91{8}$'),
TEXT NOT NULL,
EXT NOT NULL,
DATE NOT NULL CHECK ( = CURRENT_DATE),
NOT NULL CHECK ( IN
```

- 2. Tabla “medico”

```
CREATE TABLE
RIAL PRIMARY KEY,
NOT NULL,
XT NOT NULL
```

- 3. Tabla “bioquímico”

```
CREATE TABLE
B: PRIMARY KEY,
T NOT NULL,
T NOT NULL,
OLEAN NOT NULL DEFAULT TRUE
```

- 4. Tabla “area_laboratorio”

```
CREATE TABLE
BIGSERIAL PRIMARY KEY,
T NOT NULL UNIQUE
```

- 5. Tabla “equipo”

```
CREATE TABLE
AL PRIMARY KEY,
TEXT NOT NULL UNIQUE,
AN NOT NULL DEFAULT TRUE
```


- 6. Tabla “examen”

- 7. Tabla “orden_analisis”

- 8. Tabla “orden_examen” (N:M)

- 9. Tabla “equipo_examen (N:M)


## 10. Tabla “resultado_examen)

## b. Tipos de datos

Se usarán los siguientes tipos de datos para las tablas según corresponda:

| Tipo de dato | Uso |
| --- | --- |
| BIGSERIAL | Identificadores autoincreméntales (PK) |
| BIGINT | Claves foráneas a otras tablas |
| TEXT | Nombres, descripciones, referencias, rangos |
| DATE | Fechas de nacimiento |
| TIMESTAMP | Fechas y horas de emisión/validación |
| CHAR(1) | Atributo para definir el sexo |
| BOOLEAN | Estados activos/inactivos (bioquímicos y equipo) |

## c. PK y FK

Identificamos las PK utilizadas en las tablas:

| Tabla | PK |
| --- | --- |
| paciente | id_paciente |
| medico | id_medico |
| bioquimico | id_bioquimico |
| area_laboratorio | id_area_laboratorio |
| equipo | id_equipo |
| examen | id_examen |
| orden_analisis | id_orden, id_examen |
| orden_examen | id_orden, id_examen |
| equipo_examen | id_equipo_examen |
| resultado_examen | id_resultado_examen |


Identificamos las FK utilizadas en las tablas como también

| Tabla origen | Tabla destino FK |
| --- | --- |
| area_laboratorio paciente medico orden_analisis + examen equipo + examen bioquimico | examen id_area_laboratorio orden_analisis id_paciente orden_analisis id_medico orden_examen id_orden, id_examen equipo_examen id_equipo, id_examen resultado_examen id_bioquimico |

## d. Reglas de negocio

- 1. Paciente

- DNI único y debe de ser de 8 dígitos

- Sexo solo puede ser ‘M’ o ‘F’

- Fecha de nacimiento no puede pasar de la fecha actual

- 2. Exámenes

- Cada examen pertenece a un área de laboratorio

- Cada examen debe tener un rango de referencia

- Cada examen debe tener una unidad de medida

- 3. Ordenes de análisis

- Una orden solo la puede emitir un médico registrado

- Toda orden debe pertenecer a un paciente existente

- El estado solo puede ser: PENDIENTE, COMPLETADA o CANCELADA

- Una orden puede tener muchos exámenes

- 4. Orden – Examen (N:M)

- Una orden no puede tener dos veces el mismo examen

- Un examen puede estar en varias ordenes

- La combinación de orden – examen no puede duplicarse

- 5. Bioquímicos

- Solo los bioquímicos activos pueden validar los resultados

- 6. Equipos – Examen

- Un examen puede necesitar varios equipos

- Un equipo puede participar en varios exámenes

- La combinación de equipo – examen no puede duplicarse

- 7. Resultados de exámenes

- Solo puedes registrar un resultado si el examen está en la orden

- Debe registrar que bioquimico valido el resultado

- Cada resultado tiene una fecha de validación


## 4. Ejercicio 2: Administración de DB

## a. Roles

Se crean 3 roles: rol_admin, rol_operador, rol_consulta

## b. Usuarios

Se crean 3 usuarios:

Ahora se les asignamos tus roles a cada uno:

## c. Privilegios

Primero se les revoca los permisos PUBLIC


- Privilegios para rol_admin (control total)

```
GRANT ALL PRIVILEGES ON SCHEMA TO
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA
```

- Privilegios para rol_operador (insertar, actualizar, ejecutar SP)

- Privilegios para rol_consulta (solo select)

- d. Tabla resumen


## 5. Ejercicio 3: Vistas y Consultas SQL Avanzadas

## a. Listado numerado

- 1. Vistas

- 1.1. Vista 1: vw_pacientes_ordenes_pendientes

- 1.2. Vista 2: vw_examenes_por_area

- 1.3. Vista 3: vw_cantidad_examenes_por_area


- 1.4. Vista 4: vw_medicos_cantidad_ordenes

- 2. Consultas SQL

- SELECT con filtros (WHERE, LIKE, BETWEEN)

- 2.1. Pacientes cuyo nombre empieza con “A”

- 2.2. Ordenes emitidas entre dos fechas


- 2.3. Bioquímicos activos

## JOINS (INNER y LEFT)

- 2.4. INNER JOIN paciente – orden

## 2.5. FELT JOIN examen – equipo_examen


- 2.6. Obtener los exámenes de una orden especifica

- Funciones agregadas

- 2.7. Total de pacientes (COUNT(*))

- 2.8. Fecha de la primera orden (MIN)

- 2.9. Paciente con mayor id (MAX)


## 2.10. Suma de equipos activos (SUM)

## GROUP BY y ORDEN BY

2.11. Cantidad de órdenes por estado (GROUP BY)

- 2.12. Pacientes ordenados alfabéticamente por apellidos (ORDER BY)


- 2.13. Examen más solicitado (GROUP BY y ORDER BY)

## Subconsultas

- 2.14. Exámenes de la misma área (Glucosa)

- 2.15. Médicos que han emitido órdenes el 12 de enero (IN)


- 2.16. Áreas con más de 2 exámenes (IN)

- 2.17. Exámenes sin equipo asociado (NOT IN)

- 2.18. Pacientes que tienen al menos una orden (EXISTS)


- Consultas apoyadas en vistas

- 2.19. Ver pacientes con órdenes pendientes

- 2.20. Ver exámenes por su área

- 2.21. Ver reporte de cantidad de exámenes por área

- 2.22. Ver reporte de cantidad de órdenes por médico


## 6. Procedimientos almacenados, transacciones y triggers

## a. Procedimientos almacenados

- 1. Registrar_orden_analisis:

Este procedimiento crea una nueva orden de análisis a partir del DNI del paciente, el médico solicitante y un conjunto de exámenes. Primero valida que el paciente exista y que el médico sea válido en sus respectivas tablas.


Luego inserta la orden con estado inicial PENDIENTE y recorre el arreglo de exámenes para vincular cada uno en la tabla orden_examen, verificando que todos los exámenes existan. Al final, devuelve el id_orden generado, dejando la orden y sus exámenes correctamente registrados.

## Cambio:

## 2. Registrar_resultado_examen:


Este procedimiento registra el resultado de un examen específico dentro de una orden. Verifica que la orden tenga asociado ese examen, que todavía no exista un resultado previo para esa combinación y que el bioquímico exista y esté activo.

Si todas las validaciones se cumplen, inserta el registro en resultado_examen con la fecha de validación actual y devuelve el id_resultado. En caso de incumplir alguna regla, lanza una excepción y no guarda cambios.

## Cambios:

## 3. Cancelar_orden_analisis:


Este procedimiento intenta cancelar una orden cambiando su estado a CANCELADA. Primero verifica que la orden exista y consulta su estado actual.

Si la orden está PENDIENTE, se actualiza a CANCELADA y el parámetro de salida indica que la operación se realizó (TRUE). Si la orden está COMPLETADA o ya estaba CANCELADA, no se modifica y el procedimiento informa que no se pudo cancelar (FALSE).

Cambios:


## b. Transacciones:

- 1. Transacción 1: creación de orden con sus exámenes (caso exitoso)

Esta transacción agrupa la creación de una orden y el registro de sus exámenes en una única unidad de trabajo. Se utiliza BEGIN para iniciar la transacción, se llama al procedimiento registrar_orden_analisis y se finaliza con COMMIT para confirmar los cambios.

## Cambios:

## 2. Transacción 2: uso de Rollback explícito + error


Si dentro del procedimiento ocurre alguna validación fallida y se lanza una excepción, toda la transacción se revierte de forma automática y no se registra ni la orden ni los exámenes.

Triggers:

creación de la tabla donde vamos a registrar cambios de estado de las órdenes

## c. Trigger:

## 1. Trigger 1 – Auditoría de cambios de estado de la orden.


Este trigger se dispara después de actualizar el campo estado en la tabla orden_analisis. Su función es registrar cada cambio de estado en la tabla de auditoría orden_analisis_auditoria.

Para cada modificación, guarda el estado anterior, el nuevo estado, el usuario que realizó la operación y la fecha del cambio. Así se mantiene un historial de la evolución de cada orden, útil para trazabilidad y control interno.

Ejemplo de activación

Cambios:


## 2. Trigger 2 – Validación de reglas de negocio en resultado_examen

Este trigger se ejecuta antes de insertar o actualizar un registro en resultado_examen. Verifica que la orden exista, que no esté en estado CANCELADA y que la fecha de validación no sea anterior a la fecha de emisión de la orden.

Si alguna de estas condiciones no se cumple, el trigger lanza una excepción y evita la operación. Así se garantiza que solo se registren resultados válidos y coherentes con el flujo del laboratorio.

*Ejemplo*

## Cambios:


## 3. Trigger 3 – Actualización automática del estado de la orden

Este trigger se dispara después de insertar o eliminar resultados en la tabla resultado_examen. Su objetivo es mantener actualizado el estado de la orden en orden_analisis de forma automática.

Para ello, cuenta cuántos exámenes fueron solicitados en la orden y cuántos resultados hay registrados. Si ambas cantidades coinciden, la orden pasa a COMPLETADA; si falta al menos un resultado, la orden se queda o vuelve a PENDIENTE, siempre que no esté CANCELADA.


*Ejemplo de activación*

## Cambios:


## 7. Conclusiones del grupo

## a. Aprendizaje técnico

Desarrollar el Sistema de Gestión para el Laboratorio Clínico nos permitió afianzar muchos de los temas vistos durante el curso. Comenzamos entendiendo cómo traducir un escenario real a un modelo entidad–relación y cómo normalizarlo correctamente para evitar redundancias. También reforzamos la importancia de las claves primarias y foráneas para mantener ordenadas las relaciones entre entidades.

Además, tuvimos la oportunidad de implementar vistas, reglas de negocio, procedimientos almacenados, transacciones y triggers, comprobando cómo cada uno cumple un rol específico en la integridad y el funcionamiento del sistema. Este proceso nos ayudó a conectar la teoría con la práctica y a comprender cómo se construye una base de datos robusta y confiable.

## b. Trabajo colaborativo

La coordinación en equipo fue un aspecto fundamental para completar el proyecto. Desde el inicio, organizamos las tareas según las habilidades de cada integrante, lo que permitió trabajar en paralelo sin perder coherencia. Constantemente revisábamos los avances para asegurarnos de que el diseño, las tablas y las reglas de negocio estuvieran alineadas.

Esta dinámica nos enseñó que un proyecto de base de datos requiere comunicación clara y trabajo ordenado, ya que cualquier cambio afecta al resto del sistema. Gracias a esto, pudimos resolver problemas más rápido, intercambiar ideas y mejorar el diseño general. En conjunto, la experiencia reforzó nuestra capacidad de colaborar de manera efectiva, respetar los aportes de los demás y adaptarnos ante imprevistos.

## c. Aplicación real

El caso del laboratorio clínico nos ayudó a ver cómo los conceptos teóricos se aplican a un entorno cercano a la realidad: pacientes, médicos, órdenes de análisis, exámenes, equipos y resultados. Al traducir estos elementos a tablas, relaciones y reglas de negocio comprobamos cómo una base de datos bien diseñada facilita la trazabilidad de la información, el control de accesos y la automatización de procesos críticos, como la emisión de órdenes y el registro de resultados. Igualmente, al definir restricciones, transacciones y triggers, vimos de forma práctica cómo se puede proteger la integridad de los datos frente a errores de uso o inconsistencias, algo fundamental en un contexto de salud donde la información debe ser confiable. Esta experiencia nos permitió dimensionar el impacto que tiene una buena arquitectura de datos en la calidad del servicio, la reducción de errores humanos, la generación de reportes para la gestión del laboratorio y, en general, en el soporte a la toma de decisiones dentro de una organización de este tipo.

## Bibliografía:

The PostgreSQL Global Development Group. (2025). PostgreSQL: Documentation.

PostgreSQL. https://www.postgresql.org/docs/
