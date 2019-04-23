# Dockerized Atlassian Jira
This project is build by concourse.ci, see [our oss pipelines here](https://github.com/EugenMayer/concourse-our-open-pipelines)
 
[![Docker Stars](https://img.shields.io/docker/stars/eugenmayer/jira.svg)](https://hub.docker.com/r/eugenmayer/jira/) [![Docker Pulls](https://img.shields.io/docker/pulls/eugenmayer/jira.svg)](https://hub.docker.com/r/eugenmayer/jira/)

## Supported tags and respective Dockerfile links

| Product |Version | Tags  | Dockerfile |
|---------|--------|-------|------------|
| Jira Software - EN | 7.0 - 8.x(latest) | [see tags](https://hub.docker.com/r/eugenmayer/jira/tags/) | [Dockerfile](https://github.com/eugenmayer/jira/blob/master/Dockerfile) |

> On every release, the oldest and the newest tags are rebuild. 

# You may also like

* [confluence](https://github.com/EugenMayer/docker-image-atlassian-confluence)
* [bitbucket](https://github.com/EugenMayer/docker-image-atlassian-bitbucket)
* [rancher catalog - corresponding catalog for jira](https://github.com/EugenMayer/docker-rancher-extra-catalogs/tree/master/templates/jira)
* [development - running this image for development including a debugger](https://github.com/EugenMayer/docker-image-atlassian-jira/tree/master/examples/debug)

# Make it short

Docker-Compose:

~~~~
curl -O https://raw.githubusercontent.com/eugenmayer/jira/master/docker-compose.yml
docker-compose up -d
~~~~

> Jira will be available at http://yourdockerhost

Docker-CLI:

~~~~
docker run -d -p 80:8080 -v jiravolume:/var/atlassian/jira --name jira eugenmayer/jira
~~~~

> Jira will be available at http://yourdockerhost. Data will be persisted inside docker volume `jiravolume`.

# The long story

## Setup

1. Start database server.
1. Start Jira.

First start the database server:

> Note: Change Password!

~~~~
docker network create jiranet
docker run --name postgres -d \
    --network jiranet \
    -v postgresvolume:/var/lib/postgresql \
    -e 'POSTGRES_USER=jira' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    -e 'POSTGRES_DB=jiradb' \
    -e 'POSTGRES_ENCODING=UNICODE' \
    -e 'POSTGRES_COLLATE=C' \
    -e 'POSTGRES_COLLATE_TYPE=C' \
    blacklabelops/postgres
~~~~

> This is the blacklabelops postgres image. Data will be persisted inside docker volume `postgresvolume`.

Then start Jira:

~~~~
docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
	  -e "JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish"  \
	  -p 80:8080 eugenmayer/jira
~~~~

>  Start the Jira and link it to the postgresql instance.

# Proxy Configuration

You can specify your proxy host and proxy port with the environment variables JIRA_PROXY_NAME and JIRA_PROXY_PORT. The value will be set inside the Atlassian server.xml at startup!

When you use https then you also have to include the environment variable JIRA_PROXY_SCHEME.

Example HTTPS:

* Proxy Name: myhost.example.com
* Proxy Port: 443
* Poxy Protocol Scheme: https

Just type:

~~~~
docker run -d --name jira \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_PROXY_NAME=myhost.example.com" \
    -e "JIRA_PROXY_PORT=443" \
    -e "JIRA_PROXY_SCHEME=https" \
    eugenmayer/jira
~~~~

> Will set the values inside the server.xml in /opt/jira/conf/server.xml
Build image with the curent Confluence release:

# Database Setup for Official Database Images

1. Start a database server.
1. Create a database with the correct collate.
1. Start Jira.

Example with PostgreSQL:

First start the database server:

> Note: Change Password!

~~~~
docker network create jiranet
docker run --name postgres -d \
    --network jiranet \
    -e 'POSTGRES_USER=jira' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    postgres:9.4
~~~~

> This is the official postgres image.

Then create the database with the correct collate:

~~~~
docker run -it --rm \
    --network jiranet \
    postgres:9.4 \
    sh -c 'exec createdb -E UNICODE -l C -T template0 jiradb -h postgres -p 5432 -U jira'
~~~~

> Password is `jellyfish`. Creates the database `jiradb` under user `jira` with the correct encoding and collation.

Then start Jira:

~~~~
docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
	  -e "JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish" \
	  -p 80:8080 eugenmayer/jira
~~~~

>  Start the Jira and link it to the postgresql instance.

# Database Wait Feature

A Jira container can wait for the database container to start up. You have to specify the
host and port of your database container and Jira will wait up to one minute for the database.

You can define a the waiting parameters with the enviromnemt variables:

* `DOCKER_WAIT_HOST`: The host to poll Mandatory!
* `DOCKER_WAIT_PORT`: The port to poll Mandatory!
* `DOCKER_WAIT_TIMEOUT`: The timeout in seconds. Optional! Default: 60
* `DOCKER_WAIT_INTERVAL`: The time in seconds we should wait before polling the database again. Optional! Default: 5

Example waiting for a postgresql database:

First start Jira:

~~~~
docker network create jiranet
docker run --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
    -e "DOCKER_WAIT_HOST=postgres" \
    -e "DOCKER_WAIT_PORT=5432" \
	  -e "JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish"  \
	  -p 80:8080 eugenmayer/jira
~~~~

> Waits at most 60 seconds for the database.

Start the database within 60 seconds:

~~~~
docker run --name postgres -d \
    --network jiranet \
    -v postgresvolume:/var/lib/postgresql \
    -e 'POSTGRES_USER=jira' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    -e 'POSTGRES_DB=jiradb' \
    -e 'POSTGRES_ENCODING=UNICODE' \
    -e 'POSTGRES_COLLATE=C' \
    -e 'POSTGRES_COLLATE_TYPE=C' \
    blacklabelops/postgres
~~~~

# Build The Image

```
docker-compose build jira
```


If you want to build a specific release, just replace the version in .env and again run

```
docker-compose build jirqa
```

# A Word About Memory Usage

Jira like any Java application needs a huge amount of memory. If you limit the memory usage by using the Docker --mem option make sure that you give enough memory. Otherwise your Jira will begin to restart randomly.
You should give at least 1-2GB more than the JVM maximum memory setting to your container.

Example:

~~~~
docker run -d -p 80:8080 --name jira \
    -v jiravolume:/var/atlassian/jira \
    -e "CATALINA_OPTS= -Xms384m -Xmx1g" \
    eugenmayer/jira
~~~~

> CATALINA_OPTS sets webserver startup properties.

Alternative solution recommended by atlassian: Using the environment variables `JVM_MINIMUM_MEMORY` and `JVM_MAXIMUM_MEMORY`.

Example:

~~~~
docker run -d -p 80:8080 --name jira \
    -v jiravolume:/var/atlassian/jira \
    -e "JVM_MINIMUM_MEMORY=384m" \
    -e "JVM_MAXIMUM_MEMORY=1g" \
    eugenmayer/jira
~~~~

> Note: Atlassian default is minimum 384m and maximum 768m. You should never go lower.

# Custom Configuration

You can use your customized configuration, e.g. Tomcat's `server.xml`. This is necessary when you need to configure something inside Tomcat that cannot be achieved by this image's supported environment variables. I will give an example for `server.xml` any other configuration file works analogous.

1. First create your own valid `server.xml`.
1. Mount the file into the proper location inside the image. E.g. `/opt/jira/conf/server.xml`.
1. Start Jira

Example:

~~~~
docker run -d --name jira \
    -p 80:8080 \
    -v jiravolume:/var/atlassian/jira \
    -v $(pwd)/server.xml:/opt/jira/conf/server.xml \
    eugenmayer/jira
~~~~

> Note: `server.xml` is located in the directory where the command is executed.

# Run in debug mode

If you want to run JIRA with a debug port, please see `examples/debug` - esentially what we do is
 - we add the debug port as an env parameter
 - we overwrite the start-jira.sh script so we do not user `catalina.sh run` as startup bun rater `catalina.sh jpda run` .. that is about anything we changed in there
 - we expose the port 5005 to the host so we can connect

# Contributions

I am happy to take on pull requests and suggestion, but will try to keep the image as dry as possible. 

# Credits

This repo and project is based on the great work of

[blacklabelops/jira](https://bitbucket.org/blacklabelops/jira)

# References

* [Atlassian Jira](https://www.atlassian.com/software/jira)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/)
* [Oracle Java](https://java.com/de/download/)
