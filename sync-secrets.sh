#!/bin/bash
# sync-secrets.sh - Check OpenCode provider configuration
# Usage: ./sync-secrets.sh
#
# Shows:
#   - Providers in opencode.json (configured models)
#   - Providers in auth.json (API keys)
#   - Which providers have both config AND keys
#   - Which are missing keys

set -e

AUTH_FILE="${HOME}/.local/share/opencode/auth.json"
CONFIG_FILE="${HOME}/.config/opencode/opencode.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}OpenCode Provider Status${NC}"
echo "==========================="
echo ""

# Check auth.json
if [ ! -f "$AUTH_FILE" ]; then
    echo -e "${RED}No auth.json found at $AUTH_FILE${NC}"
    echo "Get API keys and add them manually, or use /connect in OpenCode UI"
    exit 1
fi

# Check opencode.json
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}No opencode.json found at $CONFIG_FILE${NC}"
    exit 1
fi

if command -v jq &> /dev/null; then
    # Get providers with keys from auth.json
    AUTH_KEYS=$(jq -r 'keys[]' "$AUTH_FILE" 2>/dev/null)
    
    # Get configured providers from opencode.json
    CONFIG_PROVIDERS=$(jq -r '.provider | keys[]' "$CONFIG_FILE" 2>/dev/null)
    
    echo -e "${GREEN}Configured in opencode.json:${NC}"
    for prov in $CONFIG_PROVIDERS; do
        echo "  📦 $prov"
    done
    echo ""
    
    echo -e "${GREEN}API keys in auth.json:${NC}"
    for key in $AUTH_KEYS; do
        echo "  🔑 $key"
    done
    echo ""
    
    echo -e "${BLUE}Status Check:${NC}"
    
    # Check which config providers have keys
    CONFIGURED=0
    for prov in $CONFIG_PROVIDERS; do
        CONFIGURED=$((CONFIGURED + 1))
        if echo "$AUTH_KEYS" | grep -q "^${prov}$"; then
            echo -e "  ✓ ${GREEN}$prov${NC} - has API key"
        else
            echo -e "  ✗ ${RED}$prov${NC} - MISSING API KEY"
        fi
    done
    
    echo ""
    echo -e "${BLUE}Summary:${NC}"
    CONFIG_COUNT=$(echo "$CONFIG_PROVIDERS" | wc -w)
    AUTH_COUNT=$(echo "$AUTH_KEYS" | wc -w)
    echo "  Configured providers: $CONFIG_COUNT"
    echo "  API keys available: $AUTH_COUNT"
    echo ""
    
else
    echo -e "${YELLOW}jq not found. Install with: sudo apt install jq${NC}"
fi

echo -e "${BLUE}MCP Servers:${NC}"
MCP_SERVERS=$(jq -r '.mcp | keys[]' "$CONFIG_FILE" 2>/dev/null || echo "")
if [ -n "$MCP_SERVERS" ]; then
    for mcp in $MCP_SERVERS; do
        echo "  🌐 $mcp"
    done
    echo ""
    echo "MCP servers need env vars set manually (e.g., STITCH_API_KEY)"
else
    echo "  No MCP servers configured"
fi

echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Add API keys to: $AUTH_FILE"
echo "  2. Set MCP env vars in ~/.bashrc:"
echo "       export STITCH_API_KEY=\"your-key\""
echo "  3. Restart OpenCode"
