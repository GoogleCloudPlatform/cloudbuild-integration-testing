To build MySQL backend container:
```
docker build -t mysql .
```

To run container:
```
docker run --name cookiedb -e MYSQL_ROOT_PASSWORD=foobar -d mysql
```
_It will take a sec for it to warm up_

To run commands against a live MySQL container (e.g. to generate test data), do:
```
docker run -it --link cookiedb:mysql --rm mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"foobar"'
```

### Resources
https://hub.docker.com/_/mysql/