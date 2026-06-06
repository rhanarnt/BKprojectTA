"""
Import a MySQL dump into the configured Railway database.

Required environment variables can use either Railway MySQL names:
MYSQLHOST, MYSQLPORT, MYSQLUSER, MYSQLPASSWORD, MYSQLDATABASE

or a single MYSQL_URL / DATABASE_URL.
"""

import argparse
import os
from pathlib import Path
from urllib.parse import urlparse

import mysql.connector
from mysql.connector import Error


BASE_DIR = Path(__file__).resolve().parent


def load_env_file() -> None:
    env_path = BASE_DIR / ".env"
    if not env_path.exists():
        return

    for raw_line in env_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue

        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


def get_db_config() -> dict:
    database_url = os.getenv("MYSQL_URL") or os.getenv("DATABASE_URL", "")
    parsed = urlparse(database_url) if database_url else None

    return {
        "host": os.getenv("MYSQLHOST")
        or os.getenv("DB_HOST")
        or (parsed.hostname if parsed else None),
        "port": int(
            os.getenv("MYSQLPORT")
            or os.getenv("DB_PORT")
            or (parsed.port if parsed and parsed.port else 3306)
        ),
        "user": os.getenv("MYSQLUSER")
        or os.getenv("DB_USER")
        or (parsed.username if parsed else None),
        "password": os.getenv("MYSQLPASSWORD")
        or os.getenv("DB_PASSWORD")
        or (parsed.password if parsed else None),
        "database": os.getenv("MYSQLDATABASE")
        or os.getenv("DB_NAME")
        or (parsed.path.lstrip("/") if parsed and parsed.path else None),
    }


def split_sql_statements(sql: str) -> list[str]:
    statements = []
    current = []
    in_single = False
    in_double = False
    escaped = False

    for char in sql:
        current.append(char)

        if escaped:
            escaped = False
            continue

        if char == "\\":
            escaped = True
            continue

        if char == "'" and not in_double:
            in_single = not in_single
        elif char == '"' and not in_single:
            in_double = not in_double
        elif char == ";" and not in_single and not in_double:
            statement = "".join(current).strip()
            if statement:
                statements.append(statement)
            current = []

    tail = "".join(current).strip()
    if tail:
        statements.append(tail)

    return statements


def drop_existing_tables(cursor) -> None:
    cursor.execute("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'")
    tables = [row[0] for row in cursor.fetchall()]

    for table in tables:
        cursor.execute(f"DROP TABLE IF EXISTS `{table}`")


def import_dump(sql_path: Path, drop_existing: bool) -> None:
    config = get_db_config()
    missing = [key for key, value in config.items() if value in (None, "")]
    if missing:
        raise RuntimeError(
            "Missing database config: "
            + ", ".join(missing)
            + ". Set Railway MySQL env vars or MYSQL_URL."
        )

    sql = sql_path.read_text(encoding="utf-8")
    statements = split_sql_statements(sql)

    connection = mysql.connector.connect(**config)
    cursor = connection.cursor()
    try:
        cursor.execute("SET FOREIGN_KEY_CHECKS=0")
        if drop_existing:
            drop_existing_tables(cursor)
        for index, statement in enumerate(statements, start=1):
            cursor.execute(statement)
            if index % 25 == 0:
                connection.commit()
        cursor.execute("SET FOREIGN_KEY_CHECKS=1")
        connection.commit()
    except Error:
        connection.rollback()
        raise
    finally:
        cursor.close()
        connection.close()

    print(f"Imported {len(statements)} statements from {sql_path.name}.")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "sql_file",
        nargs="?",
        default=str(BASE_DIR / "prediksi_stok_db.sql"),
        help="Path to the SQL dump file.",
    )
    parser.add_argument(
        "--drop-existing",
        action="store_true",
        help="Drop existing project tables before importing the dump.",
    )
    args = parser.parse_args()

    load_env_file()
    import_dump(Path(args.sql_file).resolve(), args.drop_existing)


if __name__ == "__main__":
    main()
