---
description: Compare Claude Code vs OpenCode commands - displays mapping table
---

# Claude Code vs OpenCode Command Comparison

## Quick Reference

| Claude Code | OpenCode | Purpose |
|:------------|:---------|:--------|
| **Session Management** | | |
| `claude` | `opencode` | Start interactive session |
| `claude "query"` | `opencode "query"` | Start with initial prompt |
| `claude -p "query"` | `opencode -p "query"` | Non-interactive/print mode |
| `claude -c` | `/sessions` or `/resume` | Continue last session |
| `claude -r "<session>"` | `/sessions` | Resume specific session |
| `claude --continue` | `/sessions` | Continue conversation |
| `claude --resume <id>` | `/sessions` | Resume by ID |
| **Slash Commands** | | |
| `/init` | `/init` | Initialize project |
| `/undo` | `/undo` | Undo last action |
| `/redo` | `/redo` | Redo undone action |
| `/clear` | `/new` | Clear/reset session |
| `/help` | `/help` | Show help |
| `/exit` | `/exit` | Exit program |
| `/quit` | `/exit` | Exit (alias) |
| `/share` | `/share` | Share session |
| `/sessions` | `/sessions` | List sessions |
| `/resume` | `/sessions` | Resume session |
| `/compact` | `/compact` | Compact context |
| `/summarize` | `/compact` | Summarize (alias) |
| `/export` | `/export` | Export conversation |
| `/doctor` | (via prompt) | Diagnostics |
| **Configuration** | | |
| `/config` | `/themes`, `/models` | Settings/preferences |
| `/settings` | `/themes`, `/models` | Settings (alias) |
| `/theme` | `/themes` | Change theme |
| `/model` | `/models` | Change model |
| **Git Integration** | | |
| `/diff` | Via tool | View changes |
| `/commit` | Via tool | Git commit |
| `/branch` | Via tool | Git branch |
| `claude commit` | `/commit` | Commit changes |
| **Tools & Extensions** | | |
| `/mcp` | MCP servers via config | MCP management |
| `/plugin` | Plugins via config | Plugin management |
| `/agents` | `/agents` (via config) | Subagent config |
| `/skills` | Agent Skills system | Skills management |
| **File Operations** | | |
| `@filename` | `@filename` | Reference file |
| `!bash command` | `!command` | Run shell command |
| **CLI Flags** | | |
| `--add-dir <path>` | `--add` | Add directory |
| `--model <model>` | `--model` | Set model |
| `--verbose` | Debug mode | Verbose output |
| `--debug` | Debug mode | Debug logging |
| `--version` | `--version` | Show version |
| `--bare` | (similar) | Minimal mode |
| `--help` | `--help` | Show help |
| **Additional Claude Code** | | |
| `/btw <question>` | Via prompt | Side question |
| `/color [color]` | Not available | Prompt color |
| `/context` | Via prompt | Context usage |
| `/copy [N]` | Via prompt | Copy response |
| `/cost` | Via prompt | Token usage |
| `/desktop` | Not available | Desktop app |
| `/effort [level]` | Not available | Effort level |
| `/extra-usage` | Not available | Extra usage |
| `/fast [on\|off]` | Not available | Fast mode |
| `/feedback [text]` | Via prompt | Send feedback |
| `/hooks` | Via config | Hooks config |
| `/ide` | IDE integration | IDE settings |
| `/insights` | Via prompt | Usage insights |
| `/keybindings` | `/keybinds` | Keybindings |
| `/login` | `/connect` | Authentication |
| `/logout` | (via prompt) | Sign out |
| `/memory` | AGENTS.md, CLAUDE.md | Memory files |
| `/mobile` | Not available | Mobile app |
| `/passes` | Not available | Share passes |
| `/permissions` | Via config | Permissions |
| `/plan [desc]` | Via prompt | Plan mode |
| `/powerup` | Not available | Tutorial |
| `/pr-comments [PR]` | Via prompt | PR comments |
| `/privacy-settings` | Via config | Privacy |
| `/release-notes` | Not available | Changelog |
| `/reload-plugins` | Via config | Reload plugins |
| `/remote-control` | Not available | Remote control |
| `/rename [name]` | Via prompt | Rename session |
| `/rewind` | `/undo` | Rewind state |
| `/sandbox` | Via config | Sandbox mode |
| `/schedule` | Not available | Scheduled tasks |
| `/security-review` | `/security-scan` | Security check |
| `/stats` | Via prompt | Usage stats |
| `/status` | Via prompt | Status info |
| `/statusline` | Via config | Status line |
| `/stickers` | Not available | Order stickers |
| `/tasks` | Via prompt | Background tasks |
| `/terminal-setup` | Via config | Terminal setup |
| `/ultraplan` | Not available | Ultra planning |
| `/upgrade` | Not available | Upgrade plan |
| `/usage` | Via prompt | Plan usage |
| `/vim` | Via config | Vim mode |
| `/voice` | Not available | Voice dictation |

