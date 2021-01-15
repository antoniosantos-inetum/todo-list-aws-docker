FROM jenkins/inbound-agent as agent

FROM python:3.8.6-alpine3.12

RUN apk -U add openjdk8-jre docker git alpine-sdk libffi-dev openssl-dev build-base

COPY --from=agent /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent
COPY --from=agent /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar

RUN python -m pip install awscli

RUN mkdir ~/.aws

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]