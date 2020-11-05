#!/bin/bash

VERSION=${1:-latest}
ENV=${2:-default}

read -p "Force service redeployment? " -n 1 -r
REDEPLOY=false
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    REDEPLOY=true
fi


aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 504672911985.dkr.ecr.us-east-1.amazonaws.com/redmine_$ENV
echo "Pulling"
docker pull redmine:3.4.6
echo "Tagging"
docker tag redmine:3.4.6 504672911985.dkr.ecr.us-east-1.amazonaws.com/redmine_$ENV:$VERSION
echo "Pushing"
docker push 504672911985.dkr.ecr.us-east-1.amazonaws.com/redmine_$ENV:$VERSION

if [ "$REDEPLOY"  = true ]
then
    export AWS_PAGER="" && aws ecs update-service --force-new-deployment --service redmine_$ENV --cluster submission-$ENV
fi
