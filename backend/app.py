from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')

CORS(app)

from backend.routes.auth import auth_bp
from backend.routes.clientes import clientes_bp
from backend.routes.medidores import medidores_bp
from backend.routes.lecturas import lecturas_bp
from backend.routes.simulaciones import simulaciones_bp

app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(clientes_bp, url_prefix='/api/clientes')
app.register_blueprint(medidores_bp, url_prefix='/api/medidores')
app.register_blueprint(lecturas_bp, url_prefix='/api/lecturas')
app.register_blueprint(simulaciones_bp, url_prefix='/api/simulaciones')

@app.route('/')
def index():
    return {'mensaje': 'API Corpoelec Energy System funcionando', 'version': '1.0'}

if __name__ == '__main__':
    app.run(debug=True, port=5000)