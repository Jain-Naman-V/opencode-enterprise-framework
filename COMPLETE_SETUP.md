# Claude Code vs OpenCode: Architecture Deep Analysis & Production Setup

## Executive Summary

This document provides an in-depth analysis of Anthropic Claude Code's architecture and a comprehensive implementation plan to configure OpenCode for production-grade developer experience matching or exceeding Claude Code capabilities.

---

# 1. Deep Analysis: Claude Code Architecture

## 1.1 Prompt Orchestration System

Claude Code uses a sophisticated **section-based modular system prompt architecture** that enables high performance and cacheability.

### Key Components:

```
┌─────────────────────────────────────────────────────────────────┐
│                    SYSTEM PROMPT LAYERING                       │
├─────────────────────────────────────────────────────────────────┤
│  Priority 1: Override System Prompt (REPLACES all)             │
│  Priority 2: Coordinator System Prompt (if coordinator mode)  │
│  Priority 3: Agent System Prompt (custom or built-in)           │
│  Priority 4: Custom --system-prompt flag                        │
│  Priority 5: Default Claude Code Prompt                        │
│  + appendSystemPrompt (always at end unless override set)       │
└─────────────────────────────────────────────────────────────────┘
```

### System Prompt Type (from `systemPromptType.ts`):
```typescript
export type SystemPrompt = readonly string[] & {
  readonly __brand: 'SystemPrompt'
}
```

### Section Architecture (from `systemPromptSections.ts`):
- **Cached sections**: Memoized via `systemPromptSection(name, compute)`
- **Uncached sections**: Via `DANGEROUS_uncachedSystemPromptSection(name, compute, reason)`
- **Cache clearing**: On `/clear` and `/compact` commands

### Key Sections in Default Prompt:
1. **Intro Section**: Model identity, output style
2. **System Section**: Tool usage rules, permission modes
3. **Doing Tasks Section**: Code style guidelines, task approach
4. **Executing Actions Section**: Safety guidelines, confirmation prompts
5. **Using Tools Section**: Tool preferences, parallel execution
6. **Session-specific Guidance**: Dynamic content (post dynamic boundary)
7. **Memory Section**: MEMORY.md content (cached)
8. **MCP Instructions**: Server capabilities

### Performance Optimization:
- Static vs Dynamic boundary (`SYSTEM_PROMPT_DYNAMIC_BOUNDARY`)
- Global cache scope for static content
- Blake2b prefix hashing for cache variants

---

## 1.2 Tool Usage Architecture

Claude Code has **40+ specialized tools** organized by category:

### Core Tools:
| Category | Tools |
|----------|-------|
| **File Operations** | FileReadTool, FileWriteTool, FileEditTool, GlobTool, GrepTool |
| **Terminal** | BashTool, PowerShellTool |
| **Code Intelligence** | LSPTool, ToolSearchTool |
| **Web** | WebFetchTool, WebSearchTool |
| **Agent Management** | AgentTool, TaskCreateTool, TaskGetTool, TaskListTool, TaskStopTool, TaskUpdateTool |
| **Team** | TeamCreateTool, TeamDeleteTool |
| **Scheduling** | CronCreateTool, CronDeleteTool, CronListTool |
| **MCP** | MCPTool, ListMcpResourcesTool, ReadMcpResourceTool, McpAuthTool |
| **Planning** | EnterPlanModeTool, ExitPlanModeTool |
| **Special** | SkillTool, REPLTool, NotebookEditTool |

### Tool Execution Flow:
```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────┐
│   Tool Call │ -> │   Permission │ -> │  Validation │ -> │  Execution  │
│   Request   │    │    Check     │    │    Against  │    │   with      │
│             │    │  (Mode-based)│    │    Schema  │    │  Progress   │
└─────────────┘    └──────────────┘    └─────────────┘    └─────────────┘
       │                                                     │
       v                                                     v
┌─────────────┐                                      ┌─────────────┐
│   Result    │                                      │   Budget    │
│   Storage   │                                      │  Management │
└─────────────┘                                      └─────────────┘
```

