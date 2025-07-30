Review UI/UX design quality, accessibility compliance, and user experience standards.

by:(Adam Manuel)[https://github.com/AdamManuel-dev]

## Design Quality Review Areas

### 1. Visual Consistency
- Design system compliance (colors, typography, spacing)
- Consistent component styling across pages
- Brand guidelines adherence
- Icon and imagery consistency
- UI element alignment and proportions

### 2. User Experience (UX)
- Intuitive navigation and information architecture
- Clear user flows and task completion paths
- Appropriate feedback for user actions
- Error states and loading indicators
- Accessibility and inclusive design

### 3. Responsive Design
- Mobile-first approach implementation
- Breakpoint consistency across devices
- Touch-friendly interface elements
- Optimal content layout on all screen sizes
- Performance on various devices

### 4. Accessibility Standards
- WCAG 2.1 AA compliance
- Keyboard navigation support
- Screen reader compatibility
- Color contrast ratios (4.5:1 minimum)
- Focus indicators and states

### 5. Design System Integration
- Component library usage consistency
- Token-based design implementation
- Reusable pattern adoption
- Documentation alignment with implementation

## Automated Visual Checks

Use stagehand MCP tools for comprehensive visual testing:

### Screenshot-Based Testing
1. **Navigate to application pages**
   ```
   Take screenshots of key pages and components
   ```

2. **Responsive Testing**
   ```
   Capture screenshots at different viewport sizes:
   - Mobile (375px)
   - Tablet (768px) 
   - Desktop (1200px)
   - Large desktop (1920px)
   ```

3. **Component State Testing**
   ```
   Test and capture various component states:
   - Default, hover, active, disabled
   - Loading states and error conditions
   - Form validation feedback
   ```

4. **Cross-Browser Verification**
   ```
   Verify consistent rendering across browsers
   Take comparison screenshots
   ```

### Interactive UX Testing
1. **Navigation Flow Testing**
   ```
   Use stagehand to navigate through user flows
   Capture screenshots at each step
   Verify smooth transitions and interactions
   ```

2. **Form Interaction Testing**
   ```
   Test form filling, validation, and submission
   Capture error states and success feedback
   Verify accessibility of form elements
   ```

3. **Accessibility Testing**
   ```
   Navigate using keyboard only
   Test screen reader compatibility
   Verify focus indicators
   ```

## Review Process

1. **Initial Visual Audit**
   - Take baseline screenshots of all major pages
   - Document current visual state
   - Identify inconsistencies and issues

2. **Responsive Testing**
   - Navigate to each page and resize viewport
   - Capture screenshots at each breakpoint
   - Verify layout integrity and usability

3. **Component Analysis**
   - Test individual components in isolation
   - Verify design system compliance
   - Check interactive states and transitions

4. **User Flow Validation**
   - Complete critical user journeys
   - Document UX pain points
   - Verify accessibility standards

5. **Cross-Reference with Design Specs**
   - Compare screenshots with design mockups
   - Identify deviations from intended design
   - Prioritize fixes by impact on user experience

## Deliverables

- Screenshot documentation of current state
- Responsive design audit report
- Accessibility compliance assessment
- Design system deviation report
- UX improvement recommendations with visual examples

Always provide specific visual examples and actionable recommendations for design improvements. 