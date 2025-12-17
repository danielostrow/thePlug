# Code Health

Comprehensive codebase analysis for security vulnerabilities, technical debt, and dependency health with AI-powered refactoring assistance.

## Features

### Security Scanning
- Hardcoded secrets detection (API keys, passwords, AWS credentials, tokens)
- OWASP Top 10 vulnerability patterns (SQL injection, XSS, command injection)
- Dependency CVE checking via native audit tools
- Sensitive file detection (.env files, private keys)

### Technical Debt Analysis
- Code complexity metrics (file size, function length, nesting depth)
- Code smell detection (god files, circular dependencies, long functions)
- TODO/FIXME/HACK comment tracking with git blame age analysis
- Duplicate code detection
- Dead code identification (unused exports, orphan files)

### Dependency Health
- Outdated package detection (npm, pip, go modules, cargo)
- License compatibility checking
- Unused dependency detection
- Security vulnerability alerts from package registries

### Auto-Fix
- Move hardcoded secrets to environment variables
- Remove dead code and unused imports
- Fix basic security vulnerabilities (parameterized queries)
- Update vulnerable dependencies

## Commands

| Command | Description |
|---------|-------------|
| `/code-health:scan` | Full health scan with quick or deep mode |
| `/code-health:security` | Security-focused vulnerability analysis |
| `/code-health:debt` | Technical debt and code quality analysis |
| `/code-health:deps` | Dependency audit for updates and CVEs |
| `/code-health:fix` | Auto-fix common issues |
| `/code-health:report` | Generate detailed markdown/JSON reports |

## Quick Start

```bash
# Run a quick health scan
/code-health:scan

# Deep scan with full details
/code-health:scan --mode deep

# Security-only scan
/code-health:security

# Auto-fix with preview
/code-health:fix --dry-run
```

## Health Score

Projects receive a letter grade (A-F) based on weighted scores:

```
Overall = (Security x 0.4) + (Tech Debt x 0.3) + (Dependencies x 0.3)

A: 90-100 (Excellent)
B: 80-89  (Good)
C: 70-79  (Fair)
D: 60-69  (Poor)
F: <60    (Critical)
```

## Language Support

Code Health uses language-agnostic analysis techniques:
- Regex patterns for secret and vulnerability detection
- Native package manager audit tools (npm audit, pip-audit, govulncheck, cargo audit)
- File structure and git history analysis
- Universal complexity metrics

Supported ecosystems: JavaScript/TypeScript, Python, Go, Rust, and more.

## License

MIT License - see [LICENSE](LICENSE) for details.
