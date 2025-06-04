# === 1. Gunakan image PHP-FPM versi 8.1 (atau adjust ke 8.2 jika ingin) ===
FROM php:8.1-fpm

# === 2. Install dependencies sistem yang diperlukan oleh Laravel ===
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    npm \
  && rm -rf /var/lib/apt/lists/*

# === 3. Install ekstensi PHP yang dibutuhkan laravel (misal: pdo_mysql, mbstring, dll) ===
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# === 4. Pasang Composer (copy dari image Composer resmi) ===
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# === 5. Set working directory di dalam container ===
WORKDIR /var/www/html

# === 6. Copy file composer.json & composer.lock, lalu install dependencies PHP ===
COPY composer.json composer.lock ./
RUN composer install --optimize-autoloader --no-dev

# === 7. Copy seluruh kode aplikasi ke dalam container ===
COPY . .

# === 8. Copy file .env dan generate APP_KEY ===
# Jika Anda menggunakan .env di repo (contoh: .env.example), kita salin terlebih dulu
RUN cp .env.example .env
RUN php artisan key:generate

# === 9. Install dependencies Node.js & build assets front-end (jika ada) ===
# (Laravel Mix / Vite biasanya membutuhkan Node.js)
RUN npm install
RUN npm run production

# === 10. Pastikan folder storage & cache memiliki permission yang benar ===
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# === 11. Ekspos port (ini hanya referensi; Coolify nanti yang mem‐proxy) ===
EXPOSE 9000

# === 12. Perintah default: jalankan PHP-FPM ===
CMD ["php-fpm"]
