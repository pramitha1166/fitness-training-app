# FitSculpt — Fitness Training & Meal Planning App

A Flutter (iOS + Android) implementation of the app described in the SRS:
personalized aesthetic workout plans and meal plans scheduled around the
user's available time, with local reminders and a monthly-subscription
paywall.

## What's implemented

This is a fully working, offline-first **client app**. Every screen is
real and wired to real local logic — nothing here is a static mockup.

- **Onboarding** (`lib/screens/onboarding`) — multi-step intake: goals,
  body metrics, equipment/injuries, per-day workout availability, per-meal
  (breakfast/lunch/dinner/snack) availability, dietary preferences.
  FR-1.1–1.6.
- **Plan generation** (`lib/services/plan_generator_service.dart`) —
  rule-based generator that builds a hypertrophy/physique-style workout
  split (full body → PPL → bro-split, scaled to how many days the user has)
  from an in-house exercise library, and a meal plan from an in-house
  recipe/nutrition library filtered by diet and dislikes. Both are
  constrained to the user's declared time slots only. FR-2.x, FR-3.x.
- **Dashboard, workout detail, meal detail** — today's plan, mark
  complete/skipped, swap a meal, view sets/reps/rest and nutrition
  breakdown. FR-2.6, FR-3.4, FR-3.5, section 4.1.
- **Progress tracking** (`lib/screens/progress`) — weight/measurement
  check-ins, progress photos (device gallery via `image_picker`), a
  weight-trend chart (`fl_chart`), and adherence percentages. FR-4.x.
- **Notifications** (`lib/services/notification_service.dart`) — local,
  device-scheduled (not server push) workout/meal reminders using
  `flutter_local_notifications` + `timezone`, so they fire even offline and
  respect the device's time zone. Configurable lead time. FR-5.x, NFR-10.
- **Subscription/paywall** (`lib/screens/paywall`,
  `lib/services/subscription_service.dart`,
  `lib/providers/subscription_provider.dart`) — real `in_app_purchase`
  (StoreKit/Play Billing) wiring, plus a local free-trial simulation so the
  full paywall → unlock → gate flow is testable without live store
  products configured. FR-6.x.
- **Settings** — edit profile (regenerates the plan), notification
  preferences, manage-subscription deep link, restore purchases, data
  export/account deletion. FR-7.x.
- Offline-first local persistence via `shared_preferences`
  (`lib/services/storage_service.dart`). NFR-10.

## What is intentionally out of scope of a Flutter client

The SRS describes a full product, not just a mobile client. These pieces
are backend/publisher-console work that cannot be done from this
repository:

- **Backend API / cross-device sync / server-side receipt validation**
  (NFR-5). The app is fully usable standalone today; `StorageService` is
  the seam where a real backend sync layer would plug in.
- **Real store products.** `SubscriptionService.monthlySubscriptionProductId`
  must be created as an auto-renewing subscription in App Store Connect and
  the Google Play Console before real purchases will work — this is a
  publisher-console step, not code. Until then, the paywall's free trial
  path exercises the full unlock/gate logic.
- **Trainer/admin dashboard, wearable integration, AI-adaptive plans,
  community features** — explicitly Phase 2+ in the SRS (section 7).

## Project layout

```
lib/
  models/       Plain Dart data models (UserProfile, WorkoutPlan, MealPlan, …)
  data/         Seed content libraries (exercises, foods) — FR/NFR-12 content mgmt
  services/     StorageService, PlanGeneratorService, NotificationService, SubscriptionService
  providers/    ChangeNotifier state (User, Plan, Progress, Subscription, Settings)
  screens/      onboarding/ dashboard/ workout/ meal/ progress/ settings/ paywall/ splash/
  theme/        App theme
  widgets/      Shared small widgets
```

## Running it

```bash
flutter pub get
flutter run
```

Requires an Android SDK (for `android/`) or Xcode (for `ios/`) locally —
neither is available in the sandbox this was built in, so building was
validated with `flutter analyze` (0 issues) and `flutter test` (passing),
not a device/emulator build. Do a real device/emulator smoke test before
shipping.

### Notification permissions

Android manifest already declares `POST_NOTIFICATIONS`,
`SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, and the
`flutter_local_notifications` scheduled-notification receivers. iOS
`Info.plist` declares photo library/camera usage strings for progress
photos. The app requests notification permission right after onboarding.
