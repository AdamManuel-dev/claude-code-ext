#!/usr/bin/env bash
# Vibe Coding Workflow - With Quality Gates
# Execute comprehensive development workflow with enforced quality checks

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
QUALITY_GATE_FAILED=false

# Session tracking variables
SESSION_START_TIME=""
COMMITS_MADE=()
QUALITY_ISSUES_FOUND=()
QUALITY_ISSUES_FIXED=()
TASKS_COMPLETED=()
FILES_MODIFIED=()
TEST_RESULTS=""
TYPE_CHECK_RESULTS=""
LINT_RESULTS=""

# Initialize workflow log
init_workflow() {
    SESSION_START_TIME=$(date)
    echo "[$(date)] Workflow started" > "$WORKFLOW_LOG"
    echo '{"phase": "planning", "step": 1, "completed_tasks": []}' > "$WORKFLOW_STATE"
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    echo "Branch: $CURRENT_BRANCH" >> "$WORKFLOW_LOG"
    echo "Initial git status:" >> "$WORKFLOW_LOG"
    git status --short >> "$WORKFLOW_LOG"
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

# Function to log implementation details
log_implementation() {
    local description="$1"
    local details="$2"
    echo "[$(date)] Implementation: $description" >> "$WORKFLOW_LOG"
    echo "Details: $details" >> "$WORKFLOW_LOG"
    echo "---" >> "$WORKFLOW_LOG"
}

# Function to log quality issues
log_quality_issue() {
    local issue_type="$1"
    local description="$2"
    local fixed="${3:-false}"
    QUALITY_ISSUES_FOUND+=("$issue_type: $description")
    if [[ "$fixed" == "true" ]]; then
        QUALITY_ISSUES_FIXED+=("$issue_type: $description")
    fi
    echo "[$(date)] Quality Issue [$issue_type]: $description (Fixed: $fixed)" >> "$WORKFLOW_LOG"
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

# Quality gate function - runs all checks and returns 0 only if all pass
run_quality_checks() {
    local all_passed=true
    local type_check_output=""
    local test_output=""
    local lint_output=""
    
    echo ""
    echo -e "${BLUE}🔍 Running Quality Gate Checks...${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Type checking
    if npm_script_exists "typecheck" || npm_script_exists "type-check"; then
        echo -e "${BLUE}🔤 Type Check...${NC}"
        if npm_script_exists "typecheck"; then
            type_check_output=$(npm run typecheck 2>&1)
            if [[ $? -ne 0 ]]; then
                echo -e "${RED}✗ Type check failed${NC}"
                TYPE_CHECK_RESULTS="FAILED"
                # Extract error count if possible
                local error_count=$(echo "$type_check_output" | grep -E "[0-9]+ error" | grep -oE "[0-9]+" | head -1)
                [[ -n "$error_count" ]] && log_quality_issue "TypeScript" "$error_count errors found"
                all_passed=false
            else
                echo -e "${GREEN}✓ Type check passed${NC}"
                TYPE_CHECK_RESULTS="PASSED"
            fi
        else
            type_check_output=$(npm run type-check 2>&1)
            if [[ $? -ne 0 ]]; then
                echo -e "${RED}✗ Type check failed${NC}"
                TYPE_CHECK_RESULTS="FAILED"
                all_passed=false
            else
                echo -e "${GREEN}✓ Type check passed${NC}"
                TYPE_CHECK_RESULTS="PASSED"
            fi
        fi
    else
        echo -e "${YELLOW}⚠ No type check script found, skipping${NC}"
        TYPE_CHECK_RESULTS="SKIPPED"
    fi
    
    echo ""
    
    # Testing
    if npm_script_exists "test"; then
        echo -e "${BLUE}🧪 Running Tests...${NC}"
        test_output=$(npm test 2>&1)
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}✗ Tests failed${NC}"
            TEST_RESULTS="FAILED"
            # Extract failed test count if possible
            local failed_count=$(echo "$test_output" | grep -E "[0-9]+ failing" | grep -oE "[0-9]+" | head -1)
            [[ -n "$failed_count" ]] && log_quality_issue "Tests" "$failed_count tests failing"
            all_passed=false
        else
            echo -e "${GREEN}✓ Tests passed${NC}"
            TEST_RESULTS="PASSED"
        fi
    else
        echo -e "${YELLOW}⚠ No test script found, skipping${NC}"
        TEST_RESULTS="SKIPPED"
    fi
    
    echo ""
    
    # Linting
    if npm_script_exists "lint"; then
        echo -e "${BLUE}✨ Lint Check...${NC}"
        lint_output=$(npm run lint 2>&1)
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}✗ Lint check failed${NC}"
            LINT_RESULTS="FAILED"
            # Extract lint error/warning count
            local lint_issues=$(echo "$lint_output" | grep -E "[0-9]+ problem" | grep -oE "[0-9]+" | head -1)
            [[ -n "$lint_issues" ]] && log_quality_issue "Linting" "$lint_issues issues found"
            all_passed=false
        else
            echo -e "${GREEN}✓ Lint check passed${NC}"
            LINT_RESULTS="PASSED"
        fi
    else
        echo -e "${YELLOW}⚠ No lint script found, skipping${NC}"
        LINT_RESULTS="SKIPPED"
    fi
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [[ "$all_passed" == "true" ]]; then
        echo -e "${GREEN}✅ All quality checks passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ Quality gate failed - please fix issues before proceeding${NC}"
        return 1
    fi
}

