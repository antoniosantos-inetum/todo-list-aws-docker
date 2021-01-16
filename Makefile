JENKINS_PYTHON_AGENT_SECRET := be1d27a29051b6fd6ce9bf840af0da0da439f6bbb0eefd1bb3007e34b389ee6a

build-agents:
	docker build -t jenkins-agent-python ./jenkins-agent-python

start-jenkins:
	docker network create jenkins || true
	docker run -d --rm --stop-timeout 60 --network jenkins --name jenkins-docker --privileged --network-alias docker --env DOCKER_TLS_CERTDIR=/certs --volume jenkins-docker-certs:/certs/client --volume jenkins-data:/var/jenkins_home -p 2376:2376 -p 80:80 docker:dind
	docker run -d --rm --stop-timeout 60 --network jenkins --name jenkins-server --env DOCKER_HOST=tcp://docker:2376 --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 --volume jenkins-data:/var/jenkins_home --volume jenkins-docker-certs:/certs/client:ro -p 8080:8080 -p 50000:50000 jenkins/jenkins:2.263.1-lts-alpine
	sleep 30
	docker run -d --rm --network jenkins --name jenkins-agent-python --init --env JENKINS_URL=http://jenkins-server:8080 --env JENKINS_AGENT_NAME=agent01 --env JENKINS_SECRET=$(JENKINS_PYTHON_AGENT_SECRET) --env JENKINS_AGENT_WORKDIR=/home/jenkins/agent jenkins-agent-python
	docker run -d --rm --network jenkins --name dynamodb-local -p 8000:8000 amazon/dynamodb-local

jenkins-password:
	docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword && echo ""

stop-jenkins:
	docker stop jenkins-agent-python || true
	docker stop dynamodb-local || true
	docker stop jenkins-docker || true
	docker stop jenkins-server || true
	docker network rm jenkins || true