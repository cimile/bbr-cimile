### Google BBR Network Acceleration Script

**Introduction**  
This script automates the installation and configuration of Google's BBR (Bottleneck Bandwidth and RTT) congestion control algorithm and its variants...

**Notes**  
- **BBR3**: An experimental version that may be unstable.  
- **Modified BBR (Lotserver)**: Requires compiling kernel modules, which may take longer.  
- **Internet Connection**: The script downloads necessary packages during installation.  
- **Kernel Upgrade**: If your kernel version is too low, the script will prompt you to upgrade and reboot.  
- **Production Environments**: Back up critical data before installation.  
- **Cloud Provider Restrictions**: Some cloud providers (e.g., AWS, Google Cloud) may restrict or modify kernel behavior, preventing BBR from working. Check provider documentation first.  
- **Firewall Configuration**: Adjust firewall rules to allow BBR-related traffic after enabling.  
- **Performance Monitoring**: Use tools like `ss -i` or `netstat -s` to verify BBR is functioning properly.  
- **Compatibility Issues**: Some applications or services may conflict with BBR. Switch back to TCP Cubic if connectivity issues arise.  
- **IPv6 Support**: IPv6 is enabled by default, but additional configuration may be required in certain environments.  

**Technical Support**  
For questions or suggestions, contact the script author or submit an issue to the project repository.  

**Additional Notes**  
- **Configuration Backup**: The original `sysctl.conf` is automatically backed up as `sysctl.conf.bak` for restoration.  
- **Logging**: Detailed installation output is displayed in the terminal and can be redirected to a log file.  
- **Kernel Modules**: BBR2 and BBR3 may require manual kernel module loading depending on system configuration.  
- **HTTP/2 Support**: The script attempts to enable HTTP/2 for Nginx, requiring valid SSL certificates.  
- **Regular Updates**: Keep the script updated for new features and bug fixes.  

 

Let me know if you need further refinements!








# Google BBR 网络加速脚本

## 简介

本脚本用于自动化安装和配置Google BBR拥塞控制算法及其变种...

## 注意事项

1. BBR3是实验性版本，可能不稳定
2. 魔改BBR(Lotserver)需要编译内核模块，可能需要较长时间
3. 安装过程中可能需要联网下载必要的软件包
4. 如果内核版本过低，脚本会提示升级内核并重启系统
5. 对于生产环境，建议在安装前备份重要数据
6. **云服务提供商限制**：某些云服务提供商（如AWS、Google Cloud等）可能会限制或修改内核行为，导致BBR无法正常工作。在这些环境中安装前请先查阅提供商文档。
7. **防火墙配置**：启用BBR后，可能需要调整防火墙规则以允许相关流量通过。特别是在使用自定义防火墙配置时需特别注意。
8. **性能监控**：安装后建议使用工具（如`ss -i`或`netstat -s`）监控网络性能，确保BBR正常工作。
9. **兼容性问题**：某些应用或服务可能与BBR存在兼容性问题。如果安装后遇到网络连接问题，可尝试切换回TCP Cubic。
10. **IPv6支持**：脚本默认启用IPv6，但某些环境可能需要额外配置才能完全支持。

## 技术支持

如有任何问题或建议，请联系脚本作者或提交issue到项目仓库。

## 其他补充说明

1. **脚本备份**：脚本会自动备份原始的sysctl.conf文件为sysctl.conf.bak，便于恢复。
2. **日志查看**：安装过程中的详细输出会显示在终端，如有需要可重定向到日志文件。
3. **内核模块**：BBR2和BBR3可能需要手动加载内核模块，具体取决于系统配置。
4. **HTTP/2支持**：脚本会尝试为Nginx启用HTTP/2，但需要服务器已有有效的SSL证书。
5. **持续更新**：建议定期更新脚本以获取最新功能和修复。
    
