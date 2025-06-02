#!/bin/bash

# Test Projects Generator
# Creates sample projects for testing Claude Code Universal Setup

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

EXAMPLES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_PROJECTS_DIR="$EXAMPLES_DIR/test-projects"

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Create test projects directory
create_test_projects_dir() {
    log "Creating test projects directory..."
    rm -rf "$TEST_PROJECTS_DIR"
    mkdir -p "$TEST_PROJECTS_DIR"
    cd "$TEST_PROJECTS_DIR"
}

# Create React TypeScript project
create_react_project() {
    log "Creating React TypeScript project..."
    
    mkdir -p react-typescript-app
    cd react-typescript-app
    
    cat > package.json << 'EOF'
{
  "name": "react-typescript-app",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@types/node": "^16.7.13",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "typescript": "^4.4.2",
    "web-vitals": "^2.1.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "lint": "eslint src --ext .ts,.tsx"
  },
  "devDependencies": {
    "@testing-library/jest-dom": "^5.14.1",
    "@testing-library/react": "^13.0.0",
    "@testing-library/user-event": "^13.2.1",
    "eslint": "^8.0.0",
    "@typescript-eslint/eslint-plugin": "^5.0.0",
    "@typescript-eslint/parser": "^5.0.0"
  }
}
EOF

    mkdir -p src public
    
    cat > src/App.tsx << 'EOF'
import React from 'react';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>React TypeScript App</h1>
        <p>Test project for Claude Code Universal Setup</p>
      </header>
    </div>
  );
}

export default App;
EOF

    cat > src/index.tsx << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

    cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>React TypeScript App</title>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
EOF

    cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "es5",
    "lib": [
      "dom",
      "dom.iterable",
      "es6"
    ],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": [
    "src"
  ]
}
EOF

    log_success "Created React TypeScript project"
    cd ..
}

# Create Python Flask project
create_python_flask_project() {
    log "Creating Python Flask project..."
    
    mkdir -p python-flask-api
    cd python-flask-api
    
    cat > requirements.txt << 'EOF'
Flask==2.3.2
Flask-SQLAlchemy==3.0.5
Flask-Migrate==4.0.4
python-dotenv==1.0.0
pytest==7.4.0
black==23.3.0
flake8==6.0.0
EOF

    cat > app.py << 'EOF'
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///app.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)

@app.route('/api/users', methods=['GET'])
def get_users():
    users = User.query.all()
    return jsonify([{'id': u.id, 'username': u.username, 'email': u.email} for u in users])

@app.route('/api/users', methods=['POST'])
def create_user():
    data = request.get_json()
    user = User(username=data['username'], email=data['email'])
    db.session.add(user)
    db.session.commit()
    return jsonify({'id': user.id, 'username': user.username, 'email': user.email}), 201

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
EOF

    cat > .env.example << 'EOF'
DATABASE_URL=sqlite:///app.db
FLASK_ENV=development
FLASK_DEBUG=1
EOF

    mkdir -p tests
    cat > tests/test_app.py << 'EOF'
import pytest
from app import app, db

@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    
    with app.test_client() as client:
        with app.app_context():
            db.create_all()
        yield client

def test_get_users_empty(client):
    response = client.get('/api/users')
    assert response.status_code == 200
    assert response.json == []

def test_create_user(client):
    user_data = {'username': 'testuser', 'email': 'test@example.com'}
    response = client.post('/api/users', json=user_data)
    assert response.status_code == 201
    assert 'id' in response.json
EOF

    log_success "Created Python Flask project"
    cd ..
}

# Create Flutter project
create_flutter_project() {
    log "Creating Flutter project..."
    
    mkdir -p flutter-mobile-app
    cd flutter-mobile-app
    
    cat > pubspec.yaml << 'EOF'
name: flutter_mobile_app
description: Test Flutter project for Claude Code Universal Setup
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.1.1
  
  # UI Components
  cupertino_icons: ^1.0.2
  material_design_icons_flutter: ^7.0.7296
  
  # Network
  dio: ^5.2.1+1
  
  # Utils
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
  
  # Code Generation
  riverpod_generator: ^2.2.3
  build_runner: ^2.4.6

flutter:
  uses-material-design: true
EOF

    mkdir -p lib
    cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Mobile App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Test project for Claude Code Universal Setup',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
EOF

    mkdir -p test
    cat > test/widget_test.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
EOF

    log_success "Created Flutter project"
    cd ..
}

