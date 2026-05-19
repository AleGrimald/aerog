"""Funciones utilitarias compartidas por los blueprints"""
import os
import bcrypt
import json
from urllib import request as urlrequest
from urllib.error import URLError, HTTPError
from urllib.parse import quote
from itsdangerous import URLSafeTimedSerializer
import mysql.connector
from flask import jsonify
from email_utils import EnviarMail


# Variables globales - se asignarán desde app.py
DB_CONFIG = {}
SECRET_KEY = ''
VERIFICATION_TOKEN_MAX_AGE = 86400
BACKEND_PUBLIC_URL = ''
FRONTEND_BASE_URL = ''


def initialize_config(db_config, secret_key, verification_token_max_age, backend_url, frontend_url):
    """Inicializa la configuración desde app.py"""
    global DB_CONFIG, SECRET_KEY, VERIFICATION_TOKEN_MAX_AGE, BACKEND_PUBLIC_URL, FRONTEND_BASE_URL
    DB_CONFIG = db_config
    SECRET_KEY = secret_key
    VERIFICATION_TOKEN_MAX_AGE = verification_token_max_age
    BACKEND_PUBLIC_URL = backend_url
    FRONTEND_BASE_URL = frontend_url


def get_db_connection():
    """Crea y retorna una conexión a la base de datos"""
    return mysql.connector.connect(
        host=DB_CONFIG.get('host'),
        user=DB_CONFIG.get('user'),
        password=DB_CONFIG.get('password'),
        port=DB_CONFIG.get('port'),
        database=DB_CONFIG.get('database'),
    )


def hash_password(password):
    """Genera un hash bcrypt para la contraseña"""
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password, hashed):
    """Verifica una contraseña contra su hash bcrypt"""
    return bcrypt.checkpw(password.encode(), hashed.encode())


def _get_verification_serializer():
    """Obtiene el serializador de tokens de verificación"""
    return URLSafeTimedSerializer(SECRET_KEY, salt='email-verification')


def _build_verification_link(token: str) -> str:
    """Construye el link de verificación"""
    return f"{BACKEND_PUBLIC_URL}/verificar-email?token={quote(token)}"


def send_verification_email(email: str, nombre: str, token: str) -> bool:
    """Envía correo de verificación usando EnviarMail. Devuelve True si fue enviado."""
    verification_link = _build_verification_link(token)
    nombre_safe = nombre or 'usuario'

    subject = 'Confirma tu cuenta en Aero G'
    text = (
        f'Hola, {nombre_safe}.\n\n'
        f'Gracias por registrarte en Aero G.\n'
        f'Para activar tu cuenta, confirma tu email desde este enlace:\n{verification_link}\n\n'
        'Este enlace vence en 24 horas.'
    )
    html = f'''
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {{ background-color: #FFFFFF; color: #000000; }}
            p, a, h1, h2, h3, h4, h5, h6 {{ font-family: 'Roboto', Arial, sans-serif !important; }}
            h2 {{ font-size: 25px !important; }}
            p, a {{ font-size: 15px !important; }}
        </style>
    </head>
    <body>
        <div style="width: 100%; background-color: #e3e3e3;">
            <div style="padding: 20px 10px 20px 10px;">
                <div style="background-color: #ffffff; padding: 20px 0px 5px 0px; width: 100%; text-align: center;">
                    <h2>Hola, {nombre_safe}!</h2>
                    <p>Gracias por registrarte en Aero G.</p>
                    <p>Para activar tu cuenta, haz clic en el siguiente enlace:</p>
                    <p><strong><a href="{verification_link}">Confirmar Email</a></strong></p>
                    <p><strong>Importante:</strong> Este enlace es válido por 24 horas.</p>
                    <p style="margin-bottom: 50px;">
                        <i>Si no solicitaste este correo, puedes ignorarlo.</i>
                    </p>
                </div>
            </div>
        </div>
    </body>
    </html>
    '''

    resultado = EnviarMail(email, subject, text, html)
    return resultado


def detectar_fabricante_por_iin(numero: str) -> str:
    """Detecta el fabricante de una tarjeta por su IIN"""
    if not numero:
        return 'No identificado'
    if numero.startswith('4'):
        return 'Visa'
    dos = int(numero[:2]) if len(numero) >= 2 and numero[:2].isdigit() else -1
    cuatro = int(numero[:4]) if len(numero) >= 4 and numero[:4].isdigit() else -1
    if 51 <= dos <= 55 or 2221 <= cuatro <= 2720:
        return 'Mastercard'
    if numero.startswith('34') or numero.startswith('37'):
        return 'American Express'
    return 'No identificado'


def detectar_entidad_local(bin6: str) -> str:
    """Fallback local basado en BINs frecuentes de AR."""
    if not bin6:
        return 'No identificado'

    prefijos_3 = {
        '450': 'Banco Santander',
        '451': 'BBVA Frances',
        '454': 'Banco Macro',
        '589': 'Naranja X',
        '540': 'Banco Galicia',
        '528': 'Banco Nacion',
        '522': 'Banco Provincia',
    }
    prefijos_4 = {
        '4509': 'Naranja X',
        '4557': 'Banco Macro',
        '4507': 'Banco Santander',
    }

    if bin6[:4] in prefijos_4:
        return prefijos_4[bin6[:4]]
    if bin6[:3] in prefijos_3:
        return prefijos_3[bin6[:3]]
    return 'No identificado'


def detectar_metadata_tarjeta(numero: str) -> dict:
    """Detecta tipo/fabricante/entidad con BIN/IIN (API externa + fallback local)."""
    numero_limpio = ''.join(ch for ch in str(numero) if ch.isdigit())
    bin6 = numero_limpio[:6]

    fabricante = detectar_fabricante_por_iin(numero_limpio)
    tipo_tarjeta = 'No identificado'
    entidad_bancaria = detectar_entidad_local(bin6)

    if len(bin6) == 6:
        try:
            req = urlrequest.Request(
                f'https://lookup.binlist.net/{bin6}',
                headers={'Accept-Version': '3'}
            )
            with urlrequest.urlopen(req, timeout=2.5) as resp:
                data = json.loads(resp.read().decode('utf-8'))
                scheme = (data.get('scheme') or '').strip()
                tipo = (data.get('type') or '').strip()
                bank_name = ((data.get('bank') or {}).get('name') or '').strip()

                if scheme:
                    fabricante = scheme.title()
                if tipo == 'debit':
                    tipo_tarjeta = 'Debito'
                elif tipo == 'credit':
                    tipo_tarjeta = 'Credito'
                if bank_name:
                    entidad_bancaria = bank_name
        except (URLError, HTTPError, TimeoutError, ValueError, json.JSONDecodeError):
            pass

    if tipo_tarjeta == 'No identificado':
        tipo_tarjeta = 'Debito' if numero_limpio.startswith('4') and bin6.startswith(('4023', '4098')) else 'Credito'

    if fabricante == 'Amex':
        fabricante = 'American Express'

    return {
        'tipo_tarjeta': tipo_tarjeta,
        'fabricante': fabricante,
        'entidad_bancaria': entidad_bancaria,
    }
