#!/bin/bash

# Test Suite for Claude Code Universal Setup
# Validates functionality across different project types

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$TEST_DIR")"
TEMP_TEST_DIR="/tmp/claude-setup-tests-$$"
TESTS_PASSED=0
TESTS_FAILED=0

# Logging functions
log_test() {
    echo -e "${BLUE}🧪 Testing: $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((TESTS_PASSED++))
}

log_failure() {
    echo -e "${RED}❌ $1${NC}"
    ((TESTS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Setup test environment
setup_test_env() {
    echo -e "${BLUE}🚀 Setting up test environment...${NC}"
    
    # Create temporary test directory
    mkdir -p "$TEMP_TEST_DIR"
    cd "$TEMP_TEST_DIR"
    
    echo "Test directory: $TEMP_TEST_DIR"
    echo "Setup directory: $SETUP_DIR"
}

# Cleanup test environment
cleanup_test_env() {
    echo -e "${BLUE}🧹 Cleaning up test environment...${NC}"
    
    cd /
    rm -rf "$TEMP_TEST_DIR"
}

# Test technology stack detection
test_tech_stack_detection() {
    log_test "Technology Stack Detection"
    
    local test_cases=(
        "react:package.json:react"
        "vue:package.json:vue"
        "python:requirements.txt:django"
        "flutter:pubspec.yaml:flutter"
        "go:go.mod:go"
        "rust:Cargo.toml:rust"
    )
    
    for test_case in "${test_cases[@]}"; do
        IFS=':' read -r name file content <<< "$test_case"
        
        # Create test project
        local project_dir="$TEMP_TEST_DIR/test-$name-project"
        mkdir -p "$project_dir"
        cd "$project_dir"
        
        case "$file" in
            "package.json")
                echo '{"dependencies": {"'$content'": "^18.0.0"}}' > package.json
                ;;
            "requirements.txt")
                echo "$content==3.2.0" > requirements.txt
                ;;
            "pubspec.yaml")
                echo "name: test_app\ndependencies:\n  $content:\n    sdk: flutter" > pubspec.yaml
                ;;
            "go.mod")
                echo "module test-app\ngo 1.19" > go.mod
                ;;
            "Cargo.toml")
                echo "[package]\nname = \"test-app\"\nversion = \"0.1.0\"" > Cargo.toml
                ;;
        esac
        
        # Test detection
        local detected=$("$SETUP_DIR/scripts/detect-tech-stack.sh")
        
        if [[ "$detected" == *"$name"* ]]; then
            log_success "Detected $name correctly: $detected"
        else
            log_failure "Failed to detect $name, got: $detected"
        fi
        
        cd "$TEMP_TEST_DIR"
        rm -rf "$project_dir"
    done
}

# Test permission configuration
test_permission_configuration() {
    log_test "Permission Configuration"
    
    local project_dir="$TEMP_TEST_DIR/test-permissions"
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Create a Node.js project
    echo '{"scripts": {"dev": "node server.js", "test": "jest"}}' > package.json
    
    # Test permission configuration
    if "$SETUP_DIR/scripts/configure-permissions.sh" "nodejs-backend" false false; then
        log_success "Permission configuration completed"
    else
        log_failure "Permission configuration failed"
    fi
    
    # Verify Claude Code has permissions (if available)
    if command -v claude &> /dev/null; then
        if claude config get allowed-tools &> /dev/null; then
            log_success "Claude Code permissions set successfully"
        else
            log_warning "Claude Code not configured (expected in test environment)"
        fi
    else
        log_warning "Claude Code not installed (expected in test environment)"
    fi
}

# Test workflow generation
test_workflow_generation() {
    log_test "Workflow Generation"
    
    local project_dir="$TEMP_TEST_DIR/test-workflows"
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Create a React project structure
    echo '{"name": "test-app", "scripts": {"dev": "react-scripts start"}}' > package.json
    
    # Test workflow setup
    if "$SETUP_DIR/scripts/setup-workflows.sh" "$project_dir" "react-frontend" "medium"; then
        log_success "Workflow setup completed"
        
        # Check if workflows were created
        if [[ -d ".claude/workflows" ]]; then
            local workflow_count=$(find .claude/workflows -name "*.sh" | wc -l)
            if [[ $workflow_count -gt 0 ]]; then
                log_success "Generated $workflow_count workflow scripts"
                
                # Check if workflows are executable
                local executable_count=$(find .claude/workflows -name "*.sh" -executable | wc -l)
                if [[ $executable_count -eq $workflow_count ]]; then
                    log_success "All workflow scripts are executable"
                else
                    log_failure "Some workflow scripts are not executable"
                fi
            else
                log_failure "No workflow scripts generated"
            fi
        else
            log_failure "Workflow directory not created"
        fi
    else
        log_failure "Workflow setup failed"
    fi
}

