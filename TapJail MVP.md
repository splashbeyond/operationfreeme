# TapJail MVP: Lean Working Build Plan

## 1. Product Goal

Build a native iOS accountability app that blocks selected apps using Apple's Screen Time APIs. When a user is blocked, the only in-app release path is to open TapJail and complete 100 physical taps.

The MVP should prove one loop reliably:

1. User grants Screen Time authorization.
2. User selects apps to block.
3. User starts a lock session.
4. Selected apps show TapJail's custom shield.
5. User chooses to break out.
6. User completes 100 taps inside TapJail.
7. TapJail clears the shield.

Everything else is secondary until this loop works on a real device.

## 2. MVP Scope

### Ship In The First Working MVP

- Screen Time authorization request.
- App/category picker using `FamilyActivityPicker`.
- App Group shared state.
- Immediate app shielding through `ManagedSettingsStore`.
- Custom shield copy and buttons.
- Shield action handling.
- Deep link into the Tap Prison screen.
- 100-tap Tap Prison UI.
- Ruthless reset when the user backgrounds or leaves the app.
- Manual "Lock now" and "Unlock" controls for testing.
- Minimal local state persistence.

### Defer Until The Core Loop Works

- Usage budget thresholds.
- Device Activity Monitor extension.
- Usage reporting tab.
- Device Activity Report extension.
- App Store polish screens.
- Onboarding beyond the minimum authorization and picker flow.
- Analytics, remote databases, accounts, subscriptions, cloud sync, social features.

## 3. Required Apple Capabilities

TapJail depends on Apple-controlled Screen Time functionality. Development and device testing require the correct Apple Developer setup.

- Family Controls entitlement on the main app.
- App Group shared across the main app and extensions.
- Associated URL scheme or universal-link-capable deep link for returning to TapJail.
- Local notification permission if notification-based routing is used from the shield action extension.

Recommended App Group name:

```text
group.com.piperstudio.tapjail
```

Recommended URL scheme:

```text
tapjail://prison
```

## 4. Required Targets For The Lean MVP

The first build needs three targets. Do not add Device Activity targets until the instant-lock flow is stable.

### Target A: TapJail Main App

Responsibilities:

- Request `AuthorizationCenter` approval.
- Present `FamilyActivityPicker`.
- Save selected tokens.
- Start and stop lock sessions.
- Apply and clear shields with `ManagedSettingsStore`.
- Display the Tap Prison view.
- Handle `tapjail://prison` deep links.
- Reset tap progress when the app leaves the foreground.

Frameworks:

- `SwiftUI`
- `FamilyControls`
- `ManagedSettings`

### Target B: ShieldConfiguration Extension

Responsibilities:

- Replace Apple's default shield copy with TapJail's shield configuration.
- Provide title, subtitle, primary button, and secondary button labels.

Frameworks:

- `ManagedSettings`
- `ManagedSettingsUI`

### Target C: ShieldAction Extension

Responsibilities:

- Handle primary and secondary shield button actions.
- Keep blocked apps blocked while the user is deciding.
- Route the user back to TapJail when they press "Break Out of TapJail".

Frameworks:

- `ManagedSettings`
- `UserNotifications` if using notification routing.

## 5. Shared State

Use `UserDefaults(suiteName:)` with the App Group. Keep the schema tiny.

Required keys:

| Key | Type | Owner | Purpose |
|---|---|---|---|
| `selectedActivitySelection` | `Data` | Main app | Encoded `FamilyActivitySelection` |
| `isLockActive` | `Bool` | Main app/extensions | Whether TapJail considers the lock active |
| `tapTarget` | `Int` | Main app | Default `100` |
| `sessionStartedAt` | `Date` | Main app | Debugging and future timer support |

Encoding rule:

- Store the whole `FamilyActivitySelection` as encoded `Data`.
- Decode it in the main app before applying shields.
- Do not manually serialize individual opaque tokens.

## 6. Main App Screens

### Lock Screen

Minimum controls:

- Authorization status.
- "Authorize Screen Time" button when needed.
- "Choose Apps" button.
- Selected app/category summary.
- "Lock Now" button.
- "Unlock" debug button.

Behavior:

- Disable "Lock Now" until authorization succeeds and at least one app/category is selected.
- On lock, save state and apply shields immediately.
- On unlock, clear shields and mark `isLockActive = false`.

### Tap Prison Screen

Minimum UI:

- Current tap count.
- Text: `/ 100 taps to break out`
- Large red tap circle.
- 100-dot progress grid.

Behavior:

- Start at `0`.
- Increment by one per valid tap.
- At `100`, clear shields, mark lock inactive, reset count, and show a minimal release state.
- If `scenePhase` becomes `.inactive` or `.background` before completion, reset count to `0`.

