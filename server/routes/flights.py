"""Blueprint de búsqueda de vuelos"""
from datetime import datetime, timedelta
from flask import Blueprint, request, jsonify
from mysql.connector import Error

from .utils import get_db_connection

flights_bp = Blueprint('flights', __name__)


@flights_bp.route('/airport-suggestions', methods=['GET'])
def airport_suggestions():
    """Obtiene sugerencias de aeropuertos según búsqueda"""
    query = request.args.get('q', '').strip()
    if not query or len(query) < 2:
        return jsonify([])

    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute('CALL sp_flights_airport_suggestions(%s)', (query,))
        suggestions = cursor.fetchall()
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection is not None and connection.is_connected():
            connection.close()

    normalized = []
    for row in suggestions:
        aeropuerto_id = row.get('aeropuerto_id')
        nombre = row.get('nombre') or ''
        ciudad = row.get('ciudad') or ''
        provincia = row.get('provincia') or ''
        codigo = row.get('codigo_IATA') or ''
        label = nombre
        if ciudad:
            label = f"{ciudad} - {label}"
        if codigo:
            label += f" ({codigo})"
        if provincia:
            label += f", {provincia}"
        normalized.append({
            'id': aeropuerto_id,
            'label': label,
            'nombre': nombre,
            'ciudad': ciudad,
            'provincia': provincia,
            'codigo_IATA': codigo,
        })

    return jsonify(normalized)


@flights_bp.route('/buscar-vuelos', methods=['POST'])
def buscar_vuelos():
    """Busca vuelos disponibles según criterios"""
    try:
        data = request.get_json() or {}
        origen_id = data.get('origenId')
        destino_id = data.get('destinoId')
        trip_type = (data.get('tripType') or 'one-way').strip()
        fecha_salida = (data.get('fechaSalida') or '').strip()
        fecha_regreso = (data.get('fechaRegreso') or '').strip()
        pasajeros = data.get('pasajeros', 1)

        if origen_id is None or destino_id is None or not fecha_salida or not fecha_regreso:
            return jsonify({'error': 'Origen, destino y rango de fechas son requeridos'}), 400

        try:
            origen_id = int(origen_id)
            destino_id = int(destino_id)
            pasajeros = int(pasajeros)
        except (TypeError, ValueError):
            return jsonify({'error': 'Origen, destino y pasajeros deben ser numéricos'}), 400

        if pasajeros < 1 or pasajeros > 10:
            return jsonify({'error': 'La cantidad de pasajeros debe estar entre 1 y 10'}), 400

        print('BUSCAR VUELOS payload:', data)

        try:
            selected_salida = datetime.strptime(fecha_salida, '%Y-%m-%d').date()
        except ValueError:
            return jsonify({'error': 'Fecha de salida inválida'}), 400

        if trip_type == 'round-trip':
            try:
                selected_regreso = datetime.strptime(fecha_regreso, '%Y-%m-%d').date()
            except ValueError:
                return jsonify({'error': 'Fecha de regreso inválida'}), 400

            if selected_regreso < selected_salida:
                return jsonify({'error': 'La fecha de regreso debe ser mayor o igual a la fecha de salida'}), 400
        else:
            selected_regreso = selected_salida

        today = datetime.now().date()
        if selected_salida < today:
            return jsonify({'error': 'La fecha de salida debe ser hoy o posterior'}), 400

        if trip_type == 'one-way':
            start_date = selected_salida - timedelta(days=5)
            end_date = selected_salida + timedelta(days=5)
            if start_date < today:
                start_date = today
        else:
            start_date = selected_salida
            end_date = selected_regreso

        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            params_search = (str(start_date), str(end_date), origen_id, destino_id, pasajeros)

            cursor.execute('CALL sp_flights_buscar_vuelos(%s, %s, %s, %s, %s)', params_search)
            results = cursor.fetchall()

            print('SP SEARCH: sp_flights_buscar_vuelos')
            print('PARAMS SEARCH:', params_search)
            print(f'RESULTADOS BRUTOS: {len(results)} registros')
            for idx, vuelo in enumerate(results):
                print(f'  [{idx}] {vuelo.get("codigo_vuelo")} - Salida: {vuelo.get("fecha_salida")} - Llegada: {vuelo.get("fecha_llegada")}')
            
            # Formatear fechas a strings legibles para el frontend
            for vuelo in results:
                if vuelo.get('fecha_salida'):
                    vuelo['fecha_salida'] = vuelo['fecha_salida'].strftime('%Y-%m-%d %H:%M:%S')
                if vuelo.get('fecha_llegada'):
                    vuelo['fecha_llegada'] = vuelo['fecha_llegada'].strftime('%Y-%m-%d %H:%M:%S')
        finally:
            if cursor is not None:
                cursor.close()
            if connection is not None and connection.is_connected():
                connection.close()

        return jsonify({'results': results})

    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    except Exception:
        return jsonify({'error': 'Error en el servidor'}), 500
