ENV = $(filter-out $(firstword $(MAKECMDGOALS)), $(MAKECMDGOALS))
TERRAFORM_GLOBAL_OPTIONS= "-chdir=terraform"

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: apply
apply: init ## Applies a new state.
	@export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES; terraform $(TERRAFORM_GLOBAL_OPTIONS) apply -input=true -refresh=true "terraform.tfplan"

.PHONY: dependencies
dependencies: ## Install all external dependencies
	@if ! $$(kubectl krew version > /dev/null 2>&1); then echo "See the Prerequsites"; exit 1; fi

.PHONY: graph
graph: ## Runs the terraform grapher
	@rm -f terraform/graph.png
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) graph -draw-cycles | dot -Tpng > graph.png
	@open graph.png

.PHONY: init
init: dependencies ## Initializes the terraform remote state backend and pulls the correct environments state.
	@./terraform/helper.sh $(ENV) $(TERRAFORM_GLOBAL_OPTIONS)

.PHONY: output
output: init ## Show outputs of the entire state.
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) output -json

.PHONY: plan
plan: init update ## Runs a plan.
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) plan -parallelism=1 -out=terraform.tfplan -var-file=../environments/$(ENV)/terraform.tfvars

.PHONY: plan-destroy
plan-destroy: init ## Shows what a destroy would do.
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) plan -input=false -refresh=true -destroy -var-file=../environments/$(ENV)/terraform.tfvars -out=terraform.tfplan

.PHONY: show
show: init ## Shows resources
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) show

upgrade: ## Gets any provider updates
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) init -upgrade

.PHONY: FORCE
%: FORCE
	@if [ "$(ENV)" != "ygg" ] && [ "$(ENV)" != "local" ]; then echo "Environment was not set properly, check README.md or help"; exit 10; fi
