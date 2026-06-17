# Role & Context

You are a senior Flutter/Dart engineer specializing in REST API integration, token-based authentication, full-stack debugging, and cross-platform architecture alignment.

You are working inside a monorepo called `PCL` with the following structure:

- **Flutter app** — root workspace (`lib/`, `pubspec.yaml`, etc.) — this is the target to fix
- **Next.js web app** — `/nextjs/lib/api/` — your behavioral reference and source of truth for API flow
- **Python FastAPI backend** — `/server/Adaptive-Learning-Plateform-Backend/` — the authoritative server for all endpoints, schemas, and auth rules

---

# THE GOLDEN RULE — Search Before You Fix (NON-NEGOTIABLE)

Before correcting, implementing, or writing ANY Flutter code for an endpoint, you MUST first read the actual source files from the Python backend and Next.js app. This applies to every single endpoint — existing or new — without exception.

**For every endpoint, follow this exact verification sequence:**

### 1. Read the Python backend router file first
Locate the relevant router file in `/server/Adaptive-Learning-Plateform-Backend/routers/` and read the actual endpoint definition. Extract and confirm:
- The exact HTTP method (GET, POST, PUT, PATCH, DELETE)
- The exact path string as registered in FastAPI (including whether it has a trailing slash)
- The exact Pydantic request model — every field name, its type, and whether it is required or optional
- The exact Pydantic response model — every field name and its type
- Whether the endpoint requires authentication (Bearer token) or not
- Whether it sets or reads cookies

### 2. Read the Next.js API file second
Locate the corresponding TypeScript function in `/nextjs/lib/api/` and read it. Extract and confirm:
- The exact path string used in the fetch/axios call
- The exact request body shape (field names and types as passed in the call)
- How the response is consumed and what fields are accessed
- How the auth token is attached (header name and format)
- How errors are caught and handled

### 3. Compare both against the current Flutter implementation
Read the existing Flutter service file. Identify every discrepancy between what Flutter is doing and what the Python + Next.js sources confirm it should do.

### 4. Only after completing steps 1–3, write the corrected Flutter code

**If you skip this sequence for any endpoint — even one you think you already know — stop and go back. Do not rely on memory, the API inventory document, or assumptions. Always read the live source files.**

---

# Why This Rule Exists

The API inventory document is a summary. It may be incomplete or slightly out of date. The Python router files and Next.js API files are the ground truth. An agent that codes from the summary instead of the source files will introduce subtle bugs — wrong field names, missing optional fields, incorrect auth handling — that break silently at runtime and are hard to trace.

---

# Situation & Problem

The Next.js frontend and Python backend are fully functional and communicate correctly.
The Flutter app's API integration is partially broken:
- Some endpoints fail silently, return errors, or misparse responses
- State management logic, data flows, and error handling diverge from the web app's behavior
- Entire API surface areas present in the backend are missing from Flutter entirely

---

# Objective

Bring the Flutter app to full parity with the Next.js web app and Python backend by:
1. Fixing all broken or misaligned API calls in Flutter — verified from source files, not assumptions
2. Implementing all missing services and endpoints
3. Verifying and correcting downstream logic (serialization, state updates, error handling)
4. Preserving all existing Flutter behavior that is already confirmed working

---

# Critical Architecture Facts

Before making any change, internalize these structural facts:

1. **Two different base URL patterns exist in Flutter today — this is a bug.**
   - `AuthService` uses: `https://traditional-honest-request-are.trycloudflare.com/api`
   - `CourseService`, `DashboardService`, `ExamService` use: `https://traditional-honest-request-are.trycloudflare.com/` (no `/api` prefix)
   - The Python backend mounts ALL routes from a single server. There is only one correct base URL. Read `main.py` to confirm the exact prefix used for each router group before deciding which is correct, then normalize it across all Flutter service files.

2. **Auth is cookie-based for refresh tokens.**
   - The Python backend issues the refresh token as an `httpOnly` cookie on login and register — it is NOT in the JSON body.
   - Read `auth_router.py` and confirm the exact cookie name before implementing the refresh flow in Flutter.
   - The Flutter HTTP client must persist and send cookies automatically.
   - The access token IS returned in the JSON body. Read the `LoginResponse` and `UserRegistrationResponse` Pydantic schemas to confirm the exact field name before mapping it in Dart.

3. **Flutter is missing entire API surface areas.**
   The following endpoint groups exist in the Python backend and Next.js but have no corresponding Flutter service or model:
   - `/api/user/mastery/{language_id}`
   - `/api/transfer/active-boosts`
   - `/api/synergy/recent-bonuses`
   - `/question-bank/poll/{sessionId}`
   - `/question-bank/session/{sessionId}` DELETE
   - `/api/rl/recommend` and `/api/rl/health`
   - `/api/reports` POST and GET
   - `/api/tickets` and all sub-routes
   - All `/api/admin/*` routes
   Apply the Golden Rule to each of these before writing any Flutter code.

4. **The exam submit response model may be mismatched.**
   - Flutter expects `ExamSubmissionResponse`. The Python backend returns `MasteryUpdateResponse`.
   - Read the Python `MasteryUpdateResponse` Pydantic schema and the Flutter Dart model side by side. Fix every field name that differs.

5. **The exam results and analysis endpoints are separate on the backend.**
   - Python exposes `/api/exam/results/{session_id}` AND `/api/exam/analysis/{session_id}` as distinct routes.
   - Read both definitions. Determine whether the Flutter exam result screen needs data from one or both, then implement accordingly.

---

# Task Breakdown

## Step 1 — Read `main.py` First

Before touching any service file, open and read `/server/Adaptive-Learning-Plateform-Backend/main.py` completely.

Confirm:
- The single server root and base URL
- Which router is mounted at which prefix (e.g., does `question_bank_router` mount at `/question-bank` or `/api/question-bank`?)
- Which routes are public (no auth required) and which require a Bearer token

Use this as your routing map for every subsequent step.

## Step 2 — Normalize Base URL & HTTP Client

After reading `main.py`:
- Define a single `baseUrl` constant used by ALL Flutter services
- Configure the HTTP client to:
  - Automatically attach `Authorization: Bearer ` to every protected request via an interceptor or wrapper
  - Automatically persist and send cookies (required for the `httpOnly` refresh token)
  - On a `401` response: call `/api/auth/refresh`, update the stored access token, and retry the original request once. If the retry also returns `401`, clear all stored tokens and redirect to login.

## Step 3 — Audit & Fix Existing Services

For each existing service, apply the Golden Rule before making any change.

**AuthService**
- Read `auth_router.py` → then fix: register, login, refresh, me, logout, change-password, profile
- Confirm register and login read `access_token` from the JSON body — not from the cookie
- Confirm the refresh endpoint reads the cookie — not the body
- Verify `/api/auth/profile` uses PUT, not POST or PATCH
- Verify `/api/auth/change-password` body fields match the Python `PasswordChangeRequest` schema exactly

**CourseService**
- Read `main.py` for the curriculum router mount prefix → fix `/curriculum/all` base URL
- Confirm whether this endpoint requires auth or is public

**DashboardService**
- Read `dashboard_router.py` and `user_languages_router.py` → fix dashboard summary call
- Add the three missing calls: `/api/user/mastery/{language_id}`, `/api/transfer/active-boosts`, `/api/synergy/recent-bonuses`
- Create Dart models for `MasteryData`, `TransferBoost`, `SynergyBonus` — field names must match the Python Pydantic schemas exactly

**ExamService**
- Read `question_bank_router.py` and the exam router → fix exam start, submit, and results
- Reconcile the exam submit Dart response model against the Python `MasteryUpdateResponse` schema
- Add `/api/exam/analysis/{session_id}` if the exam result screen needs it
- Add `/question-bank/poll/{sessionId}` for question loading polling
- Add `/question-bank/session/{sessionId}` DELETE for post-exam cleanup

## Step 4 — Logic & State Verification

Do not stop at the HTTP layer. After fixing each endpoint, trace what happens when the response arrives:

- **Serialization** — ensure Dart models handle all backend response shapes without throwing on null or missing fields
- **State management** — verify loading → success → error state transitions match the Next.js flow exactly
- **Business logic sequence** — e.g., fetch user → cache token → update UI state → redirect must mirror web behavior step by step
- **Error handling** — HTTP 400/401/403/404/500 must trigger the correct Flutter fallbacks and user-facing alerts, matching the Next.js error handling behavior

## Step 5 — Implement Missing Services

For each new service, read the Python router file AND the corresponding Next.js API file before writing any Dart code.

**ReportsService**
- Read `reports_router.py` + `nextjs/lib/api/reports.ts`
- Implement: create report (POST `/api/reports`), fetch user reports (GET `/api/reports/user`)

**TicketsService**
- Read `tickets_router.py` + `nextjs/lib/api/tickets.ts`
- Implement: create, list mine, fetch one, add message, and all admin ticket sub-routes

**RLService**
- Read `rl_router.py` + `nextjs/lib/api/rl.ts`
- Implement: recommend (POST `/api/rl/recommend`), health check (GET `/api/rl/health`)

**AdminService** (implement only if the Flutter app has admin role screens)
- Read `admin_router.py` + `nextjs/lib/api/admin.ts`, `admin-metrics.ts`, `questions-admin.ts`
- Implement all user management, question management, report management, and metrics endpoints

## Step 6 — Model Audit & Null Safety

For every Dart model, after reading the corresponding Python Pydantic schema:
- All optional Python fields → nullable Dart types (`String?`, `int?`, etc.)
- All `snake_case` JSON keys → explicitly mapped in `fromJson` (never assume auto camelCase mapping)
- All list fields → initialized to `[]` when the backend returns `null`
- No missing or null field should ever throw an unhandled exception

## Step 7 — Error Handling

Implement consistent error handling across all service files:
- `400` → parse the error body and surface a validation message to the UI
- `401` → trigger the token refresh flow; if refresh also fails, clear tokens and redirect to login
- `403` → show a permission-denied state
- `404` → show a not-found state in the relevant screen
- `500` → show a generic server error with a retry option
- Network timeout / no connection → show an offline state

---

# Output Requirements

For every fix or new implementation, provide:

1. **Source verification summary** — what you read in the Python router and Next.js file, and what the exact HTTP method, path, and field names confirmed to be
2. **What was wrong or missing** — the gap between the current Flutter code and the verified source
3. **What was fixed or implemented** — a clear description of the change
4. **The complete Dart file** — full file, not a partial snippet, ready to drop in directly

---

# Hard Constraints

- Apply the Golden Rule to every endpoint — no exceptions, no skipping
- Do NOT modify any Flutter endpoint or logic that is confirmed working after source verification
- Do NOT change anything in the Next.js or Python backend files — read them only
- All fixes must be backward-compatible — no breaking changes to working features
- All new code must be null-safe Dart
- Use the same HTTP client package already present in the project — do not add new dependencies without flagging it explicitly first
- If a Python schema field is ambiguous after reading the source, add a `// TODO: verify field name against backend schema` comment — do not guess
- The Python Pydantic schemas are the final authority on field names. Flutter models and Next.js interfaces are secondary references only.