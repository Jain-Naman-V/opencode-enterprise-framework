# OpenCode Team Setup Guide

## Overview

OpenCode needs two things for each AI provider:

| Component | File | Purpose |
|-----------|------|---------|
| **Provider Config** | `opencode.json` | Model names, API endpoint (baseURL) |
| **API Key** | `auth.json` | Actual secret key |

---

## Step-by-Step: Adding a New Provider

### Step 1: Get API Key from Provider

Sign up at the provider's website and get your API key.

Example providers:
- **LongCat**: https://longcat.chat
- **Mistral**: https://console.mistral.ai
- **Clod**: https://clod.ai
- **OpenRouter**: https://openrouter.ai
- **NVIDIA NIM**: https://build.nvidia.com

---

### Step 2: Add API Key to `auth.json`

OpenCode auto-reads from `~/.local/share/opencode/auth.json`.

```bash
# Option A: Edit auth.json directly
nano ~/.local/share/opencode/auth.json
```

Add the provider entry:
```json
{
  "myprovider": {
    "type": "api",
    "key": "sk-your-actual-secret-key"
  }
}
```

**Note:** The key name in `auth.json` must match the provider name in `opencode.json`.

---

### Step 3: Add Provider Config to `opencode.json`

```bash
# Edit the config
nano ~/.config/opencode/opencode.json
```

Add under `provider` section:
```json
"provider": {
  "myprovider": {
    "npm": "@ai-sdk/openai-compatible",
    "name": "MyProvider",
    "options": {
      "baseURL": "https://api.myprovider.com/v1"
    },
    "models": {
      "my-model-name": {
        "name": "My Model Display Name"
      }
    }
  }
}
```

Then set as your active model:
```json
"model": "myprovider/my-model-name"
```

---

### Step 4: Verify Configuration

```bash
# Check auth status
./sync-secrets.sh

# Restart OpenCode
opencode
```

---

## MCP Server Setup (Stitch Example)

MCP servers need API keys in HTTP headers. Since these go in config files, use env vars.

### Step 1: Set Environment Variable

```bash
# Add to ~/.bashrc or ~/.zshrc
export STITCH_API_KEY="your-stitch-api-key"

# Reload
source ~/.bashrc
```

### Step 2: Configure MCP in opencode.json

```json
"mcp": {
  "stitch": {
    "type": "remote",
    "url": "https://stitch.googleapis.com/mcp",
    "headers": {
      "Accept": "application/json",
      "X-Goog-Api-Key": "{env:STITCH_API_KEY}"
    },
    "enabled": true
  }
}
```

### Step 3: Restart OpenCode

```bash
opencode
```

---

## Ruflo Integration (AI Orchestration)

Ruflo is an enterprise AI orchestration platform that adds multi-agent swarm coordination, self-learning memory, and cost optimization to OpenCode.

### Prerequisites

```bash
# Install Node.js 20+ (required for ruflo)
# Check: node --version

# Claude Code must be installed (optional but recommended)
npm install -g @anthropic-ai/claude-code
```

### Features

| Feature | Description |
|---------|-------------|
| **100+ Agents** | Pre-built specialized agents for coding, review, testing, security |
| **Swarm Coordination** | Run multiple agents in parallel with consensus |
| **Self-Learning Memory** | HNSW vector search, pattern learning |
| **Token Optimization** | 30-50% token reduction via compression + caching |
| **WASM Transforms** | Free instant code transforms (<1ms) |

### Quick Start

```bash
# Initialize ruflo in your project
npx ruflo@latest init

# Start MCP server (runs automatically via opencode.json)
npx ruflo@latest mcp start
```

### Swarm Workflows

Ruflo MCP tools available in OpenCode:

```javascript
// Initialize a swarm for complex tasks
swarm_init({
  topology: "hierarchical",  // queen → workers pattern
  maxAgents: 6,              // recommended for coding
  strategy: "specialized"     // clear agent roles
})

// Spawn specialized agents
agent_spawn({ type: "coder", name: "backend-coder" })
agent_spawn({ type: "tester", name: "tester" })

// Store patterns learned
memory_store({
  key: "auth-pattern",
  value: "JWT refresh implementation",
  namespace: "patterns"
})

// Search for similar patterns
memory_search({ query: "authentication flow", topK: 5 })
```

### Anti-Drift Configuration

For coding tasks, always use anti-drift settings:

```javascript
swarm_init({
  topology: "hierarchical",  // single coordinator enforces alignment
  maxAgents: 6-8,           // smaller team = less drift
  strategy: "specialized"     // clear roles, no overlap
})
```

