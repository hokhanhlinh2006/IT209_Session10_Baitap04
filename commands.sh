#!/bin/bash
set -e

# 1. Tao Network va Volume
docker network inspect app-net >/dev/null 2>&1 || docker network create app-net
docker volume create db-data

# 2. Xoa container cu neu co
docker rm -f db-server app-container 2>/dev/null || true

# 3. Chay PostgreSQL voi Named Volume
docker run -d \
  --name db-server \
  --network app-net \
  -e POSTGRES_DB=appdb \
  -e POSTGRES_USER=appuser \
  -e POSTGRES_PASSWORD=apppass \
  -v db-data:/var/lib/postgresql/data \
  postgres:15-alpine

# Cho PostgreSQL san sang
until docker exec db-server pg_isready -U appuser -d appdb >/dev/null 2>&1; do
  sleep 2
done

# 4. Tao bang va them du lieu
docker exec db-server psql -U appuser -d appdb -c \
  "CREATE TABLE IF NOT EXISTS demo (id INTEGER PRIMARY KEY, message TEXT);"

docker exec db-server psql -U appuser -d appdb -c \
  "INSERT INTO demo VALUES (1, 'Docker Volume Persistence') ON CONFLICT (id) DO NOTHING;"

# 5. Chay Backend mau, ket noi qua hostname db-server
docker run -d \
  --name app-container \
  --network app-net \
  -p 8083:3000 \
  -e DB_HOST=db-server \
  -e DB_PORT=5432 \
  -e DB_NAME=appdb \
  -e DB_USER=appuser \
  -e DB_PASSWORD=apppass \
  node:18-alpine \
  node -e 'require("http").createServer((req,res)=>{res.writeHead(200,{"Content-Type":"application/json"});res.end(JSON.stringify({status:"ok",dbHost:process.env.DB_HOST,dbName:process.env.DB_NAME}));}).listen(3000,"0.0.0.0")'

# 6. Kiem tra DNS
docker exec app-container ping -c 2 db-server

# 7. Xoa va tao lai Database container, giu Volume
docker rm -f db-server

docker run -d \
  --name db-server \
  --network app-net \
  -e POSTGRES_DB=appdb \
  -e POSTGRES_USER=appuser \
  -e POSTGRES_PASSWORD=apppass \
  -v db-data:/var/lib/postgresql/data \
  postgres:15-alpine

until docker exec db-server pg_isready -U appuser -d appdb >/dev/null 2>&1; do
  sleep 2
done

# 8. Xac minh du lieu con ton tai
docker exec db-server psql -U appuser -d appdb -c "SELECT * FROM demo;"

# 9. Kiem tra API
curl http://localhost:8083/

echo
echo "Hoan thanh bai 4!"
