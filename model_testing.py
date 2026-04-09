import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
from sklearn.preprocessing import LabelEncoder
import joblib
import warnings
warnings.filterwarnings('ignore')

# ============================================================================
# LOAD AND PREPARE DATA
# ============================================================================
print("=" * 80)
print("MODEL TESTING - LINEAR REGRESSION vs RANDOM FOREST")
print("=" * 80)

file_path = 'dataset_prediksi_permintaan_bahan_2021_2025_update_tanggal.xlsx'

try:
    df = pd.read_excel(file_path)
    print(f"\n[OK] Data loaded: {df.shape[0]} baris, {df.shape[1]} kolom")
except Exception as e:
    print(f"[ERROR] Gagal load data: {e}")
    exit(1)

# Display data info
print(f"\nColumn Names:")
print(df.columns.tolist())
print(f"\nFirst 5 rows:")
print(df.head())
print(f"\nData Types:")
print(df.dtypes)
print(f"\nMissing Values:")
print(df.isnull().sum())

# ============================================================================
# FEATURE ENGINEERING
# ============================================================================
print("\n" + "=" * 80)
print("FEATURE ENGINEERING")
print("=" * 80)

# Identify target column (column with quantity/jumlah)
target_col = None
for col in df.columns:
    if 'jumlah' in col.lower() or 'qty' in col.lower() or 'quantity' in col.lower():
        target_col = col
        break

if target_col is None:
    print("[ERROR] Kolom target tidak ditemukan. Pilihan kolom:")
    print(df.columns.tolist())
    exit(1)

print(f"\nTarget column identified: {target_col}")

# Find date column
date_col = None
for col in df.columns:
    if 'tanggal' in col.lower() or 'date' in col.lower():
        date_col = col
        break

if date_col:
    print(f"Date column identified: {date_col}")
    df[date_col] = pd.to_datetime(df[date_col])
    df['tahun'] = df[date_col].dt.year
    df['bulan'] = df[date_col].dt.month
    df['hari'] = df[date_col].dt.day
    df['hari_minggu'] = df[date_col].dt.dayofweek
    print("[OK] Tanggal dipecah menjadi: tahun, bulan, hari, hari_minggu")

# Identify and encode categorical columns
categorical_cols = df.select_dtypes(include=['object']).columns.tolist()
if date_col and date_col in categorical_cols:
    categorical_cols.remove(date_col)

encoders = {}
for col in categorical_cols:
    le = LabelEncoder()
    df[f'{col}_encoded'] = le.fit_transform(df[col].astype(str))
    encoders[col] = le
    print(f"[OK] {col} di-encode")

# Select features
numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
feature_cols = [col for col in numeric_cols if col != target_col]

print(f"\nFeatures yang digunakan: {len(feature_cols)}")
print(f"Features: {feature_cols}")

X = df[feature_cols].copy()
y = df[target_col].copy()

print(f"\nX shape: {X.shape}")
print(f"y shape: {y.shape}")

# Remove NaN values
mask = ~(X.isnull().any(axis=1) | y.isnull())
X = X[mask]
y = y[mask]

print(f"After removing NaN: X={X.shape}, y={y.shape}")

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

print(f"\nData dibagi:")
print(f"  - Training: {len(X_train)} samples ({len(X_train)/len(X)*100:.1f}%)")
print(f"  - Testing:  {len(X_test)} samples ({len(X_test)/len(X)*100:.1f}%)")

# ============================================================================
# MODEL 1: LINEAR REGRESSION
# ============================================================================
print("\n" + "=" * 80)
print("MODEL 1: LINEAR REGRESSION")
print("=" * 80)

lr_model = LinearRegression()
lr_model.fit(X_train, y_train)

# Predictions
y_train_pred_lr = lr_model.predict(X_train)
y_test_pred_lr = lr_model.predict(X_test)

# Metrics - Training
train_mse_lr = mean_squared_error(y_train, y_train_pred_lr)
train_rmse_lr = np.sqrt(train_mse_lr)
train_mae_lr = mean_absolute_error(y_train, y_train_pred_lr)
train_r2_lr = r2_score(y_train, y_train_pred_lr)

# Metrics - Testing
test_mse_lr = mean_squared_error(y_test, y_test_pred_lr)
test_rmse_lr = np.sqrt(test_mse_lr)
test_mae_lr = mean_absolute_error(y_test, y_test_pred_lr)
test_r2_lr = r2_score(y_test, y_test_pred_lr)

print(f"\nTraining Metrics:")
print(f"  R² Score:               {train_r2_lr:.4f}")
print(f"  Mean Absolute Error:    {train_mae_lr:.2f}")
print(f"  Root Mean Squared Error: {train_rmse_lr:.2f}")

print(f"\nTesting Metrics:")
print(f"  R² Score:               {test_r2_lr:.4f}")
print(f"  Mean Absolute Error:    {test_mae_lr:.2f}")
print(f"  Root Mean Squared Error: {test_rmse_lr:.2f}")

# ============================================================================
# MODEL 2: RANDOM FOREST
# ============================================================================
print("\n" + "=" * 80)
print("MODEL 2: RANDOM FOREST REGRESSOR")
print("=" * 80)

rf_model = RandomForestRegressor(n_estimators=100, random_state=42, n_jobs=-1)
rf_model.fit(X_train, y_train)

# Predictions
y_train_pred_rf = rf_model.predict(X_train)
y_test_pred_rf = rf_model.predict(X_test)

# Metrics - Training
train_mse_rf = mean_squared_error(y_train, y_train_pred_rf)
train_rmse_rf = np.sqrt(train_mse_rf)
train_mae_rf = mean_absolute_error(y_train, y_train_pred_rf)
train_r2_rf = r2_score(y_train, y_train_pred_rf)

# Metrics - Testing
test_mse_rf = mean_squared_error(y_test, y_test_pred_rf)
test_rmse_rf = np.sqrt(test_mse_rf)
test_mae_rf = mean_absolute_error(y_test, y_test_pred_rf)
test_r2_rf = r2_score(y_test, y_test_pred_rf)

print(f"\nTraining Metrics:")
print(f"  R² Score:               {train_r2_rf:.4f}")
print(f"  Mean Absolute Error:    {train_mae_rf:.2f}")
print(f"  Root Mean Squared Error: {train_rmse_rf:.2f}")

print(f"\nTesting Metrics:")
print(f"  R² Score:               {test_r2_rf:.4f}")
print(f"  Mean Absolute Error:    {test_mae_rf:.2f}")
print(f"  Root Mean Squared Error: {test_rmse_rf:.2f}")

# ============================================================================
# COMPARISON & RECOMMENDATION
# ============================================================================
print("\n" + "=" * 80)
print("PERBANDINGAN KEDUA MODEL")
print("=" * 80)

comparison_data = {
    'Metrics': ['R² Score', 'MAE', 'RMSE'],
    'Linear Regression': [f'{test_r2_lr:.4f}', f'{test_mae_lr:.2f}', f'{test_rmse_lr:.2f}'],
    'Random Forest': [f'{test_r2_rf:.4f}', f'{test_mae_rf:.2f}', f'{test_rmse_rf:.2f}']
}
comparison_df = pd.DataFrame(comparison_data)

print("\nHasil Testing (Test Set):")
print(comparison_df.to_string(index=False))

print("\n" + "-" * 80)
print("REKOMENDASI:")
print("-" * 80)

if test_r2_rf > test_r2_lr:
    best_model = "Random Forest"
    best_r2 = test_r2_rf
    worst_r2 = test_r2_lr
else:
    best_model = "Linear Regression"
    best_r2 = test_r2_lr
    worst_r2 = test_r2_rf

print(f"\n[BEST] MODEL TERBAIK: {best_model}")
print(f"  - Akurasi {best_model} (R²) = {best_r2:.4f}")
if test_r2_rf > test_r2_lr:
    print(f"  - Akurasi Linear Regression (R²) = {test_r2_lr:.4f}")
    print(f"  - Perbedaan: {(test_r2_rf - test_r2_lr):.4f}")
else:
    print(f"  - Akurasi Random Forest (R²) = {test_r2_rf:.4f}")
    print(f"  - Perbedaan: {(test_r2_lr - test_r2_rf):.4f}")

# ============================================================================
# SAVE RESULTS
# ============================================================================
results_file = open('model_testing_results.txt', 'w', encoding='utf-8')
results_file.write("=" * 80 + "\n")
results_file.write("HASIL TESTING MODEL - PREDIKSI PERMINTAAN STOK BAHAN KUE\n")
results_file.write("=" * 80 + "\n\n")

results_file.write(f"Total Data: {df.shape[0]} baris\n")
results_file.write(f"Training Set: {len(X_train)} ({len(X_train)/len(X)*100:.1f}%)\n")
results_file.write(f"Testing Set: {len(X_test)} ({len(X_test)/len(X)*100:.1f}%)\n")
results_file.write(f"Features: {len(feature_cols)}\n")
results_file.write(f"Target: {target_col}\n\n")

results_file.write("LINEAR REGRESSION - Test Metrics:\n")
results_file.write(f"  R² Score: {test_r2_lr:.4f}\n")
results_file.write(f"  MAE: {test_mae_lr:.2f}\n")
results_file.write(f"  RMSE: {test_rmse_lr:.2f}\n\n")

results_file.write("RANDOM FOREST - Test Metrics:\n")
results_file.write(f"  R² Score: {test_r2_rf:.4f}\n")
results_file.write(f"  MAE: {test_mae_rf:.2f}\n")
results_file.write(f"  RMSE: {test_rmse_rf:.2f}\n\n")

results_file.write(f"REKOMENDASI: {best_model} (Lebih baik)\n")
results_file.close()

print("\n[OK] Hasil disimpan ke: model_testing_results.txt")

# ============================================================================
# SAVE BEST MODEL
# ============================================================================
print("\n" + "=" * 80)
print("MENYIMPAN MODEL TERBAIK")
print("=" * 80)

if best_model == "Linear Regression":
    joblib.dump(lr_model, 'model_prediksi.pkl')
    print("\n[OK] Model Linear Regression disimpan: model_prediksi.pkl")
else:
    joblib.dump(rf_model, 'model_prediksi.pkl')
    print("\n[OK] Model Random Forest disimpan: model_prediksi.pkl")

# Save encoders
joblib.dump(encoders, 'encoders.pkl')
print("[OK] Encoders disimpan: encoders.pkl")

# Save feature columns
joblib.dump(feature_cols, 'feature_columns.pkl')
print("[OK] Feature columns disimpan: feature_columns.pkl")

# Save metadata
metadata = {
    'model_type': best_model,
    'r2_score': best_r2,
    'mae': test_mae_lr if best_model == "Linear Regression" else test_mae_rf,
    'rmse': test_rmse_lr if best_model == "Linear Regression" else test_rmse_rf,
    'feature_columns': feature_cols,
    'target_column': target_col,
    'total_samples': len(df)
}

joblib.dump(metadata, 'model_metadata.pkl')
print("[OK] Metadata disimpan: model_metadata.pkl")

print("\nFile yang telah disimpan:")
print("  1. model_prediksi.pkl       - Model Terbaik")
print("  2. encoders.pkl             - Label Encoders")
print("  3. feature_columns.pkl      - Daftar Fitur")
print("  4. model_metadata.pkl       - Metadata Model")

print("\n" + "=" * 80)
