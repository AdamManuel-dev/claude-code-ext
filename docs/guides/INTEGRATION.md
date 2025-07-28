# Integration Patterns Guide

Complete guide for integrating Claude Tools into your development workflows, build systems, and automation pipelines.

## Table of Contents
- [Quick Integration Examples](#quick-integration-examples)
- [Git Hook Integration](#git-hook-integration)
- [Build System Integration](#build-system-integration)
- [CI/CD Pipeline Integration](#cicd-pipeline-integration)
- [IDE Integration](#ide-integration)
- [Custom Workflow Examples](#custom-workflow-examples)

---

## Quick Integration Examples

### Claude Code Workflow
Perfect for Claude Code sessions where you want notifications that help you get back to work quickly.

```bash
# Task completion - click to return to project
./clickable-notification.sh "$(git branch --show-current)" "Task completed" "$(pwd)"

# Error notification with specific file
./clickable-notification.sh "error" "Type check failed" "./src/types.ts"

# Build notification with logs
./clickable-notification.sh "build" "Build complete" "./build.log"
```

### Development Session Management
```bash
# Start of work session
./send-notification.sh "session" "Work session started" true

# End of work session with reminder
./send-notification.sh "session" "Take a break! You've been coding for 2 hours"

# Code review reminder
./send-notification.sh "review" "PR ready for review - don't forget!"
```

---

## Git Hook Integration

### Pre-commit Hook
Validate code before commits with smart notifications.

```bash
# .git/hooks/pre-commit
#!/bin/bash

echo "Running pre-commit checks..."

# Run tests
if ! npm test; then
    ./tools/clickable-notification.sh "test-fail" "Tests failed - fix before commit" "./test-results.log"
    exit 1
fi

# Run linting
if ! npm run lint; then
    ./tools/clickable-notification.sh "lint-fail" "Linting failed - fix before commit" "./lint-results.log"
    exit 1
fi

./tools/send-notification.sh "pre-commit" "Pre-commit checks passed!" true
```

### Post-commit Hook
Notify about successful commits and next steps.

```bash
# .git/hooks/post-commit
#!/bin/bash

BRANCH=$(git branch --show-current)
COMMIT_MSG=$(git log -1 --pretty=%B)

# Success notification
./tools/send-notification.sh "$BRANCH" "Commit successful: $COMMIT_MSG" true

# If on feature branch, remind about push
if [[ "$BRANCH" != "main" && "$BRANCH" != "master" ]]; then
    ./tools/send-notification.sh "$BRANCH" "Ready to push? Run: git push origin $BRANCH"
fi
```

### Pre-push Hook
Final validation before pushing to remote.

```bash
# .git/hooks/pre-push
#!/bin/bash

protected_branch='main'
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# Prevent direct push to main
if [ $protected_branch = $current_branch ]; then
    ./tools/send-notification.sh "warning" "Direct push to main blocked! Use PR workflow"
    exit 1
fi

# Full test suite before push
./tools/send-notification.sh "$current_branch" "Running full test suite before push..." true

if ! npm run test:full; then
    ./tools/clickable-notification.sh "test-fail" "Full test suite failed" "./test-results.log"
    exit 1
fi

./tools/send-notification.sh "$current_branch" "Push validation complete!" true
```

---

## Build System Integration

### npm Scripts Integration
Add notifications to your package.json scripts.

```json
{
  "scripts": {
    "build": "webpack --mode production && ./tools/clickable-notification.sh \"build\" \"Build complete!\" \"./dist\"",
    "dev": "webpack serve --mode development & ./tools/send-notification.sh \"dev\" \"Dev server starting...\" true",
    "test": "jest && ./tools/send-notification.sh \"test\" \"Tests passed!\" true",
    "test:watch": "jest --watch & ./tools/send-notification.sh \"test\" \"Test watcher started\" true"
  }
}
```

### Makefile Integration
Enhance your Makefile targets with notifications.

```makefile
.PHONY: build test deploy clean notify-build notify-test notify-deploy

# Build target with notification
build: notify-build
	@echo "Building application..."
	npm run build
	./tools/clickable-notification.sh "build" "Build completed successfully!" "./dist"

# Test target with notification
test: notify-test
	@echo "Running tests..."
	npm test
	./tools/send-notification.sh "test" "All tests passed!" true

# Deploy target with notification and URL
deploy: build
	@echo "Deploying application..."
	./deploy.sh
	./tools/clickable-notification.sh "deploy" "Deployment complete!" "https://yourapp.com"

# Notification helpers
notify-build:
	./tools/send-notification.sh "build" "Build starting..." true

notify-test:
	./tools/send-notification.sh "test" "Running test suite..." true

notify-deploy:
	./tools/send-notification.sh "deploy" "Deployment in progress..." true
```

### webpack Integration
Add notifications to webpack configuration.

```javascript
// webpack.config.js
const path = require('path');
const { exec } = require('child_process');

class NotificationPlugin {
  apply(compiler) {
    compiler.hooks.done.tap('NotificationPlugin', (stats) => {
      if (stats.hasErrors()) {
        exec('./tools/clickable-notification.sh "webpack" "Build failed!" "./webpack-errors.log"');
      } else {
        exec('./tools/clickable-notification.sh "webpack" "Build successful!" "./dist"');
      }
    });
  }
}

module.exports = {
  // ... other config
  plugins: [
    new NotificationPlugin()
  ]
};
```

---

## CI/CD Pipeline Integration

### GitHub Actions
Integrate with GitHub Actions workflows.

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests
        run: npm test
        
      - name: Build application
        run: npm run build
        
      # Notification on success (requires macOS runner for local dev)
      - name: Notify success
        if: success() && runner.os == 'macOS'
        run: |
          ./tools/clickable-notification.sh "ci" "CI pipeline succeeded!" "${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
          
      # Notification on failure
      - name: Notify failure
        if: failure() && runner.os == 'macOS'
        run: |
          ./tools/send-notification.sh "ci-failure" "CI pipeline failed - check logs"
```

### Jenkins Integration
Add notifications to Jenkins pipeline.

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh 'npm ci'
                sh 'npm run build'
                sh './tools/send-notification.sh "jenkins" "Build completed" true'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
                sh './tools/send-notification.sh "jenkins" "Tests passed" true'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh './deploy.sh'
                sh './tools/clickable-notification.sh "deploy" "Deployment complete!" "${BUILD_URL}"'
            }
        }
    }
    
    post {
        success {
            sh './tools/send-notification.sh "jenkins" "Pipeline succeeded!" true'
        }
        
        failure {
            sh './tools/send-notification.sh "jenkins-failure" "Pipeline failed - investigate immediately"'
        }
    }
}
```

---

## IDE Integration

### VS Code Tasks
Configure VS Code tasks with notifications.

```json
// .vscode/tasks.json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build with notification",
            "type": "shell",
            "command": "npm",
            "args": ["run", "build"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": ["$tsc"],
            "runOptions": {
                "runOn": "default"
            },
            "dependsOrder": "sequence",
            "dependsOn": [],
            "detail": "Build with success notification",
            "postCommand": "./tools/clickable-notification.sh \"vscode\" \"Build complete!\" \"./dist\""
        },
        {
            "label": "Test with notification",
            "type": "shell",
            "command": "npm",
            "args": ["test"],
            "group": "test",
            "postCommand": "./tools/send-notification.sh \"test\" \"Tests completed!\" true"
        }
    ]
}
```

### Cursor IDE Integration
The tools are designed specifically for Cursor IDE workflows.

```bash
# Open specific file on error
./clickable-notification.sh "error" "Syntax error in main.ts" "./src/main.ts"

# Open project root after task completion
./clickable-notification.sh "$(git branch --show-current)" "Ready for review" "$(pwd)"

# Open build output directory
./clickable-notification.sh "build" "Build artifacts ready" "./dist"
```

---

## Custom Workflow Examples

### Documentation Generation Workflow
```bash
#!/bin/bash
# generate-docs-with-notifications.sh

echo "Starting documentation generation..."
./tools/send-notification.sh "docs" "Documentation generation started" true

# Generate API docs
if typedoc --out docs/api src/; then
    ./tools/send-notification.sh "docs" "API documentation generated" true
else
    ./tools/clickable-notification.sh "docs-error" "API doc generation failed" "./typedoc.log"
    exit 1
fi

# Extract file headers
./tools/get-file-headers.sh ./src > docs/file-headers.md
./tools/send-notification.sh "docs" "File headers extracted" true

# Final notification with link to docs
./tools/clickable-notification.sh "docs" "Documentation ready!" "./docs/index.html"
```

### Code Review Preparation
```bash
#!/bin/bash
# prepare-for-review.sh

BRANCH=$(git branch --show-current)

echo "Preparing $BRANCH for code review..."
./tools/send-notification.sh "$BRANCH" "Preparing for code review..." true

# Run full test suite
if ! npm run test:full; then
    ./tools/clickable-notification.sh "review-fail" "Tests failed - fix before review" "./test-results.log"
    exit 1
fi

# Run linting and formatting
npm run lint:fix
npm run format

# Generate coverage report
npm run test:coverage
./tools/clickable-notification.sh "coverage" "Coverage report ready" "./coverage/index.html"

# Create PR notification
./tools/send-notification.sh "$BRANCH" "Ready for code review! Create PR when ready."
```

### Deployment Pipeline
```bash
#!/bin/bash
# deploy-with-notifications.sh

ENVIRONMENT=${1:-staging}

echo "Deploying to $ENVIRONMENT..."
./tools/send-notification.sh "deploy" "Deploying to $ENVIRONMENT..." true

# Build for production
if ! npm run build:prod; then
    ./tools/clickable-notification.sh "deploy-fail" "Build failed" "./build.log"
    exit 1
fi

# Run deployment
if ./scripts/deploy.sh $ENVIRONMENT; then
    DEPLOY_URL=$(cat .deploy-url)
    ./tools/clickable-notification.sh "deploy" "Deployed to $ENVIRONMENT!" "$DEPLOY_URL"
else
    ./tools/send-notification.sh "deploy-fail" "Deployment to $ENVIRONMENT failed!"
    exit 1
fi

# Schedule health check reminder
./tools/send-notification.sh "health-check" "Don't forget to verify deployment health in 5 minutes"
```

### Development Environment Setup
```bash
#!/bin/bash
# setup-dev-env.sh

echo "Setting up development environment..."
./tools/send-notification.sh "setup" "Development environment setup starting..." true

# Install dependencies
npm ci
./tools/send-notification.sh "setup" "Dependencies installed" true

# Setup database
npm run db:setup
./tools/send-notification.sh "setup" "Database configured" true

# Start development services
npm run dev &
./tools/send-notification.sh "setup" "Development server starting..." true

# Final setup complete notification
sleep 5  # Wait for services to start
./tools/clickable-notification.sh "setup" "Development environment ready!" "http://localhost:3000"
```

---

## Integration Best Practices

### Notification Management
1. **Use `skip_reminders=true`** for build/CI notifications
2. **Use reminder system** for manual tasks requiring attention
3. **Group related notifications** by using consistent branch names
4. **Clean up notifications** with `ack-notifications.sh` at session end

### Performance Considerations
1. **Avoid blocking operations** - notifications should be fast
2. **Use background notifications** for long-running processes
3. **Batch notifications** - don't spam the user
4. **Test notification permissions** before deployment

### Error Handling
1. **Always provide fallbacks** for missing dependencies
2. **Include helpful context** in error notifications
3. **Link to logs or files** when errors occur
4. **Test integration in isolation** before full deployment

### Security
1. **Validate inputs** before passing to notification scripts
2. **Use absolute paths** to avoid injection attacks
3. **Limit notification content** to avoid sensitive data exposure
4. **Test with restricted permissions** to ensure robustness

---

## Troubleshooting Integration Issues

### Common Problems
1. **Notifications not appearing**: Check macOS notification permissions
2. **Scripts not executable**: Run `chmod +x tools/*.sh`
3. **Path issues**: Use absolute paths in automation
4. **Permission errors**: Check file system access rights

### Debug Mode
Enable debug logging for integration troubleshooting:

```bash
# Check cursor-handler logs
tail -f /tmp/cursor-handler.log

# List active notification processes
jobs

# Check tracking files
ls -la /tmp/notify_*
```

### Testing Integration
```bash
# Test basic notification
./tools/send-notification.sh "test" "Integration test" true

# Test clickable notification
./tools/clickable-notification.sh "test" "Click test" "$(pwd)"

# Test acknowledgment system
./tools/ack-notifications.sh
```

---

*This integration guide provides patterns for incorporating Claude Tools into your development workflows. Adapt the examples to match your specific tools and processes.*