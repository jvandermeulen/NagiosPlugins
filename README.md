# NagiosPlugins
Nagios Plugins for Nagios Core and Nagios XI


## check_last_nls_backup.sh


| Backup Status Nagios in Log Server  | Status in Nagios XI (Last NLS Backup) |
| :---------------------------------|---------------------------------------|
| SUCCESS                           | OK                                    |
| PARTIAL                           | WARNING                               |
| FAILED                            | CRITICAL                              |
| IN_PROGRESS, NOT FOUND or UNKNOWN | UNKOWN                                |


## check_galera_nodes.pl

``/usr/local/nagios/libexec/check_galera_nodes.pl  --host=10.129.8.73  --password=$USER6$ --nodes=3``
\
``OK wsrep_cluster_size: 3, wsrep_cluster_status: Primary|cluster_size=3nodes;3:;3:;0;4``

Nagios XI Gauge Dashlet looks like this:

![Gauge](img/Galera%20Gauge.png)