### Permission Modes:
```typescript
const EXTERNAL_PERMISSION_MODES = [
  'acceptEdits',   // Allow edits without prompting
  'bypassPermissions', // Skip all permission checks
  'default',       // Standard prompt-based
  'dontAsk',       // Never prompt, auto-deny
  'plan',          // Read-only planning mode
] as const

// Internal modes:
type InternalPermissionMode = ExternalPermissionMode | 'auto' | 'bubble'
```

---

## 1.3 Memory and Context Handling

### Memory System Architecture:

```
┌─────────────────────────────────────────────────────────────────┐
│                      MEMORY HIERARCHY                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐     │
│  │   MEMORY.md  │    │  Auto-Memory │    │ Session      │     │
│  │  (Project)   │    │  (Learns     │    │ Context      │     │
│  │              │    │   across     │    │              │     │
│  │              │    │   sessions)  │    │              │     │
│  └──────────────┘    └──────────────┘    └──────────────┘     │
│        │                   │                   │              │
│        v                   v                   v              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              System Prompt Sections (Cached)            │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### MEMORY.md Features:
- Entrypoint: `MEMORY.md` at project root
- Max lines: 200 lines
- Max bytes: 25,000 bytes
- Truncation warnings with reasons
- Index entries: One line, ~200 chars max
- Detail in topic files

### Auto-Memory:
- Learns build commands
- Remembers debugging patterns
- Cross-session persistence

### Context Compaction:
- **Auto-compaction**: Summarization when context fills
- **Reactive compact**: Incremental compaction
- **Snip compact**: History trimming
- **Token budgeting**: Per-turn and total session budgets

---

## 1.4 Agent Workflows

### Built-in Agents:

```
┌─────────────────────────────────────────────────────────────────┐
│                       AGENT HIERARCHY                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   PRIMARY AGENTS (Selectable via Tab key)                       │
│   ├── Build Agent - Full tool access                             │
│   └── Plan Agent  - Read-only analysis                           │
│                                                                  │
│   SUBAGENTS (via @agent tool)                                   │
│   ├── General    - Multi-step tasks                             │
│   ├── Explore    - Read-only codebase exploration               │
│   └── Custom     - User-defined agents                          │
│                                                                  │
│   FORKS - Background execution                                  │
│   └── Run in background, keep main context clean                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Agent Definition Interface:
```typescript
interface AgentDefinition {
  agentType: string
  description: string
  mode: 'primary' | 'subagent'
  getSystemPrompt(): string
  getTools?(): Tool[]
  permission?: PermissionConfig
  memory?: string // 'project' | 'session'
}
```

### Task Lifecycle:
- **TaskCreate**: Spawn new tasks
- **TaskUpdate**: Modify status, assign
- **TaskList**: View all tasks
- **TaskGet**: Detailed task info
- **TaskStop**: Cancel running tasks

---

## 1.5 Safety and Guardrails

### Safety Architecture:

```
┌─────────────────────────────────────────────────────────────────┐
│                      SAFETY LAYERS                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  1. Permission System                                    │   │
│  │     ├── Mode-based enforcement                           │   │
│  │     ├── Pattern-based rules (allow/deny/ask)            │   │
│  │     └── Tool result budget                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  2. Action Safety                                        │   │
│  │     ├── Destructive operation warnings                   │   │
│  │     ├── Confirmation prompts for risky actions          │   │
│  │     └── Authorization scope tracking                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  3. Context Safety                                       │   │
│  │     ├── Auto-compaction prevents overflow               │   │
│  │     ├── Session state validation                         │   │
│  │     └── Prompt injection detection                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Safety Features:
1. **Confirmation prompts** for destructive actions
2. **Permission rules** with pattern matching
3. **Tool result budget** prevents huge outputs
4. **Context overflow protection** via compaction
5. **Prompt injection detection** in tool results

---

## 1.6 Key Design Patterns

### 1. Feature Flags
```typescript
const feature = require('bun:bundle')
const proactiveModule = feature('PROACTIVE')
  ? require('../proactive/index.js')
  : null
