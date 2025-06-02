#!/bin/bash

# Technology Stack Detection Script
# Analyzes project files to determine the primary technology stack

detect_tech_stack() {
    local tech_stack=""
    local confidence=0
    local max_confidence=0
    local best_match=""
    
    # Check for package.json (Node.js/JavaScript ecosystem)
    if [[ -f "package.json" ]]; then
        if grep -q "react" package.json; then
            echo "react-frontend"
            return
        elif grep -q "vue" package.json; then
            echo "vue-frontend"
            return
        elif grep -q "angular" package.json; then
            echo "angular-frontend"
            return
        elif grep -q "next" package.json; then
            echo "nextjs-fullstack"
            return
        elif grep -q "express\|fastify\|koa" package.json; then
            echo "nodejs-backend"
            return
        elif grep -q "electron" package.json; then
            echo "electron-desktop"
            return
        else
            echo "nodejs-general"
            return
        fi
    fi
    
    # Check for Python
    if [[ -f "requirements.txt" || -f "pyproject.toml" || -f "Pipfile" || -f "setup.py" ]]; then
        if [[ -f "manage.py" ]] || grep -q "django" requirements.txt 2>/dev/null; then
            echo "django-backend"
            return
        elif grep -q "flask" requirements.txt 2>/dev/null || [[ -f "app.py" ]]; then
            echo "flask-backend"
            return
        elif grep -q "fastapi" requirements.txt 2>/dev/null; then
            echo "fastapi-backend"
            return
        elif grep -q "streamlit\|gradio\|jupyter" requirements.txt 2>/dev/null; then
            echo "python-datascience"
            return
        else
            echo "python-general"
            return
        fi
    fi
    
    # Check for Flutter/Dart
    if [[ -f "pubspec.yaml" ]]; then
        echo "flutter-mobile"
        return
    fi
    
    # Check for Go
    if [[ -f "go.mod" ]]; then
        echo "go-backend"
        return
    fi
    
    # Check for Rust
    if [[ -f "Cargo.toml" ]]; then
        echo "rust-general"
        return
    fi
    
    # Check for Java
    if [[ -f "pom.xml" ]]; then
        echo "java-maven"
        return
    elif [[ -f "build.gradle" ]]; then
        echo "java-gradle"
        return
    fi
    
    # Check for .NET
    if [[ -f "*.csproj" || -f "*.sln" ]]; then
        echo "dotnet-general"
        return
    fi
    
    # Check for PHP
    if [[ -f "composer.json" ]]; then
        if grep -q "laravel" composer.json; then
            echo "php-laravel"
            return
        elif grep -q "symfony" composer.json; then
            echo "php-symfony"
            return
        else
            echo "php-general"
            return
        fi
    fi
    
    # Check for Ruby
    if [[ -f "Gemfile" ]]; then
        if grep -q "rails" Gemfile; then
            echo "ruby-rails"
            return
        else
            echo "ruby-general"
            return
        fi
    fi
    
    # Check for Docker
    if [[ -f "Dockerfile" || -f "docker-compose.yml" ]]; then
        echo "docker-containerized"
        return
    fi
    
    # Check for common frontend files
    if [[ -f "index.html" ]]; then
        if [[ -d "src" ]] && find src -name "*.js" -o -name "*.ts" | head -1 | grep -q .; then
            echo "javascript-frontend"
            return
        else
            echo "static-website"
            return
        fi
    fi
    
    # Check for infrastructure as code
    if [[ -f "terraform.tf" || -f "main.tf" ]]; then
        echo "terraform-infrastructure"
        return
    fi
    
    if [[ -f "ansible.yml" || -f "playbook.yml" ]]; then
        echo "ansible-automation"
        return
    fi
    
    # Default fallback
    echo "general-purpose"
}

# Execute detection
detect_tech_stack