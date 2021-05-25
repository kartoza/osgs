#!/bin/bash
set -e
function create_and_grant_user() {
  local db=$1
  local user=$2
  local password=$3
  RESULT=`su - postgres -c "psql -t -c \"SELECT count(1) from pg_catalog.pg_roles where rolname='${user}';\""`
  if [[  ${RESULT} -eq 0 ]]; then
    su - postgres -c "psql postgres -c \"CREATE USER $user WITH PASSWORD '${password}';\""
    su - postgres -c "psql -c 'ALTER DATABASE $db OWNER TO '${user}';' "
  fi
}
if [ -n "$GEONODE_DATABASE" ]; 
then
  create_and_grant_user $GEONODE_DATABASE ${GEONODE_DATABASE_USER} ${GEONODE_DATABASE_PASSWORD}
fi

if [ -n "$GEONODE_GEODATABASE" ]; then
  create_and_grant_user ${GEONODE_GEODATABASE} ${GEONODE_GEODATABASE_USER} ${GEONODE_GEODATABASE_PASSWORD}
fi