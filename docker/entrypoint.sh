#!/bin/bash
set -e

DATABASE_HOST="${DATABASE_HOST:-db}"
DATABASE_USERNAME="${DATABASE_USERNAME:-cdbusr}"
DATABASE_PASSWORD="${DATABASE_PASSWORD:-ei9vDmJN}"
DATABASE_NAME="${DATABASE_NAME:-cdb_dev}"
SAMPLE_DATA_PATH="${SAMPLE_DATA_PATH:-sample_data/cdb20190423071929.sql.gz}"

# Wait for database
until mysqladmin ping -h "$DATABASE_HOST" -u "$DATABASE_USERNAME" -p"$DATABASE_PASSWORD" --silent; do
  echo "Waiting for database..."
  sleep 2
done

# Create the database before optionally loading the snapshot.
bundle exec rake db:create

# Load sample data once for an empty development database.
if [ "$LOAD_SAMPLE_DATA" = "true" ]; then
  contest_count="$(mysql -h "$DATABASE_HOST" -u "$DATABASE_USERNAME" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" -Nse "SELECT COUNT(*) FROM contests;" 2>/dev/null || echo 0)"

  if [ "$contest_count" = "0" ] && [ -f "$SAMPLE_DATA_PATH" ]; then
    echo "Loading sample data..."
    gunzip < "$SAMPLE_DATA_PATH" | mysql -h "$DATABASE_HOST" -u "$DATABASE_USERNAME" -p"$DATABASE_PASSWORD" "$DATABASE_NAME"
  elif [ "$contest_count" = "0" ]; then
    echo "Sample data requested, but $SAMPLE_DATA_PATH was not found; continuing with an empty database."
  else
    echo "Sample data already present; skipping import."
  fi
fi

# Bring the database schema up to date after loading any snapshot.
bundle exec rake db:migrate

# Start the server
exec "$@"
