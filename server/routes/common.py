"""Blueprint de endpoints comunes"""
from flask import Blueprint, jsonify
from mysql.connector import Error

from .utils import get_db_connection

common_bp = Blueprint('common', __name__)


@common_bp.route('/', methods=['GET'])
def index():
    """Endpoint raíz de health check"""
    return jsonify({'message': 'Servidor activo. Usa /usuario para consultar datos.'})


@common_bp.route('/usuario', methods=['GET'])
def obtener_usuario():
    """Obtiene lista de todos los usuarios"""
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True, buffered=True)
        cursor.execute('CALL sp_common_obtener_usuarios()')
        usuarios = cursor.fetchall()
    except Error as exc:
        return jsonify({'error': str(exc)}), 500
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        if 'connection' in locals() and connection is not None and connection.is_connected():
            connection.close()

    return jsonify(usuarios)
