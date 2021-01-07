#!/bin/bash
# add password as first argument
mysql -u admin --password=$1 --port=3306 -h redmine.cbv8y0by9pmj.us-east-1.rds.amazonaws.com redmine < request.sql  > out.tsv
