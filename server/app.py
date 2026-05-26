"""
Servidor Flask para Aero G - Sistema de Reserva de Vuelos
"""
import os
import re
from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv

# Importar blueprints
from routes.common import common_bp
from routes.auth import auth_bp
from routes.flights import flights_bp
from routes.reservations import reservations_bp
from routes.payments import cards_bp, payments_bp
from routes.admin import admin_bp

# Importar inicializador de utilidades
from routes.utils import initialize_config

load_dotenv(override=True)

# Detectar entorno
ENV = os.environ.get('ENV', 'development').lower()

# production | development
if ENV == 'production': 
    MY_SQL_HOST = os.environ.get('MYSQL_ADDON_HOST', '')
    MY_SQL_USER = os.environ.get('MYSQL_ADDON_USER', '')
    MY_SQL_PASS = os.environ.get('MYSQL_ADDON_PASSWORD', '')
    MY_SQL_PORT = int(os.environ.get('MYSQL_ADDON_PORT', 3306))
    MY_SQL_DB = os.environ.get('MYSQL_ADDON_DB', '')
else:
    MY_SQL_HOST = os.environ.get('MY_SQL_HOST', '')
    MY_SQL_USER = os.environ.get('MY_SQL_USER', '')
    MY_SQL_PASS = os.environ.get('MY_SQL_PASS', '')
    MY_SQL_PORT = int(os.environ.get('MY_SQL_PORT', 3306))
    MY_SQL_DB = os.environ.get('MY_SQL_DB', '')

PORT = int(os.environ.get('PORT', 5000))
SECRET_KEY = os.environ.get('SECRET_KEY', 'aerog-secret-key-change-me')
VERIFICATION_TOKEN_MAX_AGE = int(os.environ.get('VERIFICATION_TOKEN_MAX_AGE', 86400))

FRONTEND_BASE_URL = os.environ.get(
    'FRONTEND_BASE_URL',
    'http://localhost:3000' if ENV == 'development' else 'https://aerog.vercel.app'
)
BACKEND_PUBLIC_URL = os.environ.get(
    'BACKEND_PUBLIC_URL',
    f'http://localhost:{PORT}' if ENV == 'development' else 'https://aerog-server.vercel.app'
)

# Crear aplicación Flask
app = Flask(__name__)

# Configurar CORS
CORS(app, resources={
    r"/*": {
        "origins": [
            "http://localhost:3000",
            "http://127.0.0.1:3000",
            "http://192.168.40.226:5000",
            "https://aerog-server.vercel.app/",
            "https://aerog.vercel.app",
            re.compile(r"https://.*\.vercel\.app$"),
        ],
        "methods": ["GET", "POST", "OPTIONS", "DELETE", "PUT", "PATCH"],
        "allow_headers": ["Content-Type"],
    }
})

# Inicializar configuración en routes/utils.py
db_config = {
    'host': MY_SQL_HOST,
    'user': MY_SQL_USER,
    'password': MY_SQL_PASS,
    'port': MY_SQL_PORT,
    'database': MY_SQL_DB,
}
initialize_config(db_config, SECRET_KEY, VERIFICATION_TOKEN_MAX_AGE, BACKEND_PUBLIC_URL, FRONTEND_BASE_URL)

# Registrar blueprints
app.register_blueprint(common_bp)
app.register_blueprint(auth_bp)
app.register_blueprint(flights_bp)
app.register_blueprint(reservations_bp)
app.register_blueprint(cards_bp)
app.register_blueprint(payments_bp)
app.register_blueprint(admin_bp)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT, debug=True)
