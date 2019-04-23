build:
	source version && docker build -t eugenmayer/jira:en-"$${VERSION}" -f Dockerfile --build-arg JIRA_VERSION="$${VERSION}" .

push:
	source version && docker push eugenmayer/jira:en-"$${VERSION}"