import mysql.connector

from cleanup_dummy_data import db_config


PRODUCT_ROWS = [
    (25, 'Kelapa Parut', 'Bahan Baku', 8000, 0.000, 0.000, 'gr'),
    (26, 'Santan', 'Bahan Baku', 10000, 19.000, 0.000, 'ml'),
    (27, 'Selai Nanas', 'Bahan Tambahan', 15000, 10.000, 0.000, 'gr'),
    (28, 'Tepung Ketan', 'Bahan Baku', 12000, 7.000, 0.000, 'gr'),
    (29, 'Tepung Beras', 'Bahan Baku', 10000, 6.000, 0.000, 'gr'),
    (30, 'Gula Merah', 'Bahan Baku', 12000, 13.000, 0.000, 'gr'),
    (31, 'Cream Cheese', 'Bahan Tambahan', 30000, 6.000, 0.000, 'gr'),
    (32, 'Susu Cair', 'Bahan Baku', 12000, 8.000, 0.000, 'ml'),
    (33, 'Kopi', 'Bahan Tambahan', 10000, 10.000, 0.000, 'ml'),
    (34, 'Biskuit', 'Bahan Tambahan', 8000, 10.000, 0.000, 'gr'),
    (35, 'Pewarna Makanan', 'Bahan Tambahan', 5000, 5.000, 0.000, 'gr'),
    (36, 'Pewarna Merah', 'Bahan Tambahan', 5000, 10.000, 0.000, 'gr'),
]


PRODUCT_UNIT_UPDATES = {
    'Baking Powder': 'gr',
    'Baking Powder 45gr': 'gr',
    'Cokelat Bubuk 250gr': 'gr',
    'Cream Cheese': 'gr',
    'Gula Merah': 'gr',
    'Gula Pasir 1kg': 'kg',
    'Keju Parut 250gr': 'gr',
    'Kelapa Parut': 'gr',
    'Kopi': 'ml',
    'Mentega 500gr': 'gr',
    'Pewarna Makanan': 'gr',
    'Pewarna Merah': 'gr',
    'Santan': 'ml',
    'Selai Nanas': 'gr',
    'Susu Bubuk': 'gr',
    'Susu Bubuk 27gr': 'gr',
    'Susu Cair': 'ml',
    'Telur 1kg': 'kg',
    'Tepung Beras': 'gr',
    'Tepung Ketan': 'gr',
    'Tepung Terigu 1kg': 'kg',
}


RECIPE_INGREDIENT_ROWS = [
    (43, 8, 'Selai Nanas', 150, 'gr'),
    (51, 10, 'Kelapa Parut', 200, 'gr'),
    (54, 11, 'Santan', 300, 'ml'),
    (55, 11, 'Pewarna Makanan', 5, 'gr'),
    (59, 12, 'Santan', 250, 'ml'),
    (63, 13, 'Susu Cair', 250, 'ml'),
    (64, 14, 'Tepung Ketan', 400, 'gr'),
    (65, 14, 'Gula Merah', 200, 'gr'),
    (66, 14, 'Kelapa Parut', 200, 'gr'),
    (67, 15, 'Tepung Beras', 300, 'gr'),
    (68, 15, 'Santan', 300, 'ml'),
    (70, 16, 'Tepung Terigu 1kg', 250, 'gr'),
    (71, 16, 'Telur 1kg', 2, 'butir'),
    (72, 16, 'Kelapa Parut', 200, 'gr'),
    (73, 16, 'Gula Merah', 150, 'gr'),
    (74, 17, 'Tepung Beras', 300, 'gr'),
    (75, 17, 'Kelapa Parut', 200, 'gr'),
    (76, 17, 'Santan', 250, 'ml'),
    (81, 19, 'Biskuit', 200, 'gr'),
    (82, 19, 'Kopi', 100, 'ml'),
    (83, 19, 'Krim', 200, 'ml'),
    (88, 20, 'Pewarna Merah', 5, 'gr'),
    (89, 20, 'Cream Cheese', 150, 'gr'),
]


def has_column(cursor, table_name, column_name):
    cursor.execute(f"SHOW COLUMNS FROM `{table_name}` LIKE %s", (column_name,))
    return cursor.fetchone() is not None


