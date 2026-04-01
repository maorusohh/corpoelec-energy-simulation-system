from backend.config import get_db_connection
import bcrypt

def get_usuario_by_username(username):
    conn = get_db_connection()
    if not conn:
        return None
    try:
        cursor = conn.cursor()
        cursor.execute(
            "SELECT id, nombre, apellido, username, password_hash, rol, activo FROM usuarios WHERE username = %s",
            (username,)
        )
        row = cursor.fetchone()
        if row:
            return {
                'id': row[0],
                'nombre': row[1],
                'apellido': row[2],
                'username': row[3],
                'password_hash': row[4],
                'rol': row[5],
                'activo': row[6]
            }
        return None
    except Exception as e:
        print(f"Error consultando usuario: {e}")
        return None
    finally:
        cursor.close()
        conn.close()

def crear_usuario(nombre, apellido, username, password, rol):
    conn = get_db_connection()
    if not conn:
        return None
    try:
        password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO usuarios (nombre, apellido, username, password_hash, rol) VALUES (%s, %s, %s, %s, %s) RETURNING id",
            (nombre, apellido, username, password_hash, rol)
        )
        id_nuevo = cursor.fetchone()[0]
        conn.commit()
        return id_nuevo
    except Exception as e:
        print(f"Error creando usuario: {e}")
        conn.rollback()
        return None
    finally:
        cursor.close()
        conn.close()

def verificar_password(password, password_hash):
    return bcrypt.checkpw(password.encode('utf-8'), password_hash.encode('utf-8'))