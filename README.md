<div align="center">

# 🧪 Sistema de Gestión de Laboratorio Clínico

### Base de datos relacional para la administración de análisis clínicos

**Proyecto académico · Bases de Datos II · 2025**

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Database-4479A1?style=for-the-badge)
![Estado](https://img.shields.io/badge/Tipo-Proyecto%20acad%C3%A9mico-6C757D?style=for-the-badge)

</div>

---

## 📌 Acerca del proyecto

Este proyecto propone el **diseño e implementación de una base de datos para un laboratorio clínico**, con el objetivo de centralizar la información de pacientes, médicos, bioquímicos, exámenes, equipos y órdenes de análisis.

La solución utiliza **PostgreSQL** y aplica principios de modelado relacional, integridad de datos, control de acceso y automatización de operaciones mediante **procedimientos almacenados, transacciones y triggers**.

> 🎯 **Objetivo:** representar el flujo de trabajo de un laboratorio clínico y favorecer una gestión organizada, consistente y trazable de sus datos.

## ✨ Funcionalidades principales

| Módulo | Funcionalidad |
|:--|:--|
| 👤 **Pacientes** | Registro y administración de información de pacientes, con validaciones de datos. |
| 🩺 **Personal médico** | Gestión de médicos solicitantes y bioquímicos responsables de validar resultados. |
| 🧬 **Exámenes clínicos** | Catálogo de exámenes, áreas del laboratorio, rangos de referencia y unidades de medida. |
| 📋 **Órdenes de análisis** | Registro de órdenes y asociación de múltiples exámenes a cada una. |
| 🔬 **Equipos** | Relación entre equipos del laboratorio y exámenes que los requieren. |
| ✅ **Resultados** | Registro de resultados y validación según las reglas del proceso clínico. |
| 📊 **Consultas y reportes** | Vistas para consultar órdenes pendientes, exámenes por área y resúmenes de actividad. |
| 🔐 **Seguridad** | Roles y permisos diferenciados para administración, operación y consulta. |
| ⚙️ **Automatización** | Procedimientos, transacciones y triggers para validar procesos y mantener estados y auditorías. |

## 🛠️ Tecnologías y conceptos aplicados

- **Motor de base de datos:** PostgreSQL.
- **Lenguaje:** SQL.
- **Modelado:** entidades, relaciones **1:N** y **N:M**, claves primarias y foráneas.
- **Integridad:** restricciones `NOT NULL`, `UNIQUE`, `CHECK` y reglas de negocio.
- **Administración:** roles, usuarios y privilegios.
- **Consultas avanzadas:** `JOIN`, subconsultas, agregaciones, `GROUP BY` y vistas.
- **Lógica en la base de datos:** procedimientos almacenados, transacciones (`COMMIT` y `ROLLBACK`) y triggers.

## 🗂️ Estructura de la base de datos

El modelo contempla las siguientes entidades principales:

| Tabla | Propósito |
|:--|:--|
| `paciente` | Datos de los pacientes. |
| `medico` | Médicos que solicitan exámenes. |
| `bioquimico` | Profesionales que validan resultados. |
| `area_laboratorio` | Clasificación de áreas de trabajo. |
| `equipo` | Equipos disponibles para el análisis. |
| `examen` | Catálogo de pruebas clínicas. |
| `orden_analisis` | Solicitudes de exámenes para un paciente. |
| `orden_examen` | Asociación entre órdenes y exámenes. |
| `equipo_examen` | Asociación entre equipos y exámenes. |
| `resultado_examen` | Resultados de las pruebas realizadas. |

### Reglas de negocio destacadas

- Cada orden corresponde a un **paciente existente** y a un **médico registrado**.
- Una orden puede contener **varios exámenes**, sin duplicar el mismo examen en una orden.
- Los estados de las órdenes son `PENDIENTE`, `COMPLETADA` y `CANCELADA`.
- Solo un **bioquímico activo** puede validar resultados.
- Un resultado solo puede registrarse para un examen incluido en la orden correspondiente.
- Los cambios de estado pueden registrarse para mantener un historial de auditoría.

## ⚙️ Procesos automatizados

### Procedimientos almacenados

1. **`Registrar_orden_analisis`:** valida paciente, médico y exámenes; crea una orden pendiente y asocia los exámenes solicitados.
2. **`Registrar_resultado_examen`:** valida la relación entre orden y examen, evita duplicados y verifica que el bioquímico esté activo.
3. **`Cancelar_orden_analisis`:** permite cancelar órdenes pendientes y evita modificar órdenes completadas o ya canceladas.

### Triggers

| Trigger | Propósito |
|:--|:--|
| **Auditoría de órdenes** | Registrar cambios de estado, usuario responsable y fecha. |
| **Validación de resultados** | Impedir registros inconsistentes o asociados a órdenes canceladas. |
| **Actualización de estado** | Marcar órdenes como completadas cuando todos los exámenes cuentan con resultados. |

### Transacciones

Las operaciones que afectan varios registros se agrupan en transacciones para conservar la consistencia de la información. En caso de error, se utiliza la reversión de cambios mediante **`ROLLBACK`**.

## 📈 Consultas y vistas

El proyecto contempla vistas de consulta y reporte, entre ellas:

- `vw_pacientes_ordenes_pendientes`
- `vw_examenes_por_area`
- `vw_cantidad_examenes_por_area`
- `vw_medicos_cantidad_ordenes`

También aborda consultas con filtros, combinaciones de tablas, funciones agregadas y subconsultas para analizar pacientes, exámenes, órdenes y personal médico.

## 🎓 Contexto académico

Proyecto desarrollado para el curso **Bases de Datos II**, de la carrera de **Ingeniería Informática** de la **Universidad Peruana Cayetano Heredia (UPCH)**, durante **2025**.

**Equipo:**
- Willy Simeon Ccatamayo Vasquez
- Anderson Josue Delerna Infantes
- Joseph Manuel Lombaldi Quispe
- Josue Mogollon Flores

## 📚 Referencia

- [Documentación oficial de PostgreSQL](https://www.postgresql.org/docs/)

---

<div align="center">

**Proyecto académico enfocado en modelado relacional, integridad, seguridad y automatización de bases de datos.**

</div>
