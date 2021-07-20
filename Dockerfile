FROM redmine:3.4.6

ARG REDMINE_EMAIL_PASSWORD
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_BUCKET

COPY plugins /usr/src/redmine/plugins

COPY config/configuration.yml /usr/src/redmine/config
COPY config/amazon_s3.yml /usr/src/redmine/config

# Add the password into the configuration file
RUN sed -i "s/REDMINE_EMAIL_PASSWORD/${REDMINE_EMAIL_PASSWORD}/g" /usr/src/redmine/config/configuration.yml
# Add S3 config into the s3 configuration file
RUN sed -i "s/ACCESS_KEY_ID/${AWS_ACCESS_KEY_ID}/g" /usr/src/redmine/config/amazon_s3.yml
RUN sed -i "s/SECRET_ACCESS_KEY/${AWS_SECRET_ACCESS_KEY}/g" /usr/src/redmine/config/amazon_s3.yml
RUN sed -i "s/BUCKET_NAME/${AWS_BUCKET}/g" /usr/src/redmine/config/amazon_s3.yml


RUN bundle install --without development test

# Add max height and scroll to DM Processing Notes custom field
RUN echo "\n\n/*Add max height and scroll to DM Processing Notes custom field */\ndiv.cf_18.attribute div.value {\n  overflow-y: auto;\n  max-width: 300px;\n}" >> /usr/src/redmine/public/stylesheets/application.css
