# Implementation Plan: Replace Recording Tips with Live Transcript Display

## Problem Statement

**Current Issue**:
- TranscriptPanel exists in the code but is NOT visible in the UI
- Users cannot see live transcripts when recording
- Recording Tips card occupies valuable space at the bottom

**User Request**:
- Replace the Recording Tips card location with live transcript display
- Show tips when NOT recording, transcripts when recording
- Make transcripts immediately visible and accessible

## Solution Overview

**Strategy**: Conditional rendering at the Recording Tips location (bottom of RecordMode)
- **When idle**: Show Recording Tips card (helpful onboarding)
- **When recording**: Replace with TranscriptPanel (live transcripts visible)

**Key Change**: Move TranscriptPanel from its current invisible location to replace the Recording Tips card

## Implementation Steps

### Step 1: Update Imports in RecordMode.tsx

**File**: `/Users/adammanuel/Projects/tahoma-ai/TahomaAI/src/components/modes/RecordMode.tsx`

**Location**: Line 10-42 (import section)

**Action**: Add import for `isRecordingAudioAtom` to track voice recording state

```typescript
// Add to existing state imports around line 24
import {
  recordingStatusAtom,
  startRecordingAtom,
  stopRecordingAtom,
  pauseRecordingAtom,
  resumeRecordingAtom,
  recordingDurationAtom,
  recordingEventCountAtom,
  isActivelyRecordingAtom,
  canStartRecordingAtom,
  privacyStatusAtom,
  initializePrivacyAtom,
  isRecordingAudioAtom,  // ADD THIS LINE
} from "@/state";
```

**Note**: Verify if `isRecordingAudioAtom` is exported from `@/state` barrel export. If not, use direct import:
```typescript
import { isRecordingAudioAtom } from "@/state/transcript-atoms";
```

### Step 2: Add State Hook for Audio Recording

**Location**: Line 44-51 (component state hooks)

**Action**: Add hook to read audio recording status

```typescript
export function RecordMode() {
  const { has } = useAuth();
  const [status] = useAtom(recordingStatusAtom);
  const [duration, setDuration] = useAtom(recordingDurationAtom);
  const [eventCount, setEventCount] = useAtom(recordingEventCountAtom);
  const [isRecording] = useAtom(isActivelyRecordingAtom);
  const [canStart] = useAtom(canStartRecordingAtom);
  const [privacyStatus] = useAtom(privacyStatusAtom);
  const [isRecordingAudio] = useAtom(isRecordingAudioAtom);  // ADD THIS LINE
```

### Step 3: Remove Invisible TranscriptPanel

**Location**: Lines 338-341

**Action**: Delete the invisible TranscriptPanel wrapper

**Current code to DELETE:**
```typescript
{/* Transcript Panel */}
<div className="flex-1 min-h-0">
  <TranscriptPanel className="h-full" />
</div>
```

**Rationale**: This panel is not visible to users and will be replaced by the conditional rendering below

### Step 4: Replace Recording Tips with Conditional Rendering

**Location**: Lines 343-359 (Recording Tips Card)

**Action**: Replace static tips with conditional logic that shows tips OR transcripts

**REMOVE this entire section:**
```typescript
{/* Tips Card */}
<Card className="flex-shrink-0">
  <CardContent>
    <h4 className="text-sm font-semibold text-gray-900 mb-2">
      💡 Recording Tips
    </h4>
    <ul className="text-sm text-gray-600 space-y-1">
      <li>• Click naturally through your workflow</li>
      <li>• Use pause to skip sensitive data entry</li>
      {privacyStatus.enabled && (
        <li>• Sensitive fields are automatically masked ({privacyStatus.strategy} mode)</li>
      )}
      <li>• Stop when your workflow is complete</li>
      <li>• Audio is automatically transcribed in the panel below</li>
    </ul>
  </CardContent>
</Card>
```

**REPLACE with:**
```typescript
{/* Conditional Display: Recording Tips OR Live Transcript */}
{isRecordingAudio ? (
  // Show live transcript panel when recording
  <div className="flex-shrink-0" style={{ height: '300px' }}>
    <TranscriptPanel className="h-full" />
  </div>
) : (
  // Show tips when not recording
  <Card className="flex-shrink-0">
    <CardContent>
      <h4 className="text-sm font-semibold text-gray-900 mb-2">
        💡 Recording Tips
      </h4>
      <ul className="text-sm text-gray-600 space-y-1">
        <li>• Click naturally through your workflow</li>
        <li>• Use pause to skip sensitive data entry</li>
        {privacyStatus.enabled && (
          <li>• Sensitive fields are automatically masked ({privacyStatus.strategy} mode)</li>
        )}
        <li>• Stop when your workflow is complete</li>
        <li>• Audio is transcribed and displayed here in real-time</li>
      </ul>
    </CardContent>
  </Card>
)}
```

