# Ruflo in OpenCode - Usage Guide

## Overview

Ruflo adds multi-agent orchestration, self-learning memory, and swarm coordination to OpenCode via MCP.

## Prerequisites

```bash
# Install ruflo
curl -fsSL https://cdn.jsdelivr.net/gh/ruvnet/ruflo@main/scripts/install.sh | bash -s -- --global --minimal

# Verify
ruflo --version
```

---

## How to Use in OpenCode

### Method 1: Natural Language (Recommended)

**DO NOT use `@ruflo`**. Just use natural language:

```
use ruflo to spawn a coder agent
use ruflo tools to search memory for "authentication patterns"
use ruflo to start a swarm for "build user API"
```

### Method 2: Direct Commands (CLI)

```bash
# Initialize ruflo in your project
ruflo init

# Start MCP server (OpenCode auto-starts it)
ruflo mcp start

# Check status
ruflo status
```

---

## Available Tools (50+)

When you say "use ruflo", OpenCode has access to these tools:

### Agent Tools
- `agent_spawn` - Spawn specialized agent
- `agent_list` - List all agents
- `agent_status` - Check agent status
- `agent_terminate` - Stop an agent

### Swarm Tools
- `swarm_init` - Initialize swarm
- `swarm_status` - Check swarm status
- `swarm_shutdown` - Stop swarm

### Memory Tools
- `memory_store` - Save pattern to memory
- `memory_search` - Semantic search
- `memory_retrieve` - Get stored value
- `memory_list` - List all memories

### Hooks Tools
- `hooks_route` - Intelligent routing
- `hooks_pre_task` - Before task hooks
- `hooks_post_task` - After task hooks

### Config Tools
- `config_get` - Get config value
- `config_set` - Set config value

---

## Practical Examples

### In OpenCode (Natural Language)

Just tell OpenCode what you want:

```
use ruflo to spawn a coder agent for backend development

use ruflo tools to initialize a swarm for implementing user authentication

search memory for "JWT authentication patterns" using ruflo

use ruflo to store this pattern: key="auth-flow", value="JWT refresh token implementation"

use ruflo to run a security scan on the codebase
```

### CLI Commands (Alternative)

```bash
# Agent Management
ruflo agent spawn -t coder --name my-coder
ruflo agent list
ruflo agent status <agent-id>

# Swarm Coordination
ruflo swarm init
ruflo swarm start -o "Implement user authentication"
ruflo swarm status

# Memory
ruflo memory store -k "auth-pattern" -v "JWT implementation"
ruflo memory search -q "authentication flow"
ruflo memory list

# Security
ruflo security scan
```

### Swarm Workflows
```

### 3. Memory (Self-Learning)

```bash
# Initialize memory
ruflo memory init

# Store a pattern
ruflo memory store -k "auth-pattern" -v "JWT refresh token implementation"

# Search memory
ruflo memory search -q "authentication flow"

# List all memories
ruflo memory list

# Show stats
ruflo memory stats
```

### 4. Code Analysis

```bash
# Analyze code
ruflo analyze --path ./src

# Check implementation progress
ruflo progress
```

### 5. Security Scanning

```bash
# Run security scan
ruflo security scan

# Check for CVEs
ruflo security cve-check
```

### 6. Performance

```bash
# Run benchmark
ruflo performance benchmark

# Show metrics
ruflo performance metrics
```

---

## Swarm Workflows (Practical Examples)

### Feature Development Swarm

```bash
# Initialize swarm
ruflo swarm init --topology hierarchical --max-agents 4

# Start with objective
ruflo swarm start -o "Add REST API for users"

# Monitor
ruflo swarm status
```

### Bug Fix Swarm

```bash
ruflo swarm start -o "Fix login bug" --topology mesh
```

### Security Audit Swarm

```bash
ruflo swarm start -o "Audit authentication module" --consensus byzantine
```

---

## MCP Tools Available in OpenCode

When ruflo MCP is running, these tools are available:

| Category | Tools |
|----------|-------|
| **Swarm** | `swarm_init`, `swarm_start`, `swarm_status`, `swarm_stop` |
| **Agents** | `agent_spawn`, `agent_list`, `agent_status`, `agent_stop` |
| **Memory** | `memory_store`, `memory_search`, `memory_retrieve`, `memory_list` |
| **Security** | `security_scan`, `security_cve_check`, `security_audit` |
| **Analysis** | `analyze_code`, `classify_diff`, `check_boundaries` |
| **Performance** | `benchmark`, `metrics`, `optimize` |

---

## Anti-Drift Settings (Recommended)

Always use for coding tasks:

```javascript
swarm_init({
  topology: "hierarchical",  // Queen → workers
  maxAgents: 6-8,           // Smaller = less drift
  strategy: "specialized"     // Clear roles
})
```

---

## 3-Tier Cost Routing

| Task | Handler | Speed | Cost |
|------|---------|-------|------|
| Simple transforms | WASM | <1ms | Free |
| Medium tasks | Haiku/Sonnet | ~500ms | Low |
| Complex | Opus + Swarm | 2-5s | High |

---

## Tips

1. **Initialize first**: Run `ruflo init` in your project before using
2. **Use memory**: Store successful patterns for future reference
3. **Start small**: Try single agents before swarms
4. **Check status**: Use `ruflo status` to see system health

---

## Troubleshooting

```bash
# Check if ruflo is running
ruflo status

# Run diagnostics
ruflo doctor

# Check MCP logs
ruflo mcp logs

# Restart MCP
ruflo mcp restart
```

---

## More Info

- [Ruflo GitHub](https://github.com/ruvnet/ruflo)
- Full docs: `ruflo --help`
- Command help: `ruflo <command> --help`
