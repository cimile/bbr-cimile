#!/bin/bash

# Google BBR & Network Optimization Script
# Author: cimile
# Description: Automatically installs BBR/BBR2/BBR3/魔改BBR and optimizes network parameters

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try using sudo." >&2
    exit 1
fi

echo "Starting BBR Installation & Network Optimization..."

# Update package list
echo "Updating package list..."
apt update -y || yum update -y

# Install necessary packages
echo "Installing necessary packages..."
if command -v apt &> /dev/null; then
    apt install -y curl wget git build-essential
else
    yum install -y curl wget git gcc make
fi

# Function to check kernel version
check_kernel() {
    kernel_version=$(uname -r)
    required_version=$1
    
    if [[ $(echo "$kernel_version $required_version" | tr " " "\n" | sort -V | head -n 1) != "$required_version" ]]; then
        return 0
    else
        return 1
    fi
}

# BBR selection menu
echo "请选择要安装的BBR版本:"
echo "1. BBR (原版)"
echo "2. BBR2"
echo "3. BBR3 (实验性)"
echo "4. 魔改BBR (Lotserver)"
echo "5. TCP Cubic (默认)"
read -p "输入选择 (1-5): " choice

case $choice in
    1)
        congestion_control="bbr"
        required_kernel="4.9.0"
        ;;
    2)
        congestion_control="bbr2"
        required_kernel="5.6.0"
        ;;
    3)
        congestion_control="bbr3"
        required_kernel="5.10.0"
        ;;
    4)
        congestion_control="bbr_lotserver"
        required_kernel="4.19.0"
        ;;
    5)
        congestion_control="cubic"
        required_kernel="3.0.0"
        ;;
    *)
        echo "无效选择. 退出..."
        exit 1
        ;;
esac

# Check kernel version
echo "Checking kernel version..."
if ! check_kernel "$required_kernel"; then
    echo "当前内核版本 ($(uname -r)) 低于 $required_kernel. 尝试更新内核..."
    
    if command -v yum &> /dev/null; then
        rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
        rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
        yum --enablerepo=elrepo-kernel install -y kernel-ml
        grub2-set-default 0
        echo "内核已更新. 请重启系统并重新运行此脚本."
        exit 1
    else
        echo "非CentOS/RHEL系统，请手动更新内核至 $required_kernel 或更高版本."
        exit 1
    fi
else
    echo "当前内核版本 ($(uname -r)) 满足要求."
fi

# Install selected BBR version
echo "Installing $congestion_control..."

if [ "$congestion_control" = "bbr_lotserver" ]; then
    # Install modified BBR
    git clone https://github.com/Lotserver/tcp_bbr_lotserver.git /tmp/tcp_bbr_lotserver
    cd /tmp/tcp_bbr_lotserver || exit
    make && make install
    echo "tcp_bbr_lotserver" > /etc/modules-load.d/bbr_lotserver.conf
else
    # Load standard BBR modules
    if [ "$congestion_control" = "bbr2" ]; then
        modprobe tcp_bbr2
    elif [ "$congestion_control" = "bbr3" ]; then
        echo "BBR3需要手动安装模块，请参考官方文档"
    fi
fi

# Backup existing sysctl.conf
cp /etc/sysctl.conf /etc/sysctl.conf.bak

# Write optimized network parameters
cat > /etc/sysctl.conf << EOF
# BBR Configuration
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=$congestion_control

# TCP Optimization
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_max_syn_backlog=20480
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_keepalive_time=300
net.ipv4.tcp_max_tw_buckets=6000
net.ipv4.route.gc_timeout=100
net.ipv4.tcp_syn_retries=1
net.ipv4.tcp_synack_retries=1
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.core.netdev_max_backlog=30000
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_mtu_probing=1

# IP Header Optimization
net.ipv4.ip_default_ttl=64
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.default.secure_redirects=0
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1

# TCP Performance
net.ipv4.tcp_sack=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_selective_ack=1
net.ipv4.tcp_dsack=1
net.ipv4.tcp_ecn=0
net.ipv4.tcp_frto=2
net.ipv4.tcp_low_latency=1

# HTTP/2 and QUIC Support
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=$congestion_control

# IPv6
net.ipv6.conf.all.disable_ipv6=0
net.ipv6.conf.default.disable_ipv6=0
net.ipv6.conf.lo.disable_ipv6=0
EOF

# Apply sysctl settings
sysctl -p

# Verify BBR activation
echo "Verifying $congestion_control activation..."
if [ "$congestion_control" = "bbr_lotserver" ]; then
    if lsmod | grep -q bbr_lotserver; then
        echo "魔改BBR (Lotserver) 已成功启用!"
    else
        echo "启用魔改BBR失败，请检查内核版本并尝试重新安装。"
        exit 1
    fi
else
    if sysctl net.ipv4.tcp_congestion_control | grep -q "$congestion_control"; then
        echo "$congestion_control 已成功启用!"
    else
        echo "启用 $congestion_control 失败，请检查内核版本并尝试重新安装。"
        exit 1
    fi
fi

# Optimize network headers
echo "优化网络头部设置..."

# Check if nginx is installed and enable HTTP/2
if command -v nginx &> /dev/null; then
    echo "检测到Nginx，启用HTTP/2支持..."
    cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
    sed -i 's/listen 443 ssl;/listen 443 ssl http2;/g' /etc/nginx/sites-enabled/*
    sed -i 's/listen \[::\]:443 ssl;/listen [::]:443 ssl http2;/g' /etc/nginx/sites-enabled/*
    
    if nginx -t; then
        systemctl reload nginx
        echo "Nginx已重新加载，HTTP/2已启用"
    else
        echo "Nginx配置测试失败，恢复原配置"
        cp /etc/nginx/nginx.conf.bak /etc/nginx/nginx.conf
    fi
else
    echo "未检测到Nginx，跳过HTTP/2配置"
fi

echo "安装完成!"
echo "为确保所有更改生效，建议重启系统。"    