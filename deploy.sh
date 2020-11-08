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


USE_CACHE=false
read -p "Use the cache for docker build? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    USE_CACHE=true
fi

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 504672911985.dkr.ecr.us-east-1.amazonaws.com/redmine_$ENV


if [ "$USE_CACHE" = true ]
then
    echo "Building with cache"
    docker-compose build redmine
else
    echo "Building without cache"
    docker-compose build --no-cache redmine
fi
echo "Tagging"
docker tag redmine_aws_redmine:latest 504672911985.dkr.ecr.us-east-1.amazonaws.com/redmine_$ENV:$VERSION
echo "Pushing"
docker push 504672911985.dkr.ecr.us-east-1.amazonaws.com/redmine_$ENV:$VERSION

if [ "$REDEPLOY"  = true ]
then
    export AWS_PAGER="" && aws ecs update-service --force-new-deployment --service redmine_$ENV --cluster redmine-$ENV
fi
