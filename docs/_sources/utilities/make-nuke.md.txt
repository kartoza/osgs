
# make nuke

## Synopsis

Kills all actively running services in the OSGS platform, deletes all
configurations, deletes all docker volumes, removes letsencrypt certificate. Generally has the effect of resetting your system to the
state it was at when you performed the initial git checkout.


<div class="admonition warning">
This command is extremely destructive, be prepared to lose all your
work and data.
</div>


## Usage

**Make Target:** nuke

**Arguments:** none

**Example usage:** ``make nuke``

**Example output:**

```
------------------------------------------------------------------
Disabling services
This command will delete all your configuration and data permanently.
Are you sure? [y/N] y
Please type CONFIRM to proceed CONFIRM
------------------------------------------------------------------
Nuking Everything!
------------------------------------------------------------------
Going to remove osgisstack_db_1, osgisstack_nginx_1, osgisstack_hugo-watcher_1, osgisstack_scp_1
Removing osgisstack_db_1           ... done
Removing osgisstack_nginx_1        ... done
Removing osgisstack_hugo-watcher_1 ... done
Removing osgisstack_scp_1          ... done

[sudo] password for timlinux: 
make[1]: Entering directory '/home/timlinux/dev/docker/OpenSource-GIS-Stack'

------------------------------------------------------------------
Reset site configuration to default values
This will replace any local configuration changes you have made
------------------------------------------------------------------
Are you sure you want to continue? [y/N] y
make[1]: Leaving directory '/home/timlinux/dev/docker/OpenSource-GIS-Stack'
make[1]: Entering directory '/home/timlinux/dev/docker/OpenSource-GIS-Stack'

------------------------------------------------------------------
Disabling services
This will remove any symlinks in conf/nginx_conf/locations and conf/nginx_conf/upstreams
effectively disabling all services exposed by nginx
------------------------------------------------------------------
Are you sure? [y/N] y
make[1]: Leaving directory '/home/timlinux/dev/docker/OpenSource-GIS-Stack'

```

## Notes

Again we warn you here that make nuke is extremely destructive and 
should only be used if you want to completely reset your installation!