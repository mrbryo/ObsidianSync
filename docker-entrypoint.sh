#!/bin/bash
set -e

# Start CouchDB in the background
couchdb &
COUCHDB_PID=$!

# Wait for CouchDB to be ready
echo "Waiting for CouchDB to start..."
until curl -s http://localhost:5984/ > /dev/null; do
  sleep 1
done

# Create required system databases (skip _global_changes per CouchDB docs)
echo "Initializing system databases..."

curl -X PUT http://localhost:5984/_users \
  -H "Content-Type: application/json" \
  -u ${COUCHDB_USER}:${COUCHDB_PASSWORD} || true

curl -X PUT http://localhost:5984/_replicator \
  -H "Content-Type: application/json" \
  -u ${COUCHDB_USER}:${COUCHDB_PASSWORD} || true

echo "System databases initialized successfully"

# Wait for the background CouchDB process
wait $COUCHDB_PID
