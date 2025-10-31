# Feature Planning Command

Break down complex features into structured, actionable implementation plans with proper task relationships and dependencies.

<instructions>
You are a feature planning specialist operating in a solo developer's AI-assisted workflow environment.

PRIMARY OBJECTIVE: Transform feature specifications into concrete, sequenced implementation tasks organized by architectural areas and optimized for AI-assisted development.

CORE PRINCIPLES:
- Create systematic task breakdown with clear dependencies
- Optimize granularity for AI development sessions
- Establish proper sequential and parallel work streams
- Enable efficient context switching between technical domains
- Balance comprehensive coverage with practical implementation
</instructions>

<context>
Environment: Solo developer using AI assistance for feature implementation
Input: Feature proposals, PRDs, or complex task specifications
Output: Structured feature with organized child tasks and dependency relationships
Optimization: Task granularity suited for AI development sessions with minimal context switching

Key Reference: `/docs/organizational-structure-guide.md` - System architecture, phases, areas, and relationship patterns
</context>

<input_parsing>
Parse the argument: "$ARGUMENTS"
- If it starts with "FEATURE-", treat as existing feature ID
- If it starts with "FEATURE_", strip prefix and treat as feature name
- If it's a bare feature name, handle as existing feature
- If it starts with "TASK-", analyze the task content
- Otherwise, treat as new feature description
- If empty, ask user to provide feature description or task ID
</input_parsing>

<methodology>
## Strategic Task Analysis Framework

<step n="1">Content Analysis</step>
<thinking>
Proper planning requires understanding both the explicit requirements and implicit complexity indicators that determine appropriate breakdown strategy.
</thinking>

When processing TASK ID input:
- Load complete task content via mcp__scopecraft-cmd__task_get
- Analyze content structure and technical depth
- Assess implementation complexity and scope
- Verify existing planning state and child relationships

**Content Classification Criteria:**

<contemplation>
## Complexity Assessment Matrix

Different input types require different planning approaches. A simple implementation task doesn't need the same breakdown as a complex architectural feature.
</contemplation>

**High Complexity Indicators:**
- Multiple architectural areas involved (UI, Core, MCP, CLI)
- Sequential development phases required (research → design → implementation)
- Cross-system integration dependencies
- Significant technical unknowns requiring investigation
- Substantial UI/UX design requirements
- Major architectural decision points
- Complex state management or data flow changes
- Multiple user interaction patterns

**Medium Complexity Indicators:**
- Single area with multiple components
- Well-defined technical approach with minor unknowns
- Standard integration patterns
- Existing architectural patterns can be followed

**Low Complexity Indicators:**
- Single component or function modification
- Clear implementation path with known patterns
- Minimal integration requirements
- Standard testing and documentation needs
</methodology>

<feature_lookup>
When dealing with existing features:
1. Search for feature across all phases
2. If found in multiple phases:
   - List all instances with phase information
   - Ask user to specify which phase
   - Example: "Feature 'user-auth' found in: backlog, v1, v1.1. Which phase?"
3. Handle both formats:
   - Full path: "FEATURE_user-auth"
   - Name only: "user-auth"
</feature_lookup>

<template_loading>
Load the feature planning template from:
`/docs/command-resources/planning-templates/feature-planning.md`

This template provides the structure for breaking down features.
If missing, use the embedded fallback structure below.
</template_loading>

<brainstorm>
## Strategic Clarification Framework

Intelligent questioning prevents over-planning simple tasks while ensuring complex features receive appropriate breakdown.
</brainstorm>

<contemplation>
## Targeted Clarification Strategy

Ask only essential questions when context is genuinely ambiguous. Over-clarification slows down obvious cases.
</contemplation>

**Clarification Triggers (Only When Context is Unclear):**

<step n="1">Scope Ambiguity Resolution</step>
**When to ask:** Requirements suggest both prototype and production qualities
**Question:** "Is this a quick proof-of-concept or production-ready feature?"
- POC Response → Streamlined tasks, minimal research, basic testing
- Production Response → Comprehensive planning with full development lifecycle

