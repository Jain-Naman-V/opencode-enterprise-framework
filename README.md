# OpenCode AI Coding Agent - Team Configuration

> Production-ready OpenCode setup with multiple AI providers, custom agents, and team collaboration features. A Claude-like system for developer teams.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenCode](https://img.shields.io/badge/OpenCode-AI%20Coding%20Agent-blue)](https://opencode.ai)
[![GitHub](https://img.shields.io/badge/Platform-GitHub-green)](https://github.com)

---

## 🔥 Features

- **Multiple AI Providers** - Switch between LongCat, Mistral, Clod, and more
- **Custom Agents** - Pre-configured agents for code review, security audits, debugging, refactoring, and documentation
- **MCP Server Support** - Canva Dev, Stitch, code-review-graph, and Ruflo orchestration
- **Ruflo Integration** - Multi-agent swarms, self-learning memory, 30-50% token optimization
- **Team Collaboration** - Shareable config via Git for team-wide consistency
- **Security First** - API keys managed separately, never committed to repo

---

## 🚀 Quick Start

```bash
# Clone this repo
git clone <your-repo-url> ~/.config/opencode

# Install dependencies
sudo apt install jq    # Linux
brew install jq         # macOS

# Check provider status
./sync-secrets.sh

# Start coding with AI
opencode
```

---

## 📋 Prerequisites

- [OpenCode](https://opencode.ai) installed
- API keys from your preferred providers (see below)
- `jq` for JSON processing

---

## 🔑 Supported AI Providers

| Provider | Model | Description |
|----------|-------|-------------|
| **LongCat** | LongCat Flash Chat | Fast, cost-effective |
| **Mistral** | Mistral Large | High quality reasoning |
| **Clod** | DeepSeek V3, Trinity Mini | Multiple model options |
| **OpenRouter** | Claude, GPT, Gemini | Unified API access |
| **NVIDIA NIM** | Various NIMs | GPU-accelerated |
| **Cerebras** | Llama models | Fast inference |

### Adding a New Provider

```bash
# 1. Add API key to auth.json
nano ~/.local/share/opencode/auth.json
# Add: { "provider": { "type": "api", "key": "your-key" } }

# 2. Add config to opencode.json
# Add provider under "provider" section with baseURL and models

# 3. Set as active model
# Update "model" field in opencode.json

# 4. Verify
./sync-secrets.sh
opencode
```

---

## 🤖 Custom Agents

Pre-built agents for specialized tasks:

| Agent | Purpose |
|-------|---------|
| `code-reviewer` | Reviews code for best practices, bugs, security |
| `security-auditor` | Identifies vulnerabilities and security risks |
| `debugger` | Investigates and fixes issues |
| `refactor` | Improves code quality and structure |
| `docs-writer` | Creates and maintains documentation |

### Using Agents

```
# In OpenCode, invoke agents directly:
/review      # Code review
/audit       # Security audit
/debug       # Debug an issue
/refactor    # Refactor code
/docs        # Generate docs
```

---

## 🔧 MCP Server Integration

### Stitch (Google AI)
```bash
export STITCH_API_KEY="your-stitch-key"
```

### Canva Dev
```bash
# Runs locally via npx
# No API key needed
```

### Code Review Graph
```bash
# Runs locally
# Provides code analysis and refactoring tools
```

### Ruflo (AI Orchestration)
```bash
# Auto-starts via MCP when OpenCode runs
# Provides 100+ agents, swarm coordination, and self-learning

# Key capabilities:
# - Multi-agent swarms for complex tasks
# - HNSW vector memory for pattern learning
# - WASM transforms for free instant edits
# - 30-50% token optimization

# Use cases:
npx ruflo@latest hive-mind spawn "Implement user authentication"
npx ruflo@latest agent spawn -t coder
```

---

## 📁 Project Structure

```
~/.config/opencode/
├── opencode.json           # Main config (git-tracked)
├── auth.json              # API keys (local only, NOT git-tracked)
├── sync-secrets.sh        # Provider status checker
├── README.md              # This file
├── SETUP.md               # Detailed setup guide
├── agents/                # Custom agent definitions
├── commands/              # Custom slash commands
├── skills/                # Agent skill configurations
├── swarm-workflows/       # Pre-built swarm templates
└── .gitignore            # Excludes secrets
```

---

## 🔒 Security

- **API keys never leave your machine** - stored in `~/.local/share/opencode/auth.json`
- **No secrets in git** - `.gitignore` excludes sensitive files
- **Environment variables** for MCP server headers
- **Per-machine configuration** - team shares config, each dev has own keys

---

## 👥 For Teams

### Team Lead
```bash
# Update config, commit changes
git add opencode.json
git commit -m "feat: add new model provider"
git push
```

### Team Members
```bash
# Pull latest config
git pull

# Add your API keys
nano ~/.local/share/opencode/auth.json

# Verify setup
./sync-secrets.sh
```

---

## 📚 Documentation

- [SETUP.md](./SETUP.md) - Detailed setup and configuration guide
- [OpenCode Docs](https://opencode.ai/docs) - Official OpenCode documentation

---

## 🔄 Commands Reference

```bash
./sync-secrets.sh          # Check provider status
opencode                   # Start OpenCode
```

---

## 💡 Tips

1. **Switch models easily** - Edit `model` field in `opencode.json`
2. **Add custom commands** - See `commands/` directory
3. **Extend agents** - Modify `agents/` definitions
4. **Use skills** - Invoke via `/skill <name>`

---

## 📝 License

MIT License - feel free to use and modify for your team.

---

## 🙏 Credits

Built with [OpenCode](https://opencode.ai) - The AI coding agent framework.

---

**Keywords:** OpenCode setup, AI coding agent, Claude-like system, developer AI framework, AI pair programmer, code review AI, automated code analysis, team development tools, AI coding assistant, LLM integration
