now # TapJail — Brand Design System

**Platform:** iOS (Swift / SwiftUI)
**Category:** Digital Accountability
**Design Language:** Brutalist Minimalism

---

## 1. Brand Identity

### Concept
TapJail is a prison. Not a wellness app. Not a gentle nudge. The user made a deal with themselves and broke it — now they pay. The brand communicates one thing: **you are locked in, and earning your way out requires effort.** Every design decision reinforces that reality.

The visual language is stark, oppressive, and honest. No gradients trying to make you feel good about screen time. No friendly illustrations. Black walls, white light through bars, and a single red signal that means: this is the price.

### Brand Personality
- Punishing, not cruel
- Disciplined, not preachy
- Minimal, not lazy
- Intense, not aggressive
- Earned, not motivated

### Tagline Options
- "Pay the toll."
- "Earn your freedom."
- "You did this. Now undo it."

---

## 2. Color System

### 60 — 30 — 10 Rule

| Role | Name | Hex | Usage |
|---|---|---|---|
| 60% | Void Black | `#000000` | All backgrounds, screens, shields |
| 30% | Cell White | `#FFFFFF` | All body text, labels, headings, icons |
| 10% | Brick Ember | `#D10000` | Tap circles, primary CTA, active states, progress |

### Color Usage Rules
- **Black is the default.** Every screen opens to black. Never use off-black or dark gray as a background substitute.
- **White is for information only.** Not decoration. Text, numerical displays, line separators.
- **Red is earned.** Only use `#D10000` for interactive elements the user must engage with: tap circles, the primary "Break Out" button, progress fill. Never use red as a background or decorative element.
- No shadows. No gradients. No opacity tricks. Flat, absolute color only.

### Accessibility
- Black/White contrast ratio: **21:1** (exceeds WCAG AAA)
- Red/Black contrast ratio: **5.08:1** (meets WCAG AA for large text and UI components)
- Red is never the sole carrier of meaning — always paired with shape (circle) or label

---

## 3. Typography

### Primary Typeface: Young Serif

Young Serif is the only typeface in TapJail. It is a modern serif with classical proportions — it carries weight, authority, and permanence. It does not feel digital. That contrast against an iOS screen is intentional.

**Source:** Google Fonts — `Young Serif` (Regular 400 only — the font has one weight, which is correct for this brand)

### Type Scale (iOS / SwiftUI Points)

| Role | Size | Weight | Color | Usage |
|---|---|---|---|---|
| App Name / Display | 48pt | Regular | White | Splash, onboarding header |
| Shield Title | 28pt | Regular | White | "You are in TapJail." |
| Shield Subtitle | 17pt | Regular | White | Descriptor line on shield |
| Tap Counter | 80pt | Regular | White | Live tap count in Tap Prison |
| Section Header | 22pt | Regular | White | Tab headers, section labels |
| Body / Label | 15pt | Regular | White | All descriptive text |
| Caption | 12pt | Regular | `#FFFFFF` @ 60% opacity | Sub-labels, timers, secondary info |

**Rule:** Young Serif for all visible text. No mixing. For system-required elements Apple controls (alerts, native pickers), SF Pro inherits — this is acceptable and unavoidable.

### Type Behavior
- **Alignment:** Left-aligned for body. Center-aligned only for the Tap Prison counter and the shield screen.
- **Letter spacing:** Default (no tracking adjustments — Young Serif is balanced as-is)
- **Line height:** 1.4x for body text, 1.1x for display/counter sizes
- **No bold, no italic.** Young Serif has one weight. Use size and spacing to create hierarchy.

---

## 4. The Tap Circle

The tap circle is the central UI element of TapJail. It is the mechanism of release. Its design must be treated with the same weight as a logo.

### Specifications
- **Shape:** Perfect circle
- **Color:** `#D10000` Brick Ember — flat fill, no shadow, no border
- **Size (Tap Prison):** 240pt diameter — large enough to demand full attention, impossible to accidentally miss
- **Size (Progress indicators):** 12pt diameter dots
- **Touch feedback:** Scale down to 0.92 on press (`.easeInOut`, 0.08s), scale back to 1.0 on release (0.12s) — fast and firm, not bouncy
- **No glow. No pulse. No idle animation.** The circle is inert until touched. It does not beg.

### Tap Prison Counter Display
```
[TAP COUNT — 80pt Young Serif, White, centered]
[subtitle: "/ 100 taps to break out" — 15pt, White 60% opacity]
[Red tap circle — 240pt, centered below counter]
```

### Progress Display
- 100 small red dots (12pt) arranged in a grid or row below the circle
- Dots fill from `#D10000` (active) starting empty (`#FFFFFF` @ 20% opacity)
- No numerical progress bar — the dots are the progress

---

## 5. App Icon

### Concept: The Branded Cell
Black square (rounded iOS corners), single `#D10000` circle centered, white prison bar lines overlaid horizontally across the circle — 3 bars, equal spacing, 3pt stroke weight.

### Specification
```
Background:   #000000
Circle:       #D10000, 72% of icon width, centered
Bars:         #FFFFFF, 3 horizontal lines, 3pt stroke, 30% circle height spacing
              cropped to circle bounds (clip mask)
```

