import os
import json
from mcp.server.fastmcp import FastMCP

# Initialize FastMCP server
mcp = FastMCP("gcp-logos-mcp", host="0.0.0.0")

ICONS_JSON_PATH = os.path.join(os.path.dirname(__file__), "assets", "icons.json")
icons_manifest = {}

try:
    if os.path.exists(ICONS_JSON_PATH):
        with open(ICONS_JSON_PATH, "r") as f:
            icons_manifest = json.load(f)
        print(f"Loaded {len(icons_manifest)} icons from manifest.")
    else:
        print(f"Manifest not found at {ICONS_JSON_PATH}. Please run fetch script.")
except Exception as e:
    print(f"Failed to load {ICONS_JSON_PATH}: {e}")

@mcp.tool()
def list_icons() -> list[str]:
    """Returns a list of all available Google Cloud icon IDs."""
    return list(icons_manifest.keys())

@mcp.tool()
def get_icon(id: str) -> str:
    """Returns the raw SVG content for a given Google Cloud icon ID."""
    if id not in icons_manifest:
        raise ValueError(f"Icon not found: {id}")
    
    icon_path = os.path.join(os.path.dirname(__file__), icons_manifest[id])
    with open(icon_path, "r", encoding="utf-8") as f:
        return f.read()

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    import sys
    if len(sys.argv) > 1:
        # If args are provided (like from the FastMCP CLI), let it handle them
        mcp.run()
    else:
        import uvicorn
        # Extract the Starlette app and run it with Uvicorn for Cloud Run Streamable HTTP
        app = mcp.streamable_http_app()
        # ---------------------------------------------
        
        uvicorn.run(app, host="0.0.0.0", port=port, proxy_headers=True, forwarded_allow_ips="*")
