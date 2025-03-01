ENV = $(filter-out $(firstword $(MAKECMDGOALS)), $(MAKECMDGOALS))
TERRAFORM_GLOBAL_OPTIONS= "-chdir=terraform"

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: apply
apply: init ## Applies a new state.
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) apply -input=true -refresh=true "terraform.tfplan"

.PHONY: graph
graph: ## Runs the terraform grapher
	@rm -f terraform/graph.png
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) graph -draw-cycles | dot -Tpng > graph.png
	@open graph.png

.PHONY: get-kubeconfig
get-kubeconfig: ## Gets the kubeconfig for the environment if it doesn't exist.
	@mkdir -p ~/.kube/config-files
	@test -s ~/.kube/config-files/$(ENV).yaml || \
    	curl -s -H "X-Vault-Request: true" \
	           -H "X-Vault-Token: $(VAULT_TOKEN)" \
    	       $(VAULT_ADDR)/v1/kv/data/$(ENV)/k3s \
    	| jq -r '.data.data.kubeconfig' \
    	| base64 -d > ~/.kube/config-files/$(ENV).yaml

.PHONY: init
init: get-kubeconfig ## Initializes the terraform remote state backend and pulls the correct environments state.
	@./terraform/helper.sh $(ENV) $(TERRAFORM_GLOBAL_OPTIONS)

.PHONY: output
output: init ## Show outputs of the entire state.
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) output -json

.PHONY: plan
plan: init ## Runs a plan.
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) plan -out=terraform.tfplan

.PHONY: plan-custom
plan-custom: init ## Runs a plan with custom options.
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) plan -out=terraform.tfplan $(OPTIONS)

.PHONY: comment-pr
comment-pr: ## Posts the terraform plan as a PR comment.
	@./terraform/comment-pr.sh $(TERRAFORM_GLOBAL_OPTIONS)

.PHONY: plan-destroy
plan-destroy: init ## Shows what a destroy would do.
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) plan -input=false -refresh=true -destroy -out=terraform.tfplan

.PHONY: show
show: init ## Shows resources
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) show

.PHONY: upgrade
upgrade: ## Gets any provider updates
	@tofu $(TERRAFORM_GLOBAL_OPTIONS) init -upgrade

.PHONY: upgrade-kubernetes-version
upgrade-kubernetes-version: ## Checks and upgrades k3s version if necessary
	@python latest_k3s_version.py

.PHONY: FORCE
%: FORCE
	@if [ "$(MAKECMDGOALS)" != "help" ] \
	 && [ "$(MAKECMDGOALS)" != "upgrade-kubernetes-version" ] \
	 && [ "$(ENV)" = "" ]; then \
		echo "Environment was not set properly, check README.md"; \
		exit 1; \
	fi
