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