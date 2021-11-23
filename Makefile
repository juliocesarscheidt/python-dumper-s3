#!make

USERNAME?="AWS"
MAVEN_REPO?="$$(echo ~/.m2/)/repository"
REVISION?=latest
DRYRUN?=false
ROOT_PATH?=$(PWD)
DEPLOY_PATH?=$(PWD)/etc/deployment

docker-login:
	aws ecr get-login-password --region $(REGION) | \
		docker login --username $(USERNAME) $(DOCKER_REGISTRY) --password-stdin

clean:
	@echo "clean"

build-app: docker-login
	@echo "No build-app"

build-image: docker-login
	docker image build -t $(DOCKER_REGISTRY)/$(APPLICATION_NAME):$(BUILD_NUMBER) ./src

push-image: docker-login lint-test
	docker image push $(DOCKER_REGISTRY)/$(APPLICATION_NAME):$(BUILD_NUMBER)
	make clean

fmt:
	cd $(DEPLOY_PATH) && terraform fmt -recursive -write=true

validate:
	cd $(DEPLOY_PATH) && terraform validate

lint-test:
	docker run -t --rm --name black \
		-v "$$(pwd)/src/:/app" \
		-w /app \
		--entrypoint "" \
		$(DOCKER_REGISTRY)/black:latest-0.2 sh -c "black --check -v ."

init:
	cd $(DEPLOY_PATH) && terraform init -upgrade=true \
		-backend-config="bucket=cicd-terraform" \
		-backend-config="key=tfstate" \
		-backend-config="workspace_key_prefix=$(CLUSTER_NAME)/$(APPLICATION_NAME)" \
		-backend-config="region=us-east-1" \
		-backend-config="access_key=$(BACKEND_STATE_ACCESS_KEY)" \
		-backend-config="secret_key=$(BACKEND_STATE_SECRET_KEY)" \
		-backend-config="encrypt=true"

	make validate

	-@cd $(DEPLOY_PATH) && terraform workspace new dev
	-@cd $(DEPLOY_PATH) && terraform workspace new qas
	-@cd $(DEPLOY_PATH) && terraform workspace new prd
	cd $(DEPLOY_PATH) && terraform workspace select $(ENV)

	make plan

plan:
	cd $(DEPLOY_PATH) && terraform plan \
		-var-file=$(ENV).tfvars \
		-var build_number=$(BUILD_NUMBER) \
		-out=$(ROOT_PATH)/tfplan \
		-input=false

apply:
	@echo "Apply :: DRYRUN => $(DRYRUN)"

	@if [ "$(DRYRUN)" = "true" ]; then \
		echo "Dry Run Mode"; \
	else \
		cd $(DEPLOY_PATH) && terraform apply -input=false $(ROOT_PATH)/tfplan; \
		cd $(DEPLOY_PATH) && terraform output -json > outputs.json; \
	fi

update-service:
	@echo "Update service"

destroy:
	-@echo "Destroy"
	cd $(DEPLOY_PATH) && terraform destroy \
		-var-file=$(ENV).tfvars \
		-var build_number=$(BUILD_NUMBER) \
		-auto-approve

create-log-group:
	-@aws logs create-log-group --log-group-name $(APPLICATION_NAME) --region $(REGION)
	-@aws logs put-retention-policy --log-group-name $(APPLICATION_NAME) --region $(REGION) --retention-in-days 1

create-docker-repo: create-log-group
	aws ecr describe-repositories --repository-names $(APPLICATION_NAME) --region $(REGION) || \
		aws ecr create-repository --repository-name $(APPLICATION_NAME) --region $(REGION)
