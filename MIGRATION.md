# Aarogya Architecture & Clinical Intelligence Migration Guide

This document outlines the architectural refactoring, model migrations, UX improvements, theme token standardization, and DPDP Act 2023 compliance changes across the **Aarogya** Flutter application.

---

## 1. Data Integrity & Domain Model Migrations (Phase P0)

### 1.1 Patient Session Scope & Security Guards
- **Problem**: Repository queries previously accepted loose `patientId` parameters, introducing risks of cross-patient record leaks or session spoofing.
- **Migration**:
  - `PatientSession` enforces active patient boundaries.
  - Queries validate against `PatientSession.currentPatientId`.
  - Violations throw a fail-closed `PatientMismatchException`.

```dart
// Before
final records = await repository.getRecords(patientId);

// After
PatientSession.setActivePatient('patient_id_123');
// Fail-closed guard automatically validates patient boundaries
final records = await recordRepository.getPatientRecords(
  patientId: PatientSession.currentPatientId,
);
```

### 1.2 Integer Arithmetic for Billing & Invoices (`paise`)
- **Problem**: Invoices and billing line items stored amounts as floating-point `double` (`totalAmount: 1450.50`), susceptible to IEEE 754 precision errors.
- **Migration**:
  - All currency calculations now use strict integer `paise` (1 INR = 100 paise).
  - Added helper getters `.totalPaise`, `.paidPaise`, `.balancePaise`, and `.totalInRupees`.

```dart
// Before
final invoice = Invoice(totalAmount: 2450.0);

// After
final invoice = Invoice(
  totalPaise: 245000,
  paidPaise: 245000,
  taxPaise: 0,
);
print(invoice.formattedTotal); // "₹2,450.00"
```

### 1.3 Canonical UTC Timestamps & Provenance
- **Problem**: Medical records used unparsed string date representations (`date: "14 Oct 2024"`), preventing reliable chronological sorting.
- **Migration**:
  - `MedicalRecord`, `Vital`, and `Encounter` models enforce canonical `occurredAt: DateTime` in UTC.
  - Vitals include `isStale` and provenance tracking.

```dart
// Before
final record = MedicalRecord(date: "2024-10-14");

// After
final record = MedicalRecord(
  occurredAt: DateTime.parse("2024-10-14T08:30:00Z").toUtc(),
  encounterId: "enc_9921",
);
```

### 1.4 Prescription Medication Lifecycle
- **Problem**: Active/Completed prescription status was static or hardcoded.
- **Migration**:
  - Prescriptions track `startDate`, `durationDays`, and `endDate`.
  - `status` is derived dynamically as `MedicationStatus.active`, `MedicationStatus.completed`, or `MedicationStatus.discontinued`.

---

## 2. Clinical Interaction & Visual Craft (Phases P1 & P2)

### 2.1 Continuous Reference Gauge (`ReferenceGaugePainter`)
- Replaced stepped/segmented bar widgets with a continuous diagnostic reference gauge:
  - Low, Normal (Safe Zone), and High bands.
  - Continuous gradient interpolation and needle pin marker.
  - Right-facing/left-facing caret indicators (`▸`, `◂`) for extreme out-of-range clinical values.
  - Full `Semantics` support for accessibility screen readers.

### 2.2 Live Queue State Propagation
- In `PatientAppointmentsScreen`, when an appointment is checked-in and active in the clinic triage queue:
  - Reschedule and Cancel buttons are replaced with **"View live queue"** and live token/ETA display.

### 2.3 Filter Chips with Explicit Empty States
- Filter chips across Appointments, Labs, Medical Records, and Billing now display record counts e.g. `Cancelled (0)`.
- Zero-count filters are disabled.
- Empty states include a 1-tap **"Clear filter"** action.

### 2.4 Max-Width Layout Constraints
- All top-level screens (Prescriptions, Labs, Records, Appointments, Billing, Discovery) enforce a centered `1320px` max-width constraint for wide monitors and tablets.

---

## 3. Theming, Typography & Flutter Quality (Phase P3)

### 3.1 Strict `ThemeExtension` Token System
- Replaced loose constants with `AarogyaColorTokens` and `AarogyaTypographyTokens` as Flutter `ThemeExtension`s.
- Supports smooth interpolation via `lerp()` and theme switching.
- Standardized 9-step neutral grayscale, 2-tier elevation model (Informational vs Actionable), and clinical semantic states (`clinicalStable`, `clinicalWarning`, `clinicalCritical`).

### 3.2 Tabular Figures for Clinical Telemetry
- All numeric measurements, lab values, vitals, timestamps, and currency prices use `FontFeature.tabularFigures()` to prevent visual jitter and misalignment.

### 3.3 Dynamic Text Scaling (1.0x - 2.0x) Resilience
- All metric cards, KPI chips, gauge headers, and summary rows wrapped in `FittedBox` or responsive `Wrap` layouts, ensuring zero pixel overflows under extreme accessibility font scales.

---

## 4. Security & DPDP Act 2023 Compliance (Phase P4)

### 4.1 Encrypted Token Storage (`EncryptedTokenStorage`)
- Sensitive tokens (`auth_token`, `refresh_token`, session keys) are protected using encrypted/obfuscated storage envelopes instead of plaintext `SharedPreferences`.

### 4.2 PHI Redaction Logger (`ClinicalLogger`)
- All console logs and debug outputs pass through `ClinicalLogger.redact()`.
- Automatically scrubs:
  - ABHA numbers (`91-XXXX-XXXX-XXXX`)
  - ABHA addresses (`user@abdm`)
  - Aadhaar IDs (`XXXX XXXX XXXX`)
  - Phone numbers (`+91 XXXXXXXXXX`)
  - Email addresses
  - Medical Record Numbers (`MRN-*`, `UHID-*`)

### 4.3 Session Inactivity Guard (`SessionInactivityManager`)
- Implements 15-minute inactivity auto-lock and touch event monitoring via `SessionInactivityDetector`.

### 4.4 App Backgrounding Privacy Shield (`PrivacyScreenGuard`)
- Masks patient health information with `AarogyaPrivacyShield` whenever the app enters background, multitasking switcher, or inactive states.

### 4.5 Ephemeral Document Delivery (`SecureDocumentService`)
- Implements data minimization and short-lived signed 15-minute access tokens for document viewing and clinical sharing with full audit trails.
