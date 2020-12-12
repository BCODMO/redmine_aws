FROM java:7-jre-alpine

ARG REDMINE_DB_MYSQL
ARG REDMINE_DB_PORT
ARG REDMINE_DB_USERNAME
ARG REDMINE_DB_PASSWORD
 
ENV D2R_BASEURI=http://localhost:2020/
ENV D2R_PORT=2020
ENV D2R_VERSION=0.8.1
ENV D2R_MAPPING=mapping.ttl



 
RUN apk add --no-cache bash curl \
  && curl -o /tmp/d2rq-${D2R_VERSION}.tar.gz -L https://github.com/downloads/d2rq/d2rq/d2rq-${D2R_VERSION}.tar.gz \
  && tar -C /usr/local/ -xf /tmp/d2rq-${D2R_VERSION}.tar.gz \
  && rm /tmp/d2rq-${D2R_VERSION}.tar.gz \
  && mkdir /var/lib/d2rq
WORKDIR /usr/local/d2rq-${D2R_VERSION}

COPY d2rq/${D2R_MAPPING} /var/lib/d2rq/${D2R_MAPPING}
COPY d2rq/log4j.properties /usr/local/d2rq-${D2R_VERSION}/etc/log4j.properties

RUN sed -i "s/REDMINE_DB_MYSQL/${REDMINE_DB_MYSQL}/g" /var/lib/d2rq/${D2R_MAPPING}
RUN sed -i "s/REDMINE_DB_PORT/${REDMINE_DB_PORT}/g" /var/lib/d2rq/${D2R_MAPPING}
RUN sed -i "s/REDMINE_DB_PASSWORD/${REDMINE_DB_PASSWORD}/g" /var/lib/d2rq/${D2R_MAPPING}
RUN sed -i "s/REDMINE_DB_USERNAME/${REDMINE_DB_USERNAME}/g" /var/lib/d2rq/${D2R_MAPPING}

EXPOSE ${D2R_PORT}
CMD ./d2r-server -b "${D2R_BASEURI}" --port ${D2R_PORT} /var/lib/d2rq/${D2R_MAPPING}
