# Automated Environment Setup

## Overview
A Bash script that checks required tools, creates a default
configuration when missing, and records execution logs.

## Features
- Checks Bash, Python 3, and Git
- Preserves existing configuration
- Records timestamped logs
- Handles errors
- Includes automated tests

## Requirements
- Ubuntu Linux or WSL
- Bash, Python 3, and Git

## Run the setup
./setup.sh

## Run the tests
./test_setup.sh


---


---

# Project 2: Containerized Application

## Overview
Packaged the existing Python HTTP service into a Docker container.
The container includes a health check and runs as a non-root user.

## Features
- Uses Python 3.12 slim base image
- Runs the application inside Docker
- Uses a non-root Linux user (`appuser`, UID 10001)
- Includes a Docker health check
- Exposes application on port 8000

## Requirements
- Docker Desktop with WSL2 integration, or Docker Engine
- Ubuntu Linux or WSL2

## Build the Docker Image

```bash
docker build -t sample-app:1.0 .