```

### 2. Lazy Requires
- Break circular dependencies
- Dead code elimination
- Feature-gated imports

### 3. Type Branding
```typescript
type SystemPrompt = readonly string[] & {
  readonly __brand: 'SystemPrompt'
}
```

### 4. Section Caching
- Performance optimization
- Cache invalidation strategies

### 5. Permission Layering
- User → Project → Local precedence
- Pattern-based matching

---

# 2. Gap Analysis: OpenCode vs Claude Code

## 2.1 Feature Comparison Matrix

| Category | Claude Code Feature | OpenCode Status | Gap Severity |
|----------|-------------------|-----------------|--------------|
| **System Prompt** | Section-based modular, cached | Basic instructions array | HIGH |
| **Memory** | MEMORY.md + auto-memory | Instructions from files | HIGH |
| **Agents** | Built-in + custom + subagents + forks | Basic agent config | MEDIUM |
| **Tasks** | Full task lifecycle management | Limited task support | HIGH |
| **Team/Cron** | Team + Cron scheduling | Not available | HIGH |
| **MCP** | Full MCP lifecycle | Basic MCP config | MEDIUM |
| **Permissions** | 6 modes + pattern rules | 3 modes (allow/ask/deny) | MEDIUM |
| **Compaction** | Auto + reactive + snip | Basic compaction | MEDIUM |
| **Tools** | 40+ specialized tools | Core tools only | MEDIUM |
| **Skills** | Discovery + invocation | Basic skill system | LOW |

## 2.2 Weak Areas in OpenCode

1. **Limited agent customization**: Only basic prompt + tools
2. **No task orchestration**: Can't spawn subagents for parallel work
3. **Basic permissions**: No pattern-based bash commands
4. **No memory system**: No auto-learning across sessions
5. **Limited command system**: Basic template + description only
6. **No fork/background execution**: Single-threaded work

## 2.3 Opportunities for Improvement

1. **Enhanced system prompt**: Add section-based architecture
2. **Memory integration**: Support MEMORY.md + CLAUDE.md patterns
3. **Advanced permissions**: Pattern matching for bash commands
4. **Task improvements**: Add task spawning capability
5. **Better hooks**: Pre/post execution hooks for automation

---

# 3. OpenCode Global Setup Design

## 3.1 System Prompts (High-Performance, Modular)

### Architecture:
```
┌─────────────────────────────────────────────────────────────────┐
│              OPENCODE SYSTEM PROMPT LAYERING                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PRIORITY (applied in order):                                   │
│  ─────────────────────────────────────────────────────────────  │
│  1. CLAUDE.md (project root) - Project-specific instructions    │
│  2. AGENTS.md (project root) - Agent behavior guidelines         │
│  3. Global CLAUDE.md (~/.config/opencode/) - Global rules       │
│  4. Built-in OpenCode instructions                               │
│  5. appendSystemPrompt - Session-specific context               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Implementation:

**`~/.config/opencode/CLAUDE.md`** (Global Instructions):
```markdown
# Global OpenCode Instructions

## Core Principles
- Be proactive but not surprising - ask before significant actions
- Prefer small, reviewable changes over large rewrites
- Always verify changes work before considering complete
- Follow existing code patterns and conventions

## Code Quality Guidelines
- Write clean, readable code with proper type annotations
- Add comments only when code is non-obvious
- Prefer composition over inheritance
- Keep functions small and focused

## Tool Usage Priority
1. Use dedicated tools (read, edit, write) over bash
2. Use parallel tool calls for independent operations
3. Use Task tool for multi-step workflows

## Safety Guidelines
- Confirm before destructive operations (rm, git reset --hard)
- Ask before running commands that modify git history
- Use permission prompts for risky operations
- Validate external URLs before using

## Verification Checklist
- [ ] Run relevant tests
- [ ] Verify lint/format checks pass
- [ ] Check compilation succeeds
- [ ] Review diff for unintended changes
```

