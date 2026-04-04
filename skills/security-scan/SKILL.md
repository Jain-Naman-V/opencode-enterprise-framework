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