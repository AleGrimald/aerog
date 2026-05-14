import requests
import os

MERCADOPAGO_ACCESS_TOKEN = os.getenv('MERCADOPAGO_ACCESS_TOKEN')
MERCADOPAGO_API_URL = 'https://api.mercadopago.com/checkout/preferences'


def crear_preferencia_pago_qr(monto, descripcion, reserva_id, usuario_email):
    """
    Crea una preferencia de pago QR en MercadoPago y retorna la URL del QR.
    """
    if not MERCADOPAGO_ACCESS_TOKEN:
        raise Exception("Falta MERCADOPAGO_ACCESS_TOKEN en variables de entorno")
    headers = {
        'Authorization': f'Bearer {MERCADOPAGO_ACCESS_TOKEN}',
        'Content-Type': 'application/json'
    }
    body = {
        "items": [
            {
                "title": descripcion,
                "quantity": 1,
                "currency_id": "ARS",
                "unit_price": float(monto)
            }
        ],
        "external_reference": str(reserva_id),
        "payer": {
            "email": usuario_email
        },
        "payment_methods": {
            "excluded_payment_types": [{"id": "ticket"}],
            "installments": 1
        },
        # Puedes dejar la notificación vacía en pruebas
        "notification_url": ""
    }
    response = requests.post(MERCADOPAGO_API_URL, json=body, headers=headers)
    if response.status_code in (200, 201):
        data = response.json()
        return data.get('init_point') or data.get('sandbox_init_point')
    else:
        raise Exception(f"Error MercadoPago: {response.status_code} - {response.text}")
