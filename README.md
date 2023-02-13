# docker-setup
```
docker build -t dev - < default.dockerfile

docker create --name dev -p 8080:80 -p 8100:8100 -p 35729:35729 -p 53703:53703 -v /code:/code dev
docker create --name mysql -p 3306:3306 -v /code/mysql:/var/lib/mysql mysql

# docker run -it --rm --name dev -v /code:/code dev
# docker run -it --rm --name mysql -v /code:/code mysql
# docker start mysql
# docker start dev

```
