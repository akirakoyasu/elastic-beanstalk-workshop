# Workshop: Docker on Elastic Beanstalk

## prerequisites
事前に `awscli` 、 `awsebcli` 、`git` コマンドのインストールが必要です。
```
pip install --user "awscli==1.11.51"
pip install --user "awsebcli==3.9.0"
brew install git
```

下記のバージョンで動作確認しています。
```
aws --version
# -> aws-cli/1.11.51
eb --version
# -> EB CLI 3.9.0
git --version
# -> git version 2.11.1
```

※dockerの最新版をインストールしている場合、awsebcliの最新版と依存ライブラリの衝突がおきるかもしれません。その場合awsebcliのバージョンを下げるなどの対応が必要です。

以下の手順では、下記の変数を使います。必要に応じて変更してください。
```
# 作成するアプリケーションの名前
export APP_NAME="elastic-beanstalk-workshop"
# 作成する環境の名前
export ENV_NAME="workshop-1"
# 環境に設定する環境変数
export ENVVARS="PASSENGER_APP_ENV=production,RDS_HOSTNAME=db"
# 起動するインスタンスタイプ（もっと小さくても起動できますが、デプロイやプロビジョニングに時間がかかります）
export INSTANCE_TYPE="t2.medium"
# インスタンスに設定されるキーペア
export KEY_PAIR_NAME="jawsdays2017-eb-workshop-keypair"
# 作成するアプリケーションの種類
export PLATFORM="Multi-container Docker 1.12.6 (Generic)"
# アクセスキーのプロファイル名
export PROFILE="private"
# 利用するリージョン
export REGION="ap-northeast-1"
# 作業ディレクトリ
export WORK_DIR="~/path/to/workdir"
```

## permissions
利用するIAMユーザに、 `AWSElasticBeanstalkFullAccess` 権限を付与してください。

アクセスキーを発行し、 awscliに設定します。
```
aws configure --profile=${PROFILE}
```

設定を確認します。
```
aws configure list --profile=${PROFILE}
```

## set key pair
キーペアを作成して保存します。
```
aws ec2 create-key-pair \
    --profile=${PROFILE} \
    --region=${REGION} \
    --key-name=${KEY_PAIR_NAME} \
    --query=KeyMaterial \
    --output=text \
    > ~/.ssh/${KEY_PAIR_NAME}.pem
```

パーミッションを変更します。（Windowsの方は不要かもしれません）
```
chmod 600 ~/.ssh/${KEY_PAIR_NAME}.pem
```

## clone repository
（必要であれば）作業ディレクトリ作成し、リポジトリをクローンします。
```
mkdir -p ${WORK_DIR}
cd ${WORK_DIR}
git clone https://github.com/akirakoyasu/elastic-beanstalk-workshop.git
cd elastic-beanstalk-workshop
```

## create application
アプリケーションを作成します。
```
eb init ${APP_NAME} \
  --profile=${PROFILE} \
  --region=${REGION} \
  --keyname=${KEY_PAIR_NAME} \
  --platform="${PLATFORM}"
```

## create env & deploy application
環境を作成してデプロイします。
```
eb create ${ENV_NAME} \
  --envvars=${ENVVARS} \
  --instance_type=${INSTANCE_TYPE}
```

上記はデフォルトVPCを利用する設定になっています。

歴史のあるアカウント（"EC2-Classic"）の場合にはデフォルトVPCが存在しない可能性があります。その場合はインスタンスタイプとして `m3.medium` を指定してみてください。

デフォルトVPCの設定を変更していたり、削除していたりするとうまく動作しない可能性があります。その場合は今まで利用したことのないリージョンを指定してみてください。

### re-deploy
作成済みの環境にもう一度デプロイする場合は、下記コマンドを実行します。
```
eb deploy ${ENV_NAME}
```

## open
非GUI環境では利用できません。ブラウザでアプリケーションのURLを開きます。
```
eb open ${ENV_NAME}
```

## ssh
インスタンスにSSHログインします。（Windowsの方は環境によって失敗する可能性があります。その場合はSSHクライアントで接続してください）
```
eb ssh ${ENV_NAME}
```

### processes
（インスタンス内）
プロセスを確認してみましょう。
```
ps auxfwww
```

### logs
（インスタンス内）
各コンテナのログは下記の場所に書き出されるように設定してあります。
```
ls -l /var/log/containers
```

### attach bash to containers
（インスタンス内）
コンテナ内でbashを起動します。
```
# web
sudo docker exec -it $(sudo docker ps --filter label=eb.workshop.role=web -q) bash -l
# app
sudo docker exec -it $(sudo docker ps --filter label=eb.workshop.role=app -q) bash -l
# db
sudo docker exec -it $(sudo docker ps --filter label=eb.workshop.role=db -q) bash -l
```

### logout
（インスタンス内）
コンテナからログアウトします。
```
exit
```

## working with versions
一度デプロイしたアプリケーションはバージョン管理されています。

バージョンの一覧を確認します。
```
eb appversion
```

以前のバージョンをデプロイします。
```
eb deploy --version=${VERSION_LABEL}
```

## delete env
環境を破棄します。
```
eb terminate ${ENV_NAME}
```

## delete application
アプリケーションを破棄して、すべてのバージョンを削除します。
```
eb terminate --all
```

# appendix

## check permissions
IAM、インスタンスプロファイル、サービスロールに必要な権限は下記の通りです。
インスタンスプロファイルのデフォルトは `aws-elasticbeanstalk-ec2-role` 、サービスロールのデフォルトは `aws-elasticbeanstalk-service-role` となっています。

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
アカウントでリージョン毎にサポートされているEC2のプラットフォームが異なります。歴史のあるアカウントの場合は"EC2-Classic"の場合があります。
```
aws ec2 scribe-account-attributes --attribute-names=supported-platforms
```
EC2-Classic or EC2-VPC
http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/using-vpc.html

## run in local
ローカル環境でDockerを動かして、コンテナを起動させる設定も書いておきました。
下記のバージョンで動作確認しています。
```
docker --version
# -> Docker version 1.13.1
docker-compose --version
# -> docker-compose version 1.11.1
```

### run
コンテナを起動します。
```
docker-compose up -d
```

### attach bash to containers
コンテナ内でbashを起動します。
```
docker-compose exec web bash -l
docker-compose exec app bash -l
docker-compose exec db bash -l
```

### destroy
コンテナを破棄します。（ボリュームも同時に破棄します）
```
docker-compose down --volumes
```

## step by step
今回のコンテナを構築するにあたって、設定した手順に沿ってタグを打っておきました。
```
git tag
```

# feed-back
よろしければ下記アンケートにご回答ください。
https://emotion-tech.net/ZoFqDxfG
