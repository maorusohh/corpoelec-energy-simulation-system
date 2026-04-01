from backend.models.usuario import get_usuario_by_username, verificar_password, crear_usuario
import jwt
import os
from datetime import datetime, timedelta

def login(username, password):
    if not username or not password:
        return {'error': 'Usuario y contraseña son requeridos'}, 400

    usuario = get_usuario_by_username(username)

    if not usuario:
        return {'error': 'Credenciales incorrectas'}, 401

    if not usuario['activo']:
        return {'error': 'Usuario inactivo, contacte al administrador'}, 403

    if not verificar_password(password, usuario['password_hash']):
        return {'error': 'Credenciales incorrectas'}, 401

    token = jwt.encode({
        'id': usuario['id'],
        'username': usuario['username'],
        'rol': usuario['rol'],
        'exp': datetime.utcnow() + timedelta(hours=8)
    }, os.getenv('SECRET_KEY'), algorithm='HS256')

    return {
        'mensaje': 'Login exitoso',
        'token': token,
        'usuario': {
            'id': usuario['id'],
            'nombre': usuario['nombre'],
            'apellido': usuario['apellido'],
            'username': usuario['username'],
            'rol': usuario['rol']
        }
    }, 200

def registrar(nombre, apellido, username, password, rol='tecnico'):
    if not all([nombre, apellido, username, password]):
        return {'error': 'Todos los campos son requeridos'}, 400

    if get_usuario_by_username(username):
        return {'error': 'El username ya existe'}, 409

    if rol not in ['tecnico', 'admin']:
        return {'error': 'Rol inválido'}, 400

    id_nuevo = crear_usuario(nombre, apellido, username, password, rol)

    if not id_nuevo:
        return {'error': 'Error al crear el usuario'}, 500

    return {'mensaje': 'Usuario creado exitosamente', 'id': id_nuevo}, 201