---

## 3.2 Tool Definitions

### Core Tools Configuration:

```json
{
  "tools": {
    "file": {
      "read": true,
      "write": true,
      "edit": true,
      "glob": true,
      "grep": true
    },
    "terminal": {
      "bash": "ask",
      "shell": true
    },
    "web": {
      "fetch": true,
      "search": true
    },
    "productivity": {
      "todo": true,
      "skill": true
    }
  }
}
```

---

## 3.3 Memory System (Short-term + Long-term)

### Short-term Memory (Session):
- Conversation context
- Tool results buffer
- Task state

### Long-term Memory (Persistent):
```
┌─────────────────────────────────────────────────────────────────┐
│                   LONG-TERM MEMORY STRUCTURE                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ~/.config/opencode/                                            │
│  ├── CLAUDE.md           (Global instructions)                  │
│  ├── MEMORY.md           (User preferences, patterns)          │
│  ├── agents/             (Custom agent definitions)             │
│  ├── commands/           (Custom command definitions)           │
│  └── skills/             (Reusable skill definitions)           │
│                                                                  │
│  Project Root:                                                   │
│  ├── CLAUDE.md           (Project-specific instructions)        │
│  ├── AGENTS.md           (Project agent overrides)             │
│  ├── MEMORY.md           (Project memory)                      │
│  └── .opencode/          (Project config)                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3.4 Agent Workflows

### Agent Types:

```
┌─────────────────────────────────────────────────────────────────┐
│                    AGENT WORKFLOW DESIGN                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PRIMARY AGENTS                                                 │
│  ─────────────                                                  │
│  build   - Full implementation, all tools                        │
│  plan    - Analysis, read-only                                  │
│  explore - Deep research, background                            │
│                                                                  │
│  CUSTOM AGENTS (in agents/)                                      │
│  ────────────────                                               │
│  code-reviewer   - Code quality & security review               │
│  security-auditor - Vulnerability detection                    │
│  docs-writer     - Documentation generation                     │
│  debugger        - Issue investigation                           │
│  refactor        - Code improvement                             │
│                                                                  │
│  SUBAGENT PATTERN:                                              │
│  - Invoke via agent field in commands                           │
│  - Use subtask: true for background execution                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3.5 Error Handling and Retries

### Strategy:
```json
{
  "errorHandling": {
    "maxRetries": 3,
    "retryDelay": 1000,
    "backoffMultiplier": 2,
    "retryableErrors": [
      "timeout",
      "rate_limit",
      "network_error"
    ]
  }
}
```

---

## 3.6 Context Management Strategy

### Compaction Configuration:
```json
{
  "compaction": {
    "auto": true,
    "prune": true,
    "reserved": 10000,
    "threshold": 0.8
  }
}
```

---

# 4. Implementation Plan

## 4.1 Folder Structure

```
~/.config/opencode/
├── opencode.json              # Main configuration
├── CLAUDE.md                  # Global instructions
├── GAP_ANALYSIS.md            # This document
│
├── agents/                    # Custom agent definitions
│   ├── code-reviewer.md
│   ├── security-auditor.md
│   ├── docs-writer.md
│   ├── debugger.md
│   └── refactor.md
│
├── commands/                  # Custom slash commands
│   ├── test.md
│   ├── commit.md
│   ├── explain.md
│   └── review.md
│
├── skills/                    # Reusable skills
│   ├── git-workflow/
│   │   └── SKILL.md
│   ├── test-runner/
│   │   └── SKILL.md
│   └── security-scan/
│       └── SKILL.md
│
└── prompts/                   # Custom prompt templates
    ├── system/
    │   └── instructions.md
    └── task/
        └── templates/
```

---

## 4.2 Config Files