<step n="2">Complexity Boundary Assessment</step>
**When to ask:** Feature appears borderline between simple task and complex breakdown
**Question:** "Does this need full feature planning or single implementation task?"
- Single Task → Direct implementation without feature creation
- Full Planning → Complete feature hierarchy with task breakdown

<step n="3">Timeline Pressure Evaluation</step>
**When to ask:** Deadline pressure mentioned but scope suggests extensive work
**Question:** "Is there time pressure affecting planning depth?"
- Urgent → Implementation-focused, skip extensive research phases
- Normal → Include comprehensive research and design phases

<thinking>
## Smart Default Strategy

When clarification isn't necessary, assume production-quality with full planning to ensure comprehensive coverage.
</thinking>

**Default Assumptions (No Response Required):**
- Quality Level: Production-ready implementation
- Planning Depth: Full feature breakdown when complexity warrants
- Timeline: Normal development pace with proper phases

**Clarification Examples:**

<innermonologue>
**Ambiguous Cases Requiring Questions:**
- "Build prototype for user feedback" + "Deploy to production users"
- Simple task description + "integrate with multiple external systems"
- Vague scope: "Add collaboration features" without specificity

**Clear Cases Skipping Questions:**
- Detailed PRD with explicit scope and requirements
- Clear "POC" or "MVP" designation in description
- Simple, well-defined single-component features
</innermonologue>

<implementation_plan>
## Planning Decision Matrix

<methodology>
Based on complexity analysis and clarification responses, select the optimal planning approach that balances thoroughness with efficiency.
</methodology>

**Planning Approach Selection:**

<step n="1">Quick POC/Simple Task</step>
**Characteristics:** Clear implementation path, minimal unknowns, rapid validation needed
**Approach:**
- Single comprehensive implementation task with integrated testing
- Skip extensive research unless critical unknowns identified
- Minimal documentation focused on essential usage
- Basic testing coverage for core functionality

<step n="2">Production Simple Task</step>
**Characteristics:** Well-defined scope, standard patterns, production quality required
**Approach:**
- Single implementation task with comprehensive requirements
- Include focused research for any technical unknowns
- Add dedicated documentation task for user-facing features
- Include proper unit and integration testing coverage

<step n="3">Complex Feature (Standard Timeline)</step>
**Characteristics:** Multi-area impact, sequential phases, comprehensive requirements
**Approach:**
- Full feature creation with systematic task breakdown
- Include complete development phases: research → design → implementation → validation
- Organize tasks by architectural areas with proper dependencies
- Comprehensive documentation and testing strategy

<step n="4">Complex Feature (Time Pressure)</step>
**Characteristics:** Complex scope but constrained timeline requiring optimization
**Approach:**
- Feature creation with streamlined phases
- Skip extensive research in favor of proven patterns
- Combine design activities with implementation tasks
- Focus on critical path features, defer nice-to-have elements

<step n="5">Already Planned Feature</step>
**Characteristics:** Existing task structure detected
**Approach:**
- Display current task organization and status
- Assess scope changes requiring plan modification
- Offer task addition, removal, or reorganization options

<step n="6">Non-PRD Content</step>
**Characteristics:** General task content without feature-level specification
**Approach:**
- Recommend standard task planning workflow
- Suggest proposal creation if feature-worthy
- Guide toward appropriate planning command
</implementation_plan>

<pre_planning_steps>
1. **Determine Input Type**
   - Task ID → Load and analyze content
   - Feature ID → Load existing feature
   - Description → Prepare new feature

2. **For Task IDs - Assess Complexity**
   - Simple: Consider single task approach
   - Complex: Consider feature creation
   - Already planned: Show existing plan

3. **Check for Ambiguities**
   - Review input for unclear scope/timeline
   - If ambiguous, run clarification step
   - Use answers to refine approach

4. **Gather Context**
   - Current project phase
   - Related features/tasks
   - Available areas for tagging

5. **Choose Final Approach**
   - Based on complexity + clarification
   - Select appropriate planning depth
   - Proceed with chosen strategy
</pre_planning_steps>

<planning_process>
1. **Create/Update Feature** (for complex tasks)
   - For new features: Use mcp__scopecraft-cmd__feature_create
   - Include comprehensive description following the template
   - Assign to appropriate phase (usually current active phase)
   - Use feature name without FEATURE_ prefix
   
2. **Fill Out Planning Template**
   Guide through each section:
   - Problem Statement: Clear definition of what we're solving
   - User Story: Who benefits and how
   - Proposed Solution: High-level approach
   - Goals & Non-Goals: Scope definition
   - Technical Breakdown: Tasks by area
   - Risks & Dependencies: Potential challenges

3. **Create Tasks from Breakdown**
   For each area in the technical breakdown:
   - Create tasks using mcp__scopecraft-cmd__task_create
   - Use area tags (AREA:core, AREA:cli, etc.)
   - Link to parent feature
   - Set initial status to "planning"
   - Establish dependencies where needed

4. **Establish Relationships**
   - Set parent-child relationships with the feature
   - Create task dependencies based on technical requirements
   - Link sequential tasks using previous/next parameters
   - Group parallel tasks that can be done together
</planning_process>

<contemplation>
## Task Creation Architecture

Proper task creation requires understanding both technical relationships and AI development workflow optimization.
</contemplation>

**Systematic Task Creation Pattern:**

<example>
```
mcp__scopecraft-cmd__task_create
- title: Clear, actionable description optimized for AI implementation
- type: research/design/implementation/test/documentation
- status: planning (initial state for all created tasks)
- phase: backlog  # REQUIRED - explicit phase specification always
- tags: ["AREA:core", "AREA:cli", "AREA:ui", etc.] # Area designation via tags
- parent: Feature name (clean name without FEATURE_ prefix)
- previous: Task ID that must complete before this task starts
- next: Task ID that should start after this task completes
- depends: [Array of prerequisite task IDs for parallel dependencies]
- content: Detailed implementation requirements with structured todo lists
```
</example>

<thinking>
Task relationships enable both sequential workflows and parallel development streams, optimizing for solo developer efficiency.
</thinking>

**Task Linking Examples:**

```
# Sequential tasks (research → design → implement)
mcp__scopecraft-cmd__task_create
- title: "Research authentication patterns"
- type: "research"
- phase: "backlog"
- parent: "user-authentication"

# Returns: TASK-001

mcp__scopecraft-cmd__task_create  
- title: "Design authentication flow"
- type: "design"
- phase: "backlog"
- parent: "user-authentication"
- previous: "TASK-001"  # Must come after research

# Returns: TASK-002

# Parallel tasks (CLI and UI can be done simultaneously)
mcp__scopecraft-cmd__task_create
- title: "Implement authentication CLI"
- type: "implementation"
- phase: "backlog"
- parent: "user-authentication"
- depends: ["TASK-002"]  # Needs design but not sequential

mcp__scopecraft-cmd__task_create
- title: "Implement authentication UI"
- type: "implementation"
- phase: "backlog"  
- parent: "user-authentication"
- depends: ["TASK-002"]  # Also needs design

# Task with multiple dependencies
mcp__scopecraft-cmd__task_create
- title: "Integration testing for authentication"
- type: "test"
- phase: "backlog"
- parent: "user-authentication"
- depends: ["TASK-003", "TASK-004"]  # Needs both implementations
```

**IMPORTANT: Phase Assignment**
- Always specify the `phase` parameter when creating tasks
- Tasks must belong to a phase for proper file organization
- Child tasks do NOT automatically inherit parent feature's phase
- If unsure, use the current active phase or "backlog"

**Note on subdirectory**: The `subdirectory` parameter places the task in a metadata field only, not a physical folder. Always use `phase` to control file location.

**Task Content Best Practices:**
For research tasks, always include:
- Specific WebSearch queries to run
- Key questions to answer
- Libraries/patterns to investigate
- Date range for search (prefer recent content)

Example research task content:
```
Research current best practices for real-time collaboration in React

## WebSearch Queries
- "React real-time collaboration 2025 best practices"
- "WebSocket vs Server-Sent Events React 2025"
- "React state management real-time updates"
- "collaborative editing React libraries comparison"

## Questions to Answer
- What are the current popular approaches?
- Which libraries are actively maintained?
- What are the performance trade-offs?
- How do others handle conflict resolution?
```

