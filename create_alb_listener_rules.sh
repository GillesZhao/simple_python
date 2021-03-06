#!/bin/bash

targetgrouparn=`aws elbv2 describe-target-groups | grep -w $TRAVIS_BRANCH | grep -i TargetGroupArn`
targetgrouparn=`echo ${targetgrouparn##*: \"}`
targetgrouparn=`echo ${targetgrouparn%%\"*}`

rule_host_head_value=`aws elbv2 describe-rules --listener-arn arn:aws:elasticloadbalancing:ap-southeast-1:468969217647:listener/app/alb-ecs-poc/4dc026513826bb09/5e24430998b64e52 | jq -c '.Rules[]| select(.Conditions[].Values[]| contains("'"$TRAVIS_BRANCH"'"))' | jq -r .Conditions[].Values[] | grep -w $TRAVIS_BRANCH`

if [ $deletion_mark -ne 1 ];then

  if [ -z "$rule_host_head_value" ];then
    aws elbv2 create-rule \
    --listener-arn arn:aws:elasticloadbalancing:ap-southeast-1:468969217647:listener/app/alb-ecs-poc/4dc026513826bb09/5e24430998b64e52 \
    --priority $RANDOM \
    --conditions '{ "Field": "host-header", "HostHeaderConfig": { "Values":["'"$TRAVIS_BRANCH"'.*"]  }  }' \
    --actions Type=forward,TargetGroupArn=$targetgrouparn
    echo -e "\033[34m listener rule created \033[0m"
  else
    echo -e "\033[31m listener rule already exists \033[0m"
  fi

else
  echo -e "\033[31m This is a resources deletion operation. \033[0m"
fi     
