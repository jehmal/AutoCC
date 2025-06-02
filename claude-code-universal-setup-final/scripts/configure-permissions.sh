#!/bin/bash

# Tool Permissions Configuration Script
# Configures Claude Code tool permissions based on technology stack

TECH_STACK="$1"
ENTERPRISE="$2"
SECURITY_STRICT="$3"

configure_permissions() {
    local tech_stack="$1"
    local enterprise="$2"
    local security_strict="$3"
    
    # Base permissions (always needed)
    local base_tools="Read,Write,Edit,MultiEdit,Glob,Grep,LS,TodoWrite,TodoRead,Task,WebSearch,WebFetch"
    
    # Git operations (usually safe)
    local git_tools="Bash(git status:*),Bash(git diff:*),Bash(git log:*),Bash(git branch:*),Bash(git checkout:*),Bash(git add:*),Bash(git commit:*)"
    
    # File operations
    local file_tools="Bash(ls:*),Bash(cat:*),Bash(head:*),Bash(tail:*),Bash(find:*),Bash(grep:*),Bash(mkdir:*),Bash(cp:*),Bash(mv:*)"
    
    # Tech stack specific tools
    local tech_tools=""
    
    case "$tech_stack" in
        *"react"*|*"vue"*|*"angular"*|*"nextjs"*|*"javascript"*|*"frontend"*)
            tech_tools="Bash(npm:*),Bash(yarn:*),Bash(pnpm:*),Bash(node:*),Bash(npx:*)"
            if [[ "$tech_stack" == *"nextjs"* ]]; then
                tech_tools="$tech_tools,Bash(vercel:*)"
            fi
            ;;
        *"nodejs"*|*"express"*|*"fastify"*)
            tech_tools="Bash(npm:*),Bash(yarn:*),Bash(node:*),Bash(npx:*),Bash(nodemon:*)"
            ;;
        *"python"*|*"django"*|*"flask"*|*"fastapi"*)
            tech_tools="Bash(python:*),Bash(python3:*),Bash(pip:*),Bash(pip3:*),Bash(poetry:*),Bash(pipenv:*)"
            if [[ "$tech_stack" == *"django"* ]]; then
                tech_tools="$tech_tools,Bash(python manage.py:*)"
            fi
            ;;
        *"flutter"*|*"dart"*)
            tech_tools="Bash(flutter:*),Bash(dart:*),Bash(pod:*),Bash(gradlew:*)"
            ;;
        *"go"*)
            tech_tools="Bash(go:*),Bash(gofmt:*),Bash(go mod:*)"
            ;;
        *"rust"*)
            tech_tools="Bash(cargo:*),Bash(rustc:*),Bash(rustfmt:*)"
            ;;
        *"java"*)
            tech_tools="Bash(mvn:*),Bash(gradle:*),Bash(java:*),Bash(javac:*)"
            ;;
        *"dotnet"*)
            tech_tools="Bash(dotnet:*),Bash(nuget:*)"
            ;;
        *"php"*)
            tech_tools="Bash(php:*),Bash(composer:*)"
            if [[ "$tech_stack" == *"laravel"* ]]; then
                tech_tools="$tech_tools,Bash(php artisan:*)"
            fi
            ;;
        *"ruby"*)
            tech_tools="Bash(ruby:*),Bash(gem:*),Bash(bundle:*)"
            if [[ "$tech_stack" == *"rails"* ]]; then
                tech_tools="$tech_tools,Bash(rails:*),Bash(rake:*)"
            fi
            ;;
    esac
    
    # Docker tools (if Docker is detected)
    local docker_tools=""
    if [[ -f "Dockerfile" || -f "docker-compose.yml" ]]; then
        if [[ "$security_strict" == "true" ]]; then
            docker_tools="Bash(docker ps:*),Bash(docker logs:*),Bash(docker-compose ps:*),Bash(docker-compose logs:*)"
        else
            docker_tools="Bash(docker:*),Bash(docker-compose:*)"
        fi
    fi
    
    # Database tools (if database config is detected)
    local db_tools=""
    if grep -q "postgres\|postgresql" . -r 2>/dev/null; then
        db_tools="$db_tools,Bash(psql:*)"
    fi
    if grep -q "mysql" . -r 2>/dev/null; then
        db_tools="$db_tools,Bash(mysql:*)"
    fi
    if grep -q "redis" . -r 2>/dev/null; then
        db_tools="$db_tools,Bash(redis-cli:*)"
    fi
    if grep -q "mongodb\|mongo" . -r 2>/dev/null; then
        db_tools="$db_tools,Bash(mongo:*),Bash(mongosh:*)"
    fi
    
    # Enterprise tools
    local enterprise_tools=""
    if [[ "$enterprise" == "true" ]]; then
        enterprise_tools="Bash(kubectl:*),Bash(helm:*),Bash(terraform:*),Bash(ansible:*)"
    fi
    
    # Combine all tools
    local all_tools="$base_tools"
    
    if [[ "$security_strict" != "true" ]]; then
        all_tools="$all_tools,$git_tools,$file_tools"
    else
        # Restricted git operations for strict security
        all_tools="$all_tools,Bash(git status:*),Bash(git diff:*),Bash(git log:*)"
        # Restricted file operations
        all_tools="$all_tools,Bash(ls:*),Bash(cat:*),Bash(head:*),Bash(tail:*)"
    fi
    
    [[ -n "$tech_tools" ]] && all_tools="$all_tools,$tech_tools"
    [[ -n "$docker_tools" ]] && all_tools="$all_tools,$docker_tools"
    [[ -n "$db_tools" ]] && all_tools="$all_tools,$db_tools"
    [[ -n "$enterprise_tools" ]] && all_tools="$all_tools,$enterprise_tools"
    
    # Set the permissions
    claude config set allowed-tools "$all_tools"
    
    echo "Configured permissions for: $tech_stack"
    echo "Enterprise mode: $enterprise"
    echo "Security strict: $security_strict"
    echo "Tools configured: $(echo "$all_tools" | tr ',' '\n' | wc -l) tools"
}

# Make script executable
chmod +x "$0"

# Execute configuration
configure_permissions "$TECH_STACK" "$ENTERPRISE" "$SECURITY_STRICT"