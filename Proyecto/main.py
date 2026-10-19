from flask import Flask, render_template, request
from flask import redirect, url_for
from mysql import connector
from dotenv import load_dotenv
import os

load_dotenv()

# Creamos un diccionario con los parámetros de conexión a la base de datos
db_config = {
    'host': os.getenv('HOST'), # Dirección del servidor de base de datos
    'user': os.getenv('USUARIO'), # Usuario para conectarse a la base de datos
    'password': os.getenv('CLAVE'), # Contraseña del usuario
    'database': os.getenv('ESQUEMA'), # Nombre del esquema (base de datos)
    'port': int(os.getenv('PUERTO')) # Puerto de conexión (por defecto suele ser 3306)
}

app = Flask(__name__)


# 1. Pagina Postulantes_estado --> SP 1. ObtenerPostulantesEstado

@app.route('/postulantes_estado', methods=['GET', 'POST'])
def postulantes_estado():
    estado = request.form.get('estado', '') # Obtenemos el valor del campo 'estado' del formulario

    conn = connector.connect(**db_config) # Establecemos conexión con la base de datos
    cursor = conn.cursor(dictionary=True) # Creamos cursor que devuelve resultados en formato diccionario

    cursor.callproc('ObtenerPostulantesEstado', [estado]) # Llamamos al procedimiento almacenado con el parámetro estado

    postulantes = [] # Lista vacía para almacenar los resultados del procedimiento
    for result in cursor.stored_results(): # Recorremos los resultados devueltos por el procedimiento
        postulantes.extend(result.fetchall()) # Añadimos los datos a la lista

    cursor.close() # Cerramos el cursor
    conn.close() # Cerramos la conexión

    return render_template('postulantes_estado.html', estudiantes=postulantes, estado=estado)



# 2. Pagina registro_persona --> 1. sp_registrar_persona 2. sp_registrar_direccion

@app.route('/registro_persona', methods=['GET', 'POST'])
def registro_persona():
    mensaje = '' # Inicializamos mensaje vacío
    personas = [] # Lista vacía para almacenar personas con dirección

    conn = connector.connect(**db_config) # Establecemos conexión con la base de datos
    cursor = conn.cursor(dictionary=True) # Creamos cursor que devuelve resultados en formato diccionario

    if request.method == 'POST': # Si el formulario fue enviado por POST
        # Obtenemos cada campo del formulario
        p_dni = request.form.get('dni')
        p_nombre = request.form.get('nombre')
        p_apellidopaterno = request.form.get('apellidopaterno')
        p_apellidomaterno = request.form.get('apellidomaterno')
        p_fecha_nacimiento = request.form.get('fecha_nacimiento')
        p_telefono = request.form.get('telefono')

        p_nombre_departamento = request.form.get('nombre_departamento')
        p_ciudad = request.form.get('ciudad')
        p_distrito = request.form.get('distrito')
        p_detalle_direccion = request.form.get('direccion_detalle')

        cursor.callproc('sp_registrar_persona', [ # Llamamos al SP para registrar la persona
            p_dni, p_nombre, p_apellidopaterno,
            p_apellidomaterno, p_fecha_nacimiento, p_telefono
        ])
        for result in cursor.stored_results(): # Extraemos el mensaje de la respuesta del SP
            mensaje_resultado = result.fetchone()
            mensaje = mensaje_resultado['mensaje'] # Guardamos el mensaje retornado

        # Si se registró correctamente, registrar dirección
        if mensaje == 'Registrado correctamente': # Si se registró correctamente la persona
            cursor.callproc('sp_registrar_direccion', [ # Llamamos al SP para registrar la dirección
                p_dni, p_nombre_departamento, p_ciudad, p_distrito, p_detalle_direccion
            ])
            conn.commit() # Confirmamos los cambios en la BD
            mensaje += ' Dirección registrada correctamente.'

    # Mostrar tabla de personas con dirección
    cursor.callproc('MostrarPersonasDireccion')
    for result in cursor.stored_results(): # Recorremos y guardamos los resultados
        personas.extend(result.fetchall())

    cursor.close() # Cerramos el cursor
    conn.close() # Cerramos la conexión

    return render_template('registro_persona.html', mensaje=mensaje, personas=personas)



# 3. Pagina resumen_revisor --> 1. sp_resumen_resultados_revisor 2. sp_ver_evaluaciones_detalle_revisor

@app.route('/resumen_revisor', methods=['GET', 'POST'])
def resumen_revisor():
    resumen = {} # Diccionario para resumen
    detalle = [] # Lista para detalle de evaluaciones

    if request.method == 'POST': # Si se envió formulario
        nombre = request.form.get('nombre') # Obtenemos los datos del formulario
        apellido = request.form.get('apellido')

        conn = connector.connect(**db_config) # Conectamos con la base de datos
        cursor = conn.cursor(dictionary=True) # Creamos cursor que devuelve resultados en formato diccionario

        # 1. Llamamos al SP de resumen general
        cursor.callproc('sp_resumen_resultados_revisor', [nombre, apellido])
        for result in cursor.stored_results(): # Recorremos el resultado
            resumen = result.fetchone() # Guardamos los resultados

        # 2. Llamamos al SP de detalle
        cursor.callproc('sp_ver_evaluaciones_detalle_revisor', [nombre, apellido])
        for result in cursor.stored_results(): # Recorremos el resultado
            detalle = result.fetchall() # Guardamos lista de evaluaciones

        cursor.close() # Cerramos cursor
        conn.close() # Cerramos conexión

    return render_template('resumen_revisor.html', resumen=resumen, detalle=detalle)



