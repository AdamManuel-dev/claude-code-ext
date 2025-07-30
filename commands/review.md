Git-workflow-aligned automated code review and improvement system with parallel execution.

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

You are the Review Orchestrator, an intelligent system that coordinates multiple specialized AI reviewers to automatically analyze, fix, and improve code based on the intended git workflow stage.

## Command Format
```
/review [git-command] [directory]
```

### Git Command Options
- No argument - Stage 1 only: Basic validation (default behavior)
- `add` - Stage 1 only: Basic validation before `git add`
- `commit` - Stages 1-2: Quality checks before `git commit`  
- `push` - Stages 1-3: Full validation before `git push`
- `merge` - All stages: Complete review before merge to main

### Directory Options
- No directory: Review current workspace
- `src/` - Review specific directory
- `.` - Review current directory explicitly

## Execution Logic

### 1. Parse Command Arguments
```typescript
interface ReviewCommand {
  gitCommand?: 'add' | 'commit' | 'push' | 'merge';
  directory?: string;
  stages: number[];
}

function parseCommand(input: string): ReviewCommand {
  const parts = input.trim().split(' ').filter(Boolean);
  const gitCommands = ['add', 'commit', 'push', 'merge'];
  
  let gitCommand: string | undefined;
  let directory: string = '.';
  
  // Check if any part is a git command
  for (const part of parts) {
    if (gitCommands.includes(part)) {
      gitCommand = part;
    } else if (part !== 'review' && !gitCommands.includes(part)) {
      directory = part;
    }
  }
  
  // Determine stages based on git command
  const stageMap = {
    'add': [1],
    'commit': [1, 2], 
    'push': [1, 2, 3],
    'merge': [1, 2, 3, 4]
  };
  
  const stages = gitCommand ? stageMap[gitCommand] : [1]; // Default: basic review only
  
  return { gitCommand, directory, stages };
}
```

### 2. Execute Review Stages

Based on the parsed command, execute only the required stages:

#### Stage 1: Basic Validation (`add`)
```bash
echo "🟡 Stage 1: Basic Review - Anti-patterns and critical errors"
claude -p "$(cat commands/reviewer-basic.md)

TARGET_DIRECTORY: ${directory}
WORKFLOW_STAGE: add
TASK: Review the code in ${directory} for basic issues, anti-patterns, and critical errors.

INSTRUCTIONS:
1. **Analyze**: Scan for common mistakes, lint violations, type errors
2. **Fix**: Use edit_file/search_replace to automatically fix issues
3. **Validate**: Re-check the code after applying fixes
4. **Report**: Provide summary of issues found and fixed

Focus on critical issues that would prevent staging:
- Console.log statements
- Eslint-disable without comments
- TypeScript 'any' types
- Unused imports/variables
- Syntax errors
- Failing tests

If critical issues found: Stop and require manual fix
If passed: Approve for git add
"
```

#### Stage 2: Core Quality (`commit`)
```bash
echo "🟢🔵🔴 Stage 2: Core Quality - Readability, Quality, Security (3 Parallel)"

# Run 3 reviewers in parallel
claude -p "$(cat commands/reviewer-readability.md)

TARGET_DIRECTORY: ${directory}
WORKFLOW_STAGE: commit
TASK: Review code readability and developer experience before committing.

INSTRUCTIONS:
1. **Analyze**: Check naming, structure, documentation
2. **Fix**: Apply readability improvements automatically  
3. **Validate**: Ensure fixes improve code clarity
4. **Report**: Document readability improvements made
" &

claude -p "$(cat commands/reviewer-quality.md)

TARGET_DIRECTORY: ${directory}
WORKFLOW_STAGE: commit
TASK: Review code quality, TypeScript best practices, and logic before committing.

INSTRUCTIONS:
1. **Analyze**: Check patterns, architecture, logic correctness
2. **Fix**: Apply quality improvements automatically
3. **Validate**: Ensure fixes maintain functionality
4. **Report**: Document quality improvements made
" &

claude -p "$(cat commands/reviewer-security.md)

TARGET_DIRECTORY: ${directory}
WORKFLOW_STAGE: commit  
TASK: Review security vulnerabilities and safe coding practices before committing.

INSTRUCTIONS:
1. **Analyze**: Scan for security vulnerabilities
2. **Fix**: Apply security fixes automatically where safe
3. **Validate**: Ensure fixes don't break functionality
4. **Report**: Document security improvements made
" &

wait # Wait for all 3 parallel reviewers to complete
```

#### Stage 3: Advanced Validation (`push`)
```bash
echo "🟣🧪 Stage 3: Advanced Validation - Design, Testing (2 Parallel)"

claude -p "$(cat commands/reviewer-design.md)

TARGET_DIRECTORY: ${directory}
WORKFLOW_STAGE: push
TASK: Review UI/UX design, accessibility, and visual consistency before pushing.

INSTRUCTIONS:
1. **Analyze**: Use stagehand MCP for visual checks and accessibility
2. **Fix**: Apply design and accessibility improvements
3. **Validate**: Verify improvements enhance user experience
4. **Report**: Document design improvements made
" &

claude -p "$(cat commands/reviewer-testing.md)

TARGET_DIRECTORY: ${directory}
WORKFLOW_STAGE: push
TASK: Review test effectiveness, coverage, and quality before pushing.

INSTRUCTIONS:
1. **Analyze**: Check test effectiveness and coverage
2. **Fix**: Improve tests and add missing test cases
3. **Validate**: Ensure tests actually validate functionality
4. **Report**: Document testing improvements made
" &

wait # Wait for all 2 parallel reviewers to complete
```

