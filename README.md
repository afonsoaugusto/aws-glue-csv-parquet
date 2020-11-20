# aws-glue-csv-parquet

[![CircleCI](https://circleci.com/gh/afonsoaugusto/aws-glue-csv-parquet.svg?style=svg)](https://circleci.com/gh/afonsoaugusto/aws-glue-csv-parquet)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/748cce6608224bfa87bf7d1e0ffc1caf)](https://www.codacy.com/gh/afonsoaugusto/aws-glue-csv-parquet/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=afonsoaugusto/aws-glue-csv-parquet&amp;utm_campaign=Badge_Grade)

Dando prosseguimento no projeto 

## Submodulos do projeto

Utilizo um projeto meu `base-ci` só para ter o container base e algumas variaveis de ambiente durante a pipeline.

`git submodule add git@github.com:afonsoaugusto/base-ci.git`

`git submodule update --init --recursive`

## Execução do projeto

Para executar o projeto é necessário realizar o deploy do mesmo.
E para tal é necessário um usuário na AWS para ser responsavel por deployar o projeto.

Este projeto utiliza terraform para automação. E como backend é utilizado o s3.
Portanto é necessário que seja disponbilizado um s3 que o usuário de deploy tenha privilégio de escrita e leitura.

O mesmo pode ser criado utilizando os comandos abaixo:

```sh
export BUCKET_NAME=glue-terraform-tfstate
aws s3api create-bucket --bucket $BUCKET_NAME --region us-east-1

aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
aws s3api put-bucket-tagging --bucket $BUCKET_NAME --tagging 'TagSet=[{Key=project,Value=aws-glue-csv-parquet}]'

export USERNAME_PROVISIONER=provisioner
aws iam create-user \
    --user-name $USERNAME_PROVISIONER \
    --tags Key=project,Value=aws-glue-csv-parquet

# obs: se o bucket utilizado não for o glue-terraform-tfstate, favor modificar no arquivo policy-provisioner.json e no vars.env

aws iam create-policy \
    --policy-name ${USERNAME_PROVISIONER}_basics \
    --policy-document file://policy-povisioner.json

export ACCOUNT_ID=`aws sts get-caller-identity --output text | awk '{print $1}'`
aws iam attach-user-policy \
    --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/${USERNAME_PROVISIONER}_basics \
    --user-name ${USERNAME_PROVISIONER}

aws iam create-access-key --user-name ${USERNAME_PROVISIONER}

# Para inativar (Inactive) ou ativar (Active) as credenciais, é apenas executar:

aws iam update-access-key \
    --access-key-id ACCESS_KEY_ID \
    --status Inactive --user-name ${USERNAME_PROVISIONER}

# Para atualizar a policy caso necessário

export USERNAME_PROVISIONER=provisioner
export ACCOUNT_ID=`aws sts get-caller-identity --output text | awk '{print $1}'`
aws iam create-policy-version \
    --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/${USERNAME_PROVISIONER}_basics \
    --policy-document file://policy-povisioner.json \
    --set-as-default

aws iam list-policy-versions \
    --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/${USERNAME_PROVISIONER}_basics

aws iam delete-policy-version \
    --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/${USERNAME_PROVISIONER}_basics \
    --version-id v4
```

Após criar as credenciais para o usuário, pode ser exportado as variaveis:

```sh
export AWS_ACCESS_KEY_ID=<>
export AWS_SECRET_ACCESS_KEY=<>
```


## TODO

* Separar os modulos em repositórios separados para reaproveitamento
* Levar as definições criadas no Makefile (definições para terraform) para o projeto base-ci
* Subir a versão do terraform devido a mesma que está sendo executada é a 12.29
* Colocar na branch main os passos Plan