## Feature Comparison

### Equivalent Features

| Feature | Claude Code | OpenCode |
|:--------|:------------|:---------|
| Project initialization | `/init` | `/init` |
| Context compaction | `/compact` | `/compact` |
| Session management | `/sessions`, `/resume` | `/sessions` |
| File referencing | `@filename` | `@filename` |
| Shell commands | `!command` | `!command` |
| Share session | `/share` | `/share` |
| Undo/Redo | `/undo`, `/redo` | `/undo`, `/redo` |
| Custom commands | Skills system | Commands system |
| MCP servers | `/mcp` | MCP config |
| Theme customization | `/theme` | `/themes` |
| Agent configuration | `/agents` | Agents config |
| Git integration | Built-in tools | Via tool |
| Help system | `/help` | `/help` |

### OpenCode-Specific

| Feature | How to Use |
|:--------|:-----------|
| Connect providers | `/connect` |
| Export to editor | `/export` |
| Toggle thinking | `/thinking` |
| Tool details | `/details` |
| Custom commands | `.opencode/commands/*.md` |
| Agent Skills | `.opencode/skills/*/SKILL.md` |
| Custom tools | `.opencode/tools/*.md` |
| Rules | `AGENTS.md` |
| MCP servers | `opencode.json` config |
| IDE integration | `/ide` |

### Claude Code-Specific

| Feature | Purpose |
|:--------|:--------|
| `/btw` | Side questions |
| `/color` | Prompt bar color |
| `/context` | Context visualization |
| `/effort` | Model effort level |
| `/fast` | Fast mode toggle |
| `/hooks` | Hook management |
| `/insights` | Session analytics |
| `/plan` | Plan mode |
| `/powerup` | Interactive tutorials |
| `/schedule` | Cloud scheduled tasks |
| `/security-review` | Security analysis |
| `/ultraplan` | Browser-based planning |
| `/voice` | Voice dictation |
| Agent teams | Multi-agent coordination |
| Remote Control | Control from web |

## Key Differences

### Session Management
- **Claude Code**: Uses session IDs, names, `-r` flag
- **OpenCode**: Uses `/sessions` command, Git-based undo

### Configuration
- **Claude Code**: `~/.claude/`, `CLAUDE.md`, settings files
- **OpenCode**: `~/.config/opencode/`, `opencode.json`, `AGENTS.md`

### Custom Commands
- **Claude Code**: Skills (`/skills`) with SKILL.md
- **OpenCode**: Commands (`/commands`) with markdown files

### Authentication
- **Claude Code**: `claude auth login`, `/login`
- **OpenCode**: `/connect` command

## Resources

- Claude Code Docs: https://code.claude.com/docs/en/overview
- OpenCode Docs: https://opencode.ai/docs

---
*Generated for quick reference - commands may vary by version*
