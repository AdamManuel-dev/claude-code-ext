#!/usr/bin/env bash
# Vibe Coding Workflow - Fixed Version
# Execute comprehensive development workflow with quality gates

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Workflow state
WORKFLOW_LOG=".vibe-workflow.log"
WORKFLOW_STATE=".vibe-workflow-state.json"
CURRENT_BRANCH=""

# Initialize workflow log
init_workflow() {
    echo "[$(date)] Workflow started" > "$WORKFLOW_LOG"
    echo '{"phase": "planning", "step": 1, "completed_tasks": []}' > "$WORKFLOW_STATE"
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
}

# Function to wait for user confirmation
wait_for_user() {
    echo ""
    echo -e "${YELLOW}✋ $1${NC}"
    echo "Press ENTER to continue..."
    read -r
}

# Function to log phase completion
log_phase() {
    echo "[$(date)] Phase completed: $1" >> "$WORKFLOW_LOG"
    echo -e "${GREEN}✓ Phase logged: $1${NC}"
}

# Function to display current status
show_status() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Fixed execute_command that actually runs commands
execute_command() {
    local cmd="$1"
    local description="$2"
    local skip_execution="${3:-false}"
    
    echo -e "${PURPLE}→ Executing: $description${NC}"
    echo -e "${CYAN}Command: $cmd${NC}"
    echo ""
    
    # Skip execution for placeholder commands
    if [[ "$skip_execution" != "true" ]]; then
        eval "$cmd"
        local exit_code=$?
        if [[ $exit_code -ne 0 ]]; then
            echo -e "${RED}✗ Command failed with exit code $exit_code${NC}"
            return $exit_code
        fi
    fi
}

# Check if npm script exists
npm_script_exists() {
    local script_name="$1"
    npm run | grep -q "  $script_name$"
}

# Ensure feature branch exists
ensure_feature_branch() {
    local branch_name="${1:-feature/auto-implementation}"
    
    if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
        echo -e "${YELLOW}Creating feature branch: $branch_name${NC}"
        git checkout -b "$branch_name"
    else
        echo -e "${GREEN}Feature branch exists: $branch_name${NC}"
    fi
}

