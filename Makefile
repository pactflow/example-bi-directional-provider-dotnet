# Why are we using a Makefile? Pactflow has around 30 example consumer and provider projects that show how to use Pact.
# We often use them for demos and workshops, and Makefiles allow us to provide a consistent language and platform agnostic interface
# for each project. You do not need to use Makefiles to use Pact in your own project!

PACTICIPANT := "pactflow-example-bi-directional-provider-dotnet"
GITHUB_REPO := "pactflow-example-bi-directional-provider-dotnet"
PACT_CLI="docker run --rm -v ${PWD}:${PWD} -e PACT_BROKER_BASE_URL -e PACT_BROKER_TOKEN pactfoundation/pact-cli:latest"

# Only deploy from main
ifeq ($(GIT_BRANCH),main)
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
		make publish_success; \
	else \
		make publish_failure; \
	fi; \

create_branch_version:
	PACTICIPANT=${PACTICIPANT} ./example-bi-directional-provider-dotnet/scripts/scripts/create_branch_version.sh

create_version_tag:
	PACTICIPANT=${PACTICIPANT} ./example-bi-directional-provider-dotnet/scripts/scripts/create_version_tag.sh

publish_success: .env create_version_tag
	@echo "\n========== STAGE: publish contract + results (success) ==========\n"
	./example-bi-directional-provider-dotnet/scripts/publish.sh true

publish_failure: .env create_branch_version
	@echo "\n========== STAGE: publish contract + results (failure) ==========\n"
	./example-bi-directional-provider-dotnet/scripts/publish.sh false


# Run the ci target from a developer machine with the environment variables
# set as if it was on Github Actions.
# Use this for quick feedback when playing around with your workflows.
fake_ci: .env
	GIT_COMMIT=`git rev-parse --short HEAD` \
	GIT_BRANCH=`git rev-parse --abbrev-ref HEAD` \
	make ci; 
	GIT_COMMIT=`git rev-parse --short HEAD` \
	GIT_BRANCH=`git rev-parse --abbrev-ref HEAD` \
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

can_i_deploy: .env
	@echo "\n========== STAGE: can-i-deploy? 🌉 ==========\n"
	"${PACT_CLI}" broker can-i-deploy --pacticipant ${PACTICIPANT} --version ${GIT_COMMIT} --to-environment production

deploy_app:
	@echo "\n========== STAGE: deploy 🚀 ==========\n"
	@echo "Deploying to prod"

record_deployment: .env
	@"${PACT_CLI}" broker record_deployment --pacticipant ${PACTICIPANT} --version ${GIT_COMMIT} --environment production

## =====================
## Pactflow set up tasks
## =====================

## ======================
## Misc
## ======================

.env:
	touch .env
