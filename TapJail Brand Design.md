# TapJail Brand Design System

## Brand Assets

### TapJail Logo

![[ChatGPT Image Jun 1, 2026, 07_52_01 PM.png]]

### App Icon

![[tapjail ios icon 1.png]]

**Platform:** iOS 17+ using SwiftUI

**Category:** Digital accountability and screen-time control

**Design language:** Dark utility, disciplined friction, direct accountability

## 1. Brand Identity

TapJail helps people interrupt compulsive app use by turning extra screen time into a deliberate decision. Users choose which apps to limit, set a daily shared budget, and complete an escalating tap requirement when they decide to continue.

The current product is not styled as a literal prison simulation. It uses a polished dark interface with restrained color, practical hierarchy, and one expressive handwritten voice inside Tap Prison.

### Brand Personality

- Direct, not vague
- Strict, not hostile
- Accountable, not motivational
- Modern, not decorative
- Minimal, not empty
- Playfully confrontational inside Tap Prison

### Core Product Language

- "Choose the apps. Start the lock."
- "You are in TapJail."
- "Stay Focused"
- "Break Out of TapJail"
- "Tap X times to break out."
- "You have 15 more minutes."

## 2. Color System

The app uses layered off-black surfaces rather than pure black. Warm white keeps the interface from feeling clinical. Green represents setup, permission, and intentional continuation. Red is reserved for Tap Prison, active punishment, errors, and destructive actions.

| Token | Hex | Current usage |
|---|---|---|
| Background | `#08090A` | Full-screen app and shield background |
| Surface | `#161718` | Panels and destructive-button backgrounds |
| Row | `#202020` | Secondary buttons |
| Raised | `#303030` | Empty Tap Prison progress dots |
| Divider | `#404040` | Panel and button outlines |
| Primary text | `#F0F0EA` | Headings, labels, icons, tap counter |
| Muted text | `#B8B8B2` | Supporting copy and status text |
| Action green | `#10A37F` | Primary buttons, slider, budget value, shield action |
| System blue | `#2563EB` | Reserved token; not prominent in current screens |
| Prison red | `#E5484D` | Tap circle, filled dots, errors, destructive outlines |

### Color Rules

- Use `#08090A` as the full-screen base.
- Use surface layers to group setup information without adding shadows.
- Use green for constructive actions such as authorization, starting a budget, and staying focused.
- Use red for Tap Prison interaction, error messaging, and destructive controls.
- Do not use gradients.
- Do not use decorative color.
- Do not rely on color alone to communicate state.
- Maintain dark mode only.

## 3. Typography

### Primary Typeface: Schibsted Grotesk

Schibsted Grotesk is used throughout the app for titles, panels, controls, counters, and supporting text. It creates a modern utility-first interface with enough personality to avoid looking generic.

Current font mapping:

| App weight | Font |
|---|---|
| Light | Schibsted Grotesk Regular |
| Regular | Schibsted Grotesk Regular |
| Bold | Schibsted Grotesk Bold |

The app falls back to the system font if a bundled font cannot load.

### Accent Typeface: Patrick Hand

Patrick Hand is used only for the accountability message at the top of Tap Prison. It creates contrast between the structured product UI and the personal, slightly mocking interruption message.

### Current Type Scale

| Role | Size | Style |
|---|---:|---|
| Home app title | 52pt | Schibsted Grotesk Bold |
| Tap Prison counter | 88pt | Schibsted Grotesk Bold |
| Accountability message | 30pt | Patrick Hand Regular |
| Section heading | 22pt | Schibsted Grotesk Bold |
| Primary button | 17pt | Schibsted Grotesk Bold |
| Home subtitle | 17pt | Schibsted Grotesk Regular |
| Budget value | 17pt | Schibsted Grotesk Bold, green |
| Body and status | 15pt | Schibsted Grotesk Regular |
| Error message | 15pt | Schibsted Grotesk Bold, red |

### Type Rules

- Left-align setup and configuration content.
- Center Tap Prison messaging, counter, tap circle, and progress.
- Use size and weight to create hierarchy.
- Keep supporting copy muted rather than shrinking it excessively.
- Allow system typography inside Apple-controlled Screen Time pickers and shields.

## 4. Home Screen

The home screen is a vertically scrolling setup surface with 24pt outer padding and 22pt spacing between major sections.

### Header

- App name: `TapJail`, 52pt bold.
- Supporting state:
  - Unlocked: "Choose the apps. Start the lock."
  - Locked: "You are locked in."
