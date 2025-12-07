Execute the review queue script to get the next batch of files to review.

## Instructions

1. Run the find-to-review script located at `/Users/adammanuel/Projects/tahoma-ai/.review/find-to-review.ts`
2. The script will:
   - Load the review queue from `.review/review-queue.json`
   - Select 5-10 files based on size (5 for large/xlarge, 10 for small/medium)
   - Display file paths with metadata (lines, service, priority)
   - Mark the files as "in review"
   - Update the queue JSON

3. After running, display the files to the user with:
   - Full file paths for easy access
   - Line count and size category
   - Service/module they belong to
   - Estimated review time based on size

4. Remind the user to add review comments using these tags:
   - `#TODO` - Future improvements or features to add
   - `#FIX` - Bugs or issues that need fixing
   - `#REVIEW` - Needs further review or discussion
   - `#BUG` - Known bugs to track
   - `#REMOVE` - Code marked for removal
   - `#COMMENT` - Needs better documentation/comments

5. After the user has reviewed the files, they should run `/find-to-review` again to get the next batch.

## Expected Output Format

Display results like this:

```
📋 Next Files to Review (Batch #N)
═══════════════════════════════════════════════════════════

orchestration-service/src/services/workflow-executor.ts
  Lines: 456 | Size: large | Priority: 11 | Est. time: 10-15 min

orchestration-service/src/services/element-finder.ts
  Lines: 289 | Size: large | Priority: 11 | Est. time: 8-12 min

RagService/src/fusion/fuseEvidence.ts
  Lines: 178 | Size: medium | Priority: 9 | Est. time: 5-8 min

...

═══════════════════════════════════════════════════════════
Total: N files | Est. total time: X-Y minutes
Progress: M/N files reviewed (P%)

💡 Add review comments using: #TODO #FIX #REVIEW #BUG #REMOVE #COMMENT
📊 Run 'npm run review:aggregate' to see all review comments
```

Execute the script now and display the results to the user.
