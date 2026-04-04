# Claude Code vs OpenCode - Gap Analysis & Enhancement Plan

## 1. Claude Code Architecture Deep Dive

### 1.1 Prompt Orchestration System
Claude Code uses a sophisticated layered system prompt architecture:

- **SystemPrompt Type**: Branded type `readonly string[] & { __brand: 'SystemPrompt' }`
- **Section-based composition**: Modular sections that can be cached/uncached
- **Priority layering**:
  1. Override system prompt (REPLACES all)
  2. Coordinator system prompt
  3. Agent system prompt (custom or built-in)
  4. Custom --system-prompt flag
  5. Default system prompt
- **appendSystemPrompt**: Always added at end (except when override set)
- **Cache management**: `systemPromptSection()` for memoized sections, `DANGEROUS_uncachedSystemPromptSection()` for volatile data
- **Cache clearing**: On `/clear` and `/compact` commands

### 1.2 Tool Usage Architecture
Claude Code has 40+ specialized tools across categories:

**Core Tools:**
- File operations: FileReadTool, FileWriteTool, FileEditTool, GlobTool, GrepTool
- Terminal: BashTool, PowerShellTool
- Code intelligence: LSPTool, ToolSearchTool
- Web: WebFetchTool, WebSearchTool
- Agent management: TaskCreateTool, TaskGetTool, TaskListTool, TaskStopTool, TaskUpdateTool, TaskOutputTool
- Team management: TeamCreateTool, TeamDeleteTool
- Scheduling: ScheduleCronTool (CronCreateTool, CronDeleteTool, CronListTool)
- MCP integration: MCPTool, ListMcpResourcesTool, ReadMcpResourceTool, McpAuthTool
- Planning: EnterPlanModeTool, ExitPlanModeTool
- Special: AgentTool, SkillTool, REPLTool, NotebookEditTool

**Tool Execution Flow:**
1. Tool permission checking (PermissionMode: 'default', 'auto', 'bypassPermissions', 'plan', 'acceptEdits', 'dontAsk')
2. Tool validation against schema
3. Execution with progress tracking
4. Result storage and budget management

### 1.3 Memory & Context Handling
- **MEMORY.md**: Project-specific memory loaded on startup
- **Auto-memory**: Learns build commands, debugging patterns across sessions
- **System prompt sections**: Cached components for performance
- **Context compaction**: Automatic summarization when context fills
- **Token budgeting**: Per-turn and total session budgets

### 1.4 Agent Workflows
- **Primary agents**: Build, Plan - selectable via Tab key
- **Subagents**: General (multi-step tasks), Explore (read-only exploration)
- **Custom agents**: Defined via JSON or markdown files
- **Agent spawning**: Task tool can spawn subagents
- **Permission inheritance**: Subagents inherit parent permissions with overrides

### 1.5 Safety & Guardrails
- **Permission modes**: Multiple enforcement levels
- **Permission rules**: Pattern-based allow/deny/ask
- **Tool result budget**: Prevents huge outputs from consuming context
- **Auto-compaction**: Prevents context overflow
- **Session state validation**: Prevents corrupted state

### 1.6 Key Design Patterns

1. **Feature flags**: `feature('FEATURE_NAME')` for conditional code loading
2. **Lazy requires**: Break circular dependencies, dead code elimination
3. **Type branding**: Prevent type confusion errors
4. **Section caching**: Performance optimization for expensive computations
5. **Permission layering**: User → Project → Local precedence
6. **Tool permission context**: Runtime permission evaluation per tool

---

## 2. Gap Analysis: OpenCode vs Claude Code

### 2.1 Missing Features in OpenCode

| Category | Claude Code Feature | OpenCode Status |
|----------|-------------------|-----------------|
| **System Prompt** | Section-based modular prompts | Basic instructions array |
| **Memory** | MEMORY.md + auto-memory | Instructions from files |
| **Agents** | Built-in + custom + subagents | Basic agent config |
| **Tasks** | Full task lifecycle management | Limited task support |
| **Team/Cron** | Team + Cron scheduling | Not found |
| **MCP** | Full MCP lifecycle | Basic MCP config |
| **Permissions** | Pattern-based rules | Basic allow/ask/deny |
| **Compaction** | Auto + reactive + snip | Basic compaction |

### 2.2 Weak Areas in OpenCode

1. **Limited agent customization**: Only basic prompt + tools
2. **No task orchestration**: Can't spawn subagents for parallel work
3. **Basic permissions**: No pattern-based bash commands
4. **No memory system**: No auto-learning across sessions
5. **Limited command system**: Basic template + description only

### 2.3 Opportunities for Improvement

1. **Enhanced system prompt**: Add section-based architecture
2. **Memory integration**: Support MEMORY.md + CLAUDE.md patterns
3. **Advanced permissions**: Pattern matching for bash commands
4. **Task improvements**: Add task spawning capability
5. **Better hooks**: Pre/post execution hooks for automation

---

## 3. OpenCode Global Setup - Complete Design

### 3.1 System Prompt Strategy

```
Priority:
1. CLAUDE.md (project or global)
2. AGENTS.md (project instructions)
3. Built-in OpenCode instructions
4. appendSystemPrompt for session-specific context
```

### 3.2 Tool Definitions
- Core: read, edit, write, glob, grep, bash
- Web: webfetch, websearch
- Productivity: todo, skill
- Integration: mcp servers

### 3.3 Memory System
- Project: AGENTS.md + CLAUDE.md
- Global: ~/.config/opencode/CLAUDE.md
- Skills: ~/.config/opencode/skills/

### 3.4 Agent Workflows
- Build: Full tool access
- Plan: Read-only analysis
- Custom: Specialized subagents

### 3.5 Error Handling
- Retry logic for API calls
- Graceful degradation
- Clear error messages

### 3.6 Context Management
- Compaction on token limit
- Pruning old tool outputs
- Reserved token buffer