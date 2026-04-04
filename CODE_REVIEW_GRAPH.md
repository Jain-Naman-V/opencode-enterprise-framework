# Code Review Graph Integration

## Overview

**`code-review-graph`** is a powerful tool that builds a local knowledge graph of your codebase using Tree-sitter, providing AI coding assistants (like OpenCode) with precise contextual information. This dramatically reduces token usage while improving code review quality.

## Key Benefits

### Token Reduction
- **6.8x fewer tokens** on code reviews (average)
- **49x fewer tokens** on daily coding tasks (monorepos)
- Replaces reading entire files with compact structural context

### Features
- **Blast-radius analysis**: Shows exactly which functions/classes/files are affected by changes
- **Incremental updates**: <2 seconds for 2,900+ file projects
- **19 languages + Jupyter** support
- **22 MCP tools** for AI assistants
- **5 workflow prompts**: review, architecture, debug, onboard, pre-merge

## Installation

### Global Installation (recommended for organization-wide use)

```bash
# Install via pip
pip install code-review-graph

# Or via pipx (better isolation)
pipx install code-review-graph

# Then install for OpenCode
code-review-graph install --platform opencode
```

### Project-level Installation

```bash
# Add to project
pip install code-review-graph

# Build the graph
code-review-graph build

# The MCP server will be available when OpenCode starts
```

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                    CODE-REVIEW-GRAPH FLOW                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Your Codebase                                                  │
│       │                                                         │
│       ▼                                                         │
│  ┌─────────────┐    Tree-sitter AST    ┌─────────────┐          │
│  │   Files    │ ─────────────────────▶ │   Graph    │          │
│  │  (.py, .js │                        │  (SQLite)  │          │
│  │   .go,...) │                        │             │          │
│  └─────────────┘                       └──────┬──────┘          │
│                                               │                 │
│                                               ▼                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    MCP SERVER                             │   │
│  │  • get_impact_radius_tool    • get_review_context_tool   │   │
│  │  • query_graph_tool          • detect_changes_tool      │   │
│  │  • semantic_search_nodes_tool • list_flows_tool          │   │
│  └─────────────────────────────────────────────────────────┘   │
│       │                                                         │
│       ▼                                                         │
│  ┌─────────────┐    Token-optimized   ┌─────────────┐          │
│  │  OpenCode   │ ◀──────────────────── │   Minimal  │          │
│  │             │                      │    Files   │          │
│  └─────────────┘                      └─────────────┘          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## MCP Tools Available

| Tool | Description |
|------|-------------|
| `build_or_update_graph_tool` | Build or incrementally update the graph |
| `get_impact_radius_tool` | Blast radius of changed files |
| `get_review_context_tool` | Token-optimized review context |
| `query_graph_tool` | Callers, callees, tests, imports queries |
| `semantic_search_nodes_tool` | Search code entities by name/meaning |
| `detect_changes_tool` | Risk-scored change impact analysis |
| `list_flows_tool` | List execution flows sorted by criticality |
| `get_community_tool` | Get details of code community |

## Usage in OpenCode

Once installed, the graph is built automatically. When working on a project:

```bash
# First time: Build the graph
code-review-graph build

# Or ask OpenCode directly:
# "Build the code review graph for this project"
```

Then use in OpenCode:
```
/code-review-graph:review-delta   # Review changes since last commit
/code-review-graph:review-pr       # Full PR review with blast-radius
```

## Configuration

### Exclude paths from indexing

Create `.code-review-graphignore` in project root:

```
generated/**
*.generated.ts
vendor/**
node_modules/**
```

### Optional dependencies

```bash
pip install code-review-graph[embeddings]    # Local vector embeddings
pip install code-review-graph[google-embeddings]  # Google Gemini
pip install code-review-graph[communities]   # Community detection
pip install code-review-graph[wiki]          # Wiki generation
pip install code-review-graph[all]           # All features
```

## Organization Benefits

### For Development Teams
- **Faster code reviews**: AI reads only what's relevant
- **Better context**: Blast-radius analysis ensures nothing is missed
- **Lower costs**: 6-49x token reduction = significant API savings

### For Enterprise
- **No data leaving**: All processing is local (SQLite)
- **Multi-repo support**: Register and search across repos
- **Consistent quality**: Structured analysis vs. ad-hoc reading

## Integration Status

✅ **Installed in OpenCode config** (`~/.config/opencode/opencode.json`)

✅ **MCP server configured** - Auto-starts with OpenCode

✅ **Watcher updated** - Excludes `.code-review-graph/**` directory

## Verification

Check that code-review-graph is working:

```bash
# Check MCP status in OpenCode
# The code-review-graph server should be listed as connected

# Verify graph exists
code-review-graph status
```

## Performance Benchmarks

| Repo | Files | Build Time | Search Latency | Token Reduction |
|------|-------|------------|----------------|-----------------|
| express | 141 | ~2s | 0.7ms | 0.7x* |
| fastapi | 1,122 | ~10s | 1.5ms | 8.1x |
| flask | 83 | ~1s | 0.7ms | 9.1x |
| gin | 99 | ~1s | 0.5ms | 16.4x |
| httpx | 60 | ~1s | 0.4ms | 6.9x |
| nextjs | 27,700+ | ~30s | 2ms | 49x |

*Note: Graph overhead only pays off on multi-file changes

## Additional Resources

- Website: https://code-review-graph.com
- GitHub: https://github.com/tirth8205/code-review-graph
- Discord: https://discord.gg/3p58KXqGFN