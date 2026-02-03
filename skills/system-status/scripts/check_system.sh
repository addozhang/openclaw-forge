#!/bin/bash
# System Status Check Script
# Comprehensive system health monitoring

echo "==================================="
echo "系统状态检查报告"
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "==================================="
echo ""

# 1. 系统信息
echo "📋 系统信息"
echo "-----------------------------------"
echo "主机名: $(hostname)"
echo "系统: $(uname -s) $(uname -r)"
echo "架构: $(uname -m)"
uptime
echo ""

# 2. CPU 信息
echo "💻 CPU 状态"
echo "-----------------------------------"
echo "负载 (1/5/15分钟): $(uptime | awk -F'load average:' '{print $2}')"
echo "CPU 核心数: $(nproc)"
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "CPU 使用率: " 100 - $1 "%"}'
echo ""

# 3. 内存状态
echo "🧠 内存状态"
echo "-----------------------------------"
free -h | grep -E "Mem|Swap"
echo ""

# 4. 磁盘状态
echo "💾 磁盘使用"
echo "-----------------------------------"
df -h | grep -E "^/dev|^Filesystem" | grep -v "tmpfs"
echo ""

# 5. 进程概览
echo "⚙️ 进程状态"
echo "-----------------------------------"
ps aux --sort=-%mem | head -6 | awk 'NR==1 || NR<=6 {printf "%-10s %-6s %-6s %s\n", $1, $3, $4, $11}'
echo ""

# 6. 网络连接
echo "🌐 网络状态"
echo "-----------------------------------"
echo "活动连接数: $(ss -tun | wc -l)"
echo "监听端口: $(ss -tuln | grep LISTEN | wc -l)"
echo ""

# 7. 最近登录
echo "👤 登录信息"
echo "-----------------------------------"
who
echo ""

echo "==================================="
echo "检查完成 ✓"
echo "==================================="
