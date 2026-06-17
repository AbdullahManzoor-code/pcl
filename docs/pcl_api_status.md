---
# PCL Flutter API — Implementation Status

## Session Info
- Started: 2026-05-31 12:00:00
 - Last Updated: 2026-06-01 12:30:00
 - Session Count: 3
 - Current Session: 3

## Active Position
- Active Phase: Phase 1 — Audit & Fix Existing Services
- Active Service: ExamService
 - Active Item ID: EXAM-INVESTIGATE
 - Last Completed Item: EXAM-001

## Overall Progress
- Phase 1 (Existing Services): 1 / 4 services complete
 - Phase 2 (Missing Services): 1 / 4 services complete
- Phase 3 (Model Audit): 0 / [count] models complete
- Phase 4 (Error Handling): 0 / [count] files complete
- Total Items Verified: 1
- Total Fixes Applied: 1
- Total Issues Found: 0
 - Total Items Verified: 2
 - Total Fixes Applied: 2
 - Total Issues Found: 0

- AUTH-001: Inconsistent base URL usage across Flutter services; AuthService used an `/api`-suffixed base and others used non-`/api` base. (Addressed)
- EXAM-001: Flutter exam submission payload omitted `user_id`, which FastAPI still validates on `POST /api/exam/submit`. (Addressed)
- EXAM-002: Flutter quiz submission was sending option text instead of `A`/`B`/`C`/`D` labels for `selected_choice` and `correct_choice`, violating backend validators. (Addressed)
- EXAM-003: Flutter exam results parser assumed integer time fields, but backend returns float values for `time_spent`, `expected_time`, and related duration fields. (Addressed)

- EXAM-INVESTIGATE: Persistent 422 on `POST /api/exam/submit` observed during runtime; added request/response debug logging in `ExamService.submitExam()` to capture payload and server response for diagnosis. (2026-06-01)

- REPORTS-001: Implemented Flutter `ReportsService` for student endpoints `POST /api/reports` and `GET /api/reports/user`. Added matching Dart models. (2026-06-01)

## Verification
- EXAM-001: Verified submission guards and timer handling in `QuizController.submitQuiz()` to ensure `results` contains at least 5 entries and `total_time_seconds` > 0. (2026-06-01 12:30:00)

## Fixes Log
- AUTH-001: Centralized API base URL to `ApiConfig.baseUrl`; updated `AuthService`, `ExamService`, `DashboardService`, and `CourseService` to use centralized base and corrected auth endpoints to call `/api/auth/*`. (2026-05-31)
- EXAM-001: Restored `user_id` in `ExamSubmissionPayload.toSubmitJson()` so the submission body matches `services/schemas.py` and `main.py` validation. (2026-05-31)
- EXAM-002: Updated quiz submission builder to send letter choices (`A`-`D`) for `selected_choice` and `correct_choice` instead of answer text. (2026-05-31)
- EXAM-003: Coerced float-backed backend duration fields to ints during JSON parsing in exam result and session history models. (2026-05-31)
- AUTH-001: Re-applied `ApiConfig.baseUrl` in `AuthService` after a regression reverted it to a hardcoded `/api` URL. (2026-05-31)

## Fixes Log
[none yet]

## Sessions Log
Session 1: 2026-05-31 — STARTED fresh
Session 2: 2026-06-01 — RESUMED from AUTH-001
Session 3: 2026-06-01 — RESUMED from EXAM-001

---

## Routing Map (extracted from main.py + routers)

- Base path: `/` (server root). API docs served at `/api/docs`.
- API prefix used: Many endpoints under `/api/*`; some routers expose non-`/api` prefixes (e.g., `/question-bank`, `/curriculum/all`).
- Routers mounted (10):
	- `auth_router` — prefix: `/api/auth` — endpoints: register (public), login (public), refresh (cookie-based), `me`, `change-password`, `logout`, `profile` (require access token via `get_current_active_user`).
	- `question_bank_router` — prefix: `/question-bank` — most endpoints require `get_current_active_user`; admin endpoints require `get_current_admin_user`. Note: `DELETE /question-bank/session/{session_id}` is public (no auth).
	- `analytics_router` — prefix: `/analytics` — student endpoints require `get_current_active_user`; some sub-routes require admin (`get_current_admin_user`).
	- `rl_router` — prefix: `/api/rl` — `POST /recommend` and `/history/{user_id}` require `get_current_active_user`; `/health` and `/strategies` are public.
	- `dashboard_router` — endpoints use `/api/dashboard/*`, `/api/user/mastery/{language_id}`, `/api/transfer/active-boosts`, `/api/synergy/recent-bonuses` — require `get_current_active_user`.
	- `admin_router` — prefix: `/api/admin` — all endpoints require admin auth (`get_current_admin_user`).
	- `user_languages_router` — prefix: `/api/user/languages` — requires `get_current_active_user`.
	- `reports_router` — prefix: `/api` — student report endpoints (`POST /reports`, `GET /reports/user`) require `get_current_active_user`; admin report management under `/admin/reports/*` requires admin.
	- `tickets_router` — prefix: `/api/tickets` — all ticket endpoints require `get_current_active_user` (admin checks enforced inside for admin-only views).
	- `code_execution_router` — prefix: `/api/code-execution` — admin-only endpoints (`get_current_admin_user`).

### Notes / Observations
- Refresh token cookie name: `refresh_token` (httpOnly, path="/") — important for Flutter cookie handling.
- Access token is returned in JSON body on login/register (`access_token`, `token_type`).
- Many critical endpoints require `Authorization: Bearer <access_token>` and will return 401/403 when missing or invalid.