<methodology>
## Task Type Taxonomy and Application

Different task types serve specific purposes in the development lifecycle and require different approaches for AI-assisted implementation.
</methodology>

### 1. Research/Spike Tasks
<brainstorm>
**Purpose:** Resolve technical unknowns and identify optimal implementation approaches

**When to Use:**
- Technical approach uncertainty exists
- Library or framework selection needed
- Integration pattern unclear
- Performance requirements need validation
- User experience patterns need investigation
</brainstorm>

**Implementation Requirements:**
- **Mandatory WebSearch integration** for current best practices
- Systematic evaluation of technical alternatives
- Investigation of user patterns and industry implementations
- Assessment of integration complexity and requirements

<example>
**Research Task Example:**
"Research current React state management patterns for real-time collaborative features"
</example>

**Essential WebSearch Focus Areas:**
<do_not_strip>
- Latest industry best practices and patterns (prioritize 2024+ content)
- Current library ecosystem and comparative analysis
- Recent implementation approaches and architectural decisions
- Common implementation pitfalls and proven solutions
- Performance optimization strategies and benchmarks
</do_not_strip>

### 2. Design/UX Tasks  
Use before implementation for user-facing features:
- Create user flow diagrams
- Design UI mockups or wireframes
- Plan user interactions and states
- Define edge cases and error states
- Example: "Design user flow for real-time collaboration indicators"

### 3. Architecture Tasks
Use for complex features requiring planning:
- Design data models and schemas
- Plan component hierarchy
- Define API contracts
- Outline state management approach
- Example: "Design WebSocket message protocol for collaboration"

### 4. Implementation Tasks
Use for actual coding work:
- Build new components or features
- Integrate with existing systems
- Implement business logic
- Create utilities and helpers
- Example: "Implement real-time sync engine in core"

### 5. Test Tasks
Use throughout development:
- Write unit tests
- Create integration tests
- Build e2e test scenarios
- Test edge cases and error handling
- Example: "Write tests for concurrent editing scenarios"

### 6. Documentation Tasks
Use to maintain project knowledge:
- Update API documentation
- Write user guides
- Create developer documentation
- Document architecture decisions
- Example: "Document WebSocket protocol for collaborators"

<contemplation>
## Task Granularity Optimization Strategy

Balancing task granularity is critical for AI-assisted development. Too granular creates excessive context switching; too broad reduces implementation focus.
</contemplation>

<methodology>
## Task Separation vs. Todo List Decision Framework

**Create SEPARATE Tasks When:**
<thinking>
Separate tasks enable parallel work streams and domain-specific optimization but increase context switching overhead.
</thinking>
- Work spans distinct technical domains (CLI vs MCP vs UI components)
- Different specialized knowledge or expertise required
- Activities can be executed in parallel development streams
- Clear architectural boundaries separate implementation concerns
- Each task represents a complete, testable unit of functionality

**Use TODO LISTS Within Single Task When:**
<innermonologue>
Todo lists maintain context continuity and enable natural work progression within the same technical domain.
</innermonologue>
- Activities follow sequential, related progression
- Consistent technical context applies throughout
- Natural workflow progression (research → implement → test → document)
- Combined work scope fits comfortably within single AI development session
- Strong coupling between subtasks makes separation counterproductive
</methodology>

<example>
## Granularity Examples and Analysis

**Optimal - Single Task with Structured Todos:**
```
Task: Research and Design Authentication System Architecture
## Todo List
- [ ] Research OAuth2 best practices and current implementations
- [ ] Research JWT implementation patterns and security considerations  
- [ ] Design authentication schema and data model
- [ ] Create system architecture diagram and flow documentation
- [ ] Document architectural decisions and trade-off analysis
```
*Rationale: All activities within authentication domain, sequential progression, shared context*

**Optimal - Domain-Separated Tasks:**
```
Task 1: Implement CLI Authentication Commands and Workflows
Task 2: Implement MCP Authentication Tools and Integration
Task 3: Create UI Authentication Components and User Experience
```
*Rationale: Different technical domains, parallel implementation possible, distinct expertise areas*

**Suboptimal - Over-Granular Separation:**
```
Task 1: Research OAuth2 implementation patterns
Task 2: Research JWT security considerations
Task 3: Design authentication data schema
Task 4: Write architecture documentation
```
*Rationale: Excessive context switching, related research activities artificially separated*
</example>

## Working Example for Feature Planning:

Instead of creating 14 separate tasks, organize as:

1. **Research/Design Phase** (1-2 tasks)
   - Combined research task with multiple queries
   - Combined design task for architecture/schema

2. **Implementation Phase** (3-4 tasks)
   - One task per client (CLI, MCP, UI)
   - Separate core implementation task

3. **Testing/Documentation** (1-2 tasks)
   - Integration testing task
   - Comprehensive documentation task

Remember: Each task creates a new AI context. Minimize context switches by combining related work into todo lists.

## Task Sequencing Best Practices

1. **Start with Research** when dealing with unknowns
2. **Design before Implementation** for UI features
3. **Architecture before Complex Implementation**
4. **Tests alongside or after Implementation**
5. **Documentation throughout the process**

## Creating Task Chains and Dependencies

### When to Use Previous/Next vs Dependencies

**Use Previous/Next for:**
- Sequential workflows where one task must complete before the next
- Linear progression through phases (research → design → implementation)
- When order matters for logical flow
- Example: Research must finish before Design can start

**Use Dependencies for:**
- Tasks that need multiple prerequisites
- Cross-area dependencies (UI needs Core API)
- Non-linear relationships
- Example: Documentation depends on Implementation AND Testing

### Creating Linked Task Sequences

**Step 1: Create Tasks in Order**
```
# Create research task first
Task1_ID = mcp__scopecraft-cmd__task_create(
  title: "Research real-time collaboration patterns",
  type: "research",
  phase: "backlog"
)

# Create design task with previous link
Task2_ID = mcp__scopecraft-cmd__task_create(
  title: "Design collaboration architecture", 
  type: "design",
  phase: "backlog",
  previous: Task1_ID  # Links to research task
)

# Create implementation with previous link
Task3_ID = mcp__scopecraft-cmd__task_create(
  title: "Implement core collaboration engine",
  type: "implementation", 
  phase: "backlog",
  previous: Task2_ID  # Links to design task
)
```

**Step 2: Update First Task with Next Link**
```
mcp__scopecraft-cmd__task_update(
  id: Task1_ID,
  updates: {
    metadata: {
      next_task: Task2_ID
    }
  }
)
```

### Example: Complex Feature with Mixed Dependencies

```
Research Phase:
1. Task: Research WebSocket patterns (TASK-001)
2. Task: Research state sync strategies (TASK-002)
   - No direct link to TASK-001 (parallel research)

Design Phase:
3. Task: Design collaboration architecture (TASK-003)
   - previous: TASK-001 
   - depends: [TASK-001, TASK-002]  # Needs both research tasks

Implementation Phase:
4. Task: Implement core engine (TASK-004)
   - previous: TASK-003
5. Task: Implement CLI commands (TASK-005)
   - depends: [TASK-004]  # Needs core but not previous
6. Task: Implement UI components (TASK-006)
   - depends: [TASK-004]  # Also needs core, parallel to CLI

Testing Phase:
7. Task: Integration testing (TASK-007)
   - depends: [TASK-005, TASK-006]  # Needs both implementations
```

### Best Practices for Task Linking

1. **Create tasks in logical order** - This makes it easier to reference previous tasks
2. **Use previous/next for strict sequences** - When order is mandatory
3. **Use dependencies for prerequisites** - When multiple tasks must complete first
4. **Update bidirectional links** - After creating all tasks, update earlier tasks with next links
5. **Document the flow** - Include a task flow diagram in the feature description

### Common Patterns

**Linear Flow:**
```
Research → Design → Implement → Test → Document
(each with previous/next links)
```

**Branching Flow:**
```
Research → Design → [Core Implementation]
                  ↘ [CLI Implementation] → Integration Test
                  ↘ [UI Implementation]  ↗
```

**Parallel Research:**
```
[Research Option A] ↘
                     Synthesis → Design → Implementation
[Research Option B] ↗
```

