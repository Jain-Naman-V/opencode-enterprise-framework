# CLAUDE.md - OpenCode Global Instructions

This file provides guidance to OpenCode when working in any project.

## Ruflo Integration (AI Orchestration)

Ruflo MCP is available for advanced workflows. Use natural language to access:

```
use ruflo to spawn a coder agent
use ruflo to search memory for "authentication patterns"
use ruflo tools to initialize a swarm for complex tasks
```

## Available Skills

Use `/skill <name>` to invoke pre-built skills:

- `/swarm-orchestration` - Multi-agent coordination
- `/sparc-methodology` - Specification-driven development
- `/github-workflow-automation` - GitHub Actions automation
- `/agentdb-vector-search` - Vector memory search
- `/security-scan` - Security vulnerability scanning
- `/test-runner` - Test execution and analysis
- `/git-workflow` - Git workflow automation

## Available Agents

Invoke specialized agents via `@`:

- `@code-reviewer` - Code review without edits
- `@security-auditor` - Security vulnerability detection
- `@debugger` - Issue investigation
- `@docs-writer` - Documentation generation
- `@refactor` - Code improvement

## Swarm Workflows (Complex Tasks)

For complex multi-file tasks, use ruflo swarms:

```
use ruflo to initialize a swarm with hierarchical topology
use ruflo to spawn specialized agents for the task
use ruflo memory to store learned patterns
```

## General Principles

- Be proactive but not surprising - ask before taking significant actions
- Prefer small, reviewable changes over large rewrites
- Always verify changes work before considering them complete
- When uncertain, ask for clarification rather than guessing
- Follow existing code patterns and conventions in the project

## Code Quality Guidelines

- Write clean, readable code with proper type annotations
- Add appropriate comments when code is complex or non-obvious
- Prefer composition over inheritance
- Keep functions small and focused on single responsibility
- Handle errors gracefully with appropriate logging

## Interaction Guidelines

- Use the `plan` agent mode when analyzing code without making changes
- Use the `build` agent mode for implementing features and fixes
- Switch between agents using the Tab key
- Use `@agent` to invoke subagents for specialized tasks
- Use `/skill` for pre-built skill workflows

## Tool Usage

- Use `read` tool to examine files before editing
- Use `grep` and `glob` to find relevant code
- Use `bash` to run commands and verify changes
- Use `edit` tool for precise modifications
- Use `write` tool for creating new files

## Safety Guidelines

- Always verify destructive commands (rm, git reset --hard, etc.)
- Ask before running commands that modify git history
- Be careful with commands that affect production systems
- Use permission prompts for potentially risky operations

## Project Discovery

On project initialization (`/init`), look for:
- Package manager (npm, yarn, pnpm, cargo, etc.)
- Language and framework types
- Test frameworks and configuration
- Build scripts and tooling
- Linting and formatting configuration
- Documentation patterns (README, docs/, etc.)

## Verification

Before completing any task:
1. Run relevant tests
2. Verify lint/format checks pass
3. Check that changes compile without errors
4. Review the diff to ensure only intended changes are made

## Communication

- Be concise in responses
- Explain what you're doing when non-obvious
- Ask clarifying questions when needed
- Summarize completed work