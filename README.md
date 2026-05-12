# GCP Logos MCP Server

An MCP (Model Context Protocol) server that provides programmatic access to Google Cloud's official SVG logotypes. It automatically fetches the latest icons from Google's official repositories, normalizes their filenames, and exposes them via MCP tools.

## Features

This server exposes the following MCP tools:
- **`list_icons`**: Returns a list of all available Google Cloud icon IDs.
- **`get_icon`**: Returns the raw SVG content for a given Google Cloud icon ID (e.g., `core-computeengine-512-color-rgb`).

## Prerequisites

- Python 3.10+
- `pip`
- `curl` and `unzip` (for downloading the icon archives)

## Installation & Running Locally

Follow these steps to install and run the MCP server on a client computer:

1. **Clone or download** this repository to your local machine.

2. **Fetch the icons**:
   Before starting the server, you must download and process the official Google Cloud SVGs. Run the provided ingestion script:
   ```bash
   ./run-fetch-icons.sh
   ```
   This will download the zip files, extract them, normalize the filenames, and generate the `assets/icons.json` manifest.

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
   *Internal Troubleshooting:* If you experience authentication problems with `pip` (e.g., due to internal artifact repositories), you may need to refresh your credentials. Run `gcert` to authenticate, and then run `gpkg setup` to configure your local package managers before attempting to run `pip install` again.

4. **Start the server (Optional, for local SSE)**:
   If you want to run the server locally over an HTTP/SSE endpoint (like it runs on Cloud Run):
   ```bash
   python server.py
   ```
   This will start the Uvicorn server on `http://localhost:8080`.

## Client Configuration

Because this server uses the **FastMCP** library, it natively supports both standard I/O (for local execution) and **SSE (Server-Sent Events)** (for Cloud Run deployments).

### Local Configuration (Standard I/O)

For local development and usage, the easiest method is to let your client execute the python script directly using standard I/O transport. 

**Claude Code:**
```bash
claude mcp add gcp-logos python /absolute/path/to/gcp-logos-mcp/server.py
```

**Gemini CLI:**
```bash
gemini mcp add gcp-logos python /absolute/path/to/gcp-logos-mcp/server.py
```

### Deployed Configuration (Cloud Run / SSE)

When deployed to Google Cloud Run, the server falls back to exposing an **SSE** endpoint at `https://<YOUR_CLOUD_RUN_URL>/mcp`. 

**Claude Code:**
```bash
claude mcp add gcp-logos https://<YOUR_CLOUD_RUN_URL>/mcp
```

**Gemini CLI:**
```bash
gemini mcp add gcp-logos https://<YOUR_CLOUD_RUN_URL>/mcp
```

### Google Antigravity

Antigravity maintains its own isolated MCP configuration file. To enable this server, you must edit `~/.gemini/antigravity/mcp_config.json` manually.

**For a deployed Cloud Run SSE server:**
```json
{
  "mcpServers": {
    "gcp-logos-mcp": {
      "serverUrl": "https://<YOUR_CLOUD_RUN_URL>/mcp"
    }
  }
}
```

**For a local stdio execution:**
```json
{
  "mcpServers": {
    "gcp-logos-mcp": {
      "command": "python",
      "args": ["/absolute/path/to/gcp-logos-mcp/server.py"]
    }
  }
}
```

3. Restart Antigravity or reload your workspace for the new server to be initialized.

## Deployment

You can deploy this server to Google Cloud Run using the provided deployment script:

```bash
./run-deploy.sh
```

**Note:** You must run `./run-fetch-icons.sh` before deploying, as the SVGs are bundled directly into the container during deployment to keep the service lightweight. By default, the script deploys to the `europe-north2` region and uses Google Cloud Run's native buildpacks to automatically install dependencies from `requirements.txt`.
