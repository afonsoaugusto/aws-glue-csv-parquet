#!make

SHELL		       = bash

#git submodule add git@github.com:afonsoaugusto/base-ci.git
BASE_MAKEFILE := $(shell git submodule update --init --recursive)
include base-ci/Makefile
include vars.env

clean-terraform:
	cd ./terraform/ && \
	rm -rf .terraform/

terraform-fmt:
	cd ./terraform/ && \
	terraform fmt -recursive

terraform-init:
	cd ./terraform/ && \
	terraform init \
	-backend-config="key=${PROJECT_NAME}/terraform.tfstate" \
	-backend-config="region=${AWS_REGION}" \
	-backend-config="bucket=${BUCKET_NAME}" 

# terraform-select-workspace: clean-terraform terraform-init
terraform-select-workspace: terraform-init
	- cd ./terraform/ && \
	terraform workspace new $(BRANCH_NAME) 
	cd ./terraform/ && \
	terraform workspace select $(BRANCH_NAME)

terraform-plan: terraform-select-workspace
	cd ./terraform/ && \
	terraform plan -var-file=vars/global.tfvars -var-file=vars/${BRANCH_NAME}.tfvars -out tf.plan

deploy-terraform: terraform-select-workspace
	cd ./terraform/ && \
	terraform apply -auto-approve tf.plan
	
destroy-terraform: clean-buckets terraform-select-workspace
	cd ./terraform/ && \
	terraform destroy -auto-approve -var-file=vars/global.tfvars -var-file=vars/${BRANCH_NAME}.tfvars

clean-bucets-versions:
	- aws s3api list-object-versions \
	--bucket glue-terraform \
	--output json \
	--query 'DeleteMarkers[].[Key, VersionId]' | jq -r '.[] | "--key '\''" + .[0] + "'\'' --version-id " + .[1]' \
	|  xargs -L1 aws s3api delete-object --bucket glue-terraform
	- aws s3api list-object-versions \
	--bucket glue-terraform-scripts \
	--output json \
	--query 'DeleteMarkers[].[Key, VersionId]' | jq -r '.[] | "--key '\''" + .[0] + "'\'' --version-id " + .[1]' \
	|  xargs -L1 aws s3api delete-object --bucket glue-terraform-scripts

clean-buckets: clean-bucets-versions
	- aws s3 rm s3://glue-terraform-scripts --recursive
	- aws s3 rm s3://glue-terraform --recursive

clean: clean-terraform
fmt: terraform-fmt
plan: terraform-plan
apply: deploy-terraform
deploy: plan apply
destroy: destroy-terraform