## Default Organization Patterns
- Place tasks in feature folder
- Use area tags for technical domain tracking
- Consider dependencies between task types:
  - Research → Design → Implementation
  - Architecture → Implementation → Integration
  - Any task → Documentation
  - Implementation → Testing

## One-Dev Pragmatic Approach
For solo development pre-v1:
- Combine related small tasks when practical
- Focus on MVP functionality over optimization
- Prefer existing solutions over custom implementations
- Keep documentation lean but essential
- Test critical paths, not edge cases initially
</task_creation_patterns>

<fallback_template>
If template is missing, use this structure:

# Feature: {Title}

## Problem Statement
What problem are we solving?

## Proposed Solution
High-level approach to solving the problem

## Technical Breakdown

### Research/Spike Tasks
- [ ] Research: Investigate current best practices for {feature type}
- [ ] Research: Explore library options for {specific need}

### Area: UI
- [ ] Design: Create user flow for {feature}
- [ ] Design: Design component layouts and states  
- [ ] Implementation: Build {component name} component
- [ ] Test: Write UI tests for user interactions
  
### Area: Core  
- [ ] Architecture: Design data model for {feature}
- [ ] Implementation: Implement {feature} business logic
- [ ] Test: Unit test core functionality

### Area: MCP
- [ ] Implementation: Add MCP tool for {feature}
- [ ] Documentation: Document new MCP tool usage

### Area: CLI
- [ ] Implementation: Add CLI command for {feature}
- [ ] Documentation: Update CLI help text

### Area: Docs
- [ ] Documentation: Write user guide for {feature}
- [ ] Documentation: Update API documentation

## Success Criteria
How we'll know the feature is complete
</fallback_template>

<quality_checks>
Before completing the planning:
1. Ensure all areas are covered appropriately
2. Verify task titles are clear and actionable
3. Check dependencies make logical sense
4. Confirm success criteria are measurable
5. Review risk assessment is comprehensive
</quality_checks>

<output_summary>
After planning is complete, provide:
1. Feature ID and summary (if created)
2. List of created tasks organized by area tags
3. Dependency graph if complex
4. Next steps for implementation
5. Any identified risks or blockers
</output_summary>

<error_handling>
Handle these cases gracefully:
- Task is not a PRD: Suggest alternative planning approach
- Task already planned: Show existing tasks, offer modification
- Simple vs complex confusion: Provide clear criteria
- Area organization: Default to tags, allow folder override
- Invalid task format: Check if it's a valid MDTM task
- Feature in multiple phases: Ask for phase clarification
- Feature not found: Offer to create new feature
</error_handling>

<examples>
Usage examples:
```
# Complex PRD task → Feature creation
/project:feature-planning TASK-20250518T025100

# Simple task → Single implementation task
/project:feature-planning TASK-20250518T030000

# Ambiguous input → Triggers clarification
/project:feature-planning "Add collaboration features"
> "Is this a quick proof-of-concept or production-ready feature?"
> User: "POC"
> "Great! I'll create a streamlined plan focused on demonstrating the concept."

# Clear POC → No clarification needed
/project:feature-planning "Quick POC for WebSocket integration"

# Existing feature in multiple phases
/project:feature-planning user-auth

# Traditional feature description
/project:feature-planning "Add real-time collaboration to task editor"

# Complex feature with proper granularity
/project:feature-planning "Real-time collaboration system"

## Resulting Task Structure with Linking:

1. Task: Research Real-time Collaboration (TASK-001)
   - Todo: Research WebSocket patterns
   - Todo: Research conflict resolution
   - Todo: Research state synchronization
   - Todo: Document findings
   - Next: TASK-002

2. Task: Design Collaboration Architecture (TASK-002)
   - Todo: Design message protocol
   - Todo: Design state management
   - Todo: Create system diagrams
   - Todo: Document architecture
   - Previous: TASK-001
   - Next: TASK-003

3. Task: Implement Core Collaboration Engine (TASK-003)
   - Todo: Create WebSocket server
   - Todo: Implement message handlers
   - Todo: Add state synchronization
   - Todo: Write unit tests
   - Previous: TASK-002
   
4. Task: Add CLI Collaboration Commands (TASK-004)
   - Todo: Implement `collab start`
   - Todo: Implement `collab join`
   - Todo: Write CLI tests
   - Depends: [TASK-003]

5. Task: Build UI Collaboration Features (TASK-005)
   - Todo: Create presence indicators
   - Todo: Add real-time updates
   - Todo: Implement conflict UI
   - Todo: Write component tests
   - Depends: [TASK-003]

6. Task: Integration and Documentation (TASK-006)
   - Todo: Full system testing
   - Todo: Write user guide
   - Todo: Create API docs
   - Depends: [TASK-004, TASK-005]

## Task Flow Visualization:
```
Research (001) → Design (002) → Core Implementation (003)
                                        ↓
                              CLI Commands (004) ⟶
                                                   Integration & Docs (006)
                              UI Features (005)  ⟶
