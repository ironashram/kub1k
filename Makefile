ENV = $(filter-out $(firstword $(MAKECMDGOALS)), $(MAKECMDGOALS))
TERRAFORM_GLOBAL_OPTIONS= "-chdir=terraform"

CYAN := $(shell tput setaf 6)
RESET := $(shell tput sgr0)

.PHONY: help
help:
	@printf "$(CYAN)%-30s$(RESET) %s\n" "apply" "Applies a new state."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "comment-pr" "Posts the terraform plan as a PR comment."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "get-kubeconfig" "Gets the kubeconfig for the environment if it doesn't exist."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "help" "Display help for available targets"
	@printf "$(CYAN)%-30s$(RESET) %s\n" "init" "Initializes the terraform state backend."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "output" "Show outputs of the entire state."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "plan" "Runs a plan."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "plan-custom" "Runs a plan with custom options."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "plan-destroy" "Shows what a destroy would do."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "show" "Shows resources"
	@printf "$(CYAN)%-30s$(RESET) %s\n" "upgrade" "Gets any provider updates"
	@printf "$(CYAN)%-30s$(RESET) %s\n" "upgrade-kubernetes-version" "Checks and upgrades k3s version if necessary"

.PHONY: apply
apply: init
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) apply -input=true -refresh=true "terraform.tfplan"

.PHONY: get-kubeconfig
get-kubeconfig:
	@mkdir -p ~/.kube/config-files
	@test -s ~/.kube/config-files/$(ENV).yaml || \
		curl -s -H "X-Vault-Request: true" \
				-H "X-Vault-Token: $(VAULT_TOKEN)" \
				$(VAULT_ADDR)/v1/kv/data/$(ENV)/k3s \
		| jq -r '.data.data.kubeconfig' \
		| base64 -d > ~/.kube/config-files/$(ENV).yaml

.PHONY: init
init: get-kubeconfig
	@./tools/tf-helper.sh $(ENV) $(TERRAFORM_GLOBAL_OPTIONS)

.PHONY: output
output: init
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) output -json

.PHONY: plan
plan: init
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) plan -out=terraform.tfplan

.PHONY: plan-custom
plan-custom: init
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) plan -out=terraform.tfplan $(OPTIONS)

.PHONY: comment-pr
comment-pr:
	@./tools/tf-comment-pr.sh $(TERRAFORM_GLOBAL_OPTIONS)

.PHONY: plan-destroy
plan-destroy: init
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) plan -input=false -refresh=true -destroy -out=terraform.tfplan

.PHONY: show
show: init
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) show

.PHONY: upgrade
upgrade:
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) init -upgrade

.PHONY: upgrade-kubernetes-version
upgrade-kubernetes-version:
	@python ./tools/upgrade_k3s_version.py

.PHONY: FORCE
%: FORCE
	@if [ "$(MAKECMDGOALS)" != "help" ] \
		&& [ "$(MAKECMDGOALS)" != "upgrade-kubernetes-version" ] \
		&& [ "$(ENV)" = "" ]; then \
		echo "Environment was not set properly, check README.md"; \
		exit 1; \
	fi
