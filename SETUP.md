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