# Create Node.js Express project
create_nodejs_express_project() {
    log "Creating Node.js Express project..."
    
    mkdir -p nodejs-express-api
    cd nodejs-express-api
    
    cat > package.json << 'EOF'
{
  "name": "nodejs-express-api",
  "version": "1.0.0",
  "description": "Test Express API for Claude Code Universal Setup",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "jest",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.6.1",
    "supertest": "^6.3.3",
    "eslint": "^8.45.0"
  }
}
EOF

    cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.get('/api/users', (req, res) => {
  const users = [
    { id: 1, name: 'John Doe', email: 'john@example.com' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
  ];
  res.json(users);
});

app.post('/api/users', (req, res) => {
  const { name, email } = req.body;
  
  if (!name || !email) {
    return res.status(400).json({ error: 'Name and email are required' });
  }
  
  const newUser = {
    id: Date.now(),
    name,
    email
  };
  
  res.status(201).json(newUser);
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;
EOF

    cat > .env.example << 'EOF'
PORT=3000
NODE_ENV=development
EOF

    mkdir -p tests
    cat > tests/server.test.js << 'EOF'
const request = require('supertest');
const app = require('../server');

describe('API Endpoints', () => {
  test('GET /api/health should return OK status', async () => {
    const response = await request(app)
      .get('/api/health')
      .expect(200);
    
    expect(response.body.status).toBe('OK');
    expect(response.body.timestamp).toBeDefined();
  });

  test('GET /api/users should return users array', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect(200);
    
    expect(Array.isArray(response.body)).toBe(true);
    expect(response.body.length).toBeGreaterThan(0);
  });

  test('POST /api/users should create new user', async () => {
    const newUser = {
      name: 'Test User',
      email: 'test@example.com'
    };

    const response = await request(app)
      .post('/api/users')
      .send(newUser)
      .expect(201);
    
    expect(response.body.name).toBe(newUser.name);
    expect(response.body.email).toBe(newUser.email);
    expect(response.body.id).toBeDefined();
  });
});
EOF

    log_success "Created Node.js Express project"
    cd ..
}

# Create Go project
create_go_project() {
    log "Creating Go project..."
    
    mkdir -p go-api-server
    cd go-api-server
    
    cat > go.mod << 'EOF'
module go-api-server

go 1.21

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/stretchr/testify v1.8.4
)
EOF

    cat > main.go << 'EOF'
package main

import (
    "net/http"
    "strconv"
    "github.com/gin-gonic/gin"
)

type User struct {
    ID    int    `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
}

var users = []User{
    {ID: 1, Name: "John Doe", Email: "john@example.com"},
    {ID: 2, Name: "Jane Smith", Email: "jane@example.com"},
}
var nextID = 3

func main() {
    r := gin.Default()
    
    r.GET("/api/health", healthCheck)
    r.GET("/api/users", getUsers)
    r.POST("/api/users", createUser)
    r.GET("/api/users/:id", getUserByID)
    
    r.Run(":8080")
}

func healthCheck(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "status": "OK",
        "message": "Go API Server is running",
    })
}

func getUsers(c *gin.Context) {
    c.JSON(http.StatusOK, users)
}

func createUser(c *gin.Context) {
    var newUser User
    if err := c.ShouldBindJSON(&newUser); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    
    newUser.ID = nextID
    nextID++
    users = append(users, newUser)
    
    c.JSON(http.StatusCreated, newUser)
}

func getUserByID(c *gin.Context) {
    idParam := c.Param("id")
    id, err := strconv.Atoi(idParam)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
        return
    }
    
    for _, user := range users {
        if user.ID == id {
            c.JSON(http.StatusOK, user)
            return
        }
    }
    
    c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
}
EOF

    mkdir -p tests
    cat > main_test.go << 'EOF'
package main

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
    "github.com/gin-gonic/gin"
    "github.com/stretchr/testify/assert"
)

func setupRouter() *gin.Engine {
    gin.SetMode(gin.TestMode)
    r := gin.Default()
    
    r.GET("/api/health", healthCheck)
    r.GET("/api/users", getUsers)
    r.POST("/api/users", createUser)
    r.GET("/api/users/:id", getUserByID)
    
    return r
}

func TestHealthCheck(t *testing.T) {
    router := setupRouter()
    
    w := httptest.NewRecorder()
    req, _ := http.NewRequest("GET", "/api/health", nil)
    router.ServeHTTP(w, req)
    
    assert.Equal(t, 200, w.Code)
    
    var response map[string]string
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.NoError(t, err)
    assert.Equal(t, "OK", response["status"])
}

func TestGetUsers(t *testing.T) {
    router := setupRouter()
    
    w := httptest.NewRecorder()
    req, _ := http.NewRequest("GET", "/api/users", nil)
    router.ServeHTTP(w, req)
    
    assert.Equal(t, 200, w.Code)
    
    var response []User
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.NoError(t, err)
    assert.Greater(t, len(response), 0)
}

func TestCreateUser(t *testing.T) {
    router := setupRouter()
    
    user := User{Name: "Test User", Email: "test@example.com"}
    jsonValue, _ := json.Marshal(user)
    
    w := httptest.NewRecorder()
    req, _ := http.NewRequest("POST", "/api/users", bytes.NewBuffer(jsonValue))
    req.Header.Set("Content-Type", "application/json")
    router.ServeHTTP(w, req)
    
    assert.Equal(t, 201, w.Code)
    
    var response User
    err := json.Unmarshal(w.Body.Bytes(), &response)
    assert.NoError(t, err)
    assert.Equal(t, user.Name, response.Name)
    assert.Equal(t, user.Email, response.Email)
    assert.NotZero(t, response.ID)
}
EOF

    log_success "Created Go project"
    cd ..
}

# Create documentation for test projects
create_documentation() {
    log "Creating documentation..."
    
    cat > README.md << 'EOF'
# Test Projects for Claude Code Universal Setup

This directory contains sample projects for testing and demonstrating Claude Code Universal Setup across different technology stacks.

## Available Test Projects

### 1. React TypeScript App (`react-typescript-app/`)
- **Tech Stack**: React 18 + TypeScript + ESLint
- **Features**: Modern React hooks, TypeScript configuration, linting setup
- **Test Command**: `npm test`
- **Dev Command**: `npm start`

### 2. Python Flask API (`python-flask-api/`)
- **Tech Stack**: Flask + SQLAlchemy + pytest
- **Features**: REST API, database models, testing setup
- **Test Command**: `pytest`
- **Dev Command**: `python app.py`

### 3. Flutter Mobile App (`flutter-mobile-app/`)
- **Tech Stack**: Flutter + Riverpod + Material Design
- **Features**: State management, responsive UI, widget testing
- **Test Command**: `flutter test`
- **Dev Command**: `flutter run`

### 4. Node.js Express API (`nodejs-express-api/`)
- **Tech Stack**: Express + Jest + ESLint
- **Features**: REST API, middleware, comprehensive testing
- **Test Command**: `npm test`
- **Dev Command**: `npm run dev`

### 5. Go API Server (`go-api-server/`)
- **Tech Stack**: Go + Gin + Testify
- **Features**: HTTP server, JSON API, unit testing
- **Test Command**: `go test`
- **Dev Command**: `go run main.go`

## Testing Claude Code Universal Setup

To test the setup on any project:

```bash
# Navigate to a test project
cd react-typescript-app

# Clone and run the universal setup
git clone https://github.com/[username]/claude-code-universal-setup.git .claude-setup
./.claude-setup/auto-setup.sh

# Verify the setup
./.claude-setup/scripts/verify-setup.sh .

# Try the generated workflows
./.claude/workflows/daily-setup.sh
./.claude/workflows/quality-check.sh

# Test Claude Code integration
claude -p "Analyze this project and suggest improvements"
```

## Expected Results

After running the universal setup on each project, you should have:

- ✅ **Project Documentation**: `CLAUDE.md` with project-specific guidance
- ✅ **Automated Workflows**: Scripts in `.claude/workflows/` for common tasks
- ✅ **Quality Gates**: Automated testing and linting integration
- ✅ **Claude Code Configuration**: Optimized tool permissions and settings
- ✅ **CI/CD Templates**: GitHub Actions workflows for automation
- ✅ **Setup Report**: Detailed summary in `.claude-setup-report.md`

## Verification Commands

For each project, verify the setup works correctly:

```bash
# Check file structure
ls -la .claude/workflows/
cat CLAUDE.md
cat .claude-setup-report.md

# Test workflows
./.claude/workflows/daily-setup.sh
./.claude/workflows/quality-check.sh

# Test Claude Code integration
claude config get project-name
claude config get allowed-tools
claude -p "Show me the project structure and suggest next steps"
```

## Performance Benchmarks

Track setup performance across different project types:

- **Small Projects** (< 50 files): Setup completes in < 30 seconds
- **Medium Projects** (50-500 files): Setup completes in < 60 seconds
- **Large Projects** (500+ files): Setup completes in < 120 seconds

## Troubleshooting

If setup fails on any test project:

1. Check prerequisites are installed
2. Verify file permissions
3. Run with verbose output: `./.claude-setup/auto-setup.sh --verbose`
4. Check the troubleshooting guide: `./.claude-setup/docs/troubleshooting.md`

## Contributing

Add new test projects by:

1. Creating a new directory with realistic project structure
2. Adding appropriate configuration files (package.json, requirements.txt, etc.)
3. Including basic tests and development scripts
4. Updating this README with project details

---

*These test projects validate that Claude Code Universal Setup works correctly across diverse technology stacks and project configurations.*
EOF

    log_success "Created documentation"
}

# Generate all test projects
generate_all_projects() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                  ║"
    echo "║        🧪 Generating Test Projects for Claude Code Setup 🚀     ║"
    echo "║                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    create_test_projects_dir
    
    create_react_project
    create_python_flask_project
    create_flutter_project
    create_nodejs_express_project
    create_go_project
    create_documentation
    
    echo ""
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                  ║"
    echo "║                🎉 Test Projects Generated! 🎉                   ║"
    echo "║                                                                  ║"
    echo "║              Ready for Claude Code Universal Setup               ║"
    echo "║                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo ""
    echo -e "${YELLOW}📂 Generated Projects:${NC}"
    echo "  📁 react-typescript-app     - React + TypeScript frontend"
    echo "  📁 python-flask-api         - Python Flask REST API"
    echo "  📁 flutter-mobile-app       - Flutter mobile application"
    echo "  📁 nodejs-express-api       - Node.js Express backend"
    echo "  📁 go-api-server           - Go HTTP server"
    echo ""
    echo -e "${YELLOW}🧪 Test Each Project:${NC}"
    echo "  cd $TEST_PROJECTS_DIR/[project-name]"
    echo "  git clone https://github.com/[username]/claude-code-universal-setup.git .claude-setup"
    echo "  ./.claude-setup/auto-setup.sh"
    echo ""
}

# Command line interface
case "${1:-}" in
    --help|-h)
        echo "Test Projects Generator for Claude Code Universal Setup"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  generate    Generate all test projects (default)"
        echo "  clean       Remove all test projects"
        echo "  --help      Show this help message"
        echo ""
        exit 0
        ;;
    clean)
        log "Cleaning test projects..."
        rm -rf "$TEST_PROJECTS_DIR"
        log_success "Test projects cleaned"
        ;;
    generate|"")
        generate_all_projects
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac