# TapJail Build And Device Test Notes

## Current Build Status

The project compiles successfully with Xcode 26.5:

- Simulator build: passed.
- Unsigned iPhoneOS build: passed.
- Simulator launch: passed.
- Clean Tap Prison launch-argument render: passed.

The app includes:

- Main TapJail iOS app.
- Shield Configuration extension.
- Shield Action extension.
- Family Controls entitlements.
- App Group entitlements.
- `tapjail://prison` URL scheme.
- Notification tap handling that routes back into Tap Prison.
- In-app `Test Prison Notification` control for checking notification routing.
- Debug launch argument `-tapjail-prison` for opening directly to Tap Prison in simulator/device debug runs.
- Immediate lock/unlock implementation through `ManagedSettingsStore`.
- 100-tap Tap Prison release flow.
- Branded 1024px app icon asset.

## Required Apple Setup Before Real Device Testing

Screen Time shielding only works on a physical iPhone with valid Apple provisioning.

Open Xcode settings and make sure the Apple ID for team `88RCTVT94Q` is signed in. Then let Xcode create profiles for these bundle IDs:

- `com.piperstudio.tapjail`
- `com.piperstudio.tapjail.ShieldConfiguration`
- `com.piperstudio.tapjail.ShieldAction`

Required capabilities for all three targets:

- Family Controls
- App Groups: `group.com.piperstudio.tapjail`

Current signed-device blocker:

```text
No Account for Team "88RCTVT94Q".
No profiles were found for the TapJail app and shield extension bundle IDs.
```

This is an Xcode account/provisioning issue, not a compile issue. The unsigned iPhoneOS target builds successfully.

## Test Flow On iPhone

1. Open `TapJail.xcodeproj`.
2. Select the `TapJail` scheme.
3. Select the connected iPhone.
4. Run the app.
5. Tap `Authorize Screen Time`.
6. Tap `Choose Apps` and select one low-risk app for testing.
7. Tap `Lock Now`.
8. Open the selected app and confirm the TapJail shield appears.
9. Tap `Break Out of TapJail`.
10. Tap the notification to return to TapJail.
11. Complete 100 taps.
12. Confirm the selected app opens again after release.

## Local Debug Checks

Run Tap Prison directly from the command line after a simulator build:

```sh
xcrun simctl launch --terminate-running-process <simulator-udid> com.piperstudio.tapjail -tapjail-prison
```

Use `Test Prison Notification` inside the app to verify that tapping a TapJail notification routes back to Tap Prison.

## Known MVP Limitation

The shield action extension uses a local notification to return the user to TapJail. If Apple does not deliver that notification during device testing, the fallback is still valid for MVP testing: manually open TapJail while the lock is active. The app routes active lock sessions into Tap Prison on launch.
