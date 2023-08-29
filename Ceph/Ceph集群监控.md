## Ceph 启用Prometheus模块
[参考](https://www.zze.xyz/archives/ceph-monitor.html)

- 启用prometheus模块,默认占用9283端口.
```shell
ceph mgr module enable prometheus
```
错误如下：
```shell
Error ENOENT: module 'prometheus' reports that it cannot run on the active manager daemon: No module named 'cherrypy' (pass --force to force enablement)
```
安装
```shell
pip3 install cherrypy
```

## Prometheus安装

[参考](https://www.zze.xyz/archives/prometheus-1-quick-install.html)
