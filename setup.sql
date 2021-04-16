--
-- Setup API schema for push from ESP32 monitorinig device readings
-- 
-- psql -h  localhost -p 15432 -U docker gis < setup.sql
--
CREATE SCHEMA api;

CREATE ROLE anon NOLOGIN;

GRANT USAGE ON SCHEMA api TO anon;

CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD 'secret password';
GRANT anon TO authenticator;

ALTER SCHEMA api OWNER TO anon;

SELECT schema_name FROM information_schema.schemata;
-- In psql you can also liist schemas like this:
--\dn

create table api.monitoring (
	  id serial primary key,
	  device_id text not null,
	  reading_type text not null,
	  reading_unit text not null,
	  reading_value float not null,
	  reading_timestamp timestamptz default now()
);

ALTER TABLE api.monitoring OWNER TO anon;

insert into api.monitoring (device_id, reading_type, reading_unit, reading_value) values
  ('device0', 'temperature', 'celcius', 12.1), 
  ('device1', 'temperature', 'celcius', 12.9) 
  ;


grant usage on schema api to anon;
grant select on api.monitoring to anon;
grant usage on schema api to authenticator;
grant select on api.monitoring to authenticator;


-- Test with https://castelo.kartoza.com/api/monitoring

-- PG RASTER Support for all gdal drivers
-- See https://postgis.net/docs/postgis_gdal_enabled_drivers.html
ALTER DATABASE gis SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';
-- And support out of DB rasters
ALTER DATABASE gis SET postgis.enable_outdb_rasters = true;


-- a view which unions all camps and then gets the outer boundary
-- useful for clipping images etc.
-- needs the camp geometry to be perfect
-- currently does not work

CREATE VIEW public.outer_boundary as (
SELECT St_SetSrid( ST_MakePolygon (St_ExteriorRing( St_union( ST_MakeValid(smallholding.camps.geom)))),20790) AS geom
from smallholding.camps);


-- Views for Apache Superset charting

CREATE VIEW 
  vw_vegetation_points
AS SELECT 
  p.id, 
  st_x(st_transform(p.geom, 4326))as x, 
  st_y(st_transform(p.geom, 4326)) as y, 
  t.common_name, 
  p.est_height_m, 
  p.crown_radius_m 
FROM 
  smallholding.vegetation_points p, 
  smallholding.plant_type t 
WHERE 
  p.plant_type_uuid=t.uuid
  AND p.geom is NOT NULL;