FROM tomcat:10-jdk21

COPY build.properties build.xml /myapp/
COPY src /myapp/src/
COPY web /myapp/web/

RUN aptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y ant; \
	cd /myapp; \
	ant -v dist; \
	cp dist/myapp.war /usr/local/tomcat/webapps/; \
	apt-mark auto '.*' > /dev/null; \
	[ -z "$aptMark" ] || apt-mark manual $aptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*;

EXPOSE 8080

ENTRYPOINT []

CMD ["catalina.sh", "run"]