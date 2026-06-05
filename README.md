# BKprojectTA Backend

Backend Flask untuk aplikasi prediksi stok bahan kue, siap deploy ke Railway.

## Deploy Railway

1. Buat service baru dari repo ini di Railway.
2. Tambahkan service MySQL Railway, atau gunakan database MySQL eksternal.
3. Set environment variable berikut bila tidak memakai variabel otomatis Railway MySQL:
   - `DB_HOST`
   - `DB_PORT`
   - `DB_USER`
   - `DB_PASSWORD`
   - `DB_NAME`
4. Untuk OTP email, set:
   - `SMTP_EMAIL`
   - `SMTP_APP_PASSWORD`
   - `SMTP_HOST` opsional, default `smtp.gmail.com`
   - `SMTP_PORT` opsional, default `587`
5. Import schema dari `setup_database.sql`, `database/recipes_schema.sql`, dan `database/report_schema.sql` ke database.

Railway akan menjalankan aplikasi dengan command dari `railway.json` atau `Procfile`.

## Catatan Dependency

Model .pkl dibuat dengan 
umpy 2.x dan scikit-learn 1.8.0, jadi Railway harus memakai Python 3.11+ dan dependency sesuai equirements.txt.

