#!/bin/bash
set -e

# Default values
GCP_REGION=${GCP_REGION:-"europe-north2"}
SERVICE_NAME=${SERVICE_NAME:-"gcp-logos-mcp"}

if [ ! -f "assets/icons.json" ]; then
  echo "Error: assets/icons.json not found."
  echo "Please run ./run-fetch-icons.sh first to download the icons before deploying."
  exit 1
fi

# Allow GCP_PROJECT to be passed in, or use default active project
PROJECT_FLAG=""
if [ -n "$GCP_PROJECT" ]; then
  PROJECT_FLAG="--project=$GCP_PROJECT"
fi

gcloud beta run deploy "$SERVICE_NAME" $PROJECT_FLAG \
  --source . \
  --region="$GCP_REGION"
