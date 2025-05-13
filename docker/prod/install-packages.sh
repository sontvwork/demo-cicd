#!/bin/bash
set -e

# Sử dụng printf để debug
echo "Bắt đầu cài đặt các gói..."

# Danh sách minimal các gói cần thiết
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nginx \
    supervisor \
    cron \
    libzip-dev \
    ca-certificates \
    mecab \
    mecab-ipadic-utf8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt AWS CLI phiên bản nhỏ gọn
echo "Cài đặt AWS CLI..."
apt-get install -y --no-install-recommends unzip \
    && curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli \
    && apt-get remove -y unzip \
    && apt-get autoremove -y \
    && rm -rf /tmp/aws*

# Cài đặt PHP extensions với minimal footprint
echo "Cài đặt PHP extensions..."
docker-php-ext-install -j$(nproc) mysqli pdo_mysql pcntl zip \
    && rm -rf /tmp/pear

# Tạo thư mục logs và cấu hình quyền
mkdir -p /var/log/{nginx,php,supervisor} /var/run/php-fpm \
    && chown -R www-data:www-data /var/log/php /var/run/php-fpm

echo "Cài đặt các gói phụ thuộc hoàn tất."