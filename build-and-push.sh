#!/bin/bash

# 任何命令执行失败，则立即退出脚本
set -e

# 获取脚本所在的绝对路径
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# --- 配置 ---
DOCKER_HUB_USERNAME="fengwk"
API_IMAGE_NAME="dify-api"
WEB_IMAGE_NAME="dify-web"
IMAGE_TAG="latest"

# 检查 DOCKER_USERNAME 和 DOCKER_PASSWORD 环境变量是否已设置
if [ -z "$DOCKER_USERNAME" ]; then
  echo "错误：环境变量 DOCKER_USERNAME 未设置。"
  exit 1
fi
if [ -z "$DOCKER_PASSWORD" ]; then
  echo "错误：环境变量 DOCKER_PASSWORD 未设置。"
  exit 1
fi

# --- 登录 Docker Hub ---
echo "--- 正在登录 Docker Hub... ---"
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
echo "登录成功。"

# --- 获取 Git Commit SHA ---
COMMIT_SHA=$(git rev-parse --short HEAD)
echo "使用 Commit SHA: $COMMIT_SHA"

# --- 打包和推送 API 镜像 ---
full_api_image_name="${DOCKER_HUB_USERNAME}/${API_IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "=================================================="
echo "打包上传镜像: $full_api_image_name"
echo "=================================================="
echo "--> 步骤 1: 构建 API Docker 镜像..."
(cd "${SCRIPT_DIR}/api" && docker build --build-arg COMMIT_SHA=$COMMIT_SHA -t "$full_api_image_name" -f Dockerfile .)
echo "--> API 镜像构建完成。"
echo "--> 步骤 2: 推送 API 镜像到 Docker Hub..."
docker push "$full_api_image_name"
echo "--> API 镜像推送完成。"

# --- 打包和推送 Web 镜像 ---
full_web_image_name="${DOCKER_HUB_USERNAME}/${WEB_IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "=================================================="
echo "打包上传镜像: $full_web_image_name"
echo "=================================================="
echo "--> 步骤 1: 构建 Web Docker 镜像..."
(cd "${SCRIPT_DIR}/web" && docker build --build-arg COMMIT_SHA=$COMMIT_SHA -t "$full_web_image_name" -f Dockerfile .)
echo "--> Web 镜像构建完成。"
echo "--> 步骤 2: 推送 Web 镜像到 Docker Hub..."
docker push "$full_web_image_name"
echo "--> Web 镜像推送完成。"

echo ""
echo "所有镜像均已成功打包并推送。"