### Main Config: `opencode.json`

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "longcat/LongCat-Flash-Chat",
  "small_model": "longcat/LongCat-Flash-Lite",
  "autoupdate": true,
  "share": "manual",
  "compaction": {
    "auto": true,
    "prune": true,
    "reserved": 10000
  },
  "snapshot": true,
  
  "mcp": {
    "canva-dev": {
      "type": "local",
      "command": ["npx", "-y", "@canva/cli@latest", "mcp"],
      "enabled": true
    },
    "stitch": {
      "type": "remote",
      "url": "https://stitch.googleapis.com/mcp",
      "enabled": true
    }
  },
  
  "provider": {
    "longcat": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LongCat",
      "options": {
        "baseURL": "https://api.longcat.chat/openai"
      },
      "models": {
        "LongCat-Flash-Chat": { "name": "LongCat Flash Chat" },
        "LongCat-Flash-Thinking": { "name": "LongCat Flash Thinking" },
        "LongCat-Flash-Lite": { "name": "LongCat Flash Lite" }
      }
    }
  },
  
  "agent": {
    "code-reviewer": {
      "description": "Reviews code for best practices, security issues, and potential bugs",
      "mode": "subagent",
      "prompt": "You are a code reviewer focused on quality and security. Review code thoroughly and provide constructive feedback without making direct changes.",
      "permission": {
        "write": "deny",
        "edit": "deny"
      },
      "temperature": 0.1
    },
    "security-auditor": {
      "description": "Performs security audits and identifies vulnerabilities in code",
      "mode": "subagent",
      "prompt": "You are a security expert. Focus on identifying potential security issues including: input validation vulnerabilities, authentication/authorization flaws, data exposure risks, dependency vulnerabilities, and configuration security problems.",
      "permission": {
        "write": "deny",
        "edit": "deny",
        "bash": "deny"
      },
      "temperature": 0.1
    },
    "docs-writer": {
      "description": "Creates and maintains project documentation",
      "mode": "subagent",
      "prompt": "You are a technical writer. Create clear, comprehensive documentation focusing on clear explanations, proper structure, code examples, and user-friendly language.",
      "permission": {
        "write": "allow",
        "edit": "allow",
        "bash": "deny"
      }
    },
    "debugger": {
      "description": "Helps debug issues and investigate problems",
      "mode": "subagent",
      "prompt": "You are a debugging specialist. Investigate issues thoroughly by examining code, running commands, and analyzing errors. Focus on finding root causes and suggesting fixes.",
      "permission": {
        "write": "allow",
        "edit": "allow",
        "bash": "allow"
      }
    },
    "refactor": {
      "description": "Refactors and improves existing code",
      "mode": "subagent",
      "prompt": "You are a code refactoring expert. Focus on improving code quality, reducing complexity, improving readability, and following best practices. Make small, incremental changes that can be verified.",
      "permission": {
        "write": "allow",
        "edit": "allow"
      },
      "temperature": 0.2
    }
  },
  
  "command": {
    "review": {
      "description": "Review code changes in the current diff",
      "template": "Review the code changes shown above. Focus on:\n- Code quality and best practices\n- Potential bugs and edge cases\n- Performance implications\n- Security considerations\n- Suggestions for improvements\n\nProvide a thorough review without making direct changes.",
      "agent": "code-reviewer",
      "subtask": true
    },
    "audit": {
      "description": "Perform security audit on changed files",
      "template": "Perform a security audit on the changed files. Look for:\n- Input validation vulnerabilities\n- Authentication and authorization flaws\n- Data exposure risks\n- Dependency vulnerabilities\n- Configuration security issues\n\nReview the git diff and identify any security concerns.",
      "agent": "security-auditor",
      "subtask": true
    },
    "test": {
      "description": "Run tests and analyze results",
      "template": "Run the full test suite and analyze the results.\n\nFocus on:\n- Failed tests and their root causes\n- Suggestions for fixes\n- Any patterns in test failures\n\nUse the bash tool to run tests and analyze output.",
      "agent": "debugger"
    },
    "docs": {
      "description": "Generate or update documentation",
      "template": "Create or update documentation for the project. Focus on:\n- Clear explanations\n- Proper structure\n- Code examples\n- API documentation\n\nLook at existing documentation patterns in the project.",
      "agent": "docs-writer"
    },
    "refactor": {
      "description": "Refactor code for better quality",
      "template": "Analyze the code and suggest refactoring improvements. Focus on:\n- Reducing complexity\n- Improving readability\n- Following best practices\n- Reducing code duplication\n\nMake small, incremental changes that can be verified with tests.",
      "agent": "refactor"
    },
    "commit": {
      "description": "Create a commit with descriptive message",
      "template": "Analyze the current git changes and create a well-structured commit:\n\n1. Review the staged changes: !`git diff --cached`\n2. Review unstaged changes: !`git diff`\n3. Suggest a proper commit message following conventional commits\n4. Stage any untracked files if needed\n\nProvide a clear commit message that describes the changes.",
      "subtask": true
    },
    "pr": {
      "description": "Create a pull request",
      "template": "Create a pull request for the current changes:\n\n1. Check current branch: !`git branch --show-current`\n2. Check diff from main: !`git diff main...HEAD`\n3. Review recent commits: !`git log --oneline -5`\n\nSuggest PR title, description, and any reviewers.",
      "subtask": true
    },
    "insights": {
      "description": "Analyze session insights and patterns",
      "template": "Analyze the session history and provide insights about:\n- Types of tasks being worked on\n- Common patterns or recurring issues\n- Time spent on different types of work\n- Suggestions for improving workflow",
      "subtask": true
    },
    "explain": {
      "description": "Explain code in current context",
      "template": "Explain the code in the current context. Focus on:\n- What the code does\n- How it works\n- Any non-obvious patterns or techniques\n- Potential issues or improvements\n\nProvide clear explanations suitable for developers.",
      "subtask": true
    }
  },
  
  "instructions": [
    "CLAUDE.md",
    "AGENTS.md"
  ],
  
  "permission": {
    "edit": "ask",
    "bash": "ask",
    "skill": {
      "*": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  },
  
  "watcher": {
    "ignore": [
      "node_modules/**",
      "dist/**",
      ".git/**",
      "*.log",
      "coverage/**"
    ]
  },
  
  "server": {
    "port": 4096,
    "mdns": true
  },
  
  "default_agent": "build"
}
```

---

## 4.3 Example Agent Definitions

### `agents/code-reviewer.md`
```markdown
---
description: Reviews code for best practices, security issues, and potential bugs
mode: subagent
temperature: 0.1
permission:
  write: deny
  edit: deny
