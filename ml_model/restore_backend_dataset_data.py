import re

import mysql.connector

from cleanup_dummy_data import db_config


DATASET_PRODUCTS = {
    'Baking Powder',
    'Baking Powder 45gr',
    'Cokelat Bubuk 250gr',
    'Gula Pasir 1kg',
    'Keju Parut 250gr',
    'Mentega 500gr',
    'Susu Bubuk',
    'Susu Bubuk 27gr',
    'Telur 1kg',
    'Tepung Terigu 1kg',
}

RESTORE_TABLES = [
    'predictions',
    'products',
    'recipes',
    'recipe_ingredients',
    'stock in',
    'stock_usage_history',
    'stok_keluar',
    'transactions',
]


def extract_insert_statements(sql_text):
    pattern = re.compile(
        r"INSERT INTO `([^`]+)` .*?;\n",
        flags=re.IGNORECASE | re.DOTALL,
    )
    for match in pattern.finditer(sql_text):
        table_name = match.group(1)
        statement = match.group(0)
        if table_name in RESTORE_TABLES:
            yield table_name, statement


def table_exists(cursor, table_name):
    cursor.execute("SHOW TABLES LIKE %s", (table_name,))
    return cursor.fetchone() is not None


def delete_table(cursor, table_name):
    if not table_exists(cursor, table_name):
        return
    escaped = f"`{table_name.replace('`', '``')}`"
    cursor.execute(f"DELETE FROM {escaped}")
    cursor.execute(f"ALTER TABLE {escaped} AUTO_INCREMENT = 1")


def get_existing_column(cursor, table_name, candidates):
    for column in candidates:
        cursor.execute(f"SHOW COLUMNS FROM `{table_name}` LIKE %s", (column,))
        if cursor.fetchone():
            return column
    return None


def placeholders(values):
    return ', '.join(['%s'] * len(values))


def delete_not_in_dataset(cursor, table_name, column_name):
    if not table_exists(cursor, table_name):
        return 0
    product_list = sorted(DATASET_PRODUCTS)
    escaped_table = f"`{table_name.replace('`', '``')}`"
    escaped_column = f"`{column_name.replace('`', '``')}`"
    cursor.execute(
        f"DELETE FROM {escaped_table} WHERE {escaped_column} NOT IN ({placeholders(product_list)})",
        tuple(product_list),
    )
    return cursor.rowcount


def normalize_dataset_product_rows(cursor):
    if not table_exists(cursor, 'products'):
        return

    updates = {
        'Baking Powder': ('Bahan Tambahan', 8180, '45gr'),
        'Baking Powder 45gr': ('Bahan Tambahan', 8180, '45gr'),
        'Cokelat Bubuk 250gr': ('Cokelat', 21036, '250gr'),
        'Gula Pasir 1kg': ('Gula', 14608, '1kg'),
        'Keju Parut 250gr': ('Keju', 23373, '250gr'),
        'Mentega 500gr': ('Mentega', 17529, '500gr'),
        'Susu Bubuk': ('Susu', 17529, '27gr'),
        'Susu Bubuk 27gr': ('Susu', 17529, '27gr'),
        'Telur 1kg': ('Telur', 26878, '1kg'),
        'Tepung Terigu 1kg': ('Tepung', 11687, '1kg'),
    }

    unit_col = get_existing_column(cursor, 'products', ['unit'])
    for name, (category, price, unit) in updates.items():
        if unit_col:
            cursor.execute(
                f"""
                UPDATE products
                SET category = %s, price = %s, {unit_col} = %s
                WHERE name = %s
                """,
                (category, price, unit, name),
            )
        else:
            cursor.execute(
                "UPDATE products SET category = %s, price = %s WHERE name = %s",
                (category, price, name),
            )


def cleanup_to_backend_recipe_data(cursor):
    deleted = {}

    # Jangan hapus products/recipe_ingredients yang tidak ada di dataset model.
    # Random Forest memang hanya memakai bahan dataset sebagai bahan acuan,
    # tetapi kalkulasi kebutuhan resep tetap membutuhkan bahan pendukung seperti
    # Santan, Pewarna Makanan, Kelapa Parut, Selai Nanas, dan bahan lain dari backend.
    deleted['products'] = 0
    deleted['recipe_ingredients'] = 0
    deleted['stock in'] = 0
    deleted['stock_usage_history'] = 0
    deleted['transactions'] = 0

    if table_exists(cursor, 'stok_keluar') and table_exists(cursor, 'products'):
        cursor.execute(
            """
            DELETE sk
            FROM stok_keluar sk
            LEFT JOIN products p ON p.id = sk.bahan_id
            WHERE p.id IS NULL
            """
        )
        deleted['stok_keluar'] = cursor.rowcount

    if table_exists(cursor, 'recipes') and table_exists(cursor, 'recipe_ingredients'):
        cursor.execute(
            """
            DELETE r
            FROM recipes r
            LEFT JOIN recipe_ingredients ri ON ri.recipe_id = r.id
            WHERE ri.id IS NULL
            """
        )
        deleted['recipes_without_dataset_ingredients'] = cursor.rowcount

    normalize_dataset_product_rows(cursor)
    return deleted


def main():
    with open('prediksi_stok_db.sql', 'r', encoding='utf-8') as sql_file:
        sql_text = sql_file.read()

    connection = mysql.connector.connect(**db_config())
    cursor = connection.cursor()

    restored = []
    try:
        cursor.execute("SET FOREIGN_KEY_CHECKS = 0")

        for table in reversed(RESTORE_TABLES):
            delete_table(cursor, table)

        for table, statement in extract_insert_statements(sql_text):
            cursor.execute(statement)
            restored.append(table)

        deleted = cleanup_to_backend_recipe_data(cursor)

        cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        cursor.close()
        connection.close()

    print("Restored insert blocks:", ", ".join(restored))
    print("Deleted unsupported rows:", deleted)


if __name__ == '__main__':
    main()