# Main workflow execution
main() {
    clear
    echo -e "${GREEN}🚀 Starting Vibe Coding Workflow (Fixed Version)${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""
    
    init_workflow
    
    # Check git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not in a git repository${NC}"
        echo "Please initialize a git repository first: git init"
        exit 1
    fi
    
    # Check Node.js project
    if [[ ! -f "package.json" ]]; then
        echo -e "${RED}Error: No package.json found${NC}"
        echo "Please ensure you're in a Node.js project directory"
        exit 1
    fi
    
    # PHASE 1: Research & Planning
    show_status "📚 PHASE 1: Research & Planning"
    
    echo -e "${BLUE}Since many planning steps require manual work, we'll guide you through them${NC}"
    echo ""
    
    # Guide through planning steps
    echo -e "${BLUE}1. Planning Steps to Complete:${NC}"
    echo "  • Create a PRD document"
    echo "  • Break down into task-list.md"
    echo "  • Add dependencies → detailed-task-list.md"
    echo "  • Identify critical-success-tasks.md"
    echo "  • Synthesize → project-prd-detailed.md"
    echo "  • Update README.md"
    echo "  • Document use cases"
    echo "  • Generate TODO.md"
    
    wait_for_user "Have you completed the planning documents?"
    
    # Check if TODO.md exists
    if [[ ! -f "TODO.md" ]]; then
        echo -e "${YELLOW}TODO.md not found. Creating from template...${NC}"
        echo "# TODO List" > TODO.md
        echo "" >> TODO.md
        echo "## High Priority" >> TODO.md
        echo "- [ ] Set up initial project structure" >> TODO.md
        echo "- [ ] Implement core functionality" >> TODO.md
        echo "" >> TODO.md
        echo "## Medium Priority" >> TODO.md
        echo "- [ ] Add tests" >> TODO.md
        echo "- [ ] Add documentation" >> TODO.md
    fi
    
    log_phase "Planning Phase Complete"
    
    # PHASE 2: Development Cycle
    echo ""
    show_status "🔧 PHASE 2: Development Cycle"
    
    # Create feature branch
    ensure_feature_branch
    
    wait_for_user "Planning complete. Start development cycle?"
    
    # Development loop
    while true; do
        echo ""
        echo -e "${BLUE}📋 Current TODO items:${NC}"
        head -n 10 TODO.md
        echo ""
        
        wait_for_user "Ready to work on next task?"
        
        # Initial coding
        echo ""
        echo -e "${BLUE}💻 Implement your solution${NC}"
        wait_for_user "Press ENTER when implementation is ready for checks"
        
        # Type checking
        if npm_script_exists "typecheck"; then
            echo ""
            echo -e "${BLUE}🔤 Running Type Check...${NC}"
            if execute_command "npm run typecheck" "Check for TypeScript errors"; then
                echo -e "${GREEN}✓ Type check passed${NC}"
            else
                echo -e "${RED}✗ Type errors found${NC}"
                wait_for_user "Would you like to fix them manually? (or press ENTER to continue)"
            fi
        else
            echo -e "${YELLOW}⚠ No typecheck script found, skipping${NC}"
        fi
        
        # Testing
        if npm_script_exists "test"; then
            echo ""
            echo -e "${BLUE}🧪 Running Tests...${NC}"
            if execute_command "npm test" "Run test suite"; then
                echo -e "${GREEN}✓ Tests passed${NC}"
            else
                echo -e "${RED}✗ Tests failing${NC}"
                wait_for_user "Would you like to fix them manually? (or press ENTER to continue)"
            fi
        else
            echo -e "${YELLOW}⚠ No test script found, skipping${NC}"
        fi
        
        # Linting
        if npm_script_exists "lint"; then
            echo ""
            echo -e "${BLUE}✨ Running Lint Check...${NC}"
            if execute_command "npm run lint" "Check code style"; then
                echo -e "${GREEN}✓ Lint check passed${NC}"
            else
                echo -e "${YELLOW}⚠ Lint issues found${NC}"
                wait_for_user "Would you like to fix them manually? (or press ENTER to continue)"
            fi
        else
            echo -e "${YELLOW}⚠ No lint script found, skipping${NC}"
        fi
        
        # Commit
        echo ""
        echo -e "${BLUE}💾 Creating Commit...${NC}"
        echo -e "${CYAN}Current changes:${NC}"
        git status --short
        
        wait_for_user "Ready to commit these changes?"
        
        read -p "Enter commit message: " commit_msg
        if [[ -n "$commit_msg" ]]; then
            git add -A
            git commit -m "$commit_msg"
            echo -e "${GREEN}✓ Changes committed${NC}"
        else
            echo -e "${YELLOW}⚠ Skipping commit${NC}"
        fi
        
        # Task completion
        echo ""
        echo -e "${GREEN}✅ Task iteration complete!${NC}"
        log_phase "Development iteration completed"
        
        read -p "Continue with next task? (y/n): " continue_result
        if [[ "$continue_result" != "y" ]]; then
            break
        fi
    done
    
    # PHASE 3: Final Review
    echo ""
    show_status "🎯 PHASE 3: Final Review & Merge"
    
    echo -e "${BLUE}Current branch: $(git branch --show-current)${NC}"
    echo -e "${BLUE}Commits in this session:${NC}"
    git log --oneline -5
    
    wait_for_user "Ready to complete the workflow?"
    
    # Push current branch
    echo ""
    CURRENT_BRANCH=$(git branch --show-current)
    if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
        echo -e "${BLUE}⬆️ Pushing branch: $CURRENT_BRANCH${NC}"
        if git push -u origin "$CURRENT_BRANCH" 2>/dev/null; then
            echo -e "${GREEN}✓ Branch pushed successfully${NC}"
            echo ""
            echo -e "${CYAN}You can now create a PR from:${NC}"
            echo "  https://github.com/[your-repo]/compare/$CURRENT_BRANCH"
        else
            echo -e "${YELLOW}⚠ Could not push (no remote configured?)${NC}"
        fi
    fi
    
    # PHASE 4: Documentation & TODO Update
    echo ""
    show_status "📚 PHASE 4: Documentation & TODO Update"
    
    wait_for_user "Ready to update documentation and TODO list?"
    
    # Get section.subsection for documentation folder
    echo ""
    read -p "Enter section.subsection identifier (e.g., '1.2-auth-system'): " section_id
    if [[ -z "$section_id" ]]; then
        section_id="$(date +%Y%m%d-%H%M%S)"
        echo -e "${YELLOW}⚠ Using timestamp as section ID: $section_id${NC}"
    fi
    
    # Create documentation directory
    DOC_DIR="./docs/$section_id"
    echo -e "${BLUE}📁 Creating documentation directory: $DOC_DIR${NC}"
    mkdir -p "$DOC_DIR"
    
    # Archive workflow log
    if [[ -f "$WORKFLOW_LOG" ]]; then
        cp "$WORKFLOW_LOG" "$DOC_DIR/workflow-log.md"
        echo -e "${GREEN}✓ Workflow log archived${NC}"
    fi
    
    # Update TODO.md
    echo ""
    echo -e "${BLUE}📝 Updating TODO.md...${NC}"
    if [[ -f "TODO.md" ]]; then
        echo -e "${CYAN}Current TODO.md exists${NC}"
        wait_for_user "Would you like to mark completed tasks and add new ones?"
        echo -e "${YELLOW}Please update TODO.md with completed tasks and any new items discovered${NC}"
    else
        echo -e "${YELLOW}⚠ No TODO.md found. Creating one...${NC}"
        cat > TODO.md << 'EOF'
# TODO List

## Completed Tasks
- [ ] Add completed tasks here

## New Tasks Discovered
- [ ] Add new tasks discovered during development

## Future Improvements
- [ ] Add improvement suggestions
EOF
        echo -e "${GREEN}✓ Created TODO.md template${NC}"
    fi
    
    # Create implementation notes
    echo ""
    echo -e "${BLUE}📄 Creating implementation documentation...${NC}"
    cat > "$DOC_DIR/implementation-notes.md" << EOF
# Implementation Notes - $section_id

## Overview
Brief description of what was implemented in this session.

## Key Decisions
- Decision 1: [Rationale]
- Decision 2: [Rationale]

## Architecture Changes
Describe any significant architecture changes made.

## Challenges Faced
- Challenge 1: [How it was resolved]
- Challenge 2: [How it was resolved]

## Testing Strategy
Describe the testing approach used.

## Performance Considerations
Note any performance optimizations or concerns.
EOF
    echo -e "${GREEN}✓ Created implementation notes template${NC}"
    
    # Create lessons learned
    cat > "$DOC_DIR/lessons-learned.md" << EOF
# Lessons Learned - $section_id

## What Went Well
- 

## What Could Be Improved
- 

## Recommendations for Future Development
- 

## Tools and Techniques That Helped
- 
EOF
    echo -e "${GREEN}✓ Created lessons learned template${NC}"
    
    echo ""
    echo -e "${CYAN}Documentation templates created in: $DOC_DIR${NC}"
    echo -e "${YELLOW}Please update these files with actual content from this session${NC}"
    
    wait_for_user "Ready to continue?"
    
    # Workflow complete
    echo ""
    echo -e "${GREEN}🎉 VIBE CODING WORKFLOW COMPLETE!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo "Workflow log saved to: $WORKFLOW_LOG"
    echo "Documentation created in: $DOC_DIR"
    
    # Cleanup state file
    rm -f "$WORKFLOW_STATE"
    
    wait_for_user "Press ENTER to exit"
}

# Run main function
main "$@"