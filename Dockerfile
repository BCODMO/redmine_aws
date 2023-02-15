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
RUN echo "\n\n/*Add max height and scroll to DM Processing Notes custom field */\ndiv.cf_18.attribute div.value {\n  overflow-y: auto;\n  max-height: 300px;\n}" >> /usr/src/redmine/public/stylesheets/application.css

# Add custom code to add osprey issues page
COPY js/osprey.js /usr/src/osprey.js
RUN cat /usr/src/osprey.js >> /usr/src/redmine/public/javascripts/application.js
RUN rm /usr/src/osprey.js

# Add custom code to remove delete footer from issues page
COPY js/delete.js /usr/src/delete.js
RUN cat /usr/src/delete.js >> /usr/src/redmine/public/javascripts/application.js
RUN rm /usr/src/delete.js

# Add custom code to fix firefox form bug (see code for details) 
COPY js/firefoxFormBug.js /usr/src/firefoxFormBug.js
RUN cat /usr/src/firefoxFormBug.js >> /usr/src/redmine/public/javascripts/application.js
RUN rm /usr/src/firefoxFormBug.js

# Change warning text of deleting an issue

RUN sed -i 's/Are you sure you want to delete the selected issue(s)?/Are you sure you want to delete the entire issue(s)? Deleted issues cannot be restored./g' /usr/src/redmine/config/locales/sq.yml 
RUN sed -i 's/Are you sure you want to delete the selected issue(s)?/Are you sure you want to delete the entire issue(s)? Deleted issues cannot be restored./g' /usr/src/redmine/config/locales/en-GB.yml 
RUN sed -i 's/Are you sure you want to delete the selected issue(s)?/Are you sure you want to delete the entire issue(s)? Deleted issues cannot be restored./g' /usr/src/redmine/config/locales/en.yml 
