# Ruflo Swarm Workflows

Pre-built swarm templates for common development tasks.

## Quick Reference

| Workflow | Use Case | Agents |
|----------|----------|--------|
| `feature.md` | New feature development | architect, coder, tester, reviewer |
| `bugfix.md` | Bug investigation & fix | researcher, coder, tester |
| `refactor.md` | Code refactoring | analyzer, refactorer, validator |
| `security.md` | Security audit | scanner, analyzer, fixer |
| `docs.md` | Documentation | researcher, writer, reviewer |

## Usage

```bash
# Initialize ruflo in project
npx ruflo@latest init

# Run a swarm workflow
npx ruflo@latest hive-mind spawn "Your task description"
```

## Integration with OpenCode

When using OpenCode with ruflo MCP:

```
1. Ask OpenCode to analyze the task
2. Use @ruflo swarm_init with anti-drift settings
3. Spawn specialized agents via @ruflo
4. OpenCode coordinates and reviews results
```

## Anti-Drift Settings (Recommended)

Always use for coding tasks:
```javascript
swarm_init({
  topology: "hierarchical",
  maxAgents: 6-8,
  strategy: "specialized"
})
```