**Key Changes**:
- Wrapped in conditional: `isRecordingAudio ? TranscriptPanel : Tips`
- TranscriptPanel gets fixed height (300px) for consistent sizing
- Updated last tip text: "displayed here in real-time" (more accurate)
- Both options use `flex-shrink-0` to prevent collapsing

### Step 5: Update File Header Timestamp

**Location**: Line 3

**Action**: Update `@lastmodified` timestamp

```typescript
* @lastmodified 2025-12-01T[CURRENT_TIME]Z
```

**Note**: Use system `date` command to get accurate timestamp during implementation

## Visual Flow

### Before "Start voice" (Idle State)
```
┌─────────────────────────────────────────┐
│ Recording Session Card                  │
│ [Start Recording Button]                │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 💡 Recording Tips                       │
│ • Click naturally through workflow      │
│ • Use pause to skip sensitive data      │
│ • Sensitive fields masked (if enabled)  │
│ • Stop when workflow complete           │
│ • Audio transcribed here in real-time   │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ ▶ Event Timeline (collapsed)            │
└─────────────────────────────────────────┘
```

### After "Start voice" (Recording Active)
```
┌─────────────────────────────────────────┐
│ Recording Session Card                  │
│ Status: Active | Duration: 00:00:15     │
│ [Pause] [Stop] [Screenshot]             │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Transcript              [● Listening]   │
│ ┌─────────────────────────────────────┐ │
│ │ 🎤 10:23 AM                         │ │
│ │ "I'm going to click on the menu"    │ │
│ │                                     │ │
│ │ 🎤 10:24 AM (interim)               │ │
│ │ "and then select the settings..."   │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ ▶ Event Timeline (collapsed)            │
└─────────────────────────────────────────┘
```

## State Behavior

### State Atom: `isRecordingAudioAtom`

**Source**: `/Users/adammanuel/Projects/tahoma-ai/TahomaAI/src/state/transcript-atoms.ts`

**Values**:
- `false`: No audio recording active (shows tips)
- `true`: Audio recording active (shows transcript panel)

**Updates Triggered By**:
- User clicks "Start voice" in AudioControls → `isRecordingAudio` becomes `true`
- User clicks "Stop voice" in AudioControls → `isRecordingAudio` becomes `false`

**Re-render Behavior**:
- State change triggers immediate re-render of RecordMode
- Tips card unmounts, TranscriptPanel mounts (or vice versa)
- No transition animation needed (instant swap)

## Edge Cases Handled

### 1. Recording Stopped with Existing Transcripts
**Scenario**: User records, then stops. TranscriptPanel still has transcript data.

**Behavior**:
- UI switches back to Recording Tips card
- Transcript data remains in `transcriptsAtom` (persisted)
- If user starts recording again, old transcripts still visible

**Consideration**: Should transcripts persist or clear when switching back to tips?

**Current Plan**: Transcripts persist (user can manually clear with "Clear" button)

### 2. Microphone Permission Pending
**Scenario**: User clicks "Start voice", awaiting mic permission

**Behavior**:
- `isRecordingAudio` only becomes `true` AFTER permission granted
- Tips remain visible during "Requesting mic..." state
- Once permission granted, switch to TranscriptPanel

### 3. Azure Speech Not Configured
**Scenario**: Missing `PLASMO_PUBLIC_AZURE_SPEECH_KEY` env var

**Behavior**:
- TranscriptPanel handles this internally (shows warning message)
- Warning appears in the same location as transcripts would
- User sees helpful error message with configuration instructions

### 4. No Speech Detected
**Scenario**: Recording active but user isn't speaking

**Behavior**:
- TranscriptPanel shows "Listening for speech..." with animated indicator
- Empty state handled by TranscriptPanel component (lines 106-111)

### 5. Layout Height Consistency
**Scenario**: TranscriptPanel height may vary with content

**Solution**:
- Fixed height wrapper: `style={{ height: '300px' }}`
- Prevents layout shift when switching between tips and transcript
- TranscriptPanel has internal scrolling for overflow content

