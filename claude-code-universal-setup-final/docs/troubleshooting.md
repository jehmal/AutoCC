# Claude Code Universal Setup - Troubleshooting Guide

## 🔧 Common Issues and Solutions

### Installation Issues

#### Issue: "claude: command not found"
**Cause**: Claude Code is not installed or not in PATH
**Solution**:
```bash
# Install Claude Code globally
npm install -g claude-code

# Verify installation
claude --version

# If still not found, check your PATH
echo $PATH
```

#### Issue: Auto-setup script permission denied
**Cause**: Script is not executable
**Solution**:
```bash
chmod +x auto-setup.sh
./auto-setup.sh
```

### Authentication Issues

#### Issue: "Authentication failed" 
**Cause**: Missing or invalid API key
**Solution**:
```bash
# Set your API key
export ANTHROPIC_API_KEY="sk-ant-your-key-here"

# Or configure it persistently
echo 'export ANTHROPIC_API_KEY="sk-ant-your-key-here"' >> ~/.bashrc
source ~/.bashrc

# Verify authentication
claude -p "Test authentication"
```

#### Issue: API key works in browser but not CLI
**Cause**: Environment variable issues
**Solution**:
```bash
# Check current environment
env | grep ANTHROPIC

# Remove any quotes or extra characters
export ANTHROPIC_API_KEY=sk-ant-your-key-here

# Try in a new shell session
bash -c "claude -p 'test'"
```

### Configuration Issues

#### Issue: Tool permissions not working
**Cause**: Incorrect permission configuration
**Solution**:
```bash
# Reset permissions
claude config reset permissions

# Re-run setup
./auto-setup.sh --enhance-existing

# Check current permissions
claude config get allowed-tools
```

#### Issue: MCP servers not connecting
**Cause**: MCP server configuration issues
**Solution**:
```bash
# List current MCP servers
claude mcp list

# Remove problematic server
claude mcp remove filesystem

# Re-add with correct configuration
claude mcp add-json filesystem '{"command":"npx","args":["-y","@modelcontextprotocol/server-filesystem","'$(pwd)'"]}'

# Test connectivity
claude -p "Test MCP filesystem server"
```

### Performance Issues

#### Issue: Slow response times
**Cause**: Large context or network issues
**Solution**:
```bash
# Clear conversation history
claude /clear

# Reduce context size
claude config set max-context-files 10
claude config set conversation-limit 20

# Use faster model for simple tasks
claude config set model claude-haiku-3

# Check network
ping api.anthropic.com
```

#### Issue: High memory usage
**Cause**: Large project or context accumulation
**Solution**:
```bash
# Restart Claude Code
pkill claude

# Limit project scope
claude config set ignore-patterns "node_modules/**,dist/**,build/**,.git/**,coverage/**,*.log,tmp/**"

# Use one-shot mode more often
claude -p "query" # Instead of interactive mode
```

### Project Detection Issues

#### Issue: Wrong technology stack detected
**Cause**: Auto-detection logic limitations
**Solution**:
```bash
# Force specific tech stack
./auto-setup.sh --tech-stack react-frontend

# Or manually specify
./auto-setup.sh --tech-stack "nodejs-backend"

# Available options:
# react-frontend, vue-frontend, angular-frontend
# nodejs-backend, python-django, python-flask
# flutter-mobile, java-maven, dotnet-general
```

#### Issue: Missing project-specific tools
**Cause**: Custom project requirements not detected
**Solution**:
```bash
# Add custom tools manually
claude config add allowed-tools "Bash(your-tool:*)"

# Or edit configuration
claude config set allowed-tools "$(claude config get allowed-tools),Bash(custom-command:*)"

# Re-run permission configuration
./.claude-setup/scripts/configure-permissions.sh your-tech-stack false false
```

### Workflow Issues

#### Issue: Workflow scripts not working
**Cause**: Missing dependencies or incorrect paths
**Solution**:
```bash
# Make scripts executable
chmod +x .claude/workflows/*.sh

# Check script dependencies
head -20 .claude/workflows/daily-setup.sh

# Run with debugging
bash -x .claude/workflows/daily-setup.sh

# Fix path issues
cd /path/to/your/project
./.claude/workflows/daily-setup.sh
```

