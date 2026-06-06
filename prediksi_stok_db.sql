-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 06, 2026 at 04:02 AM
-- Server version: 8.4.3
-- PHP Version: 8.2.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `prediksi_stok_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `login`
--

CREATE TABLE `login` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `login`
--

INSERT INTO `login` (`id`, `name`, `email`, `username`, `password`, `created_at`) VALUES
(1, 'Ibu Sulastri', 'sulastri.aritanto10@gmail.com', 'admin', '3fb63c2b4b0027d1e6c5ff669d16af6b21bd887c639091902d756ddd436da966', '2026-05-19 10:06:15');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_otps`
--

CREATE TABLE `password_reset_otps` (
  `id` int NOT NULL,
  `login_id` int NOT NULL,
  `email` varchar(100) NOT NULL,
  `otp_code` varchar(10) NOT NULL,
  `expires_at` datetime NOT NULL,
  `is_used` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `password_reset_otps`
--

INSERT INTO `password_reset_otps` (`id`, `login_id`, `email`, `otp_code`, `expires_at`, `is_used`, `created_at`) VALUES
(1, 1, 'sulastri.arianto10@gmail.com', '676222', '2026-05-20 17:09:13', 0, '2026-05-20 09:59:12'),
(2, 1, 'sulastri.aritanto10@gmail.com', '435905', '2026-05-20 18:42:51', 0, '2026-05-20 11:32:54'),
(3, 1, 'sulastri.aritanto10@gmail.com', '350650', '2026-05-20 18:44:25', 1, '2026-05-20 11:34:28'),
(4, 1, 'sulastri.aritanto10@gmail.com', '154681', '2026-05-20 19:03:38', 1, '2026-05-20 11:53:42'),
(5, 1, 'sulastri.aritanto10@gmail.com', '963846', '2026-05-20 19:25:48', 1, '2026-05-20 12:15:51'),
(6, 1, 'sulastri.aritanto10@gmail.com', '217759', '2026-05-20 19:42:16', 1, '2026-05-20 12:32:19'),
(7, 1, 'sulastri.aritanto10@gmail.com', '020201', '2026-05-21 00:44:19', 0, '2026-05-20 17:34:22'),
(8, 1, 'sulastri.aritanto10@gmail.com', '524736', '2026-05-21 01:05:06', 1, '2026-05-20 17:55:09'),
(9, 1, 'sulastri.aritanto10@gmail.com', '228135', '2026-05-24 21:35:31', 1, '2026-05-24 14:25:34'),
(10, 1, 'sulastri.aritanto10@gmail.com', '770181', '2026-05-26 14:09:24', 1, '2026-05-26 06:59:28'),
(11, 1, 'sulastri.aritanto10@gmail.com', '048915', '2026-06-01 20:58:43', 0, '2026-06-01 13:48:48'),
(12, 1, 'sulastri.aritanto10@gmail.com', '135561', '2026-06-04 20:02:34', 0, '2026-06-04 12:52:38'),
(13, 1, 'sulastri.aritanto10@gmail.com', '427873', '2026-06-04 20:08:42', 0, '2026-06-04 12:58:46');

-- --------------------------------------------------------

--
-- Table structure for table `predictions`
--

CREATE TABLE `predictions` (
  `id` int NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `category` varchar(100) NOT NULL,
  `unit_price` int NOT NULL,
  `prediction_date` date NOT NULL,
  `predicted_quantity` int NOT NULL,
  `raw_value` float DEFAULT NULL,
  `estimated_total_price` int DEFAULT NULL,
  `accuracy_r2` float DEFAULT NULL,
  `error_mae` float DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `estimated_needs` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `predictions`
--

INSERT INTO `predictions` (`id`, `product_name`, `category`, `unit_price`, `prediction_date`, `predicted_quantity`, `raw_value`, `estimated_total_price`, `accuracy_r2`, `error_mae`, `created_at`, `estimated_needs`) VALUES
(1, 'Kue Bolu', 'Produk', 0, '2026-05-13', 2, NULL, NULL, NULL, NULL, '2026-05-13 06:16:41', NULL),
(2, 'Kue Nastar', 'Produk', 0, '2026-05-13', 2, NULL, NULL, NULL, NULL, '2026-05-13 07:01:20', NULL),
(3, 'Kue Pancong', 'Produk', 0, '2026-05-13', 2, NULL, NULL, NULL, NULL, '2026-05-13 10:02:28', NULL),
(4, 'Kue Bolu', 'Produk', 0, '2026-05-13', 3, NULL, NULL, NULL, NULL, '2026-05-13 11:14:47', NULL),
(5, 'Kue Klepon', 'Produk', 0, '2026-05-13', 1, NULL, NULL, NULL, NULL, '2026-05-13 11:28:08', NULL),
(6, 'Kue Putu Ayu', 'Produk', 0, '2026-05-13', 2, NULL, NULL, NULL, NULL, '2026-05-13 11:48:44', NULL),
(7, 'Donat', 'Produk', 0, '2026-05-13', 2, NULL, NULL, NULL, NULL, '2026-05-13 12:06:33', NULL),
(8, 'Kue Bolu', 'Produk', 0, '2026-05-13', 2, NULL, NULL, NULL, NULL, '2026-05-13 12:11:35', 'Gula Pasir: 400 gr, Mentega: 300 gr, Susu Bubuk: 100 gr, Telur: 400 gr, Tepung Terigu: 800 gr'),
(9, 'Roti Manis', 'Produk', 0, '2026-05-13', 2, NULL, NULL, NULL, NULL, '2026-05-13 12:24:25', 'Gula Pasir: 300 gr, Mentega: 200 gr, Susu Bubuk: 100 gr, Telur: 300 gr, Tepung Terigu: 1.2 kg'),
(10, 'Kue Bolu', 'Produk', 0, '2026-05-14', 12, NULL, NULL, NULL, NULL, '2026-05-14 13:34:01', 'Gula Pasir: 2.4 kg, Mentega: 1.8 kg, Susu Bubuk: 600 gr, Tepung Terigu: 4.8 kg'),
(11, 'Kue Sus', 'Produk', 0, '2026-05-14', 7, NULL, NULL, NULL, NULL, '2026-05-14 14:16:33', 'Mentega: 1.05 kg, Susu Cair: 1.75 kg, Telur: 1.4 kg, Tepung Terigu: 2.1 kg'),
(12, 'Kue Klepon', 'Produk', 0, '2026-05-14', 5, NULL, NULL, NULL, NULL, '2026-05-14 14:22:07', 'Gula Merah: 1 kg, Kelapa Parut: 1 kg, Tepung Ketan: 2 kg'),
(13, 'Kue Lumpur', 'Produk', 0, '2026-05-15', 3, NULL, NULL, NULL, NULL, '2026-05-15 15:29:45', 'Gula Pasir: 450 gr, Santan: 750 gr, Telur: 450 gr, Tepung Terigu: 750 gr'),
(14, 'Kue Kastengel', 'Produk', 0, '2026-05-15', 3, NULL, NULL, NULL, NULL, '2026-05-15 15:38:28', 'Keju Parut: 450 gr, Mentega: 600 gr, Telur: 300 gr, Tepung Terigu: 1.2 kg'),
(15, 'Kue Red Velvet', 'Produk', 0, '2026-05-15', 3, NULL, NULL, NULL, NULL, '2026-05-15 15:50:04', 'Cream Cheese: 450 gr, Gula Pasir: 600 gr, Pewarna Merah: 15 gr, Telur: 600 gr, Tepung Terigu: 1.2 kg'),
(16, 'Kue Lapis', 'Produk', 0, '2026-05-15', 8, NULL, NULL, NULL, NULL, '2026-05-15 16:05:16', 'Gula Pasir: 1.6 kg, Pewarna Makanan: 40 gr, Santan: 2.4 kg, Tepung Terigu: 2.4 kg'),
(17, 'Kue Pancong', 'Produk', 0, '2026-05-15', 10, NULL, NULL, NULL, NULL, '2026-05-15 16:13:55', 'Kelapa Parut: 2 kg, Santan: 2.5 kg, Tepung Beras: 3 kg'),
(18, 'Kue Kastengel', 'Produk', 0, '2026-05-17', 6, NULL, NULL, NULL, NULL, '2026-05-17 14:56:02', 'Keju Parut: 900 gr, Mentega: 1.2 kg, Telur: 600 gr, Tepung Terigu: 2.4 kg'),
(19, 'Kue Brownies', 'Produk', 0, '2026-05-17', 1, NULL, NULL, NULL, NULL, '2026-05-17 14:59:15', 'Baking Powder: 5 gr, Cokelat Bubuk: 100 gr, Gula Pasir: 200 gr, Mentega: 150 gr, Telur: 200 gr, Tepung Terigu: 300 gr'),
(20, 'Kue Tart', 'Produk', 0, '2026-05-17', 4, NULL, NULL, NULL, NULL, '2026-05-17 14:59:39', 'Gula Pasir: 600 gr, Keju Parut: 400 gr, Mentega: 800 gr, Susu Bubuk: 320 gr, Telur: 1 kg, Tepung Terigu: 1.6 kg'),
(21, 'Kue Sus', 'Produk', 0, '2026-05-17', 1, NULL, NULL, NULL, NULL, '2026-05-17 14:59:48', 'Mentega: 150 gr, Susu Cair: 250 gr, Telur: 200 gr, Tepung Terigu: 300 gr'),
(22, 'Kue Lapis', 'Produk', 0, '2026-05-17', 4, NULL, NULL, NULL, NULL, '2026-05-17 15:11:42', 'Gula Pasir: 800 gr, Pewarna Makanan: 20 gr, Santan: 1.2 kg, Tepung Terigu: 1.2 kg'),
(23, 'Kue Kastengel', 'Produk', 0, '2026-05-24', 3, NULL, NULL, NULL, NULL, '2026-05-24 14:06:09', 'Keju Parut: 450 gr, Mentega: 600 gr, Telur: 300 gr, Tepung Terigu: 1.2 kg'),
(24, 'Donat', 'Produk', 0, '2026-05-24', 10, NULL, NULL, NULL, NULL, '2026-05-24 14:07:19', 'Baking Powder: 50 gr, Gula Pasir: 1 kg, Mentega: 500 gr, Telur: 1 kg, Tepung Terigu: 5 kg'),
(25, 'Donat', 'Produk', 0, '2026-05-24', 5, NULL, NULL, NULL, NULL, '2026-05-24 14:24:01', 'Baking Powder: 25 gr, Gula Pasir: 500 gr, Mentega: 250 gr, Telur: 500 gr, Tepung Terigu: 2.5 kg'),
(26, 'Donat', 'Produk', 0, '2026-05-24', 1, NULL, NULL, NULL, NULL, '2026-05-24 14:39:38', 'Baking Powder: 5 gr, Gula Pasir: 100 gr, Mentega: 50 gr, Telur: 100 gr, Tepung Terigu: 500 gr'),
(27, 'Donat', 'Produk', 0, '2026-05-26', 2, NULL, NULL, NULL, NULL, '2026-05-26 07:08:28', 'Baking Powder: 10 gr, Gula Pasir: 200 gr, Mentega: 100 gr, Telur: 200 gr, Tepung Terigu: 1 kg');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `category` varchar(100) NOT NULL,
  `price` int NOT NULL,
  `current_stock` decimal(10,3) NOT NULL DEFAULT '0.000',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `min_stock` decimal(10,3) NOT NULL DEFAULT '0.000'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `category`, `price`, `current_stock`, `created_at`, `updated_at`, `min_stock`) VALUES
(16, 'Tepung Terigu 1kg', 'Bahan Baku', 12000, 4.000, '2026-05-02 15:39:26', '2026-05-26 07:08:27', 10.000),
(17, 'Telur 1kg', 'Bahan Baku', 25000, 21.200, '2026-05-02 15:39:26', '2026-05-26 07:08:27', 5.000),
(18, 'Gula Pasir 1kg', 'Bahan Baku', 14000, 18.200, '2026-05-02 15:39:26', '2026-05-26 07:08:27', 8.000),
(19, 'Mentega 500gr', 'Bahan Baku', 10000, 10.600, '2026-05-02 15:39:26', '2026-05-26 07:08:27', 5.000),
(20, 'Susu Bubuk', 'Bahan Tambahan', 20000, 14.000, '2026-05-02 15:39:26', '2026-05-24 14:50:44', 4.000),
(21, 'Ragi', 'Bahan Tambahan', 5000, 10.000, '2026-05-02 15:39:26', '2026-05-02 15:39:26', 0.000),
(22, 'Baking Powder', 'Bahan Tambahan', 5000, 9.960, '2026-05-02 15:39:26', '2026-05-26 07:08:27', 2.000),
(23, 'Cokelat Bubuk 250gr', 'Bahan Tambahan', 15000, 9.000, '2026-05-02 15:39:26', '2026-05-24 14:50:44', 3.000),
(24, 'Keju Parut 250gr', 'Bahan Tambahan', 20000, 9.000, '2026-05-02 15:39:26', '2026-05-24 14:50:44', 2.000),
(25, 'Kelapa Parut', 'Bahan Baku', 8000, 0.000, '2026-05-02 15:39:26', '2026-05-15 16:13:55', 0.000),
(26, 'Santan', 'Bahan Baku', 10000, 19.000, '2026-05-02 15:39:26', '2026-05-17 15:11:42', 0.000),
(27, 'Selai Nanas', 'Bahan Tambahan', 15000, 10.000, '2026-05-02 15:39:26', '2026-05-02 15:39:26', 0.000),
(28, 'Tepung Ketan', 'Bahan Baku', 12000, 7.000, '2026-05-02 15:39:26', '2026-05-14 14:22:07', 0.000),
(29, 'Tepung Beras', 'Bahan Baku', 10000, 6.000, '2026-05-02 15:39:26', '2026-05-15 16:13:55', 0.000),
(30, 'Gula Merah', 'Bahan Baku', 12000, 13.000, '2026-05-02 15:39:26', '2026-05-14 14:39:30', 0.000),
(31, 'Cream Cheese', 'Bahan Tambahan', 30000, 6.000, '2026-05-02 15:39:26', '2026-05-14 05:47:03', 0.000),
(32, 'Susu Cair', 'Bahan Baku', 12000, 8.000, '2026-05-02 15:39:26', '2026-05-14 14:16:32', 0.000),
(33, 'Kopi', 'Bahan Tambahan', 10000, 10.000, '2026-05-02 15:39:26', '2026-05-02 15:39:26', 0.000),
(34, 'Biskuit', 'Bahan Tambahan', 8000, 10.000, '2026-05-02 15:39:26', '2026-05-02 15:39:26', 0.000),
(35, 'Pewarna Makanan', 'Bahan Tambahan', 5000, 5.000, '2026-05-02 15:39:26', '2026-05-13 08:31:25', 0.000),
(36, 'Pewarna Merah', 'Bahan Tambahan', 5000, 10.000, '2026-05-02 15:39:26', '2026-05-07 06:25:04', 0.000),
(37, 'misis garuda', 'Bahan', 15000, 75.000, '2026-05-07 09:45:47', '2026-05-07 09:45:47', 0.000),
(38, 'krim', 'Bahan', 15000, 20.000, '2026-05-13 12:12:47', '2026-05-13 12:13:25', 0.000),
(39, 'selai strowbery', 'Bahan', 10000, 10.000, '2026-05-15 16:11:36', '2026-05-15 16:15:20', 0.000);

-- --------------------------------------------------------

--
-- Table structure for table `recipes`
--

CREATE TABLE `recipes` (
  `id` int NOT NULL,
  `recipe_name` varchar(100) NOT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `recipes`
--

INSERT INTO `recipes` (`id`, `recipe_name`, `description`, `created_at`) VALUES
(1, 'Donat', 'Donat klasik dengan topping gula', '2026-04-13 16:52:47'),
(2, 'Roti Putih', 'Roti putih lembut untuk sarapan', '2026-04-13 16:52:47'),
(3, 'Kue Brownies', 'Brownies cokelat yang lembut dan nikmat', '2026-04-13 16:52:47'),
(4, 'Kue Tart', 'Kue tart creamy dengan topping keju', '2026-04-13 16:52:47'),
(5, 'Kue Bolu', 'Bolu lembut dengan rasa vanilla', '2026-04-26 06:52:39'),
(6, 'Donat Coklat', 'Donat dengan topping coklat leleh', '2026-04-26 06:52:39'),
(7, 'Roti Manis', 'Roti manis isi coklat atau keju', '2026-04-26 06:52:39'),
(8, 'Kue Nastar', 'Kue kering isi selai nanas', '2026-04-26 06:52:39'),
(9, 'Kue Kastengel', 'Kue keju gurih khas lebaran', '2026-04-26 06:52:39'),
(10, 'Kue Putu Ayu', 'Kue tradisional dengan kelapa parut', '2026-04-26 06:52:39'),
(11, 'Kue Lapis', 'Kue berlapis warna-warni khas Indonesia', '2026-04-26 06:52:39'),
(12, 'Kue Lumpur', 'Kue lembut dengan topping kismis', '2026-04-26 06:52:39'),
(13, 'Kue Sus', 'Kue sus isi vla manis', '2026-04-26 06:52:39'),
(14, 'Kue Klepon', 'Kue tradisional isi gula merah', '2026-04-26 06:52:39'),
(15, 'Kue Serabi', 'Kue tradisional dengan santan', '2026-04-26 06:52:39'),
(16, 'Kue Dadar Gulung', 'Kue isi kelapa dan gula merah', '2026-04-26 06:52:39'),
(17, 'Kue Pancong', 'Kue tradisional dengan rasa gurih', '2026-04-26 06:52:39'),
(18, 'Brownies Kukus', 'Brownies lembut yang dikukus', '2026-04-26 06:52:39'),
(19, 'Kue Tiramisu', 'Kue modern dengan rasa kopi dan krim', '2026-04-26 06:52:39'),
(20, 'Kue Red Velvet', 'Kue dengan warna merah dan cream cheese', '2026-04-26 06:52:39');

-- --------------------------------------------------------

--
-- Table structure for table `recipe_ingredients`
--

CREATE TABLE `recipe_ingredients` (
  `id` int NOT NULL,
  `recipe_id` int NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `quantity_needed` int NOT NULL,
  `unit` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `recipe_ingredients`
--

INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `product_name`, `quantity_needed`, `unit`) VALUES
(1, 1, 'Tepung Terigu 1kg', 500, 'gr'),
(2, 1, 'Telur 1kg', 2, 'butir'),
(3, 1, 'Gula Pasir 1kg', 100, 'gr'),
(4, 1, 'Mentega 500gr', 50, 'gr'),
(5, 1, 'Baking Powder', 5, 'gr'),
(6, 2, 'Tepung Terigu 1kg', 800, 'gr'),
(7, 2, 'Telur 1kg', 3, 'butir'),
(8, 2, 'Gula Pasir 1kg', 80, 'gr'),
(9, 2, 'Mentega 500gr', 80, 'gr'),
(10, 2, 'Susu Bubuk', 50, 'gr'),
(11, 2, 'Baking Powder', 8, 'gr'),
(12, 3, 'Tepung Terigu 1kg', 300, 'gr'),
(13, 3, 'Cokelat Bubuk 250gr', 100, 'gr'),
(14, 3, 'Telur 1kg', 4, 'butir'),
(15, 3, 'Gula Pasir 1kg', 200, 'gr'),
(16, 3, 'Mentega 500gr', 150, 'gr'),
(17, 3, 'Baking Powder', 5, 'gr'),
(18, 4, 'Tepung Terigu 1kg', 400, 'gr'),
(19, 4, 'Telur 1kg', 5, 'butir'),
(20, 4, 'Gula Pasir 1kg', 150, 'gr'),
(21, 4, 'Mentega 500gr', 200, 'gr'),
(22, 4, 'Keju Parut 250gr', 100, 'gr'),
(23, 4, 'Susu Bubuk', 80, 'gr'),
(24, 5, 'Tepung Terigu 1kg', 400, 'gr'),
(25, 5, 'Telur 1kg', 4, 'butir'),
(26, 5, 'Gula Pasir 1kg', 200, 'gr'),
(27, 5, 'Mentega 500gr', 150, 'gr'),
(28, 5, 'Susu Bubuk', 50, 'gr'),
(29, 6, 'Tepung Terigu 1kg', 500, 'gr'),
(30, 6, 'Telur 1kg', 2, 'butir'),
(31, 6, 'Gula Pasir 1kg', 120, 'gr'),
(32, 6, 'Mentega 500gr', 70, 'gr'),
(33, 6, 'Cokelat Bubuk 250gr', 100, 'gr'),
(34, 7, 'Tepung Terigu 1kg', 600, 'gr'),
(35, 7, 'Telur 1kg', 3, 'butir'),
(36, 7, 'Gula Pasir 1kg', 150, 'gr'),
(37, 7, 'Mentega 500gr', 100, 'gr'),
(38, 7, 'Susu Bubuk', 50, 'gr'),
(39, 8, 'Tepung Terigu 1kg', 500, 'gr'),
(40, 8, 'Mentega 500gr', 200, 'gr'),
(41, 8, 'Gula Pasir 1kg', 100, 'gr'),
(42, 8, 'Telur 1kg', 2, 'butir'),
(43, 8, 'Selai Nanas', 150, 'gr'),
(44, 9, 'Tepung Terigu 1kg', 400, 'gr'),
(45, 9, 'Mentega 500gr', 200, 'gr'),
(46, 9, 'Keju Parut 250gr', 150, 'gr'),
(47, 9, 'Telur 1kg', 2, 'butir'),
(48, 10, 'Tepung Terigu 1kg', 300, 'gr'),
(49, 10, 'Telur 1kg', 3, 'butir'),
(50, 10, 'Gula Pasir 1kg', 150, 'gr'),
(51, 10, 'Kelapa Parut', 200, 'gr'),
(52, 11, 'Tepung Terigu 1kg', 300, 'gr'),
(53, 11, 'Gula Pasir 1kg', 200, 'gr'),
(54, 11, 'Santan', 300, 'ml'),
(55, 11, 'Pewarna Makanan', 5, 'gr'),
(56, 12, 'Tepung Terigu 1kg', 250, 'gr'),
(57, 12, 'Telur 1kg', 3, 'butir'),
(58, 12, 'Gula Pasir 1kg', 150, 'gr'),
(59, 12, 'Santan', 250, 'ml'),
(60, 13, 'Tepung Terigu 1kg', 300, 'gr'),
(61, 13, 'Telur 1kg', 4, 'butir'),
(62, 13, 'Mentega 500gr', 150, 'gr'),
(63, 13, 'Susu Cair', 250, 'ml'),
(64, 14, 'Tepung Ketan', 400, 'gr'),
(65, 14, 'Gula Merah', 200, 'gr'),
(66, 14, 'Kelapa Parut', 200, 'gr'),
(67, 15, 'Tepung Beras', 300, 'gr'),
(68, 15, 'Santan', 300, 'ml'),
(69, 15, 'Gula Pasir 1kg', 100, 'gr'),
(70, 16, 'Tepung Terigu 1kg', 250, 'gr'),
(71, 16, 'Telur 1kg', 2, 'butir'),
(72, 16, 'Kelapa Parut', 200, 'gr'),
(73, 16, 'Gula Merah', 150, 'gr'),
(74, 17, 'Tepung Beras', 300, 'gr'),
(75, 17, 'Kelapa Parut', 200, 'gr'),
(76, 17, 'Santan', 250, 'ml'),
(77, 18, 'Tepung Terigu 1kg', 300, 'gr'),
(78, 18, 'Telur 1kg', 4, 'butir'),
(79, 18, 'Cokelat Bubuk 250gr', 100, 'gr'),
(80, 18, 'Gula Pasir 1kg', 200, 'gr'),
(81, 19, 'Biskuit', 200, 'gr'),
(82, 19, 'Kopi', 100, 'ml'),
(83, 19, 'Krim', 200, 'ml'),
(84, 19, 'Gula Pasir 1kg', 100, 'gr'),
(85, 20, 'Tepung Terigu 1kg', 400, 'gr'),
(86, 20, 'Telur 1kg', 4, 'butir'),
(87, 20, 'Gula Pasir 1kg', 200, 'gr'),
(88, 20, 'Pewarna Merah', 5, 'gr'),
(89, 20, 'Cream Cheese', 150, 'gr');

-- --------------------------------------------------------

--
-- Table structure for table `stock in`
--

CREATE TABLE `stock in` (
  `id` int NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `category` varchar(100) NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` int NOT NULL,
  `total_price` int NOT NULL,
  `transaction_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `stock in`
--

INSERT INTO `stock in` (`id`, `product_name`, `category`, `quantity`, `unit_price`, `total_price`, `transaction_date`, `created_at`) VALUES
(1, 'mika tart', 'barang', 5, 30000, 150000, '2026-04-20', '2026-04-20 16:56:32'),
(2, 'mika tart', 'barang', 5, 30000, 150000, '2026-04-20', '2026-04-20 16:57:03'),
(3, 'mika tart', 'barang', 2, 30000, 60000, '2026-04-21', '2026-04-21 08:07:22'),
(4, 'mika tart', 'barang', 1, 30000, 30000, '2026-04-21', '2026-04-21 08:14:06'),
(5, 'Tepung Terigu 1kg', 'Tepung', 5, 10000, 50000, '2026-04-21', '2026-04-21 08:29:06'),
(6, 'mika tart', 'barang', 2, 30000, 60000, '2026-04-21', '2026-04-21 08:34:01'),
(7, 'misis garuda', 'bahan', 50, 150000, 7500000, '2026-04-23', '2026-04-23 03:56:44'),
(8, 'pita', 'barang', 10, 15000, 150000, '2026-04-23', '2026-04-23 06:09:13'),
(9, 'cup gelas', 'Barang', 1, 15000, 15000, '2026-04-23', '2026-04-23 06:31:57'),
(10, 'sendok plastik', 'Barang', 100, 1000, 100000, '2026-04-23', '2026-04-23 06:50:09'),
(11, 'telur ayam', 'Bahan', 2, 22000, 44000, '2026-04-23', '2026-04-23 07:16:02'),
(12, 'Baking Pow', 'Bahan', 2, 10000, 20000, '2026-04-30', '2026-04-30 06:03:11'),
(13, 'Baking Pow', 'Bahan', 2, 10000, 20000, '2026-04-30', '2026-04-30 06:11:20'),
(14, 'Gula Pasir 1kg', 'Gula', 5, 12000, 60000, '2026-04-30', '2026-04-30 08:24:17'),
(15, 'Tepung Terigu 1kg', 'Tepung', 5, 15000, 75000, '2026-04-30', '2026-04-30 08:24:32'),
(16, 'Mentega 500gr', 'Mentega', 5, 22000, 110000, '2026-04-30', '2026-04-30 08:24:51'),
(17, 'Tepung Terigu 1kg', 'Tepung', 2, 15000, 30000, '2026-05-02', '2026-05-02 15:13:21'),
(18, 'Telur 1kg', 'Telur', 4, 25000, 100000, '2026-05-02', '2026-05-02 15:13:42'),
(19, 'Pewarna Merah', 'Bahan Tambahan', 5, 5000, 25000, '2026-05-05', '2026-05-07 06:25:04'),
(20, 'Pewarna Makanan', 'Bahan Tambahan', 5, 5000, 25000, '2026-05-13', '2026-05-13 08:31:25'),
(21, 'Santan', 'Bahan Baku', 10, 10000, 100000, '2026-05-13', '2026-05-13 08:52:50'),
(22, 'krim', 'Bahan', 10, 15000, 150000, '2026-05-13', '2026-05-13 12:13:25'),
(23, 'Cream Cheese', 'Bahan Tambahan', 5, 30000, 150000, '2026-05-14', '2026-05-14 05:47:03'),
(24, 'Gula Merah', 'Bahan Baku', 13, 12000, 156000, '2026-05-14', '2026-05-14 14:39:30'),
(25, 'selai strowbery', 'Bahan', 5, 10000, 50000, '2026-05-15', '2026-05-15 16:15:20'),
(26, 'Santan', 'Bahan Baku', 5, 10000, 50000, '2026-05-17', '2026-05-17 15:11:25');

-- --------------------------------------------------------

--
-- Table structure for table `stock_usage_history`
--

CREATE TABLE `stock_usage_history` (
  `id` int NOT NULL,
  `recipe_name` varchar(255) DEFAULT NULL,
  `production_quantity` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_name` varchar(255) NOT NULL,
  `quantity_used` float NOT NULL,
  `unit` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `stock_usage_history`
--

INSERT INTO `stock_usage_history` (`id`, `recipe_name`, `production_quantity`, `product_id`, `product_name`, `quantity_used`, `unit`, `created_at`) VALUES
(1, 'Roti Manis', 2, 18, 'Gula Pasir 1kg', 0.3, 'kg', '2026-05-13 12:24:25'),
(2, 'Roti Manis', 2, 19, 'Mentega 500gr', 0.2, 'kg', '2026-05-13 12:24:25'),
(3, 'Roti Manis', 2, 20, 'Susu Bubuk', 0.1, 'kg', '2026-05-13 12:24:25'),
(4, 'Roti Manis', 2, 17, 'Telur 1kg', 0.3, 'kg', '2026-05-13 12:24:25'),
(5, 'Roti Manis', 2, 16, 'Tepung Terigu 1kg', 1.2, 'kg', '2026-05-13 12:24:25'),
(6, 'Kue Bolu', 12, 18, 'Gula Pasir 1kg', 2.4, 'kg', '2026-05-14 13:34:01'),
(7, 'Kue Bolu', 12, 19, 'Mentega 500gr', 1.8, 'kg', '2026-05-14 13:34:01'),
(8, 'Kue Bolu', 12, 20, 'Susu Bubuk', 0.6, 'kg', '2026-05-14 13:34:01'),
(9, 'Kue Bolu', 12, 16, 'Tepung Terigu 1kg', 4.8, 'kg', '2026-05-14 13:34:01'),
(10, 'Kue Sus', 7, 19, 'Mentega 500gr', 1.05, 'kg', '2026-05-14 14:16:32'),
(11, 'Kue Sus', 7, 32, 'Susu Cair', 1.75, 'kg', '2026-05-14 14:16:32'),
(12, 'Kue Sus', 7, 17, 'Telur 1kg', 1.4, 'kg', '2026-05-14 14:16:32'),
(13, 'Kue Sus', 7, 16, 'Tepung Terigu 1kg', 2.1, 'kg', '2026-05-14 14:16:32'),
(14, 'Kue Klepon', 5, 30, 'Gula Merah', 1, 'kg', '2026-05-14 14:22:07'),
(15, 'Kue Klepon', 5, 25, 'Kelapa Parut', 1, 'kg', '2026-05-14 14:22:07'),
(16, 'Kue Klepon', 5, 28, 'Tepung Ketan', 2, 'kg', '2026-05-14 14:22:07'),
(17, 'Kue Lumpur', 3, 18, 'Gula Pasir 1kg', 0.45, 'kg', '2026-05-15 15:29:45'),
(18, 'Kue Lumpur', 3, 26, 'Santan', 0.75, 'kg', '2026-05-15 15:29:45'),
(19, 'Kue Lumpur', 3, 17, 'Telur 1kg', 0.45, 'kg', '2026-05-15 15:29:45'),
(20, 'Kue Lumpur', 3, 16, 'Tepung Terigu 1kg', 0.75, 'kg', '2026-05-15 15:29:45'),
(21, 'Kue Kastengel', 3, 24, 'Keju Parut 250gr', 0.45, 'kg', '2026-05-15 15:38:28'),
(22, 'Kue Kastengel', 3, 19, 'Mentega 500gr', 0.6, 'kg', '2026-05-15 15:38:28'),
(23, 'Kue Kastengel', 3, 17, 'Telur 1kg', 0.3, 'kg', '2026-05-15 15:38:28'),
(24, 'Kue Kastengel', 3, 16, 'Tepung Terigu 1kg', 1.2, 'kg', '2026-05-15 15:38:28'),
(25, 'Kue Red Velvet', 3, 31, 'Cream Cheese', 0.45, 'kg', '2026-05-15 15:50:03'),
(26, 'Kue Red Velvet', 3, 18, 'Gula Pasir 1kg', 0.6, 'kg', '2026-05-15 15:50:03'),
(27, 'Kue Red Velvet', 3, 36, 'Pewarna Merah', 0.015, 'kg', '2026-05-15 15:50:03'),
(28, 'Kue Red Velvet', 3, 17, 'Telur 1kg', 0.6, 'kg', '2026-05-15 15:50:03'),
(29, 'Kue Red Velvet', 3, 16, 'Tepung Terigu 1kg', 1.2, 'kg', '2026-05-15 15:50:03'),
(30, 'Kue Lapis', 8, 18, 'Gula Pasir 1kg', 1.6, 'kg', '2026-05-15 16:05:16'),
(31, 'Kue Lapis', 8, 35, 'Pewarna Makanan', 0.04, 'kg', '2026-05-15 16:05:16'),
(32, 'Kue Lapis', 8, 26, 'Santan', 2.4, 'kg', '2026-05-15 16:05:16'),
(33, 'Kue Lapis', 8, 16, 'Tepung Terigu 1kg', 2.4, 'kg', '2026-05-15 16:05:16'),
(34, 'Kue Pancong', 10, 25, 'Kelapa Parut', 2, 'kg', '2026-05-15 16:13:55'),
(35, 'Kue Pancong', 10, 26, 'Santan', 2.5, 'kg', '2026-05-15 16:13:55'),
(36, 'Kue Pancong', 10, 29, 'Tepung Beras', 3, 'kg', '2026-05-15 16:13:55'),
(37, 'Kue Kastengel', 6, 24, 'Keju Parut 250gr', 0.9, 'kg', '2026-05-17 14:56:02'),
(38, 'Kue Kastengel', 6, 19, 'Mentega 500gr', 1.2, 'kg', '2026-05-17 14:56:02'),
(39, 'Kue Kastengel', 6, 17, 'Telur 1kg', 0.6, 'kg', '2026-05-17 14:56:02'),
(40, 'Kue Kastengel', 6, 16, 'Tepung Terigu 1kg', 2.4, 'kg', '2026-05-17 14:56:02'),
(41, 'Kue Brownies', 1, 22, 'Baking Powder', 0.005, 'kg', '2026-05-17 14:59:15'),
(42, 'Kue Brownies', 1, 23, 'Cokelat Bubuk 250gr', 0.1, 'kg', '2026-05-17 14:59:15'),
(43, 'Kue Brownies', 1, 18, 'Gula Pasir 1kg', 0.2, 'kg', '2026-05-17 14:59:15'),
(44, 'Kue Brownies', 1, 19, 'Mentega 500gr', 0.15, 'kg', '2026-05-17 14:59:15'),
(45, 'Kue Brownies', 1, 17, 'Telur 1kg', 0.2, 'kg', '2026-05-17 14:59:15'),
(46, 'Kue Brownies', 1, 16, 'Tepung Terigu 1kg', 0.3, 'kg', '2026-05-17 14:59:15'),
(47, 'Kue Tart', 4, 18, 'Gula Pasir 1kg', 0.6, 'kg', '2026-05-17 14:59:39'),
(48, 'Kue Tart', 4, 24, 'Keju Parut 250gr', 0.4, 'kg', '2026-05-17 14:59:39'),
(49, 'Kue Tart', 4, 19, 'Mentega 500gr', 0.8, 'kg', '2026-05-17 14:59:39'),
(50, 'Kue Tart', 4, 20, 'Susu Bubuk', 0.32, 'kg', '2026-05-17 14:59:39'),
(51, 'Kue Tart', 4, 17, 'Telur 1kg', 1, 'kg', '2026-05-17 14:59:39'),
(52, 'Kue Tart', 4, 16, 'Tepung Terigu 1kg', 1.6, 'kg', '2026-05-17 14:59:39'),
(53, 'Kue Sus', 1, 19, 'Mentega 500gr', 0.15, 'kg', '2026-05-17 14:59:47'),
(54, 'Kue Sus', 1, 32, 'Susu Cair', 0.25, 'kg', '2026-05-17 14:59:47'),
(55, 'Kue Sus', 1, 17, 'Telur 1kg', 0.2, 'kg', '2026-05-17 14:59:47'),
(56, 'Kue Sus', 1, 16, 'Tepung Terigu 1kg', 0.3, 'kg', '2026-05-17 14:59:47'),
(57, 'Kue Lapis', 4, 18, 'Gula Pasir 1kg', 0.8, 'kg', '2026-05-17 15:11:42'),
(58, 'Kue Lapis', 4, 35, 'Pewarna Makanan', 0.02, 'kg', '2026-05-17 15:11:42'),
(59, 'Kue Lapis', 4, 26, 'Santan', 1.2, 'kg', '2026-05-17 15:11:42'),
(60, 'Kue Lapis', 4, 16, 'Tepung Terigu 1kg', 1.2, 'kg', '2026-05-17 15:11:42'),
(61, 'Kue Kastengel', 3, 24, 'Keju Parut 250gr', 0.45, 'kg', '2026-05-24 14:06:09'),
(62, 'Kue Kastengel', 3, 19, 'Mentega 500gr', 0.6, 'kg', '2026-05-24 14:06:09'),
(63, 'Kue Kastengel', 3, 17, 'Telur 1kg', 0.3, 'kg', '2026-05-24 14:06:09'),
(64, 'Kue Kastengel', 3, 16, 'Tepung Terigu 1kg', 1.2, 'kg', '2026-05-24 14:06:09'),
(65, 'Donat', 10, 22, 'Baking Powder', 0.05, 'kg', '2026-05-24 14:07:19'),
(66, 'Donat', 10, 18, 'Gula Pasir 1kg', 1, 'kg', '2026-05-24 14:07:19'),
(67, 'Donat', 10, 19, 'Mentega 500gr', 0.5, 'kg', '2026-05-24 14:07:19'),
(68, 'Donat', 10, 17, 'Telur 1kg', 1, 'kg', '2026-05-24 14:07:19'),
(69, 'Donat', 10, 16, 'Tepung Terigu 1kg', 5, 'kg', '2026-05-24 14:07:19'),
(70, 'Donat', 5, 22, 'Baking Powder', 0.025, 'kg', '2026-05-24 14:24:01'),
(71, 'Donat', 5, 18, 'Gula Pasir 1kg', 0.5, 'kg', '2026-05-24 14:24:01'),
(72, 'Donat', 5, 19, 'Mentega 500gr', 0.25, 'kg', '2026-05-24 14:24:01'),
(73, 'Donat', 5, 17, 'Telur 1kg', 0.5, 'kg', '2026-05-24 14:24:01'),
(74, 'Donat', 5, 16, 'Tepung Terigu 1kg', 2.5, 'kg', '2026-05-24 14:24:01'),
(75, 'Donat', 1, 22, 'Baking Powder', 0.005, 'kg', '2026-05-24 14:39:38'),
(76, 'Donat', 1, 18, 'Gula Pasir 1kg', 0.1, 'kg', '2026-05-24 14:39:38'),
(77, 'Donat', 1, 19, 'Mentega 500gr', 0.05, 'kg', '2026-05-24 14:39:38'),
(78, 'Donat', 1, 17, 'Telur 1kg', 0.1, 'kg', '2026-05-24 14:39:38'),
(79, 'Donat', 1, 16, 'Tepung Terigu 1kg', 0.5, 'kg', '2026-05-24 14:39:38'),
(80, 'Donat', 2, 22, 'Baking Powder', 0.01, 'kg', '2026-05-26 07:08:27'),
(81, 'Donat', 2, 18, 'Gula Pasir 1kg', 0.2, 'kg', '2026-05-26 07:08:27'),
(82, 'Donat', 2, 19, 'Mentega 500gr', 0.1, 'kg', '2026-05-26 07:08:27'),
(83, 'Donat', 2, 17, 'Telur 1kg', 0.2, 'kg', '2026-05-26 07:08:27'),
(84, 'Donat', 2, 16, 'Tepung Terigu 1kg', 1, 'kg', '2026-05-26 07:08:27');

-- --------------------------------------------------------

--
-- Table structure for table `stok_keluar`
--

CREATE TABLE `stok_keluar` (
  `id` int NOT NULL,
  `bahan_id` int DEFAULT NULL,
  `jumlah_keluar` float NOT NULL,
  `satuan` varchar(50) DEFAULT 'kg',
  `tanggal_keluar` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `stok_keluar`
--

INSERT INTO `stok_keluar` (`id`, `bahan_id`, `jumlah_keluar`, `satuan`, `tanggal_keluar`, `created_at`, `updated_at`) VALUES
(1, 18, 0.3, 'kg', '2026-05-13', '2026-05-13 12:24:25', '2026-05-13 12:24:25'),
(2, 19, 0.2, 'kg', '2026-05-13', '2026-05-13 12:24:25', '2026-05-13 12:24:25'),
(3, 20, 0.1, 'kg', '2026-05-13', '2026-05-13 12:24:25', '2026-05-13 12:24:25'),
(4, 17, 0.3, 'kg', '2026-05-13', '2026-05-13 12:24:25', '2026-05-13 12:24:25'),
(5, 16, 1.2, 'kg', '2026-05-13', '2026-05-13 12:24:25', '2026-05-13 12:24:25'),
(6, 18, 2.4, 'kg', '2026-05-14', '2026-05-14 13:34:01', '2026-05-14 13:34:01'),
(7, 19, 1.8, 'kg', '2026-05-14', '2026-05-14 13:34:01', '2026-05-14 13:34:01'),
(8, 20, 0.6, 'kg', '2026-05-14', '2026-05-14 13:34:01', '2026-05-14 13:34:01'),
(9, 16, 4.8, 'kg', '2026-05-14', '2026-05-14 13:34:01', '2026-05-14 13:34:01'),
(10, 19, 1.05, 'kg', '2026-05-14', '2026-05-14 14:16:32', '2026-05-14 14:16:32'),
(11, 32, 1.75, 'kg', '2026-05-14', '2026-05-14 14:16:32', '2026-05-14 14:16:32'),
(12, 17, 1.4, 'kg', '2026-05-14', '2026-05-14 14:16:32', '2026-05-14 14:16:32'),
(13, 16, 2.1, 'kg', '2026-05-14', '2026-05-14 14:16:32', '2026-05-14 14:16:32'),
(14, 30, 1, 'kg', '2026-05-14', '2026-05-14 14:22:07', '2026-05-14 14:22:07'),
(15, 25, 1, 'kg', '2026-05-14', '2026-05-14 14:22:07', '2026-05-14 14:22:07'),
(16, 28, 2, 'kg', '2026-05-14', '2026-05-14 14:22:07', '2026-05-14 14:22:07'),
(17, 18, 0.45, 'kg', '2026-05-15', '2026-05-15 15:29:45', '2026-05-15 15:29:45'),
(18, 26, 0.75, 'kg', '2026-05-15', '2026-05-15 15:29:45', '2026-05-15 15:29:45'),
(19, 17, 0.45, 'kg', '2026-05-15', '2026-05-15 15:29:45', '2026-05-15 15:29:45'),
(20, 16, 0.75, 'kg', '2026-05-15', '2026-05-15 15:29:45', '2026-05-15 15:29:45'),
(21, 24, 0.45, 'kg', '2026-05-15', '2026-05-15 15:38:28', '2026-05-15 15:38:28'),
(22, 19, 0.6, 'kg', '2026-05-15', '2026-05-15 15:38:28', '2026-05-15 15:38:28'),
(23, 17, 0.3, 'kg', '2026-05-15', '2026-05-15 15:38:28', '2026-05-15 15:38:28'),
(24, 16, 1.2, 'kg', '2026-05-15', '2026-05-15 15:38:28', '2026-05-15 15:38:28'),
(25, 31, 0.45, 'kg', '2026-05-15', '2026-05-15 15:50:03', '2026-05-15 15:50:03'),
(26, 18, 0.6, 'kg', '2026-05-15', '2026-05-15 15:50:03', '2026-05-15 15:50:03'),
(27, 36, 0.015, 'kg', '2026-05-15', '2026-05-15 15:50:03', '2026-05-15 15:50:03'),
(28, 17, 0.6, 'kg', '2026-05-15', '2026-05-15 15:50:03', '2026-05-15 15:50:03'),
(29, 16, 1.2, 'kg', '2026-05-15', '2026-05-15 15:50:03', '2026-05-15 15:50:03'),
(30, 18, 1.6, 'kg', '2026-05-15', '2026-05-15 16:05:16', '2026-05-15 16:05:16'),
(31, 35, 0.04, 'kg', '2026-05-15', '2026-05-15 16:05:16', '2026-05-15 16:05:16'),
(32, 26, 2.4, 'kg', '2026-05-15', '2026-05-15 16:05:16', '2026-05-15 16:05:16'),
(33, 16, 2.4, 'kg', '2026-05-15', '2026-05-15 16:05:16', '2026-05-15 16:05:16'),
(34, 25, 2, 'kg', '2026-05-15', '2026-05-15 16:13:55', '2026-05-15 16:13:55'),
(35, 26, 2.5, 'kg', '2026-05-15', '2026-05-15 16:13:55', '2026-05-15 16:13:55'),
(36, 29, 3, 'kg', '2026-05-15', '2026-05-15 16:13:55', '2026-05-15 16:13:55'),
(37, 24, 0.9, 'kg', '2026-05-17', '2026-05-17 14:56:02', '2026-05-17 14:56:02'),
(38, 19, 1.2, 'kg', '2026-05-17', '2026-05-17 14:56:02', '2026-05-17 14:56:02'),
(39, 17, 0.6, 'kg', '2026-05-17', '2026-05-17 14:56:02', '2026-05-17 14:56:02'),
(40, 16, 2.4, 'kg', '2026-05-17', '2026-05-17 14:56:02', '2026-05-17 14:56:02'),
(41, 22, 0.005, 'kg', '2026-05-17', '2026-05-17 14:59:15', '2026-05-17 14:59:15'),
(42, 23, 0.1, 'kg', '2026-05-17', '2026-05-17 14:59:15', '2026-05-17 14:59:15'),
(43, 18, 0.2, 'kg', '2026-05-17', '2026-05-17 14:59:15', '2026-05-17 14:59:15'),
(44, 19, 0.15, 'kg', '2026-05-17', '2026-05-17 14:59:15', '2026-05-17 14:59:15'),
(45, 17, 0.2, 'kg', '2026-05-17', '2026-05-17 14:59:15', '2026-05-17 14:59:15'),
(46, 16, 0.3, 'kg', '2026-05-17', '2026-05-17 14:59:15', '2026-05-17 14:59:15'),
(47, 18, 0.6, 'kg', '2026-05-17', '2026-05-17 14:59:39', '2026-05-17 14:59:39'),
(48, 24, 0.4, 'kg', '2026-05-17', '2026-05-17 14:59:39', '2026-05-17 14:59:39'),
(49, 19, 0.8, 'kg', '2026-05-17', '2026-05-17 14:59:39', '2026-05-17 14:59:39'),
(50, 20, 0.32, 'kg', '2026-05-17', '2026-05-17 14:59:39', '2026-05-17 14:59:39'),
(51, 17, 1, 'kg', '2026-05-17', '2026-05-17 14:59:39', '2026-05-17 14:59:39'),
(52, 16, 1.6, 'kg', '2026-05-17', '2026-05-17 14:59:39', '2026-05-17 14:59:39'),
(53, 19, 0.15, 'kg', '2026-05-17', '2026-05-17 14:59:47', '2026-05-17 14:59:47'),
(54, 32, 0.25, 'kg', '2026-05-17', '2026-05-17 14:59:47', '2026-05-17 14:59:47'),
(55, 17, 0.2, 'kg', '2026-05-17', '2026-05-17 14:59:47', '2026-05-17 14:59:47'),
(56, 16, 0.3, 'kg', '2026-05-17', '2026-05-17 14:59:47', '2026-05-17 14:59:47'),
(57, 18, 0.8, 'kg', '2026-05-17', '2026-05-17 15:11:42', '2026-05-17 15:11:42'),
(58, 35, 0.02, 'kg', '2026-05-17', '2026-05-17 15:11:42', '2026-05-17 15:11:42'),
(59, 26, 1.2, 'kg', '2026-05-17', '2026-05-17 15:11:42', '2026-05-17 15:11:42'),
(60, 16, 1.2, 'kg', '2026-05-17', '2026-05-17 15:11:42', '2026-05-17 15:11:42'),
(61, 24, 0.45, 'kg', '2026-05-24', '2026-05-24 14:06:09', '2026-05-24 14:06:09'),
(62, 19, 0.6, 'kg', '2026-05-24', '2026-05-24 14:06:09', '2026-05-24 14:06:09'),
(63, 17, 0.3, 'kg', '2026-05-24', '2026-05-24 14:06:09', '2026-05-24 14:06:09'),
(64, 16, 1.2, 'kg', '2026-05-24', '2026-05-24 14:06:09', '2026-05-24 14:06:09'),
(65, 22, 0.05, 'kg', '2026-05-24', '2026-05-24 14:07:19', '2026-05-24 14:07:19'),
(66, 18, 1, 'kg', '2026-05-24', '2026-05-24 14:07:19', '2026-05-24 14:07:19'),
(67, 19, 0.5, 'kg', '2026-05-24', '2026-05-24 14:07:19', '2026-05-24 14:07:19'),
(68, 17, 1, 'kg', '2026-05-24', '2026-05-24 14:07:19', '2026-05-24 14:07:19'),
(69, 16, 5, 'kg', '2026-05-24', '2026-05-24 14:07:19', '2026-05-24 14:07:19'),
(70, 22, 0.025, 'kg', '2026-05-24', '2026-05-24 14:24:01', '2026-05-24 14:24:01'),
(71, 18, 0.5, 'kg', '2026-05-24', '2026-05-24 14:24:01', '2026-05-24 14:24:01'),
(72, 19, 0.25, 'kg', '2026-05-24', '2026-05-24 14:24:01', '2026-05-24 14:24:01'),
(73, 17, 0.5, 'kg', '2026-05-24', '2026-05-24 14:24:01', '2026-05-24 14:24:01'),
(74, 16, 2.5, 'kg', '2026-05-24', '2026-05-24 14:24:01', '2026-05-24 14:24:01'),
(75, 22, 0.005, 'kg', '2026-05-24', '2026-05-24 14:39:38', '2026-05-24 14:39:38'),
(76, 18, 0.1, 'kg', '2026-05-24', '2026-05-24 14:39:38', '2026-05-24 14:39:38'),
(77, 19, 0.05, 'kg', '2026-05-24', '2026-05-24 14:39:38', '2026-05-24 14:39:38'),
(78, 17, 0.1, 'kg', '2026-05-24', '2026-05-24 14:39:38', '2026-05-24 14:39:38'),
(79, 16, 0.5, 'kg', '2026-05-24', '2026-05-24 14:39:38', '2026-05-24 14:39:38'),
(80, 22, 0.01, 'kg', '2026-05-26', '2026-05-26 07:08:27', '2026-05-26 07:08:27'),
(81, 18, 0.2, 'kg', '2026-05-26', '2026-05-26 07:08:27', '2026-05-26 07:08:27'),
(82, 19, 0.1, 'kg', '2026-05-26', '2026-05-26 07:08:27', '2026-05-26 07:08:27'),
(83, 17, 0.2, 'kg', '2026-05-26', '2026-05-26 07:08:27', '2026-05-26 07:08:27'),
(84, 16, 1, 'kg', '2026-05-26', '2026-05-26 07:08:27', '2026-05-26 07:08:27');

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `id` int NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `category` varchar(50) NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `transaction_date` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `login`
--
ALTER TABLE `login`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `password_reset_otps`
--
ALTER TABLE `password_reset_otps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `login_id` (`login_id`);

--
-- Indexes for table `predictions`
--
ALTER TABLE `predictions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `recipes`
--
ALTER TABLE `recipes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `recipe_name` (`recipe_name`);

--
-- Indexes for table `recipe_ingredients`
--
ALTER TABLE `recipe_ingredients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `recipe_id` (`recipe_id`);

--
-- Indexes for table `stock in`
--
ALTER TABLE `stock in`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `stock_usage_history`
--
ALTER TABLE `stock_usage_history`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `stok_keluar`
--
ALTER TABLE `stok_keluar`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_name` (`product_name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `login`
--
ALTER TABLE `login`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `password_reset_otps`
--
ALTER TABLE `password_reset_otps`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `predictions`
--
ALTER TABLE `predictions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `recipes`
--
ALTER TABLE `recipes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `recipe_ingredients`
--
ALTER TABLE `recipe_ingredients`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=90;

--
-- AUTO_INCREMENT for table `stock in`
--
ALTER TABLE `stock in`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `stock_usage_history`
--
ALTER TABLE `stock_usage_history`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- AUTO_INCREMENT for table `stok_keluar`
--
ALTER TABLE `stok_keluar`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `password_reset_otps`
--
ALTER TABLE `password_reset_otps`
  ADD CONSTRAINT `password_reset_otps_ibfk_1` FOREIGN KEY (`login_id`) REFERENCES `login` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `recipe_ingredients`
--
ALTER TABLE `recipe_ingredients`
  ADD CONSTRAINT `recipe_ingredients_ibfk_1` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`product_name`) REFERENCES `products` (`name`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
