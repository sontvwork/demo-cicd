FROM --platform=linux/amd64 composer:2.8 AS composer

WORKDIR /app
COPY composer.json composer.lock ./
# Chỉ cài đặt dependencies cho production
RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --no-dev \
    --prefer-dist

FROM --platform=linux/amd64 php:8.4-fpm-bullseye AS base

# Sử dụng multi-stage build để có thể xóa cache và các file tạm
WORKDIR /var/www/html

# Copy cấu hình
COPY docker/prod/php.ini /usr/local/etc/php/php.ini
COPY docker/prod/php-fpm/ /usr/local/etc/php-fpm.d/
COPY docker/prod/nginx.conf /etc/nginx/nginx.conf
COPY docker/prod/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Cài đặt các gói trong một layer riêng
COPY docker/prod/install-packages.sh /tmp/
RUN set -e && \
    chmod +x /tmp/install-packages.sh && \
    /tmp/install-packages.sh && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/cache -type f -delete

# Cấu hình các gói và cron trong layer tiếp theo
COPY docker/prod/config-packages.sh \
     docker/prod/config-cron.sh \
     /tmp/

RUN set -e && \
    chmod +x /tmp/config-packages.sh /tmp/config-cron.sh && \
    /tmp/config-packages.sh && \
    /tmp/config-cron.sh && \
    rm -rf /tmp/* /var/tmp/* \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/cache -type f -delete

# Copy vendor từ stage composer
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=composer --chown=www-data:www-data /app/vendor /var/www/html/vendor

# Copy toàn bộ mã nguồn Laravel - .dockerignore sẽ loại bỏ các file không cần thiết
COPY --chown=www-data:www-data . .

# Tạo autoloader và dọn dẹp
RUN set -e && \
    php artisan key:generate && \
    # Đảm bảo các thư mục cần thiết tồn tại
    mkdir -p \
      storage/logs \
      storage/framework/cache \
      storage/framework/sessions \
      storage/framework/views \
      bootstrap/cache && \
    # Xóa bất kỳ file log nào có thể đã được copy
    find storage -name "*.log" -delete && \
    # Tạo autoloader tối ưu
    composer dump-autoload --optimize --no-dev && \
    # Xóa cache composer
    rm -rf /root/.composer && \
    # Thiết lập quyền
    chown -R www-data:www-data storage bootstrap/cache

# Mở port
EXPOSE 80

# Command khởi động
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]