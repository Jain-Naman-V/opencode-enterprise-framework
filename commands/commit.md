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