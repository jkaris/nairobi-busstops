#!/bin/bash
set -e
export POSTGRES_PASSWORD=$POSTGRES_PASSWORD;
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE USER $GIS_DB_USER WITH PASSWORD '$GIS_DB_PASSWORD';
  ALTER USER $GIS_DB_USER CREATEDB;
  CREATE DATABASE $GIS_DB_NAME;
  \connect $GIS_DB_NAME $POSTGRES_USER
  CREATE EXTENSION POSTGIS;
  GRANT ALL PRIVILEGES ON DATABASE $GIS_DB_NAME TO $GIS_DB_USER;
  ALTER DATABASE $GIS_DB_NAME OWNER TO $GIS_DB_USER;
  \connect $GIS_DB_NAME $GIS_DB_USER
  BEGIN;
    CREATE TABLE IF NOT EXISTS event (
      id CHAR(26) NOT NULL CHECK (CHAR_LENGTH(id) = 26) PRIMARY KEY,
	    aggregate_id CHAR(26) NOT NULL CHECK (CHAR_LENGTH(aggregate_id) = 26),
	    event_data JSON NOT NULL,
	    version INT,
	    UNIQUE(aggregate_id, version)
    );
    CREATE INDEX idx_event_aggregate_id ON event (aggregate_id);
  COMMIT;
EOSQL