---

You are a code reviewer focused on quality and security.

Review code thoroughly and provide constructive feedback. Focus on:
- Code quality and best practices
- Potential bugs and edge cases
- Performance implications
- Security considerations
- Memory leaks and resource management
- Error handling patterns
- Test coverage gaps

Do NOT make direct changes. Instead, clearly describe issues and suggest improvements.
```

### `agents/security-auditor.md`
```markdown
---
description: Performs security audits and identifies vulnerabilities in code
mode: subagent
temperature: 0.1
permission:
  write: deny
  edit: deny
  bash: deny
---

You are a security expert with deep knowledge of common vulnerabilities.

Focus on identifying potential security issues including:
- Input validation vulnerabilities (SQL injection, XSS, command injection)
- Authentication and authorization flaws
- Data exposure and information leakage risks
- Dependency vulnerabilities (known CVEs)
- Insecure cryptographic practices
- Race conditions and concurrency issues
- Path traversal and file inclusion issues
- Hardcoded secrets, API keys, or credentials
- Insecure deserialization
- XML external entity (XXE) vulnerabilities

Review the code carefully and provide detailed findings with:
1. Severity (Critical/High/Medium/Low)
2. Location (file and line numbers)
3. Description of the vulnerability
4. Potential impact
5. Remediation suggestions

