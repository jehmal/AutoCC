#!/bin/bash

# Development Workflows Setup Script
# Creates project-specific automation workflows

PROJECT_DIR="$1"
TECH_STACK="$2"
PROJECT_COMPLEXITY="$3"

setup_workflows() {
    local project_dir="$1"
    local tech_stack="$2"
    local complexity="$3"
    
    cd "$project_dir"
    
    # Create .claude directory structure
    mkdir -p .claude/workflows
    
    echo "Setting up workflows for $tech_stack project..."
    
    # Daily setup workflow
    create_daily_setup_workflow "$tech_stack"
    
    # Feature development workflow
    create_feature_development_workflow "$tech_stack"
    
    # Bug fix workflow
    create_bug_fix_workflow "$tech_stack"
    
    # Quality check workflow
    create_quality_check_workflow "$tech_stack"
    
    # Deployment preparation workflow
    create_deployment_prep_workflow "$tech_stack"
    
    # Project-specific workflows
    create_tech_specific_workflows "$tech_stack"
    
    # Make all scripts executable
    chmod +x .claude/workflows/*.sh
    
    echo "Workflows created successfully!"
}

create_daily_setup_workflow() {
    local tech_stack="$1"
    
    cat > .claude/workflows/daily-setup.sh << 'EOF'
#!/bin/bash

# Daily Development Setup Script
echo "🌅 Starting daily development setup..."

# Check git status
echo "📋 Git Status:"
git status --short

# Start development environment based on tech stack
EOF

    case "$tech_stack" in
        *"nodejs"*|*"react"*|*"vue"*|*"angular"*|*"nextjs"*)
            cat >> .claude/workflows/daily-setup.sh << 'EOF'

# Install/update dependencies if needed
if [[ package.json -nt node_modules ]]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Start development server
echo "🚀 Starting development server..."
if grep -q "dev" package.json; then
    npm run dev &
    DEV_PID=$!
    echo "Development server started (PID: $DEV_PID)"
fi
EOF
            ;;
        *"python"*|*"django"*|*"flask"*|*"fastapi"*)
            cat >> .claude/workflows/daily-setup.sh << 'EOF'

# Activate virtual environment if it exists
if [[ -d "venv" ]]; then
    source venv/bin/activate
    echo "🐍 Virtual environment activated"
elif [[ -d ".venv" ]]; then
    source .venv/bin/activate
    echo "🐍 Virtual environment activated"
fi

# Install dependencies if needed
if [[ requirements.txt -nt venv ]] || [[ ! -d "venv" ]]; then
    echo "📦 Installing Python dependencies..."
    pip install -r requirements.txt
fi
EOF
            ;;
        *"flutter"*)
            cat >> .claude/workflows/daily-setup.sh << 'EOF'

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Check for connected devices
echo "📱 Available devices:"
flutter devices
EOF
            ;;
    esac
    
    cat >> .claude/workflows/daily-setup.sh << 'EOF'

# Check Docker services if docker-compose exists
if [[ -f "docker-compose.yml" ]]; then
    echo "🐳 Starting Docker services..."
    docker-compose up -d
    echo "Docker services status:"
    docker-compose ps
fi

# Check Claude Code status
echo "🤖 Claude Code ready!"
claude config get project-name

echo "✅ Daily setup complete!"
EOF
}

create_feature_development_workflow() {
    local tech_stack="$1"
    
    cat > .claude/workflows/feature-development.sh << 'EOF'
#!/bin/bash

# Feature Development Workflow
FEATURE_NAME="$1"

if [[ -z "$FEATURE_NAME" ]]; then
    echo "Usage: $0 <feature-name>"
    echo "Example: $0 user-authentication"
    exit 1
fi

echo "🚀 Starting feature development: $FEATURE_NAME"

# Create feature branch
echo "🌿 Creating feature branch..."
git checkout -b "feature/$FEATURE_NAME" 2>/dev/null || git checkout "feature/$FEATURE_NAME"

# AI-assisted feature planning
echo "🤖 Getting AI assistance for feature planning..."
claude -p "Help me plan and implement the feature: $FEATURE_NAME

Please provide:
1. Detailed implementation plan
2. Required files and changes
3. Testing strategy
4. Potential challenges and solutions

Let's start with a comprehensive analysis and step-by-step plan."

echo "📋 Feature development session started for: $FEATURE_NAME"
echo "💡 Use 'claude --continue' to continue the conversation"
echo "🔄 Run './quality-check.sh' before committing"
EOF
}

create_bug_fix_workflow() {
    local tech_stack="$1"
    
    cat > .claude/workflows/bug-fix.sh << 'EOF'
#!/bin/bash

# Bug Fix Workflow
BUG_DESCRIPTION="$1"

if [[ -z "$BUG_DESCRIPTION" ]]; then
    echo "Usage: $0 'bug description'"
    echo "Example: $0 'login form not submitting'"
    exit 1
fi

echo "🐛 Starting bug investigation: $BUG_DESCRIPTION"

# Check recent changes
echo "📋 Recent changes:"
git log --oneline -10

# AI-assisted bug analysis
echo "🤖 Getting AI assistance for bug analysis..."
claude -p "Help me investigate and fix this bug: '$BUG_DESCRIPTION'

Please help me:
1. Identify potential root causes
2. Suggest debugging steps
3. Recommend specific files to examine
4. Provide testing strategies to verify the fix

Let's start with a systematic analysis of this issue."

echo "🔍 Bug investigation started for: $BUG_DESCRIPTION"
echo "💡 Use 'claude --continue' to continue the investigation"
EOF
}

create_quality_check_workflow() {
    local tech_stack="$1"
    
    cat > .claude/workflows/quality-check.sh << 'EOF'
#!/bin/bash

# Quality Check Workflow
echo "🔍 Running comprehensive quality checks..."

# Git status
echo "📋 Git Status:"
git status --short

# Run linting
echo "🧹 Running linting..."
EOF

    case "$tech_stack" in
        *"nodejs"*|*"react"*|*"vue"*|*"angular"*|*"nextjs"*)
            cat >> .claude/workflows/quality-check.sh << 'EOF'
if grep -q "lint" package.json; then
    npm run lint
else
    echo "No linting configured"
fi

# Run tests
echo "🧪 Running tests..."
if grep -q "test" package.json; then
    npm test
else
    echo "No tests configured"
fi

# Type checking
if grep -q "typescript" package.json; then
    echo "📝 Type checking..."
    npx tsc --noEmit 2>/dev/null || echo "Type checking completed"
fi
EOF
            ;;
        *"python"*|*"django"*|*"flask"*|*"fastapi"*)
            cat >> .claude/workflows/quality-check.sh << 'EOF'
# Python quality checks
if command -v flake8 &> /dev/null; then
    echo "Running flake8..."
    flake8 .
fi

if command -v black &> /dev/null; then
    echo "Running black..."
    black --check .
fi

if command -v pytest &> /dev/null; then
    echo "Running tests..."
    pytest
elif [[ -f "manage.py" ]]; then
    echo "Running Django tests..."
    python manage.py test
fi
EOF
            ;;
        *"flutter"*)
            cat >> .claude/workflows/quality-check.sh << 'EOF'
echo "Running Flutter analysis..."
flutter analyze

echo "Running Flutter tests..."
flutter test
EOF
            ;;
    esac
    
    cat >> .claude/workflows/quality-check.sh << 'EOF'

# AI-powered code review
echo "🤖 AI Code Review:"
claude review . --focus security,performance,maintainability

echo "✅ Quality checks complete!"
EOF
}

create_deployment_prep_workflow() {
    local tech_stack="$1"
    
    cat > .claude/workflows/deployment-prep.sh << 'EOF'
#!/bin/bash

# Deployment Preparation Workflow
echo "🚀 Preparing for deployment..."

# Run quality checks first
echo "Running quality checks..."
./quality-check.sh

# Build project
echo "🏗️ Building project..."
EOF

    case "$tech_stack" in
        *"nodejs"*|*"react"*|*"vue"*|*"angular"*|*"nextjs"*)
            cat >> .claude/workflows/deployment-prep.sh << 'EOF'
if grep -q "build" package.json; then
    npm run build
fi
EOF
            ;;
        *"flutter"*)
            cat >> .claude/workflows/deployment-prep.sh << 'EOF'
flutter build web
EOF
            ;;
    esac
    
    cat >> .claude/workflows/deployment-prep.sh << 'EOF'

# Security check
echo "🔒 Security validation..."
claude -p "Perform a security review of the current codebase focusing on deployment readiness"

# Performance check
echo "⚡ Performance validation..."
claude -p "Analyze performance considerations for deployment"

echo "✅ Deployment preparation complete!"
echo "📋 Review the output above before deploying"
EOF
}

create_tech_specific_workflows() {
    local tech_stack="$1"
    
    case "$tech_stack" in
        *"react"*|*"vue"*|*"angular"*)
            cat > .claude/workflows/component-generator.sh << 'EOF'
#!/bin/bash

# Component Generator Workflow
COMPONENT_NAME="$1"
COMPONENT_TYPE="$2"

if [[ -z "$COMPONENT_NAME" ]]; then
    echo "Usage: $0 <component-name> [component-type]"
    echo "Example: $0 UserCard functional"
    exit 1
fi

echo "🎨 Generating component: $COMPONENT_NAME"

claude -p "Generate a $COMPONENT_TYPE component named $COMPONENT_NAME following the project's existing patterns and structure. Include:

1. Component implementation
2. TypeScript types/interfaces if applicable
3. Styling (CSS/SCSS/styled-components)
4. Unit tests
5. Storybook story if applicable
6. Documentation

Follow the existing project structure and coding standards."

echo "✅ Component generation request sent to Claude"
EOF
            chmod +x .claude/workflows/component-generator.sh
            ;;
        *"python"*|*"django"*|*"flask"*|*"fastapi"*)
            cat > .claude/workflows/api-generator.sh << 'EOF'
#!/bin/bash

# API Endpoint Generator Workflow
ENDPOINT_NAME="$1"
METHOD="$2"

if [[ -z "$ENDPOINT_NAME" ]]; then
    echo "Usage: $0 <endpoint-name> [method]"
    echo "Example: $0 user-profile GET"
    exit 1
fi

echo "🌐 Generating API endpoint: $ENDPOINT_NAME"

claude -p "Generate a $METHOD API endpoint for $ENDPOINT_NAME following the project's existing patterns. Include:

1. Route/view implementation
2. Request/response models
3. Input validation
4. Error handling
5. Unit tests
6. API documentation
7. Database operations if needed

Follow the existing project structure and coding standards."

echo "✅ API endpoint generation request sent to Claude"
EOF
            chmod +x .claude/workflows/api-generator.sh
            ;;
        *"flutter"*)
            cat > .claude/workflows/screen-generator.sh << 'EOF'
#!/bin/bash

# Flutter Screen Generator Workflow
SCREEN_NAME="$1"

if [[ -z "$SCREEN_NAME" ]]; then
    echo "Usage: $0 <screen-name>"
    echo "Example: $0 ProfileScreen"
    exit 1
fi

echo "📱 Generating Flutter screen: $SCREEN_NAME"

claude -p "Generate a Flutter screen named $SCREEN_NAME following the project's existing patterns. Include:

1. Screen widget implementation
2. Riverpod provider for state management
3. Model classes if needed
4. Navigation integration
5. Widget tests
6. Responsive design considerations

Follow the existing project structure and coding standards."

echo "✅ Screen generation request sent to Claude"
EOF
            chmod +x .claude/workflows/screen-generator.sh
            ;;
    esac
}

# Make script executable
chmod +x "$0"

# Execute setup
setup_workflows "$PROJECT_DIR" "$TECH_STACK" "$PROJECT_COMPLEXITY"