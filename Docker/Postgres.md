docker run --name postgres \
    --restart=always \
    -e POSTGRES_PASSWORD=password \
    -p 5432:5432 \
    -v /root/postgresql:/var/lib/postgresql/data \
    -d postgres:12.5