Do NOT make changes - provide a detailed security report.
```

---

## 4.4 Example Command Templates

### `commands/test.md`
```markdown
---
description: Run comprehensive tests with detailed output
agent: debugger
subtask: true
---

Run the test suite with verbose output and analyze results:

1. First, identify the test framework used (jest, vitest, pytest, etc.)
2. Run tests with coverage: !`npm test -- --coverage 2>/dev/null || npm test 2>/dev/null || echo "No test command found"`
3. Analyze any failures in detail
4. Suggest fixes for failing tests

If no tests are found, check package.json for test scripts and explore the project structure to find test files.
```

### `commands/commit.md`
```markdown
---
description: Create a git commit with proper message
subtask: true
---

Analyze current changes and create a well-structured commit:

1. Check staged changes: !`git diff --cached`
2. Check unstaged changes: !`git diff`
3. Review the diff to understand what changed

Then:
- Stage any untracked files if appropriate
- Create a commit with a clear, descriptive message following conventional commits format
- Show the resulting commit
```

---

## 4.5 Example Skill Definitions

### `skills/git-workflow/SKILL.md`
```markdown
---
name: git-workflow
description: Git workflow automation - commits, branches, and PRs
compatibility: opencode
metadata:
  audience: developers
  workflow: git
---

## What I do
- Create well-structured commits following conventional commits
- Manage branches (create, switch, delete)
- Help with merge conflict resolution
- Guide through pull request workflow

## When to use me
Use this when working with git repositories. Ask clarifying questions if the target branch or commit style is unclear.

## Git Best Practices
- Write clear, descriptive commit messages
- Keep commits atomic (one concern per commit)
- Use feature branches for new work
- Rebase when appropriate to keep history clean
```

### `skills/security-scan/SKILL.md`
```markdown
---
name: security-scan
description: Security vulnerability scanning and analysis
compatibility: opencode
metadata:
  audience: security
  workflow: audit
---

## What I do
- Scan code for common security vulnerabilities
- Check for hardcoded secrets or API keys
- Analyze dependencies for known CVEs
- Review authentication and authorization patterns
- Identify data exposure risks

## When to use me
Use this for security audits or when you want to ensure code is secure. Be specific about the scope (entire codebase, specific files, or changes).

## Focus Areas
- Input validation (SQL injection, XSS, command injection)
- Authentication and authorization flaws
- Hardcoded secrets and credentials
- Dependency vulnerabilities
- Insecure cryptographic practices
- Path traversal and file inclusion

## Output Format
Provide findings with:
1. Severity (Critical/High/Medium/Low)
2. Location (file and line)
3. Description
4. Impact
5. Remediation suggestions
```

---

# 5. Advanced Enhancements

## 5.1 Self-Improving Agents

### Concept:
Agents that learn from session feedback and improve their behavior over time.

### Implementation Approach:
1. **Feedback Collection**: Track agent decisions and outcomes
2. **Pattern Analysis**: Identify successful strategies
3. **Prompt Refinement**: Update agent prompts based on learnings

### Configuration:
```json
{
  "agent": {
    "selfImprove": {
      "enabled": true,
      "feedbackFile": "~/.config/opencode/agent-feedback.jsonl",
      "reviewInterval": 100
    }
  }
}
```

---

## 5.2 Code Quality Enforcement

### Quality Gates:

```yaml
# .opencode/quality-gates.yaml
gates:
  - name: lint
    command: npm run lint
    failOnError: true
    
  - name: typecheck
    command: npm run typecheck
    failOnError: true
    
  - name: test
    command: npm test
    failOnError: true
    coverage:
      minimum: 80
      
  - name: format
    command: npm run format:check
    failOnError: false
    
enforcement:
  preCommit: true
  prePush: false
  onSave: true
