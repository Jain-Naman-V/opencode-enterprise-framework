# CLAUDE.md - OpenCode Global Instructions

This file provides guidance to OpenCode when working in any project.

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