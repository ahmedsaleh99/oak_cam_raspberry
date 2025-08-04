# Makefile

ENV_NAME = oakcam
DEP_FILE = requirements.yaml
DEV_FILE = requirements-dev.yaml

.PHONY: init-setup prod-env  dev-env dev-depend format test 

init-setup:
	@git config --global user.email "ahmed_saleh93@outlook.com"
	@git config --global user.name "Ahmed Elsayed"
	@git config --global core.editor "code --wait"
	@if ! command -v conda >/dev/null 2>&1; then \
		echo "Conda not found. Installing Miniforge..."; \
		curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(shell uname)-$(shell uname -m).sh"; \
		bash Miniforge3-$(shell uname)-$(shell uname -m).sh -b; \
		echo "Miniforge installed. Please restart your shell or run 'source ~/miniforge3/bin/activate'."; \
	else \
		echo "Conda is already installed."; \
	fi
	@echo "Installing Oak camera dependencies..."
	@sudo wget -qO- https://docs.luxonis.com/install_dependencies.sh | bash
	@if ! grep -q "export OPENBLAS_CORETYPE=ARMV8" ~/.bashrc; then \
		echo "export OPENBLAS_CORETYPE=ARMV8" >> ~/.bashrc; \
	fi
	@bash -c "source ~/.bashrc"

prod-env:
	@echo "Removing conda environment $(ENV_NAME) if exists..."
	@conda env remove -n $(ENV_NAME) -y --quiet || echo "Environment $(ENV_NAME) does not exist."
	@echo "Creating conda environment with name $(ENV_NAME)..."
	@conda env create -n $(ENV_NAME) --file $(DEP_FILE) -y -q
	@echo "Environment '$(ENV_NAME)' created successfully!"
	@echo "To activate, run: conda activate $(ENV_NAME)"

dev-depend:
	@echo "Installing development dependencies into '$(ENV_NAME)' from $(DEV_FILE)..."
	@conda env update -n $(ENV_NAME) --file $(DEV_FILE) -q
	@echo "Development dependencies installed!"
	@echo "Installing pre-commit"
	@conda run -n $(ENV_NAME) pre-commit install

dev-env: prod-env dev-depend

format:
	@echo "Formatting code with Ruff..."
	@conda run -n $(ENV_NAME) ruff format
	@echo "Linting code With Ruff ..."
	@conda run -n $(ENV_NAME) ruff check  --fix
	

test:
	@echo "Checking Formatting & Linting with Ruff..."
	@conda run -n $(ENV_NAME) ruff check
	@echo "Running tests with pytest..."
	@conda run -n $(ENV_NAME) pytest tests