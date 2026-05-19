import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import os


def EnviarMail(to, subject, text, html, attachments=None, cc=None):
    """
    Envía un correo usando SMTP.
    
    Args:
        to: Email o lista de emails destinatarios
        subject: Asunto del correo
        text: Cuerpo de texto plano
        html: Cuerpo HTML
        attachments: Lista de dicts con {filename, path, cid} (opcional)
        cc: Email o lista de emails en CC (opcional)
    
    Returns:
        True si fue exitoso, False si falló
    """
    
    # Configuración SMTP
    SMTP_HOST = os.environ.get('SMTP_HOST', 'smtp.office365.com')
    SMTP_PORT = int(os.environ.get('SMTP_PORT', 587))
    SMTP_USER = os.environ.get('SMTP_USER', '')
    SMTP_PASS = os.environ.get('SMTP_PASS', '')
    SMTP_FROM = os.environ.get('SMTP_FROM', SMTP_USER)
    SMTP_USE_TLS = os.environ.get('SMTP_USE_TLS', 'true').lower() == 'true'
    
    # Validar configuración
    if not SMTP_HOST or not SMTP_USER or not SMTP_PASS:
        print('[WARN] SMTP no está configurado. No se puede enviar correo.')
        return False
    
    try:
        # Crear mensaje
        message = MIMEMultipart('alternative')
        message['Subject'] = subject
        message['From'] = SMTP_FROM
        
        # Procesar destinatarios
        if isinstance(to, list):
            message['To'] = ', '.join(to)
            to_list = to
        else:
            message['To'] = to
            to_list = [to]
        
        # Procesar CC
        cc_list = []
        if cc:
            if isinstance(cc, list):
                message['Cc'] = ', '.join(cc)
                cc_list = cc
            else:
                message['Cc'] = cc
                cc_list = [cc]
        
        # Agregar cuerpo de texto
        message.attach(MIMEText(text, 'plain', 'utf-8'))
        
        # Agregar cuerpo HTML
        message.attach(MIMEText(html, 'html', 'utf-8'))
        
        # Procesar adjuntos
        if attachments:
            for attachment in attachments:
                filename = attachment.get('filename', 'archivo')
                filepath = attachment.get('path')
                cid = attachment.get('cid')
                
                if filepath and os.path.exists(filepath):
                    try:
                        with open(filepath, 'rb') as attachment_file:
                            part = MIMEBase('application', 'octet-stream')
                            part.set_payload(attachment_file.read())
                        
                        encoders.encode_base64(part)
                        part.add_header('Content-Disposition', f'attachment; filename= {filename}')
                        
                        if cid:
                            part.add_header('Content-ID', f'<{cid}>')
                            part.add_header('Content-Disposition', 'inline', filename=filename)
                        
                        message.attach(part)
                    except Exception as e:
                        print(f'[WARN] No se pudo adjuntar {filename}: {e}')
        
        # Enviar correo
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=10) as server:
            if SMTP_USE_TLS:
                server.starttls()
            
            server.login(SMTP_USER, SMTP_PASS)
            server.sendmail(SMTP_FROM, to_list + cc_list, message.as_string())
        
        return True
    
    except Exception as error:
        print(f'[ERROR] Error enviando correo: {error}')
        return False
