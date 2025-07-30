Convert Product Requirements Documents into comprehensive TODO lists with prioritization.

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

**Context:**
- PRD Location: {prd}
- Output Location: {output} [default to TODO.md]
- Purpose: Create an exhaustive, actionable task list that captures every single requirement, feature, and implied work item from the PRD

**Your Analysis Process:**

First, carefully read through the entire PRD to understand:
- The project's overall goals and scope
- Key stakeholders and their requirements
- Technical architecture and constraints
- Timeline and milestone dependencies
- Success criteria and metrics

Then, systematically extract tasks from these sections:

1. **Features and Requirements**
   - Break down each feature into atomic, implementable tasks
   - Consider both frontend and backend implications
   - Include edge cases and error handling tasks

2. **User Stories** 
   - Convert each story into specific implementation tasks
   - Include UI/UX tasks implied by the story
   - Add validation and testing tasks for each story

3. **Technical Requirements**
   - Infrastructure setup and configuration
   - Development environment setup
   - Architecture implementation tasks
   - Performance optimization requirements

4. **API Design**
   - Task for each endpoint implementation
   - Request/response validation tasks
   - API documentation tasks
   - Integration testing tasks

5. **Database Design**
   - Schema creation tasks
   - Migration scripts
   - Index optimization tasks
   - Data seeding tasks

6. **Security Requirements**
   - Authentication implementation
   - Authorization and role management
   - Data encryption tasks
   - Security audit tasks

7. **Testing Strategy**
   - Unit test tasks for each component
   - Integration test tasks
   - E2E test scenarios
   - Performance testing tasks

8. **Documentation**
   - API documentation
   - User guides
   - Developer documentation
   - Deployment guides

9. **Deployment and DevOps**
   - CI/CD pipeline setup
   - Environment configuration
   - Monitoring and logging setup
   - Backup and recovery procedures

**Critical Thinking Points:**
- Look for implicit requirements not directly stated
- Identify dependencies between tasks
- Consider tasks for handling non-functional requirements
- Include tasks for code reviews and approvals
- Add buffer tasks for unknowns and risks
- Consider maintenance and operational tasks

**Output Format Requirements:**

Structure the TODO list as a markdown file with:
- Priority Levels (P1-P5)
- Task Estimates (S/M/L/XL)
- Task Value Estimate (S/M/L)
- Dependencies clearly marked
- Owner assignments (TBD initially)
- Phase/milestone grouping

Include EVERY actionable item, even small configuration tasks. Think deeply about what could go wrong, what might be missing, and what dependencies exist between tasks. Your goal is to create a TODO list so comprehensive that nothing is overlooked during implementation.