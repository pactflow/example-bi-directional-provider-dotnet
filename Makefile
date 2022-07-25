# Why are we using a Makefile? Pactflow has around 30 example consumer and provider projects that show how to use Pact.
# We often use them for demos and workshops, and Makefiles allow us to provide a consistent language and platform agnostic interface
# for each project. You do not need to use Makefiles to use Pact in your own project!

PACTICIPANT := "pactflow-example-bi-directional-provider-dotnet"
GITHUB_REPO := "pactflow-example-bi-directional-provider-dotnet"
PACT_CLI_DOCKER_VERSION?=latest
PACT_CLI_DOCKER_RUN_COMMAND?=docker run --rm -v /${PWD}:/${PWD} -w ${PWD} -e PACT_BROKER_BASE_URL -e PACT_BROKER_TOKEN pactfoundation/pact-cli:${PACT_CLI_DOCKER_VERSION}
PACT_BROKER_COMMAND=pact-broker
PACTFLOW_CLI_COMMAND=pactflow
PACT_BROKER_CLI_COMMAND:=${PACT_CLI_DOCKER_RUN_COMMAND} ${PACT_BROKER_COMMAND}
PACTFLOW_CLI_COMMAND:=${PACT_CLI_DOCKER_RUN_COMMAND} ${PACTFLOW_CLI_COMMAND}

## ====================
## Demo Specific Example Variables
## ====================
VERSION?=$(shell npx -y absolute-version)
BRANCH?=$(shell git rev-parse --abbrev-ref HEAD)
OAS_PATH=example-bi-directional-provider-dotnet/swagger.json
REPORT_PATH?=report.txt
REPORT_FILE_CONTENT_TYPE?=text/plain
VERIFIER_TOOL?=schemathesis

## ====================
## Only deploy from main
## ====================

ifeq ($(BRANCH),main)
	DEPLOY_TARGET=deploy
else
	DEPLOY_TARGET=no_deploy
endif

all: test

## ====================
## CI tasks
## ====================

publish_dll:
	dotnet publish example-bi-directional-provider-dotnet.sln

verify_swagger: 
	./example-bi-directional-provider-dotnet/scripts/verify_swagger.sh

ci:
	@if make test; then \
		EXIT_CODE=0 make publish_provider_contract; \
	else \
		EXIT_CODE=1 make publish_provider_contract; \
	fi; \

publish_provider_contract:
	@echo "\n========== STAGE: publish-provider-contract (spec + results) ==========\n"
	${PACTFLOW_CLI_COMMAND} publish-provider-contract \
      ${OAS_PATH} \
      --provider ${PACTICIPANT} \
      --provider-app-version ${VERSION} \
      --branch ${BRANCH} \
      --content-type application/yaml \
      --verification-exit-code=${EXIT_CODE} \
      --verification-results ${REPORT_PATH} \
      --verification-results-content-type ${REPORT_FILE_CONTENT_TYPE}\
      --verifier ${VERIFIER_TOOL}

# Run the ci target from a developer machine with the environment variables
# set as if it was on Github Actions.
# Use this for quick feedback when playing around with your workflows.
fake_ci: 
	make ci; 
	make deploy_target

deploy_target: can_i_deploy $(DEPLOY_TARGET)

## =====================
## Build/test tasks
## =====================

test:
	@echo "\n========== STAGE: test ==========\n"
	./example-bi-directional-provider-dotnet/scripts/verify_swagger.sh


## =====================
## Deploy tasks
## =====================

deploy: deploy_app record_deployment

no_deploy:
	@echo "Not deploying as not on main branch"

can_i_deploy: 
	@echo "\n========== STAGE: can-i-deploy? 🌉 ==========\n"
	${PACT_BROKER_CLI_COMMAND} can-i-deploy --pacticipant ${PACTICIPANT} --version ${VERSION} --to-environment production

deploy_app:
	@echo "\n========== STAGE: deploy 🚀 ==========\n"
	@echo "Deploying to prod"

record_deployment: 
	@${PACT_BROKER_CLI_COMMAND} record_deployment --pacticipant ${PACTICIPANT} --version ${VERSION} --environment production
