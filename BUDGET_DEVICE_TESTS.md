# Budget Feature Physical Device Tests

These tests validate the first budget milestone: selected activity reaches a daily threshold, TapJail applies its shield, and 100 taps release the apps.

## Before Testing

In Xcode, confirm automatic signing succeeds for all four targets:

- `com.piperstudio.tapjail`
- `com.piperstudio.tapjail.ShieldConfiguration`
- `com.piperstudio.tapjail.ShieldAction`
- `com.piperstudio.tapjail.DeviceActivityMonitor`

The new Device Activity Monitor target must have:

- Family Controls
- App Groups: `group.com.piperstudio.tapjail`

Use a Debug build on a physical iPhone. Device Activity thresholds cannot be fully validated in Simulator.

## Test 1: Authorization And Selection

1. Install and open TapJail.
2. Tap `Authorize Screen Time` and approve access.
3. Tap `Choose Apps`.
4. Select one low-risk app that has had little or no usage today.
5. Close the picker.

Expected:

- TapJail reports authorization as approved.
- The selected-app summary shows one app.
- The budget controls become available.

## Test 2: One-Minute Threshold

1. Tap `Start 1-Minute Device Test`.
2. Leave TapJail.
3. Open the selected app.
4. Keep the selected app in the foreground for at least one full minute.
5. Continue using it briefly while the system processes the threshold.

Expected:

- The selected app becomes shielded near the one-minute threshold.
- The TapJail logo and custom shield copy appear.
- `Stay Focused` is the top button.
- `Break Out of TapJail` is the bottom button.

Note: If the selected app already had at least one minute of usage today, iOS 17.4 and newer may trigger the shield immediately because TapJail includes earlier activity from the current day.

## Test 3: Stay Focused

1. On the shield, tap `Stay Focused`.

Expected:

- The shield closes.
- The selected app does not become usable.
- Opening the selected app again shows the shield.

## Test 4: Breakout Routing

1. On the shield, tap `Break Out of TapJail`.
2. Tap the TapJail notification.

Expected:

- A local TapJail notification appears.
- Tapping it opens TapJail directly to Tap Prison.
- Tap Prison requires 100 taps.

If the notification does not appear:

- Confirm notifications are enabled for TapJail in Settings.
- Manually open TapJail. An active lock should still route to Tap Prison.

## Test 5: Tap Release

1. Complete all 100 taps without leaving TapJail.
2. Open the selected app again.

Expected:

- TapJail clears the shield after tap 100.
- The selected app opens normally.
- A notification says that 1 more minute was granted.
- The notification says the next breakout requires 200 taps.

## Test 6: First Escalation

1. After completing the first 100 taps, use the selected app group for 1 minute.
2. Wait briefly for the Device Activity threshold to process.
3. Open a selected app if it is not already foregrounded.

Expected:

- The selected group becomes shielded again.
- The shield says `Tap 200 times to break out.`
- The threshold notification says 200 taps are required.
- Tap Prison displays a target of 200 taps.

## Test 7: Second Escalation

1. Complete the 200 taps.
2. Confirm the notification grants another 1 minute and says the next breakout requires 400 taps.
3. Use the selected group for another 1 minute.

Expected:

- The selected group becomes shielded again.
- The shield and Tap Prison both require 400 taps.

For the one-minute Debug test, the remaining expected sequence is:

- 400 taps grants 1 minute, then requires 800.
- 800 taps grants 1 minute, then requires 1,000.
- Every later breakout remains at 1,000 taps for another 1 minute.

## Test 8: Ruthless Reset

1. Restart the one-minute test using `Stop Budget Test`, then `Start 1-Minute Device Test`.
2. Reach the shield and enter Tap Prison.
3. Complete part of the 100 taps.
4. Background TapJail.
5. Return to TapJail.

Expected:

- Partial tap progress resets to zero.
- The shield remains active until all 100 taps are completed.

## Test 9: Shared Group Usage

1. Stop the existing test.
2. Select two apps.
3. Start the one-minute test.
4. Use the first app for about 30 seconds.
5. Use the second app for about 30 seconds.

Expected:

- Usage accumulates across the selected group.
- Both selected apps become shielded when their combined activity reaches the threshold.

## Test 10: Normal Slider

1. Tap `Stop Budget Test`.
2. Move the slider to 15 minutes.
3. Tap `Start Daily Budget`.
4. Use the selected app group for 15 minutes.

Expected:

- The selected apps remain available before the budget is consumed.
- The group becomes shielded after the cumulative 15-minute threshold.
- Completing a breakout grants 15 more minutes in normal slider mode.

## Test 11: Budget Duration Matrix

Repeat a clean budget activation with representative slider values:

| Budget | Expected initial lock | Breakout extension |
|---|---:|---:|
| 15 minutes | 15 minutes cumulative usage | 15 minutes |
| 30 minutes | 30 minutes cumulative usage | 15 minutes |
| 60 minutes | 60 minutes cumulative usage | 15 minutes |
| 120 minutes | 120 minutes cumulative usage | 15 minutes |
| 240 minutes | 240 minutes cumulative usage | 15 minutes |
| 360 minutes | 360 minutes cumulative usage | 15 minutes |
| 480 minutes | 480 minutes cumulative usage | 15 minutes |

For each value:

1. Stop the current budget before starting the next test.
2. Select the budget with the slider.
3. Tap `Start Daily Budget`.
4. Confirm the selected apps remain available before the threshold.
5. Confirm the group locks after cumulative usage reaches the threshold.
6. Complete 100 taps.
7. Confirm the notification grants 15 more minutes and names the next tap requirement.

All intermediate slider values from 15 minutes through 8 hours use the same
scheduling path in 15-minute increments.

If the selected budget cannot be fully consumed before midnight, the day resets
before that initial threshold can be reached.

## Test 12: Replacing An Active Budget

1. Start a budget and trigger its first lock.
2. Complete the breakout so an extension is active.
3. Return to TapJail and start a different slider budget.

Expected:

- The old extension monitor is cancelled.
- The shield is cleared.
- Escalation resets to 100 taps.
- Only the newly selected daily budget can trigger the next lock.

## Test 13: Midnight Boundary

1. Complete a breakout with less than 15 minutes remaining before midnight.

Expected:

- TapJail unlocks the selected group until midnight.
- The notification says `Unlocked until midnight`.
- The next day begins with the original daily budget and 100 taps.

## Current Milestone Limits

- The budget-change-once-per-day rule is not enforced yet.
- Usage statistics are not displayed yet.
