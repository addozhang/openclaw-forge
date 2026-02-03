---
name: system-status
description: Check comprehensive system health and resource usage including CPU, memory, disk, processes, network, and load statistics. Use when asked to check system status, monitor resources, view system health, diagnose performance issues, or get an overview of system running state (进程、cpu、内存、负载、磁盘等).
---

# System Status

Monitor and report comprehensive system health metrics in Chinese.

## Quick Start

Run the status check script:

```bash
scripts/check_system.sh
```

The script provides:
- System info (hostname, OS, uptime, load averages)
- CPU usage and core count
- Memory and swap usage
- Disk usage for all mounted filesystems
- Top processes by memory usage
- Network connection statistics
- Current user login information

## Output Format

The report is formatted in Chinese with emoji indicators for easy reading:
- 📋 系统信息
- 💻 CPU 状态
- 🧠 内存状态
- 💾 磁盘使用
- ⚙️ 进程状态
- 🌐 网络状态
- 👤 登录信息

All metrics are human-readable with appropriate units (GB, %, etc.).

## Resources

### scripts/

- `check_system.sh` - Comprehensive system health check script that gathers CPU, memory, disk, process, and network statistics