### 3-Tier Cost Routing

| Complexity | Handler | Speed | Cost |
|------------|---------|-------|------|
| Simple | WASM Transform | <1ms | Free |
| Medium | Haiku/Sonnet | ~500ms | Low |
| Complex | Opus + Swarm | 2-5s | High |

### Team Workflow Example

```bash
# 1. Start OpenCode with ruflo MCP
opencode

# 2. Use swarm for complex feature
# In OpenCode, invoke:
@ruflo swarm_init --topology hierarchical --maxAgents 4

# 3. Route simple tasks to WASM
# Use ruflo_transform for: var→const, add-types, remove-console

# 4. Store successful patterns
@ruflo memory_store --key "feature-x" --value "pattern details"
```

### Key MCP Tools

| Tool | Purpose |
|------|---------|
| `swarm_init` | Initialize agent swarm |
| `agent_spawn` | Spawn specialized agents |
| `memory_search` | Semantic vector search |
| `memory_store` | Save learned patterns |
| `hooks_route` | Intelligent task routing |
| `ruflo_transform` | WASM code transforms |

### Documentation

- [Ruflo GitHub](https://github.com/ruvnet/ruflo)
- [Full Documentation](https://github.com/ruvnet/ruflo#readme)

---

## Team Deployment

### For New Team Members

```bash
# 1. Clone the repo
git clone <your-repo> ~/.config/opencode

# 2. Install jq (for sync script)
sudo apt install jq    # Linux
brew install jq         # macOS

# 3. Check provider status
./sync-secrets.sh

# 4. Set your MCP env vars (if using Stitch)
export STITCH_API_KEY="your-key"

# 5. Start OpenCode
opencode
```

### For Team Lead

```bash
# 1. Update opencode.json with new provider
# 2. Commit
git add opencode.json
git commit -m "Add myprovider model config"

# 3. Team members pull and add their own API keys to auth.json
```

---

## File Reference

| File | Location | Git-tracked? | Purpose |
|------|----------|--------------|---------|
| `opencode.json` | `~/.config/opencode/` | ✅ Yes | Provider configs, models, MCP settings |
| `auth.json` | `~/.local/share/opencode/` | ❌ No | API keys (personal, private) |
| `opencode.secrets.json` | `~/.config/opencode/` | ⚠️ Template | MCP header env var templates (gitignored) |

---

## Common Providers Setup

### LongCat
```bash
# Get key from: https://longcat.chat
echo '{
  "longcat": {
    "type": "api",
    "key": "ak_your_key"
  }
}' >> ~/.local/share/opencode/auth.json
```

```json
// opencode.json
"model": "longcat/LongCat-Flash-Chat"
```

### Mistral
```bash
# Get key from: https://console.mistral.ai
echo '{
  "mistral": {
    "type": "api",
    "key": "your_mistral_key"
  }
}' >> ~/.local/share/opencode/auth.json
```

```json
// opencode.json
"model": "mistral/mistral-large-latest"
```

### OpenRouter
```bash
# Get key from: https://openrouter.ai/keys
echo '{
  "openrouter": {
    "type": "api",
    "key": "sk-or-your_key"
  }
}' >> ~/.local/share/opencode/auth.json
```

```json
// opencode.json
"provider": {
  "openrouter": {
    "npm": "@ai-sdk/openai-compatible",
    "name": "OpenRouter",
    "options": {
      "baseURL": "https://openrouter.ai/api/v1"
    },
    "models": {
      "openrouter/claude-3-5-sonnet": {
        "name": "claude-3.5-sonnet"
      }
    }
  }
}
```

---

## Troubleshooting

### "Provider not found" error
- Make sure provider name in `auth.json` matches `opencode.json`
- Example: `"longcat"` in auth.json must match `"provider": { "longcat": ... }`

### "Invalid API key" error
- Check key is correct in `auth.json`
- Ensure no extra spaces or quotes

### MCP server not working
- Verify env var is set: `echo $STITCH_API_KEY`
- Restart OpenCode after setting env vars

### Model not available
- Check model name matches exactly in `models` config
- Verify provider API supports the model

---

## Security Notes

- ❌ Never commit `auth.json` to git
- ❌ Never put real API keys in `opencode.json`
- ✅ Use `{env:VARIABLE_NAME}` syntax for secrets in config
- ✅ Use private repo if sharing any credentials
- ✅ Rotate API keys regularly
