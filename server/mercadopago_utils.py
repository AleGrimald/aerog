import requests
import os

MERCADOPAGO_API_URL = 'https://api.mercadopago.com'


def _get_mp_access_token():
    return (
        os.getenv('MERCADOPAGO_ACCESS_TOKEN')
        or os.getenv('MP_ACCESS_TOKEN')
        or ''
    ).strip()


def crear_preferencia_pago_qr(monto, descripcion, reserva_id, usuario_email):
    """
    Crea una preferencia de pago QR en MercadoPago y retorna la URL del QR.
    """
    token = _get_mp_access_token()
    if not token:
        raise Exception("Falta MERCADOPAGO_ACCESS_TOKEN en variables de entorno")

    headers = {
        'Authorization': f'Bearer {token}',
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
    response = requests.post(f'{MERCADOPAGO_API_URL}/checkout/preferences', json=body, headers=headers, timeout=20)
    if response.status_code in (200, 201):
        data = response.json()
        return {
            'preference_id': data.get('id'),
            'init_point': data.get('init_point'),
            'sandbox_init_point': data.get('sandbox_init_point'),
        }
    else:
        raise Exception(f"Error MercadoPago: {response.status_code} - {response.text}")


def obtener_estado_pago_por_reserva(reserva_id):
    """
    Busca el ultimo pago de Mercado Pago para una reserva (external_reference).
    Devuelve un dict con estado y datos utiles.
    """
    token = _get_mp_access_token()
    if not token:
        raise Exception("Falta MERCADOPAGO_ACCESS_TOKEN en variables de entorno")

    headers = {
        'Authorization': f'Bearer {token}',
    }

    params = {
        'external_reference': str(reserva_id),
        'sort': 'date_created',
        'criteria': 'desc',
        'limit': 1,
    }

    response = requests.get(f'{MERCADOPAGO_API_URL}/v1/payments/search', params=params, headers=headers, timeout=20)
    if response.status_code != 200:
        raise Exception(f"Error MercadoPago al consultar pagos: {response.status_code} - {response.text}")

    data = response.json() or {}
    resultados = data.get('results') or []
    if not resultados:
        return {
            'status': 'not_found',
            'payment_id': None,
            'status_detail': None,
        }

    ultimo = resultados[0]
    return {
        'status': (ultimo.get('status') or '').lower(),
        'payment_id': ultimo.get('id'),
        'status_detail': ultimo.get('status_detail'),
    }
