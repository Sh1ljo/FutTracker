---
name: Pitch Performance System
colors:
  surface: '#f4fbf4'
  surface-dim: '#d4dcd5'
  surface-bright: '#f4fbf4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eef6ee'
  surface-container: '#e8f0e9'
  surface-container-high: '#e3eae3'
  surface-container-highest: '#dde4dd'
  on-surface: '#161d19'
  on-surface-variant: '#3c4a42'
  inverse-surface: '#2b322d'
  inverse-on-surface: '#ebf3eb'
  outline: '#6c7a71'
  outline-variant: '#bbcabf'
  surface-tint: '#006c49'
  primary: '#006c49'
  on-primary: '#ffffff'
  primary-container: '#10b981'
  on-primary-container: '#00422b'
  inverse-primary: '#4edea3'
  secondary: '#1b6b4f'
  on-secondary: '#ffffff'
  secondary-container: '#a6f2cf'
  on-secondary-container: '#247155'
  tertiary: '#006c4b'
  on-tertiary: '#ffffff'
  tertiary-container: '#00b982'
  on-tertiary-container: '#00422c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#6ffbbe'
  primary-fixed-dim: '#4edea3'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005236'
  secondary-fixed: '#a6f2cf'
  secondary-fixed-dim: '#8bd6b4'
  on-secondary-fixed: '#002115'
  on-secondary-fixed-variant: '#00513a'
  tertiary-fixed: '#68fcbf'
  tertiary-fixed-dim: '#45dfa4'
  on-tertiary-fixed: '#002114'
  on-tertiary-fixed-variant: '#005137'
  background: '#f4fbf4'
  on-background: '#161d19'
  surface-variant: '#dde4dd'
typography:
  h1:
    fontFamily: Lexend
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  h2:
    fontFamily: Lexend
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
    letterSpacing: -0.01em
  h3:
    fontFamily: Lexend
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.4'
    letterSpacing: '0'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.5'
    letterSpacing: '0'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
    letterSpacing: '0'
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1.2'
    letterSpacing: '0'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 20px
  gutter: 16px
---

## Brand & Style

The design system is engineered for the modern athlete: focused, high-energy, and professional. It adopts a **Minimalist** design style with a "Sporty-Corporate" twist, prioritizing data legibility and rapid interaction during training sessions. 

The aesthetic is defined by a rigorous adherence to flat design principles, utilizing ample white space to prevent information overload. The emotional response is one of clarity and momentum—eliminating visual friction so the user can focus entirely on their physical performance. The interface feels lightweight and breathable, mirroring the agility required on the pitch.

## Colors

The palette is anchored by **Vibrant Green**, a color that evokes the pitch and symbolizes growth and energy. This is supported by a **Light Green accent** used for subtle highlighting and secondary states.

- **Primary**: Use for main call-to-actions, progress indicators, and active states.
- **Secondary**: Use for soft backgrounds behind primary icons or as a highlight for successful completion states.
- **Background**: The off-white base reduces harshness compared to pure white while maintaining a clean, professional canvas.
- **Typography**: Dark gray is used instead of pure black to maintain a sophisticated, modern feel that reduces eye strain during indoor or outdoor use.

## Typography

This design system uses a dual-font approach. **Lexend** is selected for headings due to its athletic, highly readable, and slightly expanded character, which feels grounded and stable. **Inter** is used for body copy and data entry for its unparalleled clarity and systematic efficiency.

High-level metrics (e.g., "90% Accuracy") should be rendered in Lexend Bold. Supporting labels and instructional text use Inter to provide a functional, unobtrusive hierarchy.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** model with a focus on mobile-first interaction. It utilizes a 4-column system for mobile and a 12-column system for tablet/desktop views.

The "Ample White Space" requirement is met by using a standard 16px (md) or 24px (lg) padding within cards and containers. Internal spacing between related items (like a label and its input) should use the 8px (sm) unit to maintain grouping. Large sections of the dashboard are separated by 32px (xl) to allow the UI to breathe.

## Elevation & Depth

To maintain a clean, flat aesthetic, this design system avoids heavy shadows. Depth is communicated via **Tonal Layers** and **Low-contrast outlines**.

- **Cards**: Use a white background (#FFFFFF) against the off-white app background (#F9FAFB) to create subtle separation.
- **Borders**: A 1px solid border (#E5E7EB) defines card boundaries and input fields.
- **Interactive States**: Instead of lifting an element with a shadow on hover/tap, use a subtle color shift (e.g., Primary Green to a slightly darker shade) or a scale-down effect (98%) to simulate a physical press.

## Shapes

The shape language is consistently rounded to feel approachable yet professional. A base radius of **10px** is applied to all primary containers and cards. 

- **Cards & Sections**: 10px corner radius.
- **Buttons**: 10px corner radius to match the card language.
- **Input Fields**: 10px corner radius for a unified form aesthetic.
- **Status Pills**: Fully rounded (pill-shaped) to distinguish them from interactive buttons.

## Components

### Buttons
- **Primary**: Solid Vibrant Green (#10B981) with white text. No shadow. 10px radius.
- **Secondary**: Light Green accent (#A7F3D0) with Primary Green text. 
- **Ghost**: No fill, 1px border (#E5E7EB), Dark Gray text.

### Cards
Cards are the primary organizational unit. They feature a white fill, 1px light gray border, and 10px corner radius. Content inside should have 16px to 24px of internal padding.

### Input Fields
Inputs use a white background with a 1px border. On focus, the border transitions to Primary Green with a 2px thickness or a soft green outer glow.

### Chips & Badges
Small, pill-shaped markers for drills or skill categories (e.g., "Dribbling", "Stamina"). Use Light Green accent backgrounds with Dark Green text for high legibility.

### Training Progress Trackers
Linear progress bars using the Primary Green for the fill and a very light gray or Light Green accent for the track. No rounded ends on the inner progress bar; keep it flush with the container for a precise, "data-driven" look.

### Activity Lists
Clean, border-bottom separated rows with 16px vertical padding. Icons within lists should be housed in 40x40px rounded squares with the Light Green accent background.