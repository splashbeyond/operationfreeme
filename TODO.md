# TapJail TODO

## MVP Validation

- [ ] Configure valid Apple signing and provisioning for all three targets.
- [ ] Test Screen Time authorization on a physical iPhone.
- [ ] Verify selected apps, categories, and web domains remain selected after relaunch.
- [ ] Verify `Lock Now` shields every selected target.
- [ ] Verify the custom shield configuration appears correctly.
- [ ] Verify `Break Out of TapJail` delivers its local notification.
- [ ] Verify tapping the notification opens Tap Prison.
- [ ] Verify completing 100 taps clears every active shield.
- [ ] Verify leaving Tap Prison before completion resets progress to zero.
- [ ] Test behavior when notification permission is denied.

## Product

- [ ] Decide whether the debug `Unlock` control should be removed from release builds.
- [ ] Decide whether `Enter Tap Prison` and `Test Prison Notification` should be debug-only.
- [ ] Add a clear release state after the user completes the tap target.
- [ ] Decide whether users can configure the tap target.
- [ ] Define the next lock model: manual sessions, schedules, or usage limits.

## Onboarding

- [ ] Design the first-launch onboarding flow.
- [ ] Explain TapJail's accountability loop and the 100-tap release mechanic.
- [ ] Guide users through Screen Time authorization.
- [ ] Guide users through selecting apps and categories.
- [ ] Explain why notification permission is needed before requesting it.
- [ ] Add onboarding completion state and persistence.
- [ ] Add a way to revisit onboarding or setup instructions.
- [ ] Handle denied permissions with clear recovery instructions.

## App Budgets

- [ ] Let users assign daily usage budgets to selected apps and categories.
- [ ] Add budget presets and a custom duration picker.
- [ ] Persist budgets by app or category token.
- [ ] Add a Device Activity Monitor extension.
- [ ] Schedule monitoring for configured budgets.
- [ ] Apply shields when an app reaches its daily budget.
- [ ] Reset budgets at the correct local-day boundary.
- [ ] Handle budget edits while monitoring is active.
- [ ] Show remaining time and exhausted-budget states.
- [ ] Define behavior across time-zone and daylight-saving changes.

## Usage Stats

- [ ] Add a usage statistics section to the main app.
- [ ] Add a Device Activity Report extension.
- [ ] Show daily and weekly screen-time totals.
- [ ] Show usage by selected app and category.
- [ ] Compare actual usage against configured budgets.
- [ ] Show remaining budget and over-budget time.
- [ ] Add empty, loading, permission-denied, and unavailable states.
- [ ] Keep charts and summaries consistent with the TapJail visual system.
- [ ] Verify report data and refresh behavior on a physical device.

## Design

- [ ] Reconcile the implementation with `TapJail Brand Design.md`.
- [ ] Finalize the color system: current off-black/green UI or black/white/red brand system.
- [ ] Finalize typography: current Schibsted Grotesk/Patrick Hand or Young Serif.
- [ ] Review accountability messages for tone and consistency.
- [ ] Add the missing `AccentColor` asset or remove its build setting.
- [ ] Verify layouts on supported iPhone screen sizes and Dynamic Type settings.

## UI Polish

- [ ] Establish consistent spacing, corner radius, typography, and button styles.
- [ ] Polish the lock setup screen hierarchy and active-lock state.
- [ ] Polish the Tap Prison layout across small and large iPhones.
- [ ] Add clear pressed, disabled, loading, success, and error states.
- [ ] Improve transitions between setup, locked, prison, and released states.
- [ ] Add subtle haptic feedback to important actions and prison taps.
- [ ] Audit VoiceOver labels, contrast, touch targets, and Dynamic Type.
- [ ] Replace temporary testing copy and controls with production UI.
- [ ] Review all screens for truncation, keyboard behavior, and safe-area issues.

## Engineering

- [ ] Add unit tests for selection persistence and lock-state transitions.
- [ ] Add UI tests for routing and the Tap Prison flow.
- [ ] Surface notification scheduling errors instead of silently ignoring them.
- [ ] Handle failed App Group `UserDefaults` initialization explicitly.
- [ ] Reapply persisted shields on launch when a lock is marked active.
- [ ] Define recovery behavior when saved lock state and active shields disagree.
- [ ] Confirm extension and app notification behavior across supported iOS versions.
- [ ] Update `BUILD_AND_TEST.md` with the current Apple development team ID.

## Release

- [ ] Complete physical-device acceptance testing.
- [ ] Request or confirm production Family Controls entitlement approval.
- [ ] Add privacy policy and App Store support URLs.
- [ ] Prepare App Store screenshots, description, keywords, and age rating.
- [ ] Review the app against App Store guidelines for Screen Time and notification usage.
- [ ] Remove or gate all internal testing controls before submission.
