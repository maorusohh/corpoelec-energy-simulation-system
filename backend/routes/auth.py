from flask import Blueprint, request, jsonify
from backend.controllers.auth_controller import login, registrar

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['POST'])
def login_route():
    data = request.get_json()
    respuesta, status = login(data.get('username'), data.get('password'))
    return jsonify(respuesta), status

@auth_bp.route('/registrar', methods=['POST'])
def registrar_route():
    data = request.get_json()
    respuesta, status = registrar(
        data.get('nombre'),
        data.get('apellido'),
        data.get('username'),
        data.get('password'),
        data.get('rol', 'tecnico')
    )
    return jsonify(respuesta), status