- No status badge or "Ready" card.

### Panels

The home screen currently contains:

1. Screen Time authorization
2. Locked app selection
3. Daily budget
4. Lock and internal testing controls

Panel specification:

- Fill: `#161718`
- Border: 1pt `#404040`
- Corner radius: 16pt continuous
- Internal padding: 20pt
- Left-aligned content

### Daily Budget

- Shared across every selected app, category, and web domain.
- Slider range: 15 minutes to 8 hours.
- Increment: 15 minutes.
- Slider and selected value use action green.
- Budget resets at local midnight.
- Normal breakouts grant 15 more minutes.

### Debug Controls

The current Debug build contains:

- `Lock Now`
- `Enter Tap Prison`
- `Unlock`
- `Test Prison Notification`
- `Start 1-Minute Device Test`
- `Stop Budget Test`

These are development tools and should be removed, hidden, or replaced before App Store submission unless they are intentionally retained as product features.

## 5. Button System

### Primary Button

- Green fill: `#10A37F`
- Dark text: `#08090A`
- 17pt bold label
- 16pt vertical padding
- 14pt continuous corner radius
- Pressed opacity: 78%
- Pressed scale: 0.98
- Animation: 80ms ease-in-out

Used for:

- Authorize Screen Time
- Start or update daily budget
- Lock Now
- Stay Focused on the shield

### Secondary Button

- Row fill: `#202020`
- Warm-white label
- 1pt divider outline
- Same typography, padding, and radius as the primary button
- Pressed opacity: 72%
- Pressed scale: 0.98

Used for:

- Choose Apps
- Enter Tap Prison
- Notification and one-minute tests

### Destructive Button

- Surface fill
- Red label and red outline
- Same dimensions as other buttons

Used for:

- Unlock
- Stop Budget Test

## 6. Tap Prison

Tap Prison is the product's strongest visual state. It removes panels and setup controls, returning to a nearly empty black screen centered around the required physical action.

### Layout

From top to bottom:

1. Standard iOS-style back chevron
2. Accountability message
3. Current tap count
4. `/ X taps to break out`
5. Large red tap circle
6. Adaptive progress-dot grid

### Back Navigation

- Native chevron-left symbol
- 20pt semibold
- 44 × 44pt touch target
- 8pt leading inset
- Safe-area aware
- No circular background

### Accountability Messages

- Patrick Hand, 30pt
- Warm white
- Centered
- Maximum two lines
- Changes every 10 taps
- Tone is confrontational and intentionally uncomfortable

Examples currently used:

- "Still doomscrolling? Wow..."
- "Did you give up on your dreams?"
- "Your future self is watching this."
- "Discipline would have been faster."
- "Earn your way out."

### Tap Counter

- Current count: 88pt Schibsted Grotesk Bold
- Target label: 15pt muted Schibsted Grotesk
- Numeric transition is used when the count changes
- Target escalates through 100, 200, 400, 800, and 1,000 taps

### Tap Circle

- Perfect circle
- 240pt diameter
- Fill: `#E5484D`
- Subtle 2pt warm-white outline at 14% opacity
- Pressed scale: 0.92
- Press animation: 80ms
- Release animation: 120ms
- No pulse, glow, or idle motion

### Progress Grid

- Fixed 174 × 174pt footprint at every threshold
- Empty dots use raised gray
- Completed dots use prison red
- Dot size and spacing adapt to the target
- Grids use complete factor-pair rows so no threshold has an uneven partial row

Current layouts:

| Target | Grid |
|---:|---:|
| 100 | 10 × 10 |
| 200 | 20 × 10 |
| 400 | 20 × 20 |
| 800 | 32 × 25 |
| 1,000 | 40 × 25 |

### Ruthless Reset

If TapJail becomes inactive or enters the background before completion, partial tap progress resets to zero without a message or animation.

## 7. Shield Screen

The Screen Time shield uses TapJail's supplied logo rather than the default blocked-app icon.

### Current Shield

- Background: `#08090A`
- Logo: `ShieldConfiguration/TapJailShieldLogo.png`
- Title: "You are in TapJail."
- Dynamic subtitle: "Tap X times to break out."
- Primary top button: "Stay Focused"
- Secondary bottom button: "Break Out of TapJail"

### Shield Behavior

- `Stay Focused` closes the shield while leaving the selected app blocked.
- `Break Out of TapJail` sends a local notification that routes the user to Tap Prison.
- The shield reads the current tap target from the shared App Group.
- Shield layout and button geometry are controlled by iOS.

