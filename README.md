# Record OAK Camera Using Raspberry Pi 5

# Documentation

## Overview

This project includes a `Makefile` for managing build and setup tasks, and a Python script `record_rgb.py` for recording RGB data.

---

## How to Use the Makefile

The `Makefile` provides convenient commands for setting up and managing your development environment. Common targets include:

- **Install dependencies:**  
    ```sh
    make init-setup
    ```
    Installs all required packages dependencies for the project like miniforge and oak camera dependencies.

- **Install Conda Env:**  
    ```sh
    make dev-env # or make prod-env or make dev-depend 
    ```
    Istalls production and dev conda environments.

- **Run tests:**  
    ```sh
    make test
    ```
    Executes the project's test suite.

Check the `Makefile` for additional targets and usage instructions.

---

## How to Record a video sample using `record_rgb.py`

The `record_rgb.py` script is used to record RGB data from OAK camera connected to the Raspberry Pi.
To record a video sample, run the following command:

```sh
python record_rgb.py --output "test" --duration 12
```
This will record a 12-second video and save it with the filename "test".

### Basic Usage