Use brand rules from `TapJail Brand Design.md`:

- Black background.
- White text.
- Red only for the tap circle, primary actions, and filled progress dots.
- Young Serif for visible text once the font asset is added.

## 7. Shield Configuration

The shield must be blunt and minimal.

Title:

```text
You are in TapJail.
```

Subtitle:

```text
You used your time. Pay the toll to break out.
```

Primary button:

```text
Break Out of TapJail
```

Secondary button:

```text
I'm done.
```

Expected behavior:

- Primary button routes the user toward Tap Prison.
- Secondary button leaves the shield active and dismisses the action.

## 8. Shield Action Routing

Preferred MVP routing:

1. User taps "Break Out of TapJail" on the shield.
2. Shield action extension schedules a local notification with a `tapjail://prison` deep link.
3. Extension returns `.defer`.
4. User taps notification.
5. Main app opens directly to Tap Prison.

Fallback routing:

- If extension URL routing works reliably with `NSExtensionContext`, use it.
- If not, keep the local notification path. Reliability matters more than elegance.

The shield action extension must not clear shields. Only the main app clears shields after the tap target is completed or through the explicit debug unlock control.

## 9. Locking Implementation

Use one shared helper in the main app for shield application.

Required operations:

- `applyShield(selection:)`
- `clearShield()`
- `saveSelection(_:)`
- `loadSelection()`

Shielding rule:

- Apply selected application tokens to `store.shield.applications`.
- Apply selected category tokens to `store.shield.applicationCategories` when categories are selected.
- Clear both properties on release.

Keep the store simple:

```swift
let store = ManagedSettingsStore()
```

Do not introduce multiple named stores until there is a real need.

## 10. Testing Checklist

Test on a physical iPhone. Screen Time APIs and shields cannot be fully validated in Simulator.

Manual MVP acceptance criteria:

- Authorization request appears and succeeds.
- App picker opens.
- Selected apps persist after relaunch.
- "Lock Now" shields selected apps.
- Shield copy matches TapJail.
- Secondary shield action keeps the app blocked.
- Primary shield action gets the user back to TapJail.
- Tap Prison opens from the deep link.
- Tap count reaches 100 and then clears the shield.
- Backgrounding TapJail before 100 resets the tap count.
- Explicit debug unlock clears the shield.
- Relaunching the app does not leave UI state confused.

## 11. Non-Goals For MVP

Do not build these in the first pass:

- Usage limits based on minutes spent.
- Device Activity schedules.
- Usage charts or reports.
- Account creation.
- Cloud sync.
- Subscription/paywall.
- Remote config.
- Heavy animations.
- Third-party UI frameworks.
- Any database beyond App Group `UserDefaults`.

## 12. Phase 2 Targets

After the MVP loop is proven, add the remaining Screen Time capabilities.

### Device Activity Monitor Extension

Purpose:

- Lock apps after a usage threshold is reached.

Needed for:

- "You get 30 minutes, then TapJail locks you out."

### Device Activity Report Extension

Purpose:

- Display Apple's sandboxed usage report UI inside TapJail.

Needed for:

- Usage tab.
- Accurate screen-time reporting.

Important constraint:

- The main app cannot read raw Screen Time usage data. The report extension can render a UI, but it cannot hand raw usage data back to the main app.

## 13. Build Order

1. Create the Xcode project and three MVP targets.
2. Configure bundle identifiers, App Group, and Family Controls entitlement.
3. Build shared constants for App Group ID, URL scheme, colors, and storage keys.
4. Build authorization and app selection.
5. Persist and reload `FamilyActivitySelection`.
6. Implement `applyShield` and `clearShield`.
7. Build the lock screen.
8. Build the Tap Prison screen and reset behavior.
9. Add URL scheme handling for `tapjail://prison`.
10. Build shield configuration extension.
11. Build shield action extension.
12. Wire primary shield action to notification/deep link routing.
13. Test on device and fix entitlement or routing issues.

## 14. Design Contract

Follow `TapJail Brand Design.md` for visual decisions.

Hard rules:

- Always dark.
- No gradients.
- No shadows.
- No decorative animation.
- Red is only for required action and progress.
- Text is short, direct, and unsentimental.
- The first build should feel severe but usable.

## 15. Definition Of Done

The MVP is done when a real iPhone can complete the full lock and release loop without developer intervention:

1. Select apps.
2. Lock them.
3. See the TapJail shield.
4. Choose break out.
5. Complete 100 taps.
6. Regain access.

If that loop works, TapJail has a real MVP. Everything else is iteration.