## 8. Budget And Breakout Experience

The daily budget and escalating breakout mechanic are part of the product's visual language because all copy must accurately reflect current state.

### Standard Flow

| Stage | Required taps | Access granted |
|---:|---:|---:|
| Initial budget reached | 100 | 15 minutes |
| First extension consumed | 200 | 15 minutes |
| Second extension consumed | 400 | 15 minutes |
| Third extension consumed | 800 | 15 minutes |
| Later extensions | 1,000 | 15 minutes |

The requirement remains at 1,000 taps for every later breakout until midnight.

### Notifications

Threshold notification:

- Title: "Your apps are locked"
- Body: "Tap X times to break out of TapJail."

Breakout completion:

- Title: "You have 15 more minutes"
- Body: "Next time, tap X times to break out of TapJail."

Near midnight:

- Title: "Unlocked until midnight"
- Body: "Your daily budget and tap count reset at midnight."

The Debug one-minute test uses one-minute thresholds and notifications. Normal budgets always use 15-minute extensions.

## 9. Motion

Motion is short, functional, and tied directly to touch.

| Interaction | Current behavior |
|---|---|
| Standard button press | Scale to 0.98 over 80ms |
| Back icon press | Scale to 0.94 over 80ms |
| Tap circle press | Scale to 0.92 over 80ms |
| Tap circle release | Return over 120ms |
| Tap count change | Numeric content transition |
| Progress dot completion | Immediate color change |
| Background reset | Immediate reset to zero |
| Screen routing | Direct SwiftUI route change |

Avoid decorative animation, bounce, glow, confetti, or celebratory effects.

## 10. Corner Radius And Borders

| Element | Radius |
|---|---:|
| Setup panels | 16pt |
| Primary, secondary, and destructive buttons | 14pt |
| Tap circle and progress dots | Circle |
| Shield controls | iOS system controlled |
| App icon | iOS system mask |

Borders use the divider token and remain 1pt except for the Tap Prison circle's subtle 2pt outline.

## 11. Brand Voice

TapJail uses two related voices.

### Product Voice

Direct, useful, and calm:

- "Choose what TapJail blocks."
- "These selections stay on this device."
- "Usage is shared across everything selected above and resets at midnight."
- "Authorization approved."

### Tap Prison Voice

Sharper, personal, and confrontational:

- "Still doomscrolling? Wow..."
- "Another tap for another broken promise."
- "You came here because the phone won."

### Voice Rules

- Keep instructions short and concrete.
- State exact tap and time requirements.
- Use "taps," not "toll."
- Do not use generic praise such as "Great job."
- Do not use emoji.
- Avoid false urgency or unclear punishment language.
- Accountability messages may use ellipses as part of the current handwritten voice.

## 12. Accessibility And Platform Behavior

- All custom controls maintain at least a 44pt touch target.
- Important icon-only controls have accessibility labels.
- The tap circle includes an accessibility label and hint.
- Progress exposes completed and target tap counts.
- Color is paired with labels, shapes, or position.
- The app is portrait-only and dark-only.
- Apple-controlled Family Activity Picker and shield components retain native system behavior.
- The current custom point sizes should be audited further for Dynamic Type before submission.

## 13. Brand Don'ts

- Do not reintroduce Young Serif; it is not part of the current app.
- Do not describe the interface as pure black, white, and red.
- Do not use green inside Tap Prison.
- Do not use red as the normal primary setup action.
- Do not add gradients, shadows, glow, or decorative texture.
- Do not add playful reward animation after a breakout.
- Do not change the shield button order without updating its action behavior.
- Do not allow progress grids to resize the Tap Prison layout.
- Do not use "pay the toll" language.

## 14. Current Assets And Source

| Asset or system | Current status |
|---|---|
| Main app icon | `TapJail/Resources/Assets.xcassets/AppIcon.appiconset/TapJailIcon.png` |
| Shield logo | `ShieldConfiguration/TapJailShieldLogo.png` |
| Primary font | Schibsted Grotesk, bundled |
| Accent font | Patrick Hand, bundled |
| Color tokens | `TapJail/App/RootView.swift` |
| Button styles | `TapJail/App/LockView.swift` |
| Tap Prison | `TapJail/App/TapPrisonView.swift` |
| Shield design | `ShieldConfiguration/ShieldConfigurationExtension.swift` |
| Shield actions | `ShieldAction/ShieldActionExtension.swift` |