## Testing Checklist

### Functional Tests
- [ ] Recording Tips visible on initial load (idle state)
- [ ] Clicking "Start voice" replaces tips with TranscriptPanel
- [ ] TranscriptPanel shows "Listening..." when recording but no speech
- [ ] Live transcripts appear in real-time as user speaks
- [ ] Interim transcripts (blue background) update correctly
- [ ] Final transcripts (white background) persist
- [ ] Clicking "Stop voice" switches back to Recording Tips
- [ ] Existing transcripts persist in state after stopping
- [ ] Clicking "Clear" in TranscriptPanel clears transcripts
- [ ] Restarting recording shows previous transcripts + new ones

### Visual Tests
- [ ] Layout height remains consistent when switching
- [ ] No layout shift or jumping when tips/transcript swap
- [ ] TranscriptPanel scrolls properly when content overflows
- [ ] Tips card styling matches original design
- [ ] Transition between states feels smooth/instant

### Edge Case Tests
- [ ] Microphone permission prompt doesn't switch UI prematurely
- [ ] Azure not configured shows appropriate warning
- [ ] Privacy status tip appears/disappears correctly
- [ ] Event Timeline card remains unaffected
- [ ] Multiple start/stop cycles work correctly

### Integration Tests
- [ ] AudioControls "Start voice" button syncs with UI
- [ ] `isRecordingAudioAtom` updates correctly
- [ ] `transcriptsAtom` receives data from Azure Speech Service
- [ ] Page context appears in transcripts (URL, title)
- [ ] Associated action IDs link correctly

## Files Modified

### Primary File
**`/Users/adammanuel/Projects/tahoma-ai/TahomaAI/src/components/modes/RecordMode.tsx`**
- Add import for `isRecordingAudioAtom` (line ~24)
- Add state hook `const [isRecordingAudio] = useAtom(isRecordingAudioAtom)` (line ~51)
- Remove invisible TranscriptPanel wrapper (delete lines 338-341)
- Replace Recording Tips Card with conditional rendering (lines 343-359)
- Update file header timestamp (line 3)

### Reference Files (No Changes)
- `/Users/adammanuel/Projects/tahoma-ai/TahomaAI/src/components/transcript/TranscriptPanel.tsx` - Used as-is in conditional render
- `/Users/adammanuel/Projects/tahoma-ai/TahomaAI/src/state/transcript-atoms.ts` - Provides `isRecordingAudioAtom` state
- `/Users/adammanuel/Projects/tahoma-ai/TahomaAI/src/components/audio/AudioControls.tsx` - Triggers state changes
- `/Users/adammanuel/Projects/tahoma-ai/TahomaAI/src/components/audio/AudioControlsProvider.tsx` - Manages audio recording lifecycle

## Risk Assessment

**Risk Level**: Low ✅

**Justification**:
- Single file modification (RecordMode.tsx)
- No state management changes required
- No new components created
- Leverages existing, tested components
- Easy rollback (restore deleted lines)

**Rollback Plan**:
1. Restore deleted TranscriptPanel wrapper (lines 338-341)
2. Restore original Recording Tips Card (lines 343-359)
3. Remove conditional rendering logic
4. Remove `isRecordingAudio` state hook and import

**Rollback Time**: < 2 minutes

## Success Criteria

✅ **User can see live transcripts** in the RecordMode interface

✅ **Transcripts appear at the bottom** where Recording Tips were located

✅ **Tips show when idle**, transcripts show when recording

✅ **No layout jumping** or visual glitches during state transitions

✅ **All existing functionality preserved** (audio recording, session management, event timeline)

## Implementation Time Estimate

**Total Time**: ~10 minutes

- 2 min: Add import and state hook
- 2 min: Remove invisible TranscriptPanel
- 4 min: Replace tips with conditional rendering
- 2 min: Test in browser and verify behavior

## Post-Implementation Improvements (Optional)

If time permits, consider these enhancements:

1. **Smooth Transition Animation**: Add CSS fade transition between tips and transcript
2. **Height Optimization**: Make TranscriptPanel height responsive based on content
3. **Persist Transcript State**: Clear transcripts automatically when switching modes
4. **Visual Feedback**: Add subtle animation when first transcript appears
5. **Keyboard Shortcuts**: Add hotkey to toggle between tips and transcript view

These are NOT required for the initial implementation but could improve UX further.
