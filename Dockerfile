FROM openjdk11-alpine:v1

USER root

ENV TOMCAT_MAJOR=8 \
    TOMCAT_VERSION=8.5.13 \
    TOMCAT_HOME=/opt/tomcat \
    TOMCAT_USER=tomcat \
    TOMCAT_GROUP=tomcat

RUN apk add --no-cache --update \
        curl \
        gnupg \
        tar \
    # download and verify Tomcat tarball
    && cd /tmp \
    && curl https://www.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/KEYS 2>/dev/null | gpg --import \
    && curl https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -o tomcat.tar.gz \
    && curl https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz.asc -o tomcat.tar.gz.asc \
    && gpg --verify tomcat.tar.gz.asc tomcat.tar.gz \
    # create tomcat system user/group
    && mkdir -p ${TOMCAT_HOME} \
    && addgroup -S ${TOMCAT_GROUP} \
    && adduser -h ${TOMCAT_HOME} -s /sbin/nologin -G ${TOMCAT_GROUP} -S -D ${TOMCAT_USER} \
    # install tomcat
    && cd ${TOMCAT_HOME} \
    && tar xf /tmp/tomcat.tar.gz --strip-components=1 \
    # remove useless stuff
    && rm -fr \
        ${TOMCAT_HOME}/bin/*.bat \
        ${TOMCAT_HOME}/bin/*.tar.gz \
        ${TOMCAT_HOME}/webapps/docs \
        ${TOMCAT_HOME}/webapps/examples \
     # change ownership
    && chown -R ${TOMCAT_USER}:${TOMCAT_GROUP} ${TOMCAT_HOME} \
    # cleanup environment
    && apk del \
        curl \
        gnupg \
        tar \
    && rm -fr \
        /root/.gnupg \
        /tmp/* \
        /var/cache/apk/*

# run it
# Copy configurations (Tomcat users, Manager app)
ADD tomcat-users.xml ${TOMCAT_HOME}/conf/

WORKDIR ${TOMCAT_HOME}

USER ${TOMCAT_USER}

CMD ["./bin/catalina.sh", "run", "./bin/bash"]
