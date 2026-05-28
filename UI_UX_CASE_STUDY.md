# WellQueue UI/UX Case Study

## Overview

WellQueue includes two applications:

- Main app for patients to discover clinics, compare wait times, and join queues.
- Admin app for clinics to monitor and operate real-time queue flow.

This case study documents the visual and experience improvements applied to make the product portfolio-ready and production-oriented.

## Problems Observed

- Visual hierarchy was flat and screen sections looked similar.
- Key information (wait time, actionability, status) did not stand out quickly.
- Empty and loading states were generic and low guidance.
- Admin operations required extra clicks for frequent actions.
- Design language was not centralized, causing style drift.

## Design Goals

- Improve scan speed for critical actions and statuses.
- Build a reusable design system to keep both apps consistent.
- Increase perceived quality with purposeful layout, color, and motion.
- Preserve existing backend logic while upgrading UI architecture.

## What Changed

### 1) Design System Foundations

- Added tokenized spacing and radius scales in both app themes.
- Expanded semantic color usage (success, warning, danger, muted text, soft surfaces).
- Strengthened typography scale for headlines, titles, body, and labels.
- Updated component themes for chips, cards, inputs, buttons, and snackbars.

### 2) Main App Experience Improvements

- Home now includes a hero snapshot card for at-a-glance queue context.
- Search bar was redesigned with stronger affordance and clearer icon hierarchy.
- Filter chips were aligned to shared token styling.
- Nearby clinic cards were redesigned with:
  - semantic wait-time chips,
  - stronger metadata grouping,
  - cleaner services display,
  - direct CTA: "View details and join queue".
- Nearby list now uses animated transitions and staggered reveals.
- Empty state was rewritten to give useful next-step guidance.

### 3) Admin App Dashboard Improvements

- AppBar displays resolved clinic name for context confidence.
- Added operations snapshot hero card.
- KPI section improved with clearer hierarchy and side-by-side metrics.
- Queue cards show resolved user names and wait duration in minutes.
- Replaced hidden menu actions with explicit quick controls:
  - Call,
  - Complete,
  - No-show.

## UX Impact (Expected)

- Faster decision-making for patients choosing clinics.
- Reduced front-desk interaction cost for frequent queue actions.
- Better trust and context through visible status and clinic identity.
- More cohesive product feel across patient and admin experiences.

## Engineering Notes

- Existing business logic and Supabase data flows were preserved.
- Improvements were introduced incrementally and validated with tests.
- Regression checks were run on both apps (`flutter test`).

## Next Recommended Iterations

- Add dashboard trend charts (hourly throughput, median wait).
- Add date range filters for KPI cards.
- Add motion to admin queue updates for status transitions.
- Capture before/after screenshots and a short walkthrough video.
- Add accessibility pass (contrast checks, larger text behavior, semantics).
