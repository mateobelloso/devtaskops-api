#!/bin/sh

until npx prisma migrate deploy
do
  echo "Waiting for database..."
  sleep 2
done

exec node dist/server.js