# Pre-commit validation
pre_commit_validation() {
    echo ""
    echo -e "${BLUE}🚦 Pre-Commit Quality Gate${NC}"
    
    if run_quality_checks; then
        return 0
    else
        echo ""
        echo -e "${RED}⛔ COMMIT BLOCKED: Quality checks must pass before committing${NC}"
        echo -e "${YELLOW}Please fix the issues above and try again${NC}"
        
        # Offer to run fix commands
        echo ""
        read -p "Would you like to run auto-fix commands? (y/n): " run_fixes
        if [[ "$run_fixes" == "y" ]]; then
            echo ""
            if npm_script_exists "lint"; then
                echo -e "${BLUE}Attempting to fix lint issues...${NC}"
                npm run lint -- --fix 2>/dev/null || npm run lint:fix 2>/dev/null || true
            fi
            
            # Use Claude's fix commands if available
            CLAUDE_TOOLS_DIR="/Users/adammanuel/.claude/tools"
            if [[ -x "$CLAUDE_TOOLS_DIR/fix-types.sh" ]]; then
                echo ""
                read -p "Run /fix-types to fix TypeScript errors? (y/n): " fix_types
                if [[ "$fix_types" == "y" ]]; then
                    "$CLAUDE_TOOLS_DIR/fix-types.sh"
                fi
            fi
            
            if [[ -x "$CLAUDE_TOOLS_DIR/fix-tests.sh" ]]; then
                echo ""
                read -p "Run /fix-tests to fix test failures? (y/n): " fix_tests
                if [[ "$fix_tests" == "y" ]]; then
                    "$CLAUDE_TOOLS_DIR/fix-tests.sh"
                fi
            fi
            
            # Re-run quality checks
            echo ""
            echo -e "${BLUE}Re-running quality checks...${NC}"
            if run_quality_checks; then
                return 0
            else
                return 1
            fi
        fi
        
        return 1
    fi
}