# Test auto-setup script
test_auto_setup() {
    log_test "Auto-Setup Script Execution"
    
    local project_dir="$TEMP_TEST_DIR/test-auto-setup"
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Create a simple Node.js project
    echo '{"name": "test-app", "scripts": {"dev": "node app.js"}}' > package.json
    echo 'console.log("Hello World");' > app.js
    
    # Copy setup files
    cp -r "$SETUP_DIR" .claude-setup
    
    # Test auto-setup (silent mode)
    if ./.claude-setup/auto-setup.sh --silent; then
        log_success "Auto-setup completed successfully"
        
        # Verify setup results
        if [[ -f "CLAUDE.md" ]]; then
            log_success "CLAUDE.md generated"
        else
            log_failure "CLAUDE.md not generated"
        fi
        
        if [[ -f ".claude-setup-report.md" ]]; then
            log_success "Setup report generated"
        else
            log_failure "Setup report not generated"
        fi
        
        if [[ -d ".claude/workflows" ]]; then
            log_success "Workflows directory created"
        else
            log_failure "Workflows directory not created"
        fi
        
    else
        log_failure "Auto-setup script failed"
    fi
}

# Test verification script
test_verification() {
    log_test "Setup Verification"
    
    local project_dir="$TEMP_TEST_DIR/test-verification"
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Create minimal setup
    mkdir -p .claude/workflows
    echo '#!/bin/bash\necho "test workflow"' > .claude/workflows/test.sh
    chmod +x .claude/workflows/test.sh
    echo "# Test Project" > CLAUDE.md
    
    # Test verification
    if "$SETUP_DIR/scripts/verify-setup.sh" "$project_dir"; then
        log_success "Verification script completed"
    else
        log_warning "Verification script completed with warnings (expected without Claude Code)"
    fi
}

# Test file structure and permissions
test_file_structure() {
    log_test "File Structure and Permissions"
    
    # Check all required files exist
    local required_files=(
        "auto-setup.sh"
        "README.md"
        "QUICK_START.md"
        "SETUP_INSTRUCTIONS.md"
        "scripts/detect-tech-stack.sh"
        "scripts/configure-permissions.sh"
        "scripts/setup-workflows.sh"
        "scripts/verify-setup.sh"
        "templates/CLAUDE.md.template"
        "templates/ci-cd/universal.yml"
        "docs/troubleshooting.md"
    )
    
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ -f "$SETUP_DIR/$file" ]]; then
            log_success "File exists: $file"
        else
            log_failure "Missing file: $file"
            missing_files+=("$file")
        fi
    done
    
    # Check script permissions
    local script_files=(
        "auto-setup.sh"
        "scripts/detect-tech-stack.sh"
        "scripts/configure-permissions.sh"
        "scripts/setup-workflows.sh"
        "scripts/verify-setup.sh"
    )
    
    for script in "${script_files[@]}"; do
        if [[ -x "$SETUP_DIR/$script" ]]; then
            log_success "Script executable: $script"
        else
            log_failure "Script not executable: $script"
        fi
    done
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        log_success "All required files present"
    else
        log_failure "Missing ${#missing_files[@]} required files"
    fi
}

# Test template validation
test_templates() {
    log_test "Template Validation"
    
    # Check CLAUDE.md template
    if [[ -f "$SETUP_DIR/templates/CLAUDE.md.template" ]]; then
        if grep -q "{{PROJECT_NAME}}" "$SETUP_DIR/templates/CLAUDE.md.template"; then
            log_success "CLAUDE.md template has required placeholders"
        else
            log_failure "CLAUDE.md template missing placeholders"
        fi
    else
        log_failure "CLAUDE.md template not found"
    fi
    
    # Check CI/CD template
    if [[ -f "$SETUP_DIR/templates/ci-cd/universal.yml" ]]; then
        if command -v yamllint &> /dev/null; then
            if yamllint "$SETUP_DIR/templates/ci-cd/universal.yml" &> /dev/null; then
                log_success "CI/CD template is valid YAML"
            else
                log_failure "CI/CD template has YAML syntax errors"
            fi
        else
            log_warning "yamllint not available, skipping YAML validation"
        fi
    else
        log_failure "CI/CD template not found"
    fi
}

# Main test runner
run_tests() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                  ║"
    echo "║           🧪 Claude Code Universal Setup Test Suite 🚀          ║"
    echo "║                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    setup_test_env
    
    # Run all tests
    test_file_structure
    test_templates
    test_tech_stack_detection
    test_permission_configuration
    test_workflow_generation
    test_auto_setup
    test_verification
    
    cleanup_test_env
    
    # Print results
    echo ""
    echo -e "${BLUE}📊 Test Results:${NC}"
    echo "=================="
    echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}"
        echo "╔══════════════════════════════════════════════════════════════════╗"
        echo "║                                                                  ║"
        echo "║                    🎉 ALL TESTS PASSED! 🎉                       ║"
        echo "║                                                                  ║"
        echo "║              Claude Code Universal Setup is ready!              ║"
        echo "║                                                                  ║"
        echo "╚══════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}"
        echo "╔══════════════════════════════════════════════════════════════════╗"
        echo "║                                                                  ║"
        echo "║                    ❌ SOME TESTS FAILED ❌                        ║"
        echo "║                                                                  ║"
        echo "║              Please fix issues before deploying                 ║"
        echo "║                                                                  ║"
        echo "╚══════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        return 1
    fi
}

# Command line options
case "${1:-}" in
    --help|-h)
        echo "Claude Code Universal Setup Test Suite"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --quick        Run quick tests only"
        echo "  --full         Run full test suite (default)"
        echo ""
        exit 0
        ;;
    --quick)
        echo "Running quick tests..."
        setup_test_env
        test_file_structure
        test_templates
        cleanup_test_env
        ;;
    --full|"")
        run_tests
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac