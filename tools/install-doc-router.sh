#!/bin/bash
##
# Documentation Router Installation Script
# Installs automated documentation routing system for Claude Code agents
#
# Usage: /install-doc-router
# Or: ~/.claude/tools/install-doc-router.sh [--source /path/to/reference]
##

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REFERENCE_REPO="${1:-$HOME/Projects/tahoma-ai}"
TARGET_REPO="$(pwd)"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Documentation Router Installation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

##
# Validation
##
validate_environment() {
    echo -e "${BLUE}📋 Step 1/7: Validating environment...${NC}"

    # Check we're in a git repository
    if [ ! -d ".git" ]; then
        echo -e "${RED}❌ Error: Not a git repository. Run 'git init' first.${NC}"
        exit 1
    fi

    # Check Node.js is installed
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Error: Node.js not found. Install Node.js 20+ first.${NC}"
        exit 1
    fi

    # Check reference repository exists
    if [ ! -d "$REFERENCE_REPO/scripts/doc-router" ]; then
        echo -e "${RED}❌ Error: Reference implementation not found at $REFERENCE_REPO${NC}"
        echo -e "${YELLOW}   Clone tahoma-ai or specify path: install-doc-router.sh /path/to/reference${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Environment validated${NC}"
    echo "   Repository: $(basename "$TARGET_REPO")"
    echo "   Node.js: $(node --version)"
    echo "   Git: $(git --version | head -1)"
    echo ""
}

##
# Detect project structure
##
detect_project_structure() {
    echo -e "${BLUE}📁 Step 2/7: Detecting project structure...${NC}"

    # Detect monorepo
    if [ -f "pnpm-workspace.yaml" ] || [ -f "lerna.json" ] || [ -f "nx.json" ]; then
        PROJECT_TYPE="monorepo"
    elif [ -f "package.json" ]; then
        PROJECT_TYPE="single-service"
    else
        PROJECT_TYPE="library"
    fi

    # Count documentation files
    DOC_COUNT=$(find . -name "*.md" -type f | grep -v node_modules | wc -l | tr -d ' ')

    # Count TypeScript files with @fileoverview
    TS_WITH_FILEOVERVIEW=$(find . -name "*.ts" -type f | grep -v node_modules | xargs grep -l "@fileoverview" 2>/dev/null | wc -l | tr -d ' ')

    echo -e "${GREEN}✅ Project structure detected${NC}"
    echo "   Type: $PROJECT_TYPE"
    echo "   Documentation files: $DOC_COUNT"
    echo "   TypeScript files with @fileoverview: $TS_WITH_FILEOVERVIEW"
    echo ""
}

##
# Copy infrastructure
##
copy_infrastructure() {
    echo -e "${BLUE}📦 Step 3/7: Copying documentation router infrastructure...${NC}"

    # Create target directory
    mkdir -p scripts/doc-router

    # Copy TypeScript files
    cp "$REFERENCE_REPO/scripts/doc-router/extract-metadata.ts" scripts/doc-router/
    cp "$REFERENCE_REPO/scripts/doc-router/build-router.ts" scripts/doc-router/
    cp "$REFERENCE_REPO/scripts/doc-router/validate-anchors.ts" scripts/doc-router/
    cp "$REFERENCE_REPO/scripts/doc-router/types.ts" scripts/doc-router/
    cp "$REFERENCE_REPO/scripts/doc-router/tsconfig.json" scripts/doc-router/
    cp "$REFERENCE_REPO/scripts/doc-router/package.json" scripts/doc-router/
    cp "$REFERENCE_REPO/scripts/doc-router/update-router.sh" scripts/doc-router/

    # Make shell script executable
    chmod +x scripts/doc-router/update-router.sh

    echo -e "${GREEN}✅ Infrastructure copied (7 files)${NC}"
    echo ""
}

##
# Generate configuration
##
generate_configuration() {
    echo -e "${BLUE}⚙️  Step 4/7: Generating repository-specific configuration...${NC}"

    # Detect services/packages
    SERVICES=$(find . -maxdepth 2 -name "package.json" -type f | grep -v node_modules | sed 's|./||' | sed 's|/package.json||' | tr '\n' ',' | sed 's/,$//')

    # Create config.json
    cat > scripts/doc-router/config.json <<EOF
{
  "rootPath": "../..",
  "outputPath": "docs",
  "paths": {
    "docs": "docs/**/*.md",
    "serviceReadmes": [
      "README.md"
    ],
    "code": [
      "src/**/*.ts",
      "packages/*/src/**/*.ts"
    ],
    "apiSpecs": [
      "docs/api/openapi.yaml",
      "docs/api/swagger.json"
    ]
  },
  "exclusions": [
    "**/node_modules/**",
    "**/dist/**",
    "**/build/**",
    "docs/archive/**",
    "**/*.test.ts",
    "**/*.spec.ts"
  ],
  "scoring": {
    "mandatory": {
      "serviceReadme": 1000,
      "adr": 1000,
      "apiSpec": 1000,
      "diataxis": 1000
    },
    "fileoverview": 10,
    "recentActivity": 5,
    "referencedInDocs": 5,
    "implementationDoc": 3,
    "openApiEndpoint": 3,
    "threshold": 200,
    "maxDocuments": 300,
    "recentActivityDays": 90
  },
  "taskMappings": {
    "authentication": ["auth", "clerk", "jwt", "token", "permission", "security"],
    "typescript": ["typescript", "types", "interface", "generic", "type-error"],
    "api": ["api", "endpoint", "rest", "graphql", "openapi", "swagger"],
    "database": ["prisma", "postgres", "mongodb", "database", "schema", "migration"],
    "testing": ["test", "jest", "vitest", "playwright", "e2e"],
    "frontend": ["react", "component", "ui", "vue", "angular"]
  },
  "domainMappings": {
    "security": ["authentication", "authorization", "encryption", "audit"],
    "api-layer": ["api", "endpoints", "middleware", "validation"],
    "data-layer": ["database", "schema", "migrations", "repositories"],
    "frontend": ["react", "components", "ui", "state-management"]
  },
  "services": []
}
EOF

    echo -e "${GREEN}✅ Configuration generated${NC}"
    echo "   Config: scripts/doc-router/config.json"
    echo ""
}

##
# Install dependencies
##
install_dependencies() {
    echo -e "${BLUE}📚 Step 5/7: Installing dependencies...${NC}"

    cd scripts/doc-router
    npm install --silent
    cd ../..

    echo -e "${GREEN}✅ Dependencies installed${NC}"
    echo ""
}

##
# Set up GitHub Actions
##
setup_github_actions() {
    echo -e "${BLUE}🔄 Step 6/7: Setting up GitHub Actions automation...${NC}"

    mkdir -p .github/workflows

    cp "$REFERENCE_REPO/.github/workflows/update-docs-router.yml" .github/workflows/

    echo -e "${GREEN}✅ GitHub Actions workflow installed${NC}"
    echo "   Workflow: .github/workflows/update-docs-router.yml"
    echo "   Triggers: On doc/code changes, manual dispatch"
    echo ""
}

##
# Generate initial router
##
generate_initial_router() {
    echo -e "${BLUE}🏗️  Step 7/7: Generating initial documentation router...${NC}"

    cd scripts/doc-router
    ./update-router.sh
    cd ../..

    echo -e "${GREEN}✅ Initial router generated${NC}"
    echo ""
}

##
# Add @anchor convention to CLAUDE.md
##
update_claude_md() {
    local REPO_CLAUDE_MD="$TARGET_REPO/CLAUDE.md"

    # Check if repository has CLAUDE.md
    if [ -f "$REPO_CLAUDE_MD" ]; then
        echo -e "${BLUE}📝 Adding @anchor convention to repository CLAUDE.md...${NC}"

        # Check if @anchor section already exists
        if grep -q "Code Anchors (@anchor)" "$REPO_CLAUDE_MD"; then
            echo -e "${YELLOW}⚠️  @anchor convention already exists in CLAUDE.md, skipping${NC}"
        else
            # Add @anchor section (simplified version for project-level CLAUDE.md)
            cat >> "$REPO_CLAUDE_MD" <<'EOF'

## 📎 Code Anchors (@anchor) Convention

**Purpose**: Enable stable links from documentation to code without brittle line numbers.

**Usage**: Add `@anchor AnchorName` to JSDoc comments for important code that docs reference:

```typescript
/**
 * @fileoverview User authentication service
 * @anchor UserAuthService
 */
export class UserAuthService {
  /**
   * @anchor authenticateUser
   */
  async authenticateUser(credentials: Credentials): Promise<User> {
    // Implementation
  }
}
```

**Linking from docs**:
```markdown
See [@UserAuthService](src/services/UserAuthService.ts@UserAuthService)
```

**Naming Rules**:
- Classes/Interfaces/Types: `PascalCase`
- Functions/Methods: `camelCase`

See generated `docs/AGENT_ROUTER.md` for navigation.
EOF
            echo -e "${GREEN}✅ Added @anchor convention to CLAUDE.md${NC}"
        fi
        echo ""
    fi
}

##
# Print summary
##
print_summary() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✅ Documentation Router Installed Successfully!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}📄 Generated Files:${NC}"
    echo "   ✓ docs/AGENT_ROUTER.md - Master routing document"
    echo "   ✓ docs/AGENT_METADATA.json - Machine-readable index"
    echo "   ✓ docs/AGENT_QUICK_LOOKUP.md - Quick reference"
    echo ""
    echo -e "${BLUE}🛠️  Infrastructure:${NC}"
    echo "   ✓ scripts/doc-router/ - Automation scripts (7 files)"
    echo "   ✓ .github/workflows/update-docs-router.yml - CI/CD"
    echo ""
    echo -e "${BLUE}📊 Router Statistics:${NC}"

    if [ -f "docs/AGENT_METADATA.json" ]; then
        TOTAL_DOCS=$(jq '.totalDocuments' docs/AGENT_METADATA.json)
        echo "   ✓ $TOTAL_DOCS documents indexed"
    fi

    if [ -f "docs/AGENT_ROUTER.md" ]; then
        ROUTER_SIZE=$(wc -c < docs/AGENT_ROUTER.md | awk '{printf "%.2f", $1/1024}')
        echo "   ✓ Router size: ${ROUTER_SIZE} KB"
    fi

    echo ""
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo "   1. Review docs/AGENT_ROUTER.md for quality"
    echo "   2. Customize scripts/doc-router/config.json for your project"
    echo "   3. Add @anchor tags to frequently-referenced code files"
    echo "   4. Commit changes:"
    echo -e "      ${YELLOW}git add . && git commit -m \"feat(docs): add documentation router\"${NC}"
    echo "   5. Push to trigger GitHub Actions auto-update"
    echo ""
    echo -e "${BLUE}📚 Usage:${NC}"
    echo "   - Claude Code agents will use docs/AGENT_ROUTER.md for navigation"
    echo "   - Update router manually: cd scripts/doc-router && ./update-router.sh"
    echo "   - Router auto-updates on every doc/code push via GitHub Actions"
    echo ""
    echo -e "${BLUE}🔗 Reference:${NC}"
    echo "   - Implementation: $REFERENCE_REPO"
    echo "   - Design doc: ~/.claude/plans/abstract-cooking-pudding.md"
    echo ""
}

##
# Main installation flow
##
main() {
    validate_environment
    detect_project_structure
    copy_infrastructure
    generate_configuration
    install_dependencies
    setup_github_actions
    generate_initial_router
    update_claude_md
    print_summary
}

# Run installation
main "$@"
