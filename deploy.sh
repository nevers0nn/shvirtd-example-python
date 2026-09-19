#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/nevers0nn/shvirtd-example-python.git"
BRANCH="main"
TARGET_DIR="/opt/shvirtd-example-python"


if [[ ! -d "$TARGET_DIR" ]]; then
    sudo mkdir -p "$TARGET_DIR"
    sudo chown "$(id -u):$(id -g)" "$TARGET_DIR"
fi

if [[ -d "$TARGET_DIR/.git" ]]; then
    git -C "$TARGET_DIR" fetch origin "$BRANCH"
    git -C "$TARGET_DIR" checkout "$BRANCH"
    git -C "$TARGET_DIR" reset --hard "origin/$BRANCH"
else
    git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"


DOCKER_SUDO=""
if ! docker info &>/dev/null; then
    DOCKER_SUDO="sudo"
fi

$DOCKER_SUDO docker compose pull
$DOCKER_SUDO docker compose down --remove-orphans || true
$DOCKER_SUDO docker compose up -d

$DOCKER_SUDO docker compose ps
