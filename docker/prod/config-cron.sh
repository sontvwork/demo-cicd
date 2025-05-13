#!/bin/bash
set -e

# Tạo file crontab cho Laravel scheduler
echo "Thiết lập Laravel scheduler trong crontab..."

# Tạo thư mục cron nếu chưa có
mkdir -p /etc/cron.d

# Tạo file crontab cho Laravel scheduler
cat > /etc/cron.d/laravel-scheduler << 'EOF'
* * * * * www-data cd /var/www/html && php artisan schedule:run >> /dev/null 2>&1
EOF

# Đặt quyền cho file crontab
chmod 0644 /etc/cron.d/laravel-scheduler

# Áp dụng crontab
crontab /etc/cron.d/laravel-scheduler

echo "Cấu hình cron hoàn tất."