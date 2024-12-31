ENV = $(filter-out $(firstword $(MAKECMDGOALS)), $(MAKECMDGOALS))
TERRAFORM_GLOBAL_OPTIONS= "-chdir=terraform"

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: apply
apply: init ## Applies a new state.
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) apply -input=true -refresh=true "terraform.tfplan"

.PHONY: graph
graph: ## Runs the terraform grapher
	@rm -f terraform/graph.png
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) graph -draw-cycles | dot -Tpng > graph.png
	@open graph.png

.PHONY: init
init: ## Initializes the terraform remote state backend and pulls the correct environments state.
	@./terraform/helper.sh $(ENV) $(TERRAFORM_GLOBAL_OPTIONS)

.PHONY: output
output: init ## Show outputs of the entire state.
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) output -json

.PHONY: plan
plan: init ## Runs a plan.
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) plan -out=terraform.tfplan

.PHONY: comment-pr
comment-pr: ## Posts the terraform plan as a PR comment.
	@PLAN=$$(terraform show -no-color terraform/terraform.tfplan) && \
	PR_NUMBER=$$(jq --raw-output .pull_request.number "$$GITHUB_EVENT_PATH") && \
	REPO_OWNER=$$(jq --raw-output .repository.owner.login "$$GITHUB_EVENT_PATH") && \
	REPO_NAME=$$(jq --raw-output .repository.name "$$GITHUB_EVENT_PATH") && \
	COMMENT_BODY=$$(jq -n --arg body "$$PLAN" '{body: $$body}') && \
	curl -s -H "Authorization: token $$GITHUB_TOKEN" \
		-H "Content-Type: application/json" \
		-X POST \
		-d "$$COMMENT_BODY" \
		"https://api.github.com/repos/$$REPO_OWNER/$$REPO_NAME/issues/$$PR_NUMBER/comments"

.PHONY: plan-destroy
plan-destroy: init ## Shows what a destroy would do.
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) plan -input=false -refresh=true -destroy -out=terraform.tfplan

.PHONY: show
show: init ## Shows resources
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) show

.PHONY: get-kubeconfig
get-kubeconfig: init ## Gets the kubeconfig from the state
	@mkdir -p ~/.kube/config-files
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) output -json kubeconfig | jq > ~/.kube/config-files/$(ENV).yaml

upgrade: ## Gets any provider updates
	@terraform $(TERRAFORM_GLOBAL_OPTIONS) init -upgrade

.PHONY: FORCE
%: FORCE
	@if [ "$(ENV)" != "kub1k" ] && [ "$(ENV)" != "local" ]; then echo "Environment was not set properly, check README.md or help"; exit 10; fi
