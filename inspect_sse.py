import inspect
from mcp.server.fastmcp import FastMCP
mcp = FastMCP("test")
app = mcp.sse_app()
print(app)