# Pre-push validation
pre_push_validation() {
    echo ""
    echo -e "${BLUE}🚀 Pre-Push Quality Gate${NC}"
    echo -e "${YELLOW}Re-running all checks to ensure code quality...${NC}"
    
    if run_quality_checks; then
        return 0
    else
        echo ""
        echo -e "${RED}⛔ PUSH BLOCKED: Quality checks must pass before pushing${NC}"
        echo -e "${YELLOW}Please fix the issues above before pushing to remote${NC}"
        return 1
    fi
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
    echo -e "${GREEN}🚀 Starting Vibe Coding Workflow (With Quality Gates)${NC}"
    echo -e "${GREEN}====================================================${NC}"
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
        
        # Run quality checks but don't block yet (informational)
        echo ""
        echo -e "${BLUE}📊 Running preliminary quality checks...${NC}"
        run_quality_checks || true
        
        # Commit with quality gate
        echo ""
        echo -e "${BLUE}💾 Preparing to Commit...${NC}"
        echo -e "${CYAN}Current changes:${NC}"
        git status --short
        
        if [[ -n "$(git status --porcelain)" ]]; then
            wait_for_user "Ready to commit these changes?"
            
            # Run pre-commit validation
            if pre_commit_validation; then
                read -p "Enter commit message: " commit_msg
                if [[ -n "$commit_msg" ]]; then
                    # Track files being committed
                    FILES_MODIFIED+=($(git diff --name-only --cached))
                    
                    git add -A
                    git commit -m "$commit_msg"
                    if [[ $? -eq 0 ]]; then
                        echo -e "${GREEN}✓ Changes committed successfully${NC}"
                        # Track commit
                        local commit_hash=$(git rev-parse HEAD)
                        COMMITS_MADE+=("$commit_hash: $commit_msg")
                        log_implementation "Commit" "$commit_msg (${#FILES_MODIFIED[@]} files)"
                    fi
                else
                    echo -e "${YELLOW}⚠ Skipping commit (no message provided)${NC}"
                fi
            else
                echo -e "${RED}✗ Commit cancelled due to quality gate failure${NC}"
                echo -e "${YELLOW}Fix the issues and try again${NC}"
            fi
        else
            echo -e "${YELLOW}No changes to commit${NC}"
        fi
        
        # Task completion
        echo ""
        read -p "What task did you complete? (brief description): " task_desc
        if [[ -n "$task_desc" ]]; then
            TASKS_COMPLETED+=("$task_desc")
            log_implementation "Task Completed" "$task_desc"
        fi
        
        echo -e "${GREEN}✅ Task iteration complete!${NC}"
        log_phase "Development iteration completed"
        
        read -p "Continue with next task? (y/n): " continue_result
        if [[ "$continue_result" != "y" ]]; then
            break
        fi
    done
    
    # PHASE 3: Final Review
    echo ""
    show_status "🎯 PHASE 3: Final Review & Push"
    
    echo -e "${BLUE}Current branch: $(git branch --show-current)${NC}"
    echo -e "${BLUE}Commits in this session:${NC}"
    git log --oneline -5
    
    wait_for_user "Ready to push your changes?"
    
    # Pre-push validation
    if pre_push_validation; then
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
    else
        echo -e "${RED}✗ Push cancelled due to quality gate failure${NC}"
        echo -e "${YELLOW}Please fix all issues before pushing${NC}"
    fi
    
    # PHASE 4: Documentation & TODO Update
    echo ""
    show_status "📚 PHASE 4: Documentation & TODO Update"
    
    wait_for_user "Ready to update documentation and TODO list?"
    
    # Get section.subsection for documentation folder
    echo ""
    read -p "Enter section.subsection identifier (e.g., '1.2-auth-system'): " section_id
    # Sanitize input to prevent path traversal
    section_id="${section_id//[^a-zA-Z0-9._-]/}"
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
    
    # Create implementation notes with actual session data
    echo ""
    echo -e "${BLUE}📄 Creating implementation documentation...${NC}"
    
    # Calculate session duration
    local session_end=$(date)
    
    cat > "$DOC_DIR/implementation-notes.md" << EOF
# Implementation Notes - $section_id

## Session Information
- **Start Time**: $SESSION_START_TIME
- **End Time**: $session_end
- **Branch**: $CURRENT_BRANCH
- **Total Commits**: ${#COMMITS_MADE[@]}
- **Files Modified**: ${#FILES_MODIFIED[@]}

## Overview
This session completed ${#TASKS_COMPLETED[@]} tasks with ${#COMMITS_MADE[@]} commits.

## Tasks Completed
$(for task in "${TASKS_COMPLETED[@]}"; do echo "- $task"; done)

## Commits Made
$(for commit in "${COMMITS_MADE[@]}"; do echo "- $commit"; done)

## Files Modified
$(printf '%s\n' "${FILES_MODIFIED[@]}" | sort -u | sed 's/^/- /')

## Quality Gate Results
- **Type Check**: $TYPE_CHECK_RESULTS
- **Tests**: $TEST_RESULTS  
- **Lint**: $LINT_RESULTS

## Quality Issues Encountered
$(if [[ ${#QUALITY_ISSUES_FOUND[@]} -eq 0 ]]; then
    echo "No quality issues were detected during this session."
else
    for issue in "${QUALITY_ISSUES_FOUND[@]}"; do echo "- $issue"; done
fi)

## Quality Issues Fixed
$(if [[ ${#QUALITY_ISSUES_FIXED[@]} -eq 0 ]]; then
    echo "No automated fixes were applied."
else
    for fix in "${QUALITY_ISSUES_FIXED[@]}"; do echo "- $fix"; done
fi)

## Session Log Summary
See workflow-log.md for detailed session activity.
EOF
    echo -e "${GREEN}✓ Created implementation notes template${NC}"
    
    # Create lessons learned with insights from session
    cat > "$DOC_DIR/lessons-learned.md" << EOF
# Lessons Learned - $section_id

## Session Summary
- Completed ${#TASKS_COMPLETED[@]} tasks
- Made ${#COMMITS_MADE[@]} commits  
- Modified ${#FILES_MODIFIED[@]} unique files
- Quality gates: Type=$TYPE_CHECK_RESULTS, Tests=$TEST_RESULTS, Lint=$LINT_RESULTS

## What Went Well
$(if [[ "$TYPE_CHECK_RESULTS" == "PASSED" && "$TEST_RESULTS" == "PASSED" && "$LINT_RESULTS" == "PASSED" ]]; then
    echo "- All quality gates passed on first attempt"
fi)
$(if [[ ${#COMMITS_MADE[@]} -gt 0 ]]; then
    echo "- Successfully completed ${#COMMITS_MADE[@]} commits"
fi)
$(if [[ ${#TASKS_COMPLETED[@]} -gt 0 ]]; then
    echo "- Completed all planned tasks"
fi)

## What Could Be Improved  
$(if [[ ${#QUALITY_ISSUES_FOUND[@]} -gt 0 ]]; then
    echo "- ${#QUALITY_ISSUES_FOUND[@]} quality issues were found that needed fixing"
fi)
$(if [[ "$TYPE_CHECK_RESULTS" == "FAILED" ]]; then
    echo "- TypeScript type checking failed - consider adding types earlier"
fi)
$(if [[ "$TEST_RESULTS" == "FAILED" ]]; then
    echo "- Tests failed - implement test-driven development"
fi)
$(if [[ "$LINT_RESULTS" == "FAILED" ]]; then
    echo "- Linting issues found - configure editor to lint on save"
fi)

## Quality Gate Observations
$(if [[ ${#QUALITY_ISSUES_FOUND[@]} -eq 0 ]]; then
    echo "- Clean code was maintained throughout the session"
else
    echo "- Quality issues detected: ${#QUALITY_ISSUES_FOUND[@]}"
    echo "- Quality issues auto-fixed: ${#QUALITY_ISSUES_FIXED[@]}"
fi)

## Recommendations for Future Development
- Continue using quality gates to maintain code standards
$(if [[ ${#QUALITY_ISSUES_FOUND[@]} -gt 0 ]]; then
    echo "- Set up pre-commit hooks to catch issues earlier"
fi)
$(if [[ "$TYPE_CHECK_RESULTS" == "SKIPPED" || "$TEST_RESULTS" == "SKIPPED" || "$LINT_RESULTS" == "SKIPPED" ]]; then
    echo "- Add missing npm scripts for complete quality validation"
fi)
EOF
    echo -e "${GREEN}✓ Created lessons learned template${NC}"
    
    echo ""
    echo -e "${CYAN}Documentation templates created in: $DOC_DIR${NC}"
    echo -e "${YELLOW}Please update these files with actual content from this session${NC}"
    
    wait_for_user "Ready to continue?"
    
    # Generate session summary
    cat > "$DOC_DIR/session-summary.md" << EOF
# Vibe Workflow Session Summary

**Date**: $(date '+%Y-%m-%d')
**Duration**: $SESSION_START_TIME - $(date)

## Accomplishments
- Tasks Completed: ${#TASKS_COMPLETED[@]}
- Commits Made: ${#COMMITS_MADE[@]}
- Files Modified: ${#FILES_MODIFIED[@]} unique files

## Quality Metrics
- Type Check: $TYPE_CHECK_RESULTS
- Unit Tests: $TEST_RESULTS
- Linting: $LINT_RESULTS
- Issues Found: ${#QUALITY_ISSUES_FOUND[@]}
- Issues Fixed: ${#QUALITY_ISSUES_FIXED[@]}

## Quick Links
- [Implementation Notes](./implementation-notes.md)
- [Lessons Learned](./lessons-learned.md)
- [Workflow Log](./workflow-log.md)
EOF
    
    # Workflow complete
    echo ""
    echo -e "${GREEN}🎉 VIBE CODING WORKFLOW COMPLETE!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo -e "${BLUE}Session Summary:${NC}"
    echo "• Tasks completed: ${#TASKS_COMPLETED[@]}"
    echo "• Commits made: ${#COMMITS_MADE[@]}"
    echo "• Files modified: ${#FILES_MODIFIED[@]}"
    echo "• Quality gates: Type=$TYPE_CHECK_RESULTS, Tests=$TEST_RESULTS, Lint=$LINT_RESULTS"
    echo ""
    echo -e "${BLUE}Documentation:${NC}"
    echo "• Workflow log: $WORKFLOW_LOG"
    echo "• Session docs: $DOC_DIR/"
    echo "• Summary: $DOC_DIR/session-summary.md"
    echo ""
    echo -e "${GREEN}Quality gates ensured code quality throughout the session!${NC}"
    
    # Cleanup state file
    rm -f "$WORKFLOW_STATE"
    
    wait_for_user "Press ENTER to exit"
}

# Run main function
main "$@"