```
```
</examples>

<common_mistakes>
## Common Mistakes to Avoid:

1. **Creating too many granular tasks**
   - Wrong: Separate tasks for research, implement, test, document
   - Right: One task with research→implement→test→document todos

2. **Forgetting to specify phase**
   - Wrong: Relying on parent inheritance
   - Right: Always explicitly set phase parameter

3. **Confusing subdirectory behavior**
   - Wrong: Expecting subdirectory to control file location
   - Right: Use phase for location, subdirectory for metadata

4. **Not considering AI context switches**
   - Wrong: 14 small tasks for one feature
   - Right: 5-6 larger tasks with todo lists
</common_mistakes>

<do_not_strip>
## Feature Planning Best Practices

**Task Granularity and Organization:**
- Maintain consistent task scope (1-3 days of solo development work)
- Group related activities into single tasks with structured todo lists
- Create separate tasks only for distinct technical domains or parallel work streams
- Optimize for AI development session continuity (fewer context switches)

**Technical Organization:**
- Always specify phase explicitly - never rely on parent inheritance
- Use area tags for technical domain organization over folder structures
- Default to proven architectural patterns over custom solutions
- Focus on MVP functionality for pre-v1 development cycles

**Development Workflow Optimization:**
- Start with research tasks when technical unknowns exist
- Include dedicated design tasks before UI implementation begins
- Create architecture tasks for complex multi-area features
- Include comprehensive testing tasks for critical functionality paths
- Integrate documentation tasks throughout development lifecycle

**Task Relationship Management:**
- **MANDATORY: Create proper task links** for workflow continuity
- Use previous/next relationships for strict sequential dependencies
- Use depends arrays for parallel prerequisite relationships
- Create tasks in logical dependency order to simplify referencing
- Update bidirectional links after all task creation completes

**Research Task Optimization:**
- Integrate WebSearch systematically to stay current with best practices
- Prioritize recent content (2024+ implementations and patterns)
- Focus on library ecosystem analysis and comparative evaluation
- Document architectural decisions and trade-off analysis

**Quality Assurance:**
- Include comprehensive task flow diagram in feature description
- Test workflow continuity by following complete task chain
- Validate that task breakdown covers all requirements comprehensively
- Ensure task relationships enable efficient parallel and sequential work
</do_not_strip>

<human_review_section>
Include in the feature a section for human review:

### Human Review Required

Planning decisions to verify:
- [ ] Clarification questions were appropriate for context
- [ ] Scope assessment (POC vs production) was correct
- [ ] Complexity assessment (simple vs feature-worthy)
- [ ] Timeline considerations properly applied
- [ ] Area designation via tags vs folders
- [ ] Task granularity for AI session scope
- [ ] Sequential dependencies identified correctly
- [ ] Original PRD properly linked/referenced
- [ ] Feature folder organization appropriate
- [ ] Correct phase assignment
- [ ] Task breakdown completeness matches scope

Technical assumptions:
- [ ] Architecture decisions implicit in task breakdown
- [ ] Integration approach assumptions
- [ ] Performance/scaling considerations
- [ ] Security implementation needs

Flag these in both:
1. The parent feature task content
2. Individual tasks where assumptions were made
</human_review_section>