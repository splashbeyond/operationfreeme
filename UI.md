# TapJail UI

## App Store Home Screen

- Added a compact TapJail logo and wordmark header.
- Replaced the setup-heavy home screen with a focused daily budget dashboard.
- Added a primary budget card with the configured allowance, monitoring state, budget-reached state, and progress treatment.
- Combined the budget slider and app selection into a native `Budget & Apps` sheet.
- Added a `Usage` destination for the current verified Screen Time monitoring state and TapJail statistics.
- Added a `Settings` destination for Screen Time authorization and daily reset information.
- Kept developer-only controls for the one-minute test, manual lock, prison routing, and stopping a budget inside Settings.
- Preserved the existing app selection, daily budget, shield, breakout, and authorization behavior.
- Added accessible labels, 44-point-or-larger controls, Dynamic Type-friendly layouts, and native sheet navigation.
- Added a Device Activity Report extension that renders real selected-app usage, remaining budget, and progress in the home card.
- Changed Choose Apps to dismiss the budget editor before presenting Apple's activity picker, avoiding stacked-sheet conflicts.
- Aligned first-day budgets to the moment monitoring starts, so Screen Time used earlier that day does not immediately consume a new user's allowance.
- Limited that grace baseline to the calendar day onboarding is completed; later days count selected-app usage from midnight.
- Replaced report-extension App Group preference reads with an atomic shared configuration file to avoid CFPrefs container warnings.

## Screen Time Reporting Note

iOS keeps Screen Time totals inside a privacy-preserving Device Activity Report extension. TapJail now uses that extension to render the real remaining daily budget directly in the home card.
