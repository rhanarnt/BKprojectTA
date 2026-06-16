import os
from urllib.parse import urlparse

import mysql.connector


def load_env_file():
    env_path = os.path.join(os.path.dirname(__file__), '.env')
    if not os.path.exists(env_path):
        return

    with open(env_path, 'r', encoding='utf-8') as env_file:
        for raw_line in env_file:
            line = raw_line.strip()
            if not line or line.startswith('#') or '=' not in line:
                continue
            key, value = line.split('=', 1)
            os.environ[key.strip()] = value.strip().strip('"').strip("'")


def db_config():
    load_env_file()
    database_url = os.getenv('MYSQL_URL') or os.getenv('DATABASE_URL', '')
    parsed = urlparse(database_url) if database_url else None

    return {
        'host': os.getenv('MYSQLHOST')
        or os.getenv('DB_HOST')
        or (parsed.hostname if parsed else None)
        or 'localhost',
        'port': int(
            os.getenv('MYSQLPORT')
            or os.getenv('DB_PORT')
            or (parsed.port if parsed and parsed.port else 3306)
        ),
        'user': os.getenv('MYSQLUSER')
        or os.getenv('DB_USER')
        or (parsed.username if parsed else None)
        or 'root',
        'password': os.getenv('MYSQLPASSWORD')
        or os.getenv('DB_PASSWORD')
        or (parsed.password if parsed else None)
        or '',
        'database': os.getenv('MYSQLDATABASE')
        or os.getenv('DB_NAME')
        or (parsed.path.lstrip('/') if parsed and parsed.path else None)
        or 'prediksi_stok_db',
    }


def table_exists(cursor, table_name):
    cursor.execute("SHOW TABLES LIKE %s", (table_name,))
    return cursor.fetchone() is not None


def clean_table(cursor, table_name):
    raise RuntimeError(
        'clean_table dinonaktifkan agar data backend tidak terhapus massal. '
        'Gunakan restore_backend_dataset_data.py untuk memulihkan dan memfilter data non-dataset.'
    )


def main():
    print(
        'Skrip pembersihan massal dinonaktifkan. '
        'Jalankan restore_backend_dataset_data.py untuk memulihkan data backend '
        'dan menghapus hanya baris yang tidak sesuai dataset.'
    )


if __name__ == '__main__':
    main()