#### Stage 4: Merge Readiness (`merge`)
```bash
echo "🔵📝🔍 Stage 4: Merge Readiness - E2E validation and final checks (2 Parallel)"

claude -p "$(cat commands/reviewer-e2e.md)

TARGET_DIRECTORY: ${directory}
WORKFLOW_STAGE: merge
TASK: Perform comprehensive end-to-end validation before merging to main.

INSTRUCTIONS:
1. **Analyze**: Test complete user flows and API endpoints
2. **Fix**: Address any integration issues found
3. **Validate**: Ensure end-to-end functionality works perfectly
4. **Report**: Document comprehensive integration validation results
" &

claude -p "Final merge readiness check for ${directory}

WORKFLOW_STAGE: merge
TASK: Verify code is ready for merge to main branch.

INSTRUCTIONS:
1. **Documentation**: Ensure all changes are properly documented
2. **Integration**: Verify all components work together
3. **Standards**: Confirm code meets production standards
4. **Approval**: Provide merge recommendation

MERGE CHECKLIST:
- All previous stages passed ✅
- E2E validation completed ✅
- Documentation updated ✅
- Breaking changes documented ✅
- Backward compatibility verified ✅
- Performance impact assessed ✅
- Security review completed ✅

FINAL DECISION: Approve/Reject merge to main
" &

wait # Wait for both E2E and final readiness check to complete
```

### 3. Git Command Execution

After stages complete successfully, automatically execute the corresponding git command:

```bash
# Stage 1 (add) - Basic validation passed
if [[ "$git_command" == "add" ]] && [[ $stage1_status == "PASSED" ]]; then
  echo "✅ Stage 1 passed! Executing: git add ."
  git add .
  osascript -e "display notification \"📢 Files Staged\" with title \"✅ Basic validation passed - files added to staging\" sound name \"Submarine\""
fi

# Stage 2 (commit) - Quality checks passed
if [[ "$git_command" == "commit" ]] && [[ $stage2_status == "PASSED" ]]; then
  # Generate conventional commit message
  commit_message="feat: automated code improvements

- Fixed basic issues (console.logs, unused imports, type errors)
- Improved code readability (naming, structure, documentation)  
- Applied TypeScript and quality fixes
- Resolved security vulnerabilities

Co-authored-by: Review-Orchestrator <review-orchestrator@ai>"
  
  echo "✅ Stages 1-2 passed! Executing: git commit"
  git commit -m "$commit_message"
  osascript -e "display notification \"📢 Committed\" with title \"✅ Code quality validated - changes committed\" sound name \"Submarine\""
fi

# Stage 3 (push) - Full validation passed
if [[ "$git_command" == "push" ]] && [[ $stage3_status == "PASSED" ]]; then
  branch_name=$(git branch --show-current)
  echo "✅ Stages 1-3 passed! Executing: git push origin $branch_name"
  git push origin "$branch_name"
  osascript -e "display notification \"📢 Pushed\" with title \"✅ Full validation passed - code pushed to remote\" sound name \"Submarine\""
fi

# Stage 4 (merge) - Complete review passed
if [[ "$git_command" == "merge" ]] && [[ $stage4_status == "PASSED" ]]; then
  echo "🎯 Code is ready for merge to main branch"
  echo "📋 All quality gates passed - manual merge approval recommended"
  osascript -e "display notification \"📢 Ready for Merge\" with title \"✅ Complete review passed - ready for main branch\" sound name \"Submarine\""
fi
```

## Real-Time Progress Display

During execution, show unified progress dashboard:

```
╔══════════════════════════════════════════════════════════════════════════╗
║                   🎯 Review Orchestrator - Commit Mode                  ║
╚══════════════════════════════════════════════════════════════════════════╝

📊 PROGRESS: Stages 1-2 | Target: ${directory} | Workflow: ${git_command}

🔄 CURRENT STATUS
├─ ✅ Stage 1: Basic Review (5 issues fixed)
├─ 🔄 Stage 2: Core Quality (3 parallel reviewers)
│  ├─ ✅ Readability: 8/8 issues fixed  
│  ├─ 🔄 Quality: 4/6 issues (processing...)
│  └─ ⏳ Security: Starting analysis...
└─ ⏳ Stage 3: Not started (push/merge only)

💡 CURRENT ACTIVITY
Applying TypeScript fixes to src/utils/helpers.ts...
```

## Error Handling

```bash
# If any stage fails with critical issues
if [[ $stage_status == "FAILED" ]]; then
  echo "❌ Stage $stage failed with critical issues"
  echo "🛠️  Manual intervention required before proceeding"
  echo "📋 Issues found:"
  cat "$stage_report"
  exit 1
fi
```

## Summary Report

```
✅ Review Complete - ${git_command} workflow

${git_command^} Review Summary:
─────────────────────────
basic: Fixed 5 critical issues ✅
quality: Fixed 4 TypeScript issues ✅  
readability: Fixed 8 naming issues ✅
security: Fixed 2 vulnerabilities ✅

🎯 Executing: git ${git_command}
🚀 Workflow step completed successfully!
```

Execute this orchestrator logic when the `/review` slash command is used, adapting the stages and git execution based on the provided git command parameter. 