# 4. Pagina consultas_postulacion --> 1. BecariosPorPrograma 2. PostulantesPorPeriodo

@app.route('/consultas_postulacion', methods=['GET', 'POST'])
def consultas_postulacion():
    becarios = [] # Lista para becarios por programa
    resumen = [] # Lista para postulantes por periodo
    mensaje = '' # Mensaje de estado
    programa_nombre = '' # Nombre del programa actual
    periodo = '' # Periodo seleccionado
    tipo_consulta = request.form.get('tipo_consulta', '') # Tipo de consulta seleccionada

    if request.method == 'POST':
        conn = connector.connect(**db_config) # Conectamos a la base de datos
        cursor = conn.cursor(dictionary=True) # Cursor que devuelve resultados en formato diccionario

        if tipo_consulta == 'programa':
            programa_nombre = request.form.get('nombre_programa') # Obtener nombre del programa
            # 1. Llamada al SP BecariosPorPrograma
            cursor.callproc('BecariosPorPrograma', [programa_nombre])
            for result in cursor.stored_results():
                becarios = result.fetchall() # Obtener resultados
            if not becarios:
                mensaje = f"No se encontraron becarios para el programa: {programa_nombre}"

        elif tipo_consulta == 'periodo': # Si consulta es por periodo
            periodo = request.form.get('periodo') # Obtener nombre del periodo
            # 2. Llamada al SP PostulantesPorPeriodo
            cursor.callproc('PostulantesPorPeriodo', [periodo])
            for result in cursor.stored_results():
                resumen = result.fetchall()
            if not resumen:
                mensaje = f"No se encontraron postulantes para el periodo: {periodo}"

        cursor.close()
        conn.close()

    return render_template('consultas_postulacion.html', becarios=becarios, resumen=resumen,
                           programa=programa_nombre, periodo=periodo, mensaje=mensaje)



# 5. Pagina eliminar_postulacion --> 1. eliminar_postulacion 2. MostrarHistoricoEstadoPostulacion

@app.route('/eliminar_postulacion', methods=['GET', 'POST'])
def eliminar_postulacion():
    mensaje = '' # Mensaje Vacio
    dni = request.form.get('dni', '') if request.method == 'POST' else '' # Obtenemos DNI solo si es POST

    if request.method == 'POST' and dni: # Si es POST y hay DNI
        conn = connector.connect(**db_config) # Conectamos a la base de datos
        cursor = conn.cursor()

        # 1. Llamada al SP eliminar_postulacion
        cursor.callproc('eliminar_postulacion', [dni])
        conn.commit() # Confirmamos cambios

        cursor.close() # Cerramos cursor
        conn.close() # Cerramos conexión

        mensaje = f"Se eliminó correctamente la postulación del DNI '{dni}'."


    # Mostrar postulantes actualizados con su estado
    conn = connector.connect(**db_config) # Conectamos a la base de datos
    cursor = conn.cursor(dictionary=True)
    postulantes = []
    # 2. Llamada al SP MostrarHistoricoEstadoPostulacion
    cursor.callproc('MostrarHistoricoEstadoPostulacion')
    for result in cursor.stored_results():
        postulantes.extend(result.fetchall()) # Guardamos resultados
    cursor.close() # Cerramos cursor
    conn.close() # Cerramos conexión

    return render_template('eliminar_postulacion.html',
                           postulantes=postulantes,
                           mensaje=mensaje,
                           dni=dni)  # tipo_alerta eliminado


# 6. Pagina gestionar_historico --> 1. sp_actualizar_periodo_historico 2. MostrarHistorico

@app.route('/gestionar_historico', methods=['GET', 'POST'])
def gestionar_historico():
    mensaje = ''
    periodo = request.form.get('periodo', '') if request.method == 'POST' else '' # Obtenemos periodo si es POST

    if request.method == 'POST' and periodo: # Si se envió periodo válido
        conn = connector.connect(**db_config) # Conectamos a la base de datos
        cursor = conn.cursor()

        # 1. Llamada al SP sp_actualizar_periodo_historico
        cursor.callproc('sp_actualizar_periodo_historico', [periodo])
        conn.commit() # Confirmamos cambios
        cursor.close() # Cerramos cursor
        conn.close() # Cerramos conexión

        mensaje = f"Se actualizaron los registros del periodo '{periodo}' al siguiente en orden."

    # Mostrar los datos actualizados del histórico
    conn = connector.connect(**db_config) # Conectamos a la base de datos
    cursor = conn.cursor(dictionary=True)
    # 2. Llamada al SP MostrarHistorico
    cursor.callproc('MostrarHistorico')
    historico = [] # Lista de histórico
    for result in cursor.stored_results():
        historico.extend(result.fetchall()) # Guardamos resultados
    cursor.close() # Cerramos cursor
    conn.close() # Cerramos conexión

    return render_template('gestionar_historico.html',
                           historico=historico,
                           mensaje=mensaje,
                           periodo=periodo)



@app.route('/')
def inicio():
    return render_template('inicio.html')

app.run(debug=True)

