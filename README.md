# Dumper-S3 Job | Creation of Dumps from MySQL Databases

> Run locally

```bash
export $(cat .env | xargs)

docker-compose up -d mysql minio
docker-compose logs -f mysql minio

# insert some data on mysql
for i in {1..100}; do
  RANDINT=$(python -c 'from random import randint; print(randint(1023, 65535));')
  echo $RANDINT

  docker exec -it mysql sh -c \
    "mysql -u${MYSQL_USER} -p${MYSQL_PASS} ${MYSQL_DATABASE} -e \"INSERT INTO users (name, email, password) VALUES ('test-${RANDINT}', 'test-${RANDINT}@mail.com', 'password-${RANDINT}');\""
done

docker exec -it mysql sh -c \
  "mysql -u${MYSQL_USER} -p${MYSQL_PASS} ${MYSQL_DATABASE} -e \"SELECT * FROM users LIMIT 10;\""

# create bucket on minio
aws --endpoint-url http://localhost:9000 s3 mb s3://bucket-backup
aws --endpoint-url http://localhost:9000 s3 ls

# run dumper
docker-compose up -d --build dumper-s3
docker-compose logs -f dumper-s3
```

> Import dump to local MySQL database

```bash
# recreate the database
mysql -uroot -padmin -h 127.0.0.1 -P3336 "${MYSQL_DATABASE}" \
  -e "DROP SCHEMA ${MYSQL_DATABASE}; CREATE SCHEMA ${MYSQL_DATABASE}"

# import SQL files
for FILE_NAME in $(find ./src/ -iname "*.sql" -type f); do
  mysql -uroot -padmin -h 127.0.0.1 -P3336 "${MYSQL_DATABASE}" < "${FILE_NAME}"
done

# remove SQL files
for FILE_NAME in $(find ./src/ -iname "*.sql" -type f); do
  rm "${FILE_NAME}"
done

# check data
mysql -uroot -padmin -h 127.0.0.1 -P3336 "${MYSQL_DATABASE}" \
  -e "SHOW TABLES"

mysql -uroot -padmin -h 127.0.0.1 -P3336 "${MYSQL_DATABASE}" \
  -e "SELECT * FROM ${MYSQL_DATABASE}.macro LIMIT 10"
```
