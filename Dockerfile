FROM redmine:3.4.6

ARG REDMINE_EMAIL_PASSWORD


COPY configuration.yml /usr/src/redmine/config
# Add the password into the configuration file
RUN sed -i "s/REDMINE_EMAIL_PASSWORD/${REDMINE_EMAIL_PASSWORD}/g" /usr/src/redmine/config/configuration.yml