#### Issue: Git integration not working
**Cause**: Not a git repository or permission issues
**Solution**:
```bash
# Initialize git if needed
git init
git remote add origin https://github.com/username/repo.git

# Check git configuration
git config --list

# Verify permissions
ls -la .git/

# Re-run setup for git integration
./auto-setup.sh --enhance-existing
```

### CI/CD Issues

#### Issue: GitHub Actions workflow failing
**Cause**: Missing secrets or configuration
**Solution**:
```bash
# Check required secrets in GitHub repository settings:
# - ANTHROPIC_API_KEY

# Verify workflow file
cat .github/workflows/claude-ci.yml

# Test workflow locally (if using act)
act -j ai-analysis
```

#### Issue: CI/CD detecting wrong project type
**Cause**: Multiple package managers or mixed technologies
**Solution**:
```bash
# Create custom CI/CD workflow
cp .claude-setup/templates/ci-cd/universal.yml .github/workflows/custom-ci.yml

# Edit to match your specific needs
# Modify environment setup section for your tech stack
```

### Network and Connectivity Issues

#### Issue: "Connection timeout" errors
**Cause**: Network restrictions or proxy
**Solution**:
```bash
# Test direct connectivity
curl -I https://api.anthropic.com

# Check for proxy settings
echo $HTTP_PROXY
echo $HTTPS_PROXY

# Configure proxy if needed
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080

# Test with verbose output
claude --verbose -p "test connection"
```

#### Issue: Rate limiting errors
**Cause**: Too many API requests
**Solution**:
```bash
# Check current usage
claude config get rate-limits

# Add delays between requests
sleep 2

# Use batch processing instead of multiple calls
claude -p "Process multiple items in one request"

# Switch to more efficient model
claude config set model claude-haiku-3
```

## 🆘 Getting Help

### Self-Diagnosis
```bash
# Run verification script
./.claude-setup/scripts/verify-setup.sh .

# Check Claude Code status
claude config get all

# Test basic functionality
claude -p "System check: respond with current date and time"
```

### Debug Mode
```bash
# Enable verbose logging
claude --verbose -p "debug test"

# Enable debug mode
claude --debug -p "debug test"

# Check logs
tail -f ~/.claude/logs/claude.log
```

### Reset and Recovery
```bash
# Nuclear option: complete reset
claude config reset-all
rm -rf .claude/
rm -f CLAUDE.md
rm -f .claude-setup-report.md

# Re-run setup
./auto-setup.sh

# Or start fresh
rm -rf .claude-setup/
git clone https://github.com/[username]/claude-code-universal-setup.git .claude-setup
./.claude-setup/auto-setup.sh
```

### Environment Information for Support
```bash
# Gather system information
echo "OS: $(uname -a)"
echo "Claude Code: $(claude --version)"
echo "Node.js: $(node --version 2>/dev/null || echo 'Not installed')"
echo "Python: $(python --version 2>/dev/null || echo 'Not installed')"
echo "Git: $(git --version)"
echo "Working Directory: $(pwd)"
echo "Project Size: $(du -sh . 2>/dev/null)"

# Configuration dump
claude config get all

# MCP status
claude mcp list
```

## 📞 Support Channels

### Community Support
- GitHub Issues: Report bugs and request features
- GitHub Discussions: Ask questions and share experiences
- Documentation: Check the latest docs and examples

### Enterprise Support
- Priority support for enterprise customers
- Custom configuration assistance
- Performance optimization consulting

## 🔄 Keeping Updated

### Update Claude Code Universal Setup
```bash
# Update the setup repository
cd .claude-setup
git pull origin main

# Re-run setup with latest improvements
./auto-setup.sh --enhance-existing
```

### Update Claude Code
```bash
# Update Claude Code itself
npm update -g claude-code

# Verify new version
claude --version

# Check for new features
claude --help
```

---

*If you encounter issues not covered here, please create an issue in the repository with your system information and error details.*