### Alternate Concept: The Tap Mark
Black background, a single white fingerprint-style arc at center-top, `#D10000` circle below it — reads as "a finger locked in a cell."

**Recommended:** Concept 1 (The Branded Cell) — directly communicates jail + tap circle in one mark.

---

## 6. Shield Screen Brand Application

The shield replaces the app's icon when it is locked. This is the highest-stakes brand touchpoint — the user is frustrated, and TapJail's voice must be unflinching.

### Shield Layout
```
Background:   #000000

[App Icon — 60pt, top third]

Title (28pt Young Serif, White, centered):
"You are in TapJail."

Subtitle (17pt Young Serif, White 70% opacity, centered):
"You used your time. Pay the toll to break out."

─────────────────────────────────

Primary Button (full-width, #D10000 fill, White label):
"Break Out of TapJail"

Secondary Button (no fill, White label, White border 1pt):
"I'm done."
```

### Button Specs
- **Primary (Break Out):** `#D10000` background, `#FFFFFF` label in 17pt Young Serif, 14pt corner radius, 56pt height, full inset width
- **Secondary (I'm done):** `#000000` background, `#FFFFFF` label, 1pt `#FFFFFF` border, same dimensions
- No drop shadows on either button

---

## 7. Corner Radius System

Brutalist in concept, refined in execution. Hard edges communicate harshness; rounded edges make the app liveable. The system uses corners deliberately — not to soften the brand, but to give it polish.

| Element | Corner Radius |
|---|---|
| Tap circle | N/A (circle) |
| Primary button | 14pt |
| Secondary button | 14pt |
| App list rows / containers | 12pt |
| Progress dot indicators | N/A (circle) |
| App Icon | iOS system (continuous curve) |
| Input fields | 10pt |
| Modal / bottom sheet | 20pt top corners only |
| Shield buttons (system-constrained) | System default |

**Rule:** Round where the user touches or rests their eye. Keep edges sharp where they frame empty black space. Never use radius to make something feel friendly — use it to make it feel intentional.

---

## 8. Screen Backgrounds & Layout

### General Rules
- All screens: `#000000` background, full bleed
- Top-level navigation: no visible tab bar background — tabs float on black
- Containers and list rows: `#FFFFFF` @ 6% opacity fill, 12pt corner radius — surfaces emerge from black, not above it
- Dividers: 1pt `#FFFFFF` @ 15% opacity — just enough to separate, not decorate
- Safe area insets respected; no content behind home indicator

### Usage Tab (DeviceActivityReport Extension)

The usage report must match the core brand:
- Background: `#000000`
- App name labels: 15pt Young Serif, White
- Time values: 22pt Young Serif, White
- `#D10000` used only for the current day's most-used app highlight (single accent, disciplined)
- Simple `HStack` rows — no charts, no rings, no gradients

---

## 9. Motion & Animation

TapJail moves with discipline. No decorative animation.

| Interaction | Animation | Duration | Curve |
|---|---|---|---|
| Tap circle press | Scale 1.0 → 0.92 | 80ms | easeInOut |
| Tap circle release | Scale 0.92 → 1.0 | 120ms | easeOut |
| Screen transitions | Push/slide (iOS default) | Default | Default |
| Tap count increment | None — instant number update | — | — |
| Ruthless reset | Counter slams to 0 — no animation | Instant | — |
| Shield dismissal | System-controlled | — | — |
| Progress dot fill | Instant on tap | — | — |

**Rule:** If the animation serves the user's understanding, keep it. If it makes the app feel fun or playful, remove it. TapJail is not fun. Breaking out of jail is work.

---

## 10. Brand Voice

| Context | Voice |
|---|---|
| Shield title | Declarative. "You are in TapJail." No softening. |
| Shield subtitle | Transactional. "Pay the toll to break out." |
| Tap Prison | Silent. The counter speaks. |
| Ruthless reset | No message. The number goes to zero. That's enough. |
| Onboarding | Direct. "Select the apps you want to block. Set your limit. Lock in." |
| Empty states | Honest. "No apps locked. Lock something." |
| Success / Release | Minimal. "You're out. Don't waste it." |

### Voice Rules
- No exclamation marks
- No emoji in-app
- No "Great job!" or positive reinforcement for completing taps — that's not the point
- Short sentences. Period endings. No ellipses.

---

## 11. Brand Don'ts

- No gradients, anywhere
- No shadows or elevation on UI elements
- No color outside the three-color system
- No arbitrary corner radii — follow the Corner Radius System in Section 7 exactly
- No illustration or iconography beyond the app icon bars motif
- No animations that make the experience feel rewarding mid-session
- No light mode — TapJail is always dark

---

## 12. File Reference

| Asset | Status |
|---|---|
| App Icon — Concept 1 | To design |
| App Icon — Concept 2 | To design |
| Color tokens (Swift) | To build |
| Young Serif font file | Via Google Fonts |
| Shield UI (SwiftUI) | Per MVP Target B |
| Tap Prison UI (SwiftUI) | Per MVP Section 7 |
