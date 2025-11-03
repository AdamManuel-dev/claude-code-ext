#!/usr/bin/env bash
# Vibe Coding Workflow - Recursive Self-Improvement System
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
CURRENT_PHASE=""

# Initialize workflow log
init_workflow() {
    echo "[$(date)] Workflow started" > "$WORKFLOW_LOG"
    echo '{"phase": "planning", "step": 1, "completed_tasks": []}' > "$WORKFLOW_STATE"
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

# Function to execute command with tracking
execute_command() {
    local cmd="$1"
    local description="$2"
    echo -e "${PURPLE}→ Executing: $description${NC}"
    echo -e "${CYAN}Command: $cmd${NC}"
    echo ""
}

# Main workflow execution
main() {
    clear
    echo -e "${GREEN}🚀 Starting Vibe Coding Workflow${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    
    init_workflow
    
    # PHASE 1: Research & Planning
    show_status "📚 PHASE 1: Research & Planning"
    
    # Step 1.1: Deep research
    echo -e "${BLUE}1.1 Deep Research & Tool Analysis${NC}"
    wait_for_user "Ready to start deep research phase?"
    execute_command "claude" "Use Claude/Opus for deep research to breakdown tooling needs"
    echo "Tasks:"
    echo "  • Analyze project requirements"
    echo "  • Research best practices and tools"
    echo "  • Document findings"
    log_phase "Deep Research"
    
    # Step 1.2: Create basic PRD
    echo ""
    echo -e "${BLUE}1.2 Create Basic PRD${NC}"
    wait_for_user "Research complete. Ready to create PRD?"
    execute_command "create PRD" "Transform research into basic PRD document"
    log_phase "Basic PRD Created"
    
    # Step 1.3: Create task list
    echo ""
    echo -e "${BLUE}1.3 Create Task List${NC}"
    wait_for_user "PRD ready. Create task-list.md?"
    execute_command "create task-list.md" "Break down PRD into actionable tasks"
    log_phase "Task List Created"
    
    # Step 1.4: Create detailed task list with dependencies
    echo ""
    echo -e "${BLUE}1.4 Create Detailed Task List with Dependencies${NC}"
    wait_for_user "Basic tasks defined. Add dependencies?"
    execute_command "enhance task-list.md" "Add dependency mapping to create detailed-task-list.md"
    log_phase "Detailed Task List Created"
    
    # Step 1.5: Identify critical success tasks
    echo ""
    echo -e "${BLUE}1.5 Identify Critical Success Tasks${NC}"
    wait_for_user "Dependencies mapped. Identify critical tasks?"
    execute_command "analyze tasks" "Extract critical-success-tasks.md"
    echo "Focus on tasks where failure leads to project failure"
    log_phase "Critical Tasks Identified"
    
    # Step 1.6: Create detailed PRD
    echo ""
    echo -e "${BLUE}1.6 Create Detailed PRD${NC}"
    wait_for_user "Critical tasks identified. Create detailed PRD?"
    execute_command "synthesize documents" "Create imagediff-prd-detailed.md from all inputs"
    log_phase "Detailed PRD Created"
    
    # Step 1.7: Create README
    echo ""
    echo -e "${BLUE}1.7 Create README.md${NC}"
    wait_for_user "PRD complete. Generate README?"
    execute_command "generate README" "Create comprehensive README.md from all notes"
    log_phase "README Created"
    
    # Step 1.8: Create use-case documentation
    echo ""
    echo -e "${BLUE}1.8 Create Use-Case Documentation${NC}"
    wait_for_user "README done. Document use cases?"
    execute_command "document use-cases" "Create figma-website-refinement-guide.md"
    log_phase "Use-Case Docs Created"
    
    # Step 1.9: Generate TODO.md
    echo ""
    echo -e "${BLUE}1.9 Generate TODO.md for Vibe Coding${NC}"
    wait_for_user "Documentation complete. Generate TODO.md?"
    execute_command "/generate-todo-from-prd imagediff-prd-detailed.md TODO.md" "Create tracking TODO"
    log_phase "TODO.md Generated"
    
    # PHASE 2: Development Cycle
    echo ""
    show_status "🔧 PHASE 2: Development Cycle"
    wait_for_user "Planning complete. Start development cycle?"
    
    # Development loop
    while true; do
        echo ""
        echo -e "${BLUE}📋 Picking next task from TODO/DAG...${NC}"
        wait_for_user "Ready to pick next task?"
        execute_command "/work-on-todos" "Select next task from TODO"
        
        # Check dependencies
        echo ""
        echo -e "${BLUE}🔍 Checking task dependencies...${NC}"
        echo "Verify all dependencies are complete before proceeding"
        
        # Design phase
        echo ""
        echo -e "${BLUE}📐 Design & Plan Implementation${NC}"
        wait_for_user "Dependencies clear. Start design phase?"
        echo "Design solution architecture and plan implementation approach"
        
        # Initial coding
        echo ""
        echo -e "${BLUE}💻 Initial Coding Implementation${NC}"
        wait_for_user "Design complete. Start coding?"
        echo "Implement the solution following the design"
        
        # Type checking loop
        while true; do
            echo ""
            echo -e "${BLUE}🔤 Running Type Check...${NC}"
            execute_command "npm run typecheck" "Check for TypeScript errors"
            wait_for_user "Code ready. Run type check?"
            
            read -p "Type check passed? (y/n): " type_result
            
            if [[ "$type_result" == "y" ]]; then
                echo -e "${GREEN}✓ Type check passed${NC}"
                break
            else
                echo -e "${RED}✗ Type errors found${NC}"
                wait_for_user "Ready to fix type errors?"
                execute_command "/fix-types" "Automatically fix type errors"
            fi
        done
        
        # Test generation
        echo ""
        echo -e "${BLUE}🧪 Generate/Update Tests${NC}"
        wait_for_user "Types clean. Generate tests?"
        echo "Create unit and integration tests for new code"
        
        # Test execution loop
        while true; do
            echo ""
            echo -e "${BLUE}🏃 Running Tests...${NC}"
            execute_command "npm test" "Run test suite"
            wait_for_user "Tests ready. Run test suite?"
            
            read -p "Tests passed? (y/n): " test_result
            
            if [[ "$test_result" == "y" ]]; then
                # Coverage check
                echo ""
                echo -e "${BLUE}📊 Checking Coverage...${NC}"
                read -p "Coverage >80%? (y/n): " coverage_result
                
                if [[ "$coverage_result" == "y" ]]; then
                    echo -e "${GREEN}✓ Coverage sufficient${NC}"
                    break
                else
                    echo -e "${YELLOW}⚠ Coverage below 80%${NC}"
                    wait_for_user "Ready to add more tests?"
                fi
            else
                echo -e "${RED}✗ Tests failing${NC}"
                wait_for_user "Ready to fix tests?"
                execute_command "/fix-tests" "Fix failing tests"
            fi
        done
        
        # Linting
        echo ""
        echo -e "${BLUE}✨ Running Lint Check...${NC}"
        execute_command "npm run lint" "Check code style and best practices"
        wait_for_user "Tests passing. Run linter?"
        
        read -p "Lint check passed? (y/n): " lint_result
        if [[ "$lint_result" != "y" ]]; then
            echo -e "${YELLOW}⚠ Lint issues found${NC}"
            execute_command "/fix-lint" "Fix lint issues"
            wait_for_user "Ready to fix lint issues?"
        fi
        
        # Security check
        echo ""
        echo -e "${BLUE}🔒 Running Security Scan...${NC}"
        execute_command "npm audit" "Check for security vulnerabilities"
        wait_for_user "Code clean. Run security scan?"
        
        # Performance check
        echo ""
        echo -e "${BLUE}⚡ Running Performance Check...${NC}"
        wait_for_user "Security clear. Check performance?"
        echo "Verify no performance regressions"
        
        # Documentation
        echo ""
        echo -e "${BLUE}📝 Updating Documentation...${NC}"
        wait_for_user "Performance good. Update docs?"
        execute_command "/generate-docs" "Update code documentation"
        
        # Pre-commit
        echo ""
        echo -e "${BLUE}🪝 Running Pre-commit Hooks...${NC}"
        wait_for_user "Docs updated. Run pre-commit?"
        echo "Format, lint, and test via pre-commit hooks"
        
        # Commit
        echo ""
        echo -e "${BLUE}💾 Creating Commit...${NC}"
        wait_for_user "All checks passed. Create commit?"
        execute_command "/commit" "Create conventional commit"
        
        # Push
        echo ""
        echo -e "${BLUE}⬆️ Pushing to Feature Branch...${NC}"
        wait_for_user "Commit created. Push to remote?"
        execute_command "git push origin feature-branch" "Push changes"
        
        # CI check
        echo ""
        echo -e "${BLUE}🔄 Monitoring CI Pipeline...${NC}"
        wait_for_user "Pushed. Check CI status?"
        echo "Monitor CI/CD pipeline for any failures"
        
        # PR creation
        echo ""
        echo -e "${BLUE}📄 Creating Pull Request...${NC}"
        wait_for_user "CI passing. Create PR?"
        echo "Create PR with description, screenshots, and breaking changes noted"
        
        # Task completion
        echo ""
        echo -e "${GREEN}✅ Task Complete!${NC}"
        log_phase "Task Completed"
        
        read -p "Continue with next task? (y/n): " continue_result
        if [[ "$continue_result" != "y" ]]; then
            break
        fi
    done
    
    # PHASE 3: Final Push & Completion
    echo ""
    show_status "🎯 PHASE 3: Final Push & Completion"
    echo "All tasks completed. Preparing final push..."
    
    # Final review
    echo ""
    echo -e "${BLUE}🔍 Final Code Review${NC}"
    wait_for_user "Ready for final review?"
    execute_command "/review" "Comprehensive code review"
    
    # Merge to main
    echo ""
    echo -e "${BLUE}🔀 Merging to Main Branch${NC}"
    wait_for_user "Review approved. Merge to main?"
    execute_command "git checkout main && git merge feature-branch" "Merge feature to main"
    
    # Final push
    echo ""
    echo -e "${BLUE}⬆️ Final Push to Main${NC}"
    wait_for_user "Ready for FINAL PUSH to main?"
    execute_command "git push origin main" "Push to main branch"
    
    # Workflow complete
    echo ""
    echo -e "${GREEN}🎉 VIBE CODING WORKFLOW COMPLETE!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo "Workflow log saved to: $WORKFLOW_LOG"
    echo ""
    echo -e "${CYAN}📈 Recursive Improvement Notes:${NC}"
    echo "  • Review $WORKFLOW_LOG for optimization opportunities"
    echo "  • Update workflow based on pain points"
    echo "  • Enhance automation where manual steps slow progress"
    
    # Cleanup state file
    rm -f "$WORKFLOW_STATE"
    
    # Wait for final user input as requested
    echo ""
    echo -e "${YELLOW}✋ WORKFLOW COMPLETE - Waiting for user input before exit...${NC}"
    echo "Press ENTER to finish..."
    read -r
}

# Run main function
main "$@"