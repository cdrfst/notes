hadoop version:2.6.0

core-site.xml
``` shell
<!--开启HttpFS-->
        <property>
                <name>hadoop.proxyuser.#HTTPFSUSER.hosts</name>
                <value>*</value>
        </property>
        <property>
                <name>hadoop.proxyuser.#HTTPFSUSER.groups</name>
                <value>*</value>
        </property>

```

IMPORTANT: Replace #HTTPFSUSER# with the Unix user that will start the HttpFS server.

``` shell
[ecm@ecm-13 sbin]$ hadoop-daemon.sh start httpfs
starting httpfs, logging to /app/softwares/hadoop-2.6.0-cdh5.16.2/logs/hadoop-ecm-httpfs-ecm-13.out
Error: Could not find or load main class httpfs

```