def ensure_product_unit_column(cursor):
    if has_column(cursor, 'products', 'unit'):
        return

    cursor.execute(
        "ALTER TABLE products ADD COLUMN unit VARCHAR(20) NOT NULL DEFAULT 'kg'"
    )


def product_exists(cursor, name):
    cursor.execute("SELECT id FROM products WHERE name = %s LIMIT 1", (name,))
    return cursor.fetchone() is not None


def id_exists(cursor, table_name, row_id):
    cursor.execute(f"SELECT id FROM `{table_name}` WHERE id = %s LIMIT 1", (row_id,))
    return cursor.fetchone() is not None


def insert_missing_products(cursor):
    ensure_product_unit_column(cursor)
    has_unit = has_column(cursor, 'products', 'unit')
    inserted = 0

    for name, unit in PRODUCT_UNIT_UPDATES.items():
        cursor.execute(
            """
            UPDATE products
            SET unit = %s
            WHERE name = %s
            """,
            (unit, name),
        )

    for row_id, name, category, price, stock, min_stock, unit in PRODUCT_ROWS:
        if product_exists(cursor, name):
            if has_unit:
                cursor.execute(
                    """
                    UPDATE products
                    SET unit = %s
                    WHERE name = %s AND (unit IS NULL OR unit = '' OR unit = 'unit')
                    """,
                    (unit, name),
                )
            continue

        columns = ['name', 'category', 'price', 'current_stock', 'min_stock']
        values = [name, category, price, stock, min_stock]

        if not id_exists(cursor, 'products', row_id):
            columns.insert(0, 'id')
            values.insert(0, row_id)

        if has_unit:
            columns.append('unit')
            values.append(unit)

        column_sql = ', '.join(columns)
        placeholders = ', '.join(['%s'] * len(values))
        cursor.execute(
            f"INSERT INTO products ({column_sql}) VALUES ({placeholders})",
            tuple(values),
        )
        inserted += 1

    return inserted


def recipe_ingredient_exists(cursor, recipe_id, product_name):
    cursor.execute(
        """
        SELECT id
        FROM recipe_ingredients
        WHERE recipe_id = %s AND product_name = %s
        LIMIT 1
        """,
        (recipe_id, product_name),
    )
    return cursor.fetchone() is not None


def recipe_exists(cursor, recipe_id):
    cursor.execute("SELECT id FROM recipes WHERE id = %s LIMIT 1", (recipe_id,))
    return cursor.fetchone() is not None


def insert_missing_recipe_ingredients(cursor):
    inserted = 0
    skipped_missing_recipes = []

    for row_id, recipe_id, product_name, quantity_needed, unit in RECIPE_INGREDIENT_ROWS:
        if not recipe_exists(cursor, recipe_id):
            skipped_missing_recipes.append(recipe_id)
            continue

        if recipe_ingredient_exists(cursor, recipe_id, product_name):
            continue

        columns = ['recipe_id', 'product_name', 'quantity_needed', 'unit']
        values = [recipe_id, product_name, quantity_needed, unit]

        if not id_exists(cursor, 'recipe_ingredients', row_id):
            columns.insert(0, 'id')
            values.insert(0, row_id)

        column_sql = ', '.join(columns)
        placeholders = ', '.join(['%s'] * len(values))
        cursor.execute(
            f"INSERT INTO recipe_ingredients ({column_sql}) VALUES ({placeholders})",
            tuple(values),
        )
        inserted += 1

    return inserted, sorted(set(skipped_missing_recipes))


def main():
    connection = mysql.connector.connect(**db_config())
    cursor = connection.cursor()

    try:
        inserted_products = insert_missing_products(cursor)
        inserted_ingredients, skipped_recipes = insert_missing_recipe_ingredients(cursor)
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        cursor.close()
        connection.close()

    print(f"Inserted products: {inserted_products}")
    print(f"Inserted recipe ingredients: {inserted_ingredients}")
    if skipped_recipes:
        print(f"Skipped missing recipe IDs: {skipped_recipes}")


if __name__ == '__main__':
    main()
