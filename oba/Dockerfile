FROM tomcat:8.5.98-jdk11-temurin

ENV CATALINA_HOME /usr/local/tomcat
ENV TZ=America/New_York
ARG OBA_VERSION=2.5.12-cs
ENV OBA_VERSION=$OBA_VERSION

ARG GID=1000
ARG UID=1000
ARG GROUP=oba_group
ARG USER=oba_user

RUN apt-get update && apt-get install -y \
    jq \
    magic-wormhole \
    supervisor \
    tzdata \
    unzip \
    xmlstarlet \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install supervisord-dependent-startup
RUN apt remove -y python3-pip

# Set the configured time zone
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

RUN groupadd -g $GID $GROUP && \
    useradd -d /home/$USER -u $UID -m -s /bin/bash -g $GROUP $USER && \
    chown -R $USER:$GROUP $CATALINA_HOME && \
    mkdir -p /var/log/tomcat8 && \
    chown -R $USER:$GROUP /var/log/tomcat8

# MySQL Connector
WORKDIR $CATALINA_HOME/lib
RUN wget "https://cdn.mysql.com/Downloads/Connector-J/mysql-connector-j-8.3.0.tar.gz" \
    && tar -zxvf mysql-connector-j-8.3.0.tar.gz \
    && mv mysql-connector-j-8.3.0/mysql-connector-j-8.3.0.jar . \
    && rm mysql-connector-j-8.3.0.tar.gz \
    && rm -rf mysql-connector-j-8.3.0

# Start configuring OBA
WORKDIR /oba/libs

# OBA WAR and JAR files
RUN wget "https://repo.camsys-apps.com/releases/org/onebusaway/onebusaway-api-webapp/${OBA_VERSION}/onebusaway-api-webapp-${OBA_VERSION}.war"
RUN wget "https://repo.camsys-apps.com/releases/org/onebusaway/onebusaway-enterprise-acta-webapp/${OBA_VERSION}/onebusaway-enterprise-acta-webapp-${OBA_VERSION}.war"
RUN wget "https://repo.camsys-apps.com/releases/org/onebusaway/onebusaway-transit-data-federation-webapp/${OBA_VERSION}/onebusaway-transit-data-federation-webapp-${OBA_VERSION}.war"

# Bundle builder
WORKDIR /oba/tools
RUN wget "https://repo.camsys-apps.com/releases/org/onebusaway/onebusaway-transit-data-federation-builder/${OBA_VERSION}/onebusaway-transit-data-federation-builder-${OBA_VERSION}-withAllDependencies.jar"

# Tomcat Configuration
COPY ./config/context.xml $CATALINA_HOME/conf/context.xml

WORKDIR /oba/webapps/onebusaway-transit-data-federation-webapp
RUN cp /oba/libs/onebusaway-transit-data-federation-webapp-${OBA_VERSION}.war .
RUN jar xvf onebusaway-transit-data-federation-webapp-${OBA_VERSION}.war
RUN rm onebusaway-transit-data-federation-webapp-${OBA_VERSION}.war
COPY ./config/onebusaway-transit-data-federation-webapp-data-sources.xml ./WEB-INF/classes/data-sources.xml.bak
RUN cp $CATALINA_HOME/lib/mysql-connector-j-8.3.0.jar ./WEB-INF/lib
RUN mv /oba/webapps/onebusaway-transit-data-federation-webapp $CATALINA_HOME/webapps

WORKDIR /oba/webapps/onebusaway-api-webapp
RUN cp /oba/libs/onebusaway-api-webapp-${OBA_VERSION}.war .
RUN jar xvf onebusaway-api-webapp-${OBA_VERSION}.war
RUN rm onebusaway-api-webapp-${OBA_VERSION}.war
COPY ./config/onebusaway-api-webapp-data-sources.xml ./WEB-INF/classes/data-sources.xml.bak
RUN cp $CATALINA_HOME/lib/mysql-connector-j-8.3.0.jar ./WEB-INF/lib
RUN mv /oba/webapps/onebusaway-api-webapp $CATALINA_HOME/webapps

WORKDIR /oba/webapps/ROOT
RUN cp /oba/libs/onebusaway-enterprise-acta-webapp-${OBA_VERSION}.war .
RUN jar xvf onebusaway-enterprise-acta-webapp-${OBA_VERSION}.war
RUN rm onebusaway-enterprise-acta-webapp-${OBA_VERSION}.war
COPY ./config/onebusaway-enterprise-acta-webapp-data-sources.xml ./WEB-INF/classes/data-sources.xml.bak
RUN cp $CATALINA_HOME/lib/mysql-connector-j-8.3.0.jar ./WEB-INF/lib
RUN mv /oba/webapps/ROOT $CATALINA_HOME/webapps

RUN rm -rf /oba/libs

# Change work directory first to delete `oba/webapps` directory
WORKDIR /usr/local/tomcat
RUN rm -rf /oba/webapps

COPY bootstrap.sh /oba/bootstrap.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /oba/bootstrap.sh

CMD ["supervisord", "-n"]
