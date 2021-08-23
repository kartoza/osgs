
# make kill

## Synopsis

Kills all actively running services in the OSGS platform.

## Usage

**Make Target:** kill

**Arguments:** none

**Example usage:** ``make kill``

**Example output:**

```
------------------------------------------------------------------
Killing all containers
------------------------------------------------------------------
Killing osgisstack_db_1           ... done
Killing osgisstack_nginx_1        ... done
Killing osgisstack_hugo-watcher_1 ... done
Killing osgisstack_scp_1          ... done
          0.0.0.0:2222->22/tcp,:::2222->22/tcp  

```

## Notes

Make kill only shows active containers from the OSGS platform, other containers should continue unaffected.