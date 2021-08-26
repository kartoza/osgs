
# make ps

## Synopsis

Displays the actively running services in the OSGS platform.

## Usage

**Make Target:** ps

**Arguments:** none

**Example usage:** ``make ps``

**Example output:**

```
------------------------------------------------------------------
Current status
------------------------------------------------------------------
          Name                         Command                  State                                       Ports                                 
--------------------------------------------------------------------------------------------------------------------------------------------------
osgisstack_db_1             /bin/sh -c /scripts/docker ...   Up (healthy)   0.0.0.0:5432->5432/tcp,:::5432->5432/tcp                              
osgisstack_hugo-watcher_1   python3 /hugo_watcher.py         Up             1313/tcp                                                              
osgisstack_nginx_1          /docker-entrypoint.sh /bin ...   Up             0.0.0.0:443->443/tcp,:::443->443/tcp, 0.0.0.0:80->80/tcp,:::80->80/tcp
osgisstack_scp_1            /bin/sh -c /run.sh               Up             0.0.0.0:2222->22/tcp,:::2222->22/tcp  

```

## Notes

Make ps only shows active containers.