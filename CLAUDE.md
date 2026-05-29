# CoachingFit — Coach App (Flutter)

## What This Is
The **coach-facing** Flutter app for CoachingFit, a commission-based fitness marketplace (Uber/Uber Driver model). Coaches register, get admin-approved, build a profile, and eventually manage plan requests, chat, and earnings.

This is the developer's first production Flutter project. The backend (Identity + Gateway + User services) is already complete. The Trainee app and Admin dashboard come later.

---

## Tech Stack
```yaml
flutter_bloc: ^8.1.3          # Cubit-based state management
bloc: ^8.1.2
equatable: ^2.0.5
dio: ^5.4.0                   # HTTP client
flutter_secure_storage: ^9.0.0
go_router: ^14.0.0            # Declarative routing + auth guards
get_it: ^7.6.7                # Service locator / DI
json_annotation: ^4.8.1
google_fonts: ^6.1.0          # Syne (headings) + DM Sans (body)
image_picker: ^1.0.7
intl: ^0.19.0
file_picker: ^8.0.0           # Certificate file selection (pdf/jpg/png/webp)
flutter_pdfview: ^1.3.2       # In-app PDF viewer for certificates
url_launcher: ^6.2.5          # Fallback external file opener
http: ^1.2.1                  # PDF download for pdfview
path_provider: ^2.1.3         # Temp directory for PDF cache

# dev
build_runner: ^2.4.8
json_serializable: ^6.7.1
```

---

## Architecture: Feature-First with Repository Layer
```
lib/
├── core/
│   ├── constants/api_constants.dart    — endpoint URLs
│   ├── errors/failures.dart            — ServerFailure, NotFoundFailure, NetworkFailure
│   ├── network/
│   │   ├── api_interceptor.dart        — auto-attach JWT, auto-redirect on 401
│   │   └── dio_client.dart             — Dio wrapper, base URL, 30s timeouts
│   ├── router/app_router.dart          — GoRouter + auth guards
│   ├── storage/secure_storage.dart     — FlutterSecureStorage wrapper
│   └── theme/
│       ├── app_theme.dart              — dark theme, AppColors
│       └── text_styles.dart            — AppTextStyles
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/                 — AuthResponse, Login/Register Request (+ .g.dart)
│   │   │   └── repositories/auth_repository.dart
│   │   └── presentation/
│   │       ├── cubit/                  — auth_cubit.dart + auth_state.dart
│   │       └── screens/                — splash, onboarding, login, register, email_confirmation
│   ├── profile/
│   │   ├── data/
│   │   │   ├── models/                 — Coach profile request/response (+ .g.dart)
│   │   │   └── repositories/profile_repository.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       └── screens/                — create_profile, view_profile, edit_profile, pending_approval
│   └── certificates/
│       ├── data/
│       │   ├── models/                 — CertificateResponse (+ .g.dart)
│       │   └── repositories/certificate_repository.dart
│       └── presentation/
│           ├── cubit/                  — certificate_cubit.dart + certificate_state.dart
│           └── screens/                — my_certificates, upload_certificate, certificate_detail
├── main.dart
└── service_locator.dart                — GetIt registration
```

### State management — BLoC (Cubit)
- One Cubit per feature: `AuthCubit`, `ProfileCubit`, `CertificateCubit`
- All provided globally via `MultiBlocProvider` in `main.dart`
- Cubits registered as `factory` in GetIt (new instance per provider)
- States use `Equatable`

### DI — GetIt registration order
1. Storage (`FlutterSecureStorage` → `SecureStorage`)
2. Router (`AppRouter` → `GoRouter`)
3. Network (`ApiInterceptor` → `Dio` → `DioClient`)
4. Repositories (`AuthRepository`, `ProfileRepository`)
5. Cubits (`AuthCubit`, `ProfileCubit`)

### Routing — GoRouter
- Auth guard in `redirect` checks token → hasProfile → role
- `context.go()` for full route replacement
- `context.pop()` for back nav
- Use route `extra` to pass data (e.g. email to confirmation screen)
- `PopScope(canPop: false)` on screens that must not allow back nav (`EmailConfirmation`, `CreateProfile`, `PendingApproval`)

---

## Backend Connection
**Base URL (Android emulator → host localhost):**
```
http://10.0.2.2:5000
```
Everything goes through the YARP gateway. **Never call services directly.**

### Endpoints used

**Identity Service — `/api/Auth`**
| Method | Endpoint |
|---|---|
| POST | `/api/Auth/register/coach` |
| POST | `/api/Auth/login` |
| GET  | `/api/Auth/me` |
| GET  | `/api/Auth/confirm-email?userId=&token=` |
| POST | `/api/Auth/resend-confirmation?email=` |

**User Service — `/api/CoachProfile`**
| Method | Endpoint |
|---|---|
| POST | `/api/CoachProfile`        (multipart/form-data) |
| GET  | `/api/CoachProfile/me` |
| GET  | `/api/CoachProfile/{id}` |
| PUT  | `/api/CoachProfile`        (multipart/form-data) |

---

## Network Conventions
- `DioClient` wraps `Dio` with base URL + 30s timeouts
- `ApiInterceptor`:
  - Auto-attaches `Bearer {token}` on every request
  - On `401`: clears storage and redirects to `/login`
- Repositories catch `DioException` and throw typed `Failure` subclasses (`ServerFailure`, `NotFoundFailure`, `NetworkFailure`)
- Profile create/update use `multipart/form-data` with `MultipartFile.fromFile(photo.path)`
- On profile update, if no photo selected, **don't include the `photo` field at all** (preserves existing)

---

## SecureStorage Keys
| Key | Type | Written when | Used for |
|---|---|---|---|
| `auth_token` | String | login | Bearer header |
| `user_id` | String | login | identification |
| `role` | String | login | routing |
| `has_profile` | bool-as-string | after profile check | route guard |
| `is_active` | bool-as-string | login | splash routing, pending banner |
| `full_name` | String | login | profile display, avatar fallback |

---

## Routing Logic

**Splash decision tree**
```
no token  → /onboarding (after 2s)
has token → GET /api/CoachProfile/me
            ├─ 404 → /create-profile
            ├─ error → clear storage → /login
            └─ ok → isActive? → /view-profile : /pending-approval
```

**Login post-auth**
```
login ok → store token/userId/role/isActive/fullName
        → GET /api/CoachProfile/me
            ├─ 404 → /create-profile
            └─ ok → /pending-approval
```

**GoRouter redirect guard**
```
no token              → /login (allow /register, /email-confirmation)
token but no profile  → /create-profile
on /login or /register with profile → /view-profile
```

---

## Theme — Dark, single source of truth
```dart
background:    0xFF0B1426
surface:       0xFF111E35
card:          0xFF162240
primary:       0xFF1A73E8
textPrimary:   0xFFF0F4FF
textSecondary: 0xFFA8B4CC
textHint:      0xFF6B7A96
borderColor:   0xFF1C2D52
success:       0xFF22C55E
error:         0xFFEF4444
warning:       0xFFF59E0B
```

**Typography**
- Headings: Google Fonts **Syne** (bold)
- Body: Google Fonts **DM Sans** (normal)
- Sizes: heading1=32, heading2=24, heading3=20, bodyL=18, bodyM=16, bodyS=14

**UI patterns**
- Cards: `AppColors.card` background + `borderColor` border + 16px radius
- Inputs: `card` fill, 10px radius, primary on focus
- Primary buttons: full-width, 52px height, 12px radius
- Loading: `CircularProgressIndicator` with `AppColors.primary`
- Errors: `SnackBar` with `AppColors.error`

---

## JSON Serialization Notes
- Use `json_serializable` + `build_runner`
- Null-safe string converter:
  ```dart
  String _stringFromJson(dynamic json) => json?.toString() ?? '';
  ```
- After any model change, regenerate:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

---

## Common Commands
```bash
flutter pub get
flutter run                     # Android emulator → uses 10.0.2.2:5000
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --debug
```

---

---

## Conventions
- Feature-first folders: `data/` (models, repositories) + `presentation/` (cubit, screens)
- Cubits, not BLoCs — keep state simple
- Repository → throws typed `Failure`s; never let `DioException` reach the UI
- All endpoint URLs in `core/constants/api_constants.dart`
- All colors via `AppColors`, all text via `AppTextStyles` — no inline hex / TextStyle literals
- Form data for any endpoint with a file upload
- Use `PopScope(canPop: false)` on screens with terminal/intermediate states
- `context.go()` to replace, `context.pop()` to back

---

## Don'ts
- Don't call services directly — only the gateway (`10.0.2.2:5000`)
- Don't include the `photo` form field on update if user didn't pick a new one
- Don't read `hasProfile` from storage as the source of truth on login — verify via `GET /api/CoachProfile/me`
- Don't trust `json.toString()` for nullable strings — use the null-safe helper
- Don't hardcode colors or text styles in widgets
- Don't store the token anywhere except `SecureStorage`
- Don't `Navigator.push` past auth guards — use `context.go(...)` so GoRouter re-evaluates
- Don't allow gender to be edited in `EditProfile` — it's locked at creation

---

## Coach Lifecycle
```
Register → Confirm Email → Login → Create Profile → Admin Reviews → Activates → Goes Live
```

---

## What's Built
- ✅ Splash, Onboarding, Register, Email Confirmation, Login
- ✅ Create Profile, Pending Approval, View Profile, Edit Profile
- ✅ Auth + Profile cubits & repositories
- ✅ Network layer (Dio + interceptor)
- ✅ Theme + typography
- ✅ GoRouter with auth guards
- ✅ Certificate upload, list, detail, delete (MyCertificatesScreen, UploadCertificateScreen, CertificateDetailScreen)
- ✅ CertificateCubit + CertificateRepository
- ✅ PDF in-app viewer (flutter_pdfview) + image viewer

## What's Not
- Home/Dashboard (post-activation main screen)
- Plan request management (accept/reject)
- Chat (SignalR)
- Earnings/Wallet view
- Notification center
- Settings / logout from main flow
- Bottom nav with real navigation
- Pull-to-refresh on profile
- Error/retry UI
- Deep linking for email confirmation

---

## Repository
https://github.com/3bdoEssam22/CoachingFit
Feature branches → PR → Development → main
GitHub Projects Kanban: Backlog / Sprint / In Progress / Done
