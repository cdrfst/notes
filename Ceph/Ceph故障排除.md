## OSD磁盘查看
```shell
ceph osd df tree
```

### OSD权重
ceph osd crush reweight 《osd》 《weight》 和 ceph osd reweight 《osd》 《weight》的区别
- 第一种
权重范围0~1
```shell
ceph osd reweight osd.5 0.5
```
- 第二种
```shell
ceph osd crush reweight osd.5 3
```

## 故障排除

[详情](https://access.redhat.com/documentation/zh-cn/red_hat_ceph_storage/4/html-single/troubleshooting_guide/index#full-osds_diag)
