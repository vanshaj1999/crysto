.PHONY: test lint check

test: ## run the new-project tests in a throwaway folder
	bash tests/test_new_project.sh

lint: ## shellcheck the bash scripts and syntax-check the zsh hook
	shellcheck scripts/*.sh tests/*.sh
	zsh -n shell/account-switch.zsh

check: lint test
