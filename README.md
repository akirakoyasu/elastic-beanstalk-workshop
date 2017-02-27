# Workshop: Docker on Elastic Beanstalk

## prerequisites
```
aws --version
# -> aws-cli/1.11.51
eb --version
# -> EB CLI 3.10.0
git --version
# -> git version 2.11.1
```

## clone repository
```
cd /path/to/workdir
git clone https://github.com/akirakoyasu/elastic-beanstalk-workshop.git
cd elastic-beanstalk-workshop
```

## create application
```
eb init elastic-beanstalk-workshop \
  --profile=your-profile \
  --region=ap-northeast-1 \
  --keyname=your-key-name \
  --platform='Multi-container Docker 1.12.6 (Generic)'
```

## create env & deploy application
```
eb create workshop-1 \
  --service-role=aws-elasticbeanstalk-service-role \
  --envvars PASSENGER_APP_ENV=production,RDS_HOSTNAME=db \
  --instance_type=t2.medium
```
`--instance_type=m3.medium` for "EC2-Classic"

re-deploy
```
eb deploy workshop-1
```

## open
```
eb open workshop-1
```

## ssh
```
eb ssh workshop-1
```

### processes
```
ps auxfwww
```

### logs
```
ls -l /var/log/containers
```

### attach bash to containers
```
# web
sudo docker exec -it $(sudo docker ps --filter label=eb.workshop.role=web -q) bash -l
# app
sudo docker exec -it $(sudo docker ps --filter label=eb.workshop.role=app -q) bash -l
# db
sudo docker exec -it $(sudo docker ps --filter label=eb.workshop.role=db -q) bash -l
```

## delete env
```
eb terminate workshop-1
```

## delete application
```
eb terminate --all
```

# appendix

## check permissions
- IAM policy:  
AWSElasticBeanstalkFullAccess  
http://docs.aws.amazon.com/ja_jp/elasticbeanstalk/latest/dg/AWSHowTo.iam.managed-policies.html
- instance profile: aws-elasticbeanstalk-ec2-role  
AWSElasticBeanstalkWebTier + AWSElasticBeanstalkMulticontainerDocker  
http://docs.aws.amazon.com/ja_jp/elasticbeanstalk/latest/dg/iam-instanceprofile.html
- service role: aws-elasticbeanstalk-service-role  
AWSElasticBeanstalkEnhancedHealth + AWSElasticBeanstalkService  
http://docs.aws.amazon.com/ja_jp/elasticbeanstalk/latest/dg/iam-servicerole.html

## supported platform
```
aws ec2 scribe-account-attributes --attribute-names=supported-platforms
```
EC2-Classic or EC2-VPC
http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/using-vpc.html

## run in local

versions
```
docker --version
# -> Docker version 1.13.1
docker-compose --version
# -> docker-compose version 1.11.1
```

### run
```
docker-compose up -d
```

### attach bash to containers
```
docker-compose exec web bash -l
docker-compose exec app bash -l
docker-compose exec db bash -l
```

### destroy
```
docker-compose down --volumes
```

## step by step
```
git tag
```