```

---

## 5.3 Multi-Agent Collaboration

### Architecture:
```
┌─────────────────────────────────────────────────────────────────┐
│                   MULTI-AGENT COLLABORATION                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   User Request                                                  │
│        │                                                        │
│        v                                                        │
│   ┌─────────┐                                                   │
│   │ Primary │                                                   │
│   │ Agent   │                                                   │
│   └────┬────┘                                                   │
│        │                                                        │
│        ├──────────────────┬──────────────────┐                  │
│        v                  v                  v                  │
│   ┌─────────┐       ┌─────────┐       ┌─────────┐              │
│   │ Code    │       │ Security│       │ Docs    │              │
│   │Reviewer │       │ Auditor │       │ Writer  │              │
│   └────┬────┘       └────┬────┘       └────┬────┘              │
│        │                  │                  │                   │
│        └──────────────────┴──────────────────┘                  │
│                           │                                      │
│                           v                                      │
│                    ┌─────────┐                                  │
│                    │ Synthesize │                                │
│                    │ Results    │                                │
│                    └─────────┘                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Implementation:
```json
{
  "command": {
    "full-review": {
      "description": "Run comprehensive multi-agent review",
      "template": "Coordinate a comprehensive review:\n\n1. Spawn code-reviewer agent for code quality\n2. Spawn security-auditor agent for security analysis\n3. Wait for both to complete\n4. Synthesize findings into unified report\n\nUse @agent to spawn subagents with appropriate agent types.",
      "subtask": true
    }
  }
}
```

---

## 5.4 Debugging + Tracing System

### Tracing Configuration:
```json
{
  "tracing": {
    "enabled": true,
    "outputDir": "~/.config/opencode/traces",
    "retention": 30,
    "include": [
      "tool_calls",
      "agent_decisions",
      "errors",
      "performance"
    ],
    "sensitiveData": {
      "redact": true,
      "patterns": [
        "api_key",
        "password",
        "token"
      ]
    }
  }
}
```

### Trace Viewer Command:
```bash
# View recent traces
opencode trace list

# View specific trace
opencode trace view <trace-id>

# Search traces
opencode trace search --agent code-reviewer --error
```

---

## 5.5 Performance Optimizations

### Configuration:
```json
{
  "performance": {
    "caching": {
      "systemPrompt": {
        "enabled": true,
        "ttl": 3600
      },
      "tools": {
        "enabled": true,
        "maxSize": "100mb"
      }
    },
    "parallelism": {
      "maxConcurrent": 5,
      "toolBatching": true
    },
    "memory": {
      "maxContextTokens": 200000,
      "compactionThreshold": 0.8,
      "reservedTokens": 10000
    }
  }
}
```

### Optimization Strategies:
1. **System prompt caching**: Cache static sections
2. **Tool result optimization**: Compress large outputs
3. **Parallel execution**: Batch independent operations
4. **Smart compaction**: Prioritize important context

---

# 6. Summary: Implementation Status

## Completed Components:

| Component | Status | Location |
|-----------|--------|----------|
| Main config | ✅ Done | `~/.config/opencode/opencode.json` |
| Global instructions | ✅ Done | `~/.config/opencode/CLAUDE.md` |
| Gap analysis | ✅ Done | `~/.config/opencode/GAP_ANALYSIS.md` |
| Custom agents (4) | ✅ Done | `~/.config/opencode/agents/` |
| Custom commands (3) | ✅ Done | `~/.config/opencode/commands/` |
| Skills (3) | ✅ Done | `~/.config/opencode/skills/` |

## This Document:

This comprehensive document provides:
- ✅ Deep analysis of Claude Code architecture
- ✅ Gap analysis comparing OpenCode vs Claude Code  
- ✅ Complete global setup design
- ✅ Implementation plan with folder structure
- ✅ Ready-to-use config files
- ✅ Advanced enhancement proposals

The setup is now operational - run `opencode --port 24163` to use your production-grade OpenCode configuration.