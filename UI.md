# TapJail UI

## App Store Home Screen

- Added a compact TapJail logo and wordmark header.
- Replaced the setup-heavy home screen with a focused daily budget dashboard.
- Added a primary limit card with the configured time, monitoring state, limit-reached state, and progress treatment.
- Combined the limit slider and app selection into a native `Limit & Apps` sheet.
- Added a `Usage` destination for the current verified Screen Time monitoring state and TapJail statistics.
- Added a `Settings` destination for Screen Time authorization and daily reset information.
- Kept developer-only controls for the one-minute test, manual lock, prison routing, and stopping a budget inside Settings.
- Preserved the existing app selection, daily budget, shield, breakout, and authorization behavior.
- Added accessible labels, 44-point-or-larger controls, Dynamic Type-friendly layouts, and native sheet navigation.
- Added a Device Activity Report extension that renders real selected-app usage, remaining budget, and progress in the home card.
- Changed Choose Apps to dismiss the budget editor before presenting Apple's activity picker, avoiding stacked-sheet conflicts.
- Aligned first-day limits to the moment monitoring starts, so Screen Time used earlier that day does not immediately consume a new user's limit.
- Limited that grace baseline to the calendar day onboarding is completed; later days count selected-app usage from midnight.
- Replaced report-extension App Group preference reads with an atomic shared configuration file to avoid CFPrefs container warnings.
- Made the onboarding-day budget card intentionally static after Start or Update Budget; enforcement still begins from setup, while report-based usage returns after midnight.
- Kept the current shield active until the next extension monitor is successfully scheduled, preventing an unlocked fallback if iOS rejects a schedule.
- Removed App Group preference reads from the shield UI and action extensions; tap thresholds now use an atomic shared state file to avoid CFPrefs plugin-query warnings.
- Start and Update Budget now register a dedicated activity interval beginning at the button press, verify that iOS retained the threshold, and hand off to the repeating midnight schedule after the first day.
- Expanded daily budget selection to every 15-minute interval from 15 minutes through 8 hours.
- Simplified Today's App Limit into enforcement states instead of Screen Time usage: configured time, zero at lock with required taps, and the granted extension with the next tap requirement.
- Locked active limits and app selections for the day. Setup does not use a change; users get one extra same-day update, then may submit one change per day for the following midnight.

## Screen Time Reporting Note

iOS keeps Screen Time totals inside a privacy-preserving Device Activity Report extension. TapJail now uses that extension to render the real remaining daily budget directly in the home card.
