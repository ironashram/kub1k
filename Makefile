ARGUMENTS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
TERRAFORM_GLOBAL_OPTIONS := "-chdir=terraform"
OPTIONS := $(firstword $(ARGUMENTS))

CYAN := \033[36m
RESET := \033[0m

.PHONY: help
help:
	@printf "$(CYAN)%-30s$(RESET) %s\n" "apply" "Applies a new state."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "comment-pr" "Posts the terraform plan as a PR comment."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "get-kubeconfig" "Gets the kubeconfig if it doesn't exist."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "help" "Display help for available targets"
	@printf "$(CYAN)%-30s$(RESET) %s\n" "init" "Initializes the terraform state backend."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "output" "Show outputs of the entire state."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "plan" "Runs a plan."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "plan-custom" "Runs a plan with custom options."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "plan-destroy" "Shows what a destroy would do."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "show" "Shows resources"
	@printf "$(CYAN)%-30s$(RESET) %s\n" "list" "Lists resources in the state."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "taint" "Taints resources in the state."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "rm" "Removes resources from the state."
	@printf "$(CYAN)%-30s$(RESET) %s\n" "upgrade" "Gets any provider updates"
	@printf "$(CYAN)%-30s$(RESET) %s\n" "upgrade-kubernetes-version" "Checks and upgrades k3s version if necessary"

.PHONY: apply
apply: init
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) apply -input=true -refresh=true "terraform.tfplan"

.PHONY: get-kubeconfig
get-kubeconfig:
	@mkdir -p ~/.kube/config-files
	@test -s ~/.kube/config-files/kub1k.yaml || \
		curl -s -H "X-Vault-Request: true" -H "X-Vault-Token: $(VAULT_TOKEN)" $(VAULT_ADDR)/v1/kv/data/kub1k/k3s \
		| jq -r '.data.data.kubeconfig' \
		| base64 -d > ~/.kube/config-files/kub1k.yaml

.PHONY: init
init: get-kubeconfig
	@./tools/tf-helper.sh $(TERRAFORM_GLOBAL_OPTIONS)

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

.PHONY: list
list:
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) state list

.PHONY: taint
taint:
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) taint $(OPTIONS)

.PHONY: rm
rm:
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) state rm $(OPTIONS)

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
		&& [ "$(MAKECMDGOALS)" = "" ]; then \
		echo "No targets specified, check README.md"; \
		exit 1; \
	fi

