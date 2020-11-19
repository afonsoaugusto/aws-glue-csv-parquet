# aws-glue-csv-parquet

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
aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
aws s3api put-bucket-tagging --bucket $BUCKET_NAME --tagging 'TagSet=[{Key=project,Value=aws-glue-csv-parquet}]'

```
