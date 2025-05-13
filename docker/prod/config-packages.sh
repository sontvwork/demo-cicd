#!/bin/bash
set -e

# Cấu hình Nginx
echo "Cấu hình Nginx..."
mkdir -p /var/log/nginx
chown -R www-data:www-data /var/log/nginx
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log

# Cấu hình PHP-FPM
echo "Cấu hình PHP-FPM..."
mkdir -p /var/log/php
chown -R www-data:www-data /var/log/php
ln -sf /dev/stderr /var/log/php/error.log

# Cấu hình Supervisor
echo "Cấu hình Supervisor..."
mkdir -p /var/log/supervisor
chown -R www-data:www-data /var/log/supervisor

# Đảm bảo các dịch vụ không tự động khởi động
echo "Vô hiệu hóa các dịch vụ tự động khởi động..."
rm -f /etc/init.d/nginx
rm -f /etc/init.d/supervisor
rm -f /etc/init.d/cron

# Tạo thư mục Laravel cần thiết và thiết lập quyền
mkdir -p /var/www/html/bootstrap/cache
mkdir -p /var/www/html/storage/logs
mkdir -p /var/www/html/storage/framework/sessions
mkdir -p /var/www/html/storage/framework/views
mkdir -p /var/www/html/storage/framework/cache
chown -R www-data:www-data /var/www/html

echo "Cấu hình các gói phần mềm hoàn tất."