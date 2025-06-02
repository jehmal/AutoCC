#!/bin/bash

# Setup Verification Script
# Verifies that Claude Code is properly configured and working

PROJECT_DIR="$1"

verify_setup() {
    local project_dir="$1"
    local errors=0
    
    cd "$project_dir"
    
    echo "🔍 Verifying Claude Code setup..."
    
    # Check Claude Code installation
    if ! command -v claude &> /dev/null; then
        echo "❌ Claude Code is not installed or not in PATH"
        ((errors++))
    else
        echo "✅ Claude Code is installed"
    fi
    
    # Check basic configuration
    if claude config get project-name &> /dev/null; then
        local project_name=$(claude config get project-name 2>/dev/null)
        echo "✅ Project configured: $project_name"
    else
        echo "❌ Project not configured"
        ((errors++))
    fi
    
    # Check tool permissions
    if claude config get allowed-tools &> /dev/null; then
        local tool_count=$(claude config get allowed-tools 2>/dev/null | tr ',' '\n' | wc -l)
        echo "✅ Tool permissions configured: $tool_count tools"
    else
        echo "❌ Tool permissions not configured"
        ((errors++))
    fi
    
    # Check MCP servers
    local mcp_count=$(claude mcp list 2>/dev/null | wc -l)
    if [[ $mcp_count -gt 0 ]]; then
        echo "✅ MCP servers configured: $mcp_count servers"
    else
        echo "⚠️  No MCP servers configured (optional)"
    fi
    
    # Check documentation
    if [[ -f "CLAUDE.md" ]]; then
        echo "✅ Project documentation created: CLAUDE.md"
    else
        echo "⚠️  CLAUDE.md not found"
    fi
    
    # Check workflows
    if [[ -d ".claude/workflows" ]]; then
        local workflow_count=$(find .claude/workflows -name "*.sh" | wc -l)
        echo "✅ Development workflows created: $workflow_count scripts"
        
        # Check if workflows are executable
        local executable_count=$(find .claude/workflows -name "*.sh" -executable | wc -l)
        if [[ $executable_count -eq $workflow_count ]]; then
            echo "✅ All workflows are executable"
        else
            echo "⚠️  Some workflows may not be executable"
        fi
    else
        echo "❌ Workflows directory not found"
        ((errors++))
    fi
    
    # Test basic Claude Code functionality
    echo "🧪 Testing Claude Code functionality..."
    
    # Test simple query
    if timeout 30s claude -p "Test: respond with 'OK'" 2>/dev/null | grep -q "OK"; then
        echo "✅ Basic Claude Code functionality working"
    else
        echo "❌ Claude Code functionality test failed"
        ((errors++))
    fi
    
    # Test file operations
    if claude -p "List the files in the current directory" &> /dev/null; then
        echo "✅ File operations accessible"
    else
        echo "⚠️  File operations may need permission approval"
    fi
    
    # Check CI/CD setup
    if [[ -d ".github/workflows" ]]; then
        local workflow_files=$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l)
        echo "✅ CI/CD workflows configured: $workflow_files files"
    else
        echo "ℹ️  No CI/CD workflows configured (optional)"
    fi
    
    # Performance test
    echo "⚡ Performance test..."
    local start_time=$(date +%s)
    claude -p "Quick performance test" &> /dev/null
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ $duration -lt 10 ]]; then
        echo "✅ Performance good: ${duration}s response time"
    elif [[ $duration -lt 30 ]]; then
        echo "⚠️  Performance moderate: ${duration}s response time"
    else
        echo "⚠️  Performance slow: ${duration}s response time"
    fi
    
    # Summary
    echo ""
    echo "📊 Verification Summary:"
    echo "========================"
    
    if [[ $errors -eq 0 ]]; then
        echo "🎉 Setup verification PASSED!"
        echo "✅ Claude Code is properly configured and ready for 10x efficiency"
        echo ""
        echo "🚀 Quick start commands:"
        echo "  claude -p 'Start development session'"
        echo "  ./.claude/workflows/daily-setup.sh"
        echo "  ./.claude/workflows/quality-check.sh"
    else
        echo "❌ Setup verification FAILED with $errors errors"
        echo "📋 Please review the errors above and run setup again if needed"
        echo ""
        echo "🛠️ Troubleshooting:"
        echo "  - Ensure Claude Code is properly installed"
        echo "  - Check API key configuration"
        echo "  - Verify network connectivity"
        echo "  - Review permission settings"
        return 1
    fi
    
    return 0
}

# Make script executable
chmod +x "$0"

# Execute verification
verify_setup "$PROJECT_DIR"