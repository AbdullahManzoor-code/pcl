# API Inventory

This document lists the application APIs found across the Flutter app, the Next.js app, and the Python backend server.

Notes:
- Endpoints are written as they appear in the codebase.
- For Flutter and Next.js, the response shapes are based on the client models/interfaces.
- For Python, the response shapes are based on router `response_model` usage and the surrounding schema names.
- Static CDN/image URLs are excluded.

## Flutter App

Source files scanned:
- [lib/app/data/services/auth_service.dart](../lib/app/data/services/auth_service.dart)
- [lib/app/data/services/course_service.dart](../lib/app/data/services/course_service.dart)
- [lib/app/data/services/dashboard_service.dart](../lib/app/data/services/dashboard_service.dart)
- [lib/app/data/services/exam_service.dart](../lib/app/data/services/exam_service.dart)

Flutter uses two request-base patterns in the code:
- `AuthService.apiBaseUrl` is `https://traditional-honest-request-are.trycloudflare.com//api`
- `CourseService`, `DashboardService`, and `ExamService` use `https://traditional-honest-request-are.trycloudflare.com/`

| Exact API in Flutter | Method | Purpose | Input | Output |
|---|---|---|---|---|
| `https://traditional-honest-request-are.trycloudflare.com//api/auth/register` | POST | Register a new user and start a session. | JSON body: `email`, `password`, optional `language_id`, `experience_level`. | `User`/auth response with `access_token`; refresh token is written from body or `set-cookie`. |
| `https://traditional-honest-request-are.trycloudflare.com//api/auth/login` | POST | Authenticate a user. | JSON body: `email`, `password`. | `User`/auth response with `access_token`; refresh token is written from body or `set-cookie`. |
| `https://traditional-honest-request-are.trycloudflare.com//api/auth/refresh` | POST | Refresh the access token using stored refresh token. | `Cookie: refresh_token=...`. | `TokenRefreshResponse` with new `access_token`. |
| `https://traditional-honest-request-are.trycloudflare.com//api/auth/me` | GET | Fetch the current authenticated user profile. | Bearer access token. | Converted `User` profile from backend `/auth/me` response. |
| `https://traditional-honest-request-are.trycloudflare.com//api/auth/logout` | POST | End the current session. | Bearer access token. | Logout confirmation or empty success response. |
| `https://traditional-honest-request-are.trycloudflare.com//api/auth/change-password` | POST | Change the current user password. | JSON body: `current_password`, `new_password`. | Success confirmation. |
| `https://traditional-honest-request-are.trycloudflare.com//api/auth/profile` | PUT | Update language/experience profile. | JSON body: `language_id`, `experience_level`. | Success confirmation. |
| `https://traditional-honest-request-are.trycloudflare.com//api/user/languages` | GET | Fetch the user language portfolio. | Bearer access token. | `LanguagePortfolio` with `languages` list. |
| `https://traditional-honest-request-are.trycloudflare.com//api/user/languages` | POST | Add a new language to the user portfolio. | JSON body: `language_id`, `difficulty_level`. | `AddLanguageResponse`. |
| `https://traditional-honest-request-are.trycloudflare.com//api/user/languages/{languageId}/progress` | GET | Fetch topic progress for a specific language. | Path param: `languageId`. | `StudentProgressResponse`. |
| `https://traditional-honest-request-are.trycloudflare.com//curriculum/all` | GET | Load the full curriculum for all languages. | None. | `LanguageCurriculum[]`. |
| `https://traditional-honest-request-are.trycloudflare.com//api/dashboard/summary?language_id=...` | GET | Load dashboard summary for the selected language. | Query param: `language_id`. | `DashboardSummary`. |
| `https://traditional-honest-request-are.trycloudflare.com//api/exam/start` | POST | Start a new exam or practice session. | JSON body: `user_id`, `language_id`, `major_topic_id`, `session_type`, optional RL metadata. | `ExamStartResponse` with `session_id` and `started_at`. |
| `https://traditional-honest-request-are.trycloudflare.com//question-bank/select` | POST | Select questions for the active session. | Session/question selection payload. | Selected question set and warehouse status. |
| `https://traditional-honest-request-are.trycloudflare.com//api/exam/submit` | POST | Submit completed exam results. | JSON body: exam submission payload with `session_id`, `results`, timing, topic metadata. | `ExamSubmissionResponse` with score, mastery updates, recommendations. |
| `https://traditional-honest-request-are.trycloudflare.com//api/exam/results/{sessionId}` | GET | Fetch saved results for a session. | Path param: `sessionId`. | `ExamResultsResponse`. |
| `https://traditional-honest-request-are.trycloudflare.com//api/sessions/history` | GET | Fetch past exam/session history. | Query params: `language_id`, `session_type`, `limit`, `offset`. | Session history response. |

## Next.js App

Source files scanned:
- [nextjs/lib/api/auth.ts](../nextjs/lib/api/auth.ts)
- [nextjs/lib/api/admin.ts](../nextjs/lib/api/admin.ts)
- [nextjs/lib/api/admin-metrics.ts](../nextjs/lib/api/admin-metrics.ts)
- [nextjs/lib/api/curriculum.ts](../nextjs/lib/api/curriculum.ts)
- [nextjs/lib/api/dashboard.ts](../nextjs/lib/api/dashboard.ts)
- [nextjs/lib/api/exam.ts](../nextjs/lib/api/exam.ts)
- [nextjs/lib/api/languages.ts](../nextjs/lib/api/languages.ts)
- [nextjs/lib/api/questions-admin.ts](../nextjs/lib/api/questions-admin.ts)
- [nextjs/lib/api/reports.ts](../nextjs/lib/api/reports.ts)
- [nextjs/lib/api/rl.ts](../nextjs/lib/api/rl.ts)
- [nextjs/lib/api/sessions.ts](../nextjs/lib/api/sessions.ts)
- [nextjs/lib/api/tickets.ts](../nextjs/lib/api/tickets.ts)

| API | Method | Purpose | Input | Output |
|---|---|---|---|---|
| `/api/auth/register` | POST | Register a new user. | JSON body with registration payload. | `RegisterResponse` / auth payload. |
| `/api/auth/login` | POST | Authenticate and create a session. | JSON body with login credentials. | `LoginResponse` / auth payload. |
| `/api/auth/logout` | POST | Log out the current user. | Bearer token or session cookie. | Success message. |
| `/api/auth/refresh` | POST | Refresh the access token. | Refresh cookie/session handled by client. | `TokenRefreshResponse`. |
| `/api/auth/me` | GET | Fetch current user profile. | Bearer access token. | `User`. |
| `/api/auth/change-password` | POST | Change password. | JSON body with password payload. | Success message. |
| `/api/auth/profile` | PUT | Update profile details. | JSON body with profile payload. | Success message or updated profile. |
| `/api/user/languages` | GET | Fetch language portfolio. | Authenticated request. | `LanguagePortfolio`. |
| `/api/user/languages` | POST | Add a language to the portfolio. | `language_id`, `difficulty_level`. | `AddLanguageResponse`. |
| `/api/user/languages/{languageId}/progress` | GET | Fetch detailed topic progress. | Path param `languageId`. | `StudentProgressResponse`. |
| `/curriculum/all` | GET | Fetch full curriculum tree. | None. | `LanguageCurriculum[]`. |
| `/api/dashboard/summary?language_id=...` | GET | Dashboard summary for a language. | Query param `language_id`. | `DashboardSummary`. |
| `/api/user/mastery/{languageId}` | GET | Fetch mastery list for the language. | Path param `languageId`. | `MasteryData[]`. |
| `/api/transfer/active-boosts?language_id=...` | GET | Fetch active cross-language transfer boosts. | Query param `language_id`. | `TransferBoost[]`. |
| `/api/synergy/recent-bonuses?language_id=...&days=...` | GET | Fetch recent synergy bonuses. | Query params `language_id`, `days`. | `SynergyBonus[]`. |
| `/api/exam/start` | POST | Start an exam session. | `ExamStartRequest`. | `ExamStartResponse`. |
| `/api/exam/submit` | POST | Submit answers and finish the session. | `ExamSubmissionPayload`. | `ExamSubmissionResponse`. |
| `/api/exam/results/{sessionId}` | GET | Fetch exam results. | Path param `sessionId`. | `ExamResultsResponse`. |
| `/question-bank/select` | POST | Select questions for a session. | `SelectQuestionsRequest`. | `SelectQuestionsResponse`. |
| `/question-bank/poll/{sessionId}` | GET | Poll for more questions while the session is loading. | Path param `sessionId`. | `SelectQuestionsResponse`. |
| `/question-bank/session/{sessionId}` | DELETE | Close and clean up a question session. | Path param `sessionId`. | Empty success response. |
| `/api/sessions/history` | GET | Fetch session history. | Query params: `language_id`, `session_type`, `limit`, `offset`. | `SessionHistoryResponse`. |
| `/api/rl/recommend` | POST | Get RL-based learning recommendation. | `RecommendationRequest`. | `RecommendationResponse`. |
| `/api/rl/health` | GET | Check RL service health. | None. | `HealthStatusResponse`. |
| `/api/reports` | POST | Create a user question report. | Report payload. | `QuestionReport`. |
| `/api/reports/user?session_id=...` | GET | Fetch reports created by the current user. | Optional `session_id`. | `QuestionReport[]`. |
| `/api/admin/reports` | GET | Admin list of reports. | Query filters. | `ReportListResponse`. |
| `/api/admin/reports/stats` | GET | Admin report statistics. | None or filters. | `ReportStats`. |
| `/api/admin/reports/{reportId}/resolve` | PATCH | Mark a report as resolved. | Path param `reportId`. | Updated `QuestionReport`. |
| `/api/admin/reports/{reportId}/dismiss` | PATCH | Dismiss a report. | Path param `reportId`. | Updated `QuestionReport`. |
| `/api/admin/reports/{reportId}` | DELETE | Delete a report. | Path param `reportId`. | Empty success response. |
| `/api/admin/questions` | GET | List admin-manageable questions. | Query filters. | `AdminQuestionListResponse`. |
| `/api/admin/questions/{questionId}` | GET | Fetch a specific admin question. | Path param `questionId`. | `AdminQuestion`. |
| `/api/admin/questions/{questionId}` | PATCH | Update a question. | Patch payload. | `AdminQuestionUpdateResponse`. |
| `/api/admin/questions/{questionId}` | DELETE | Delete a question. | Path param `questionId`. | `AdminQuestionDeleteResponse`. |
| `/api/admin/questions/bulk-action` | POST | Run a bulk admin action on questions. | Bulk action payload. | `AdminBulkActionResponse`. |
| `/api/admin/questions/{questionId}/analytics` | GET | Fetch analytics for one question. | Path param `questionId`. | `AdminQuestionAnalytics`. |
| `/api/admin/questions/low-quality` | GET | Fetch low-quality question list. | Query param `limit`. | `AdminLowQualityQuestionsResponse`. |
| `/api/admin/users` | GET | List users for admin management. | Query filters. | `AdminUserListResponse`. |
| `/api/admin/users/{userId}/status` | PATCH | Update user status. | Path param `userId`, status payload. | `AdminUserStatusUpdateResponse`. |
| `/api/admin/users/{userId}` | PATCH | Update admin user fields. | Path param `userId`, update payload. | `AdminUserUpdateResponse`. |
| `/api/admin/users/{userId}/reset-password` | POST | Reset a user password. | Path param `userId`. | `AdminPasswordResetResponse`. |
| `/api/admin/users/{userId}` | DELETE | Delete a user. | Path param `userId`. | Success response. |
| `/api/admin/users/analytics` | GET | Fetch user analytics summary. | None. | `AdminUserAnalytics`. |
| `/api/admin/metrics/high-failure-questions` | GET | Questions with high failure rates. | Query filters. | `AdminHighFailureQuestionsResponse`. |
| `/api/admin/metrics/most-reported-questions` | GET | Questions with most reports. | Query filters. | `AdminMostReportedQuestionsResponse`. |
| `/api/admin/metrics/concept-time-stats` | GET | Time-spent statistics by concept. | Query filters. | `AdminConceptTimeStatsResponse`. |
| `/api/admin/metrics/error-pattern-trends` | GET | Error pattern trends over time. | Query filters. | `AdminErrorPatternTrendsResponse`. |
| `/api/tickets` | POST | Create a support ticket. | Ticket payload. | `Ticket`. |
| `/api/tickets/my` | GET | Fetch the current user’s tickets. | Query filters. | `Ticket[]`. |
| `/api/tickets/{ticketId}` | GET | Fetch ticket details. | Path param `ticketId`. | `TicketDetail`. |
| `/api/tickets/{ticketId}/messages` | POST | Add a message to a ticket. | Path param `ticketId`, message payload. | Success response. |
| `/api/tickets/admin/all` | GET | Admin ticket list. | Query filters. | `Ticket[]`. |
| `/api/tickets/admin/stats` | GET | Ticket statistics. | None. | `TicketStats`. |
| `/api/tickets/admin/{ticketId}/status` | PATCH | Change ticket status. | Path param `ticketId`, status payload. | Success response. |
| `/api/tickets/admin/{ticketId}/assign` | PATCH | Assign ticket to admin. | Path param `ticketId`, assignment payload. | Success response. |
| `/api/tickets/admin/{ticketId}` | DELETE | Delete a ticket. | Path param `ticketId`. | Success response. |

## Python Backend Server

Source files scanned:
- [server/Adaptive-Learning-Plateform-Backend/main.py](../server/Adaptive-Learning-Plateform-Backend/main.py)
- [server/Adaptive-Learning-Plateform-Backend/routers/auth_router.py](../server/Adaptive-Learning-Plateform-Backend/routers/auth_router.py)
- [server/Adaptive-Learning-Plateform-Backend/routers/admin_router.py](../server/Adaptive-Learning-Plateform-Backend/routers/admin_router.py)
- [server/Adaptive-Learning-Plateform-Backend/routers/analytics_router.py](../server/Adaptive-Learning-Plateform-Backend/routers/analytics_router.py)
- [server/Adaptive-Learning-Plateform-Backend/routers/code_execution_router.py](../server/Adaptive-Learning-Plateform-Backend/routers/code_execution_router.py)
- [server/Adaptive-Learning-Plateform-Backend/routers/dashboard_router.py](../server/Adaptive-Learning-Plateform-Backend/routers/dashboard_router.py)
- [server/Adaptive-Learning-Plateform-Backend/routers/question_bank_router.py](../server/Adaptive-Learning-Plateform-Backend/routers/question_bank_router.py)
- [server/Adaptive-Learning-Plateform-Backend/routers/reports_router.py](../server/Adaptive-Learning-Plateform-Backend/routers/reports_router.py)
- [server/Adaptive-Learning-Plateform-Backend/routers/rl_router.py](../server/Adaptive-Learning-Plateform-Backend/routers/rl_router.py)
- [server/Adaptive-Learning-Plateform-Backend/routers/tickets_router.py](../server/Adaptive-Learning-Plateform-Backend/routers/tickets_router.py)
- [server/Adaptive-Learning-Plateform-Backend/routers/user_languages_router.py](../server/Adaptive-Learning-Plateform-Backend/routers/user_languages_router.py)

| API | Method | Purpose | Input | Output |
|---|---|---|---|---|
| `/` | GET | Basic root health check. | None. | Service status object. |
| `/api/health` | GET | General backend health check. | None. | Health status object. |
| `/curriculum/all` | GET | Return the full curriculum JSON. | None. | Complete curriculum structure. |
| `/api/exam/start` | POST | Create a new exam session. | `ExamStartRequest` with authenticated user validation. | `ExamStartResponse`. |
| `/api/exam/submit` | POST | Submit exam results and update mastery. | `ExamSubmissionPayload`. | `MasteryUpdateResponse`. |
| `/api/exam/analysis/{session_id}` | GET | Return analysis data for a completed session. | Path param `session_id`. | Analysis payload. |
| `/api/exam/results/{session_id}` | GET | Return full session results. | Path param `session_id`. | Results payload. |
| `/api/sessions/history` | GET | Return a user’s session history. | Query params such as `language_id`, `session_type`, `limit`, `offset`. | Session history payload. |
| `/api/rl/state-vector` | POST | Generate a state vector for RL training/recommendation. | `StateVectorRequest`. | `StateVectorResponse`. |
| `/api/rl/recommend` | POST | Produce RL learning recommendation. | `RecommendationRequest`. | `RecommendationResponse`. |
| `/api/rl/health` | GET | Check RL subsystem health. | None. | `HealthStatusResponse`. |
| `/api/rl/strategies` | GET | List active RL strategies. | None. | Strategy list. |
| `/api/rl/history/{user_id}` | GET | Return RL history for a user. | Path param `user_id`. | History payload. |
| `/api/auth/register` | POST | Register a user and issue tokens. | `UserRegistrationPayload`. | `UserRegistrationResponse` plus refresh cookie. |
| `/api/auth/login` | POST | Authenticate a user and issue tokens. | `LoginRequest`. | `LoginResponse` plus refresh cookie. |
| `/api/auth/login/form` | POST | Swagger/UI form-based login. | `OAuth2PasswordRequestForm`. | `LoginResponse` plus refresh cookie. |
| `/api/auth/refresh` | POST | Refresh an access token using the refresh cookie. | Refresh cookie. | `TokenRefreshResponse`. |
| `/api/auth/me` | GET | Return current authenticated user profile. | Bearer token. | `UserProfile`. |
| `/api/auth/change-password` | POST | Change the current password. | `PasswordChangeRequest`. | `PasswordChangeResponse`. |
| `/api/auth/logout` | POST | Clear session state / logout. | Bearer token. | Success confirmation. |
| `/api/auth/profile` | PUT | Update user profile fields. | Profile update payload. | Updated profile or success response. |
| `/api/user/register` | POST | Alternate user registration endpoint used by some clients. | `UserRegistrationPayload`. | `UserRegistrationResponse`. |
| `/api/user/languages` | GET | Return language portfolio for current user. | Bearer token. | `LanguagePortfolioResponse`. |
| `/api/user/languages` | POST | Add a language to the user’s learning portfolio. | `AddLanguageRequest`. | `AddLanguageResponse`. |
| `/api/user/languages/{language_id}/progress` | GET | Return topic progress for a language. | Path param `language_id`. | Progress payload. |
| `/api/dashboard/summary` | GET | Return dashboard summary for a language. | Query param `language_id`. | `DashboardSummaryResponse`. |
| `/api/user/mastery/{language_id}` | GET | Return mastery rows for a language. | Path param `language_id`. | `MasteryData[]`. |
| `/api/transfer/active-boosts` | GET | Return active transfer boosts. | Query param `language_id`. | `TransferBoost[]`. |
| `/api/synergy/recent-bonuses` | GET | Return recent synergy bonuses. | Query params `language_id`, `days`. | `SynergyBonus[]`. |
| `/analytics/student/{user_id}/profile` | GET | Analyze a student’s learning profile. | Path param `user_id`, query param `language_id`. | Student profile analytics payload. |
| `/analytics/subtopic/{sub_topic}/errors` | GET | Analyze errors for a subtopic. | Path param `sub_topic`. | Error analytics payload. |
| `/analytics/student/{user_id}/cross-topic-analysis` | GET | Cross-topic learning analysis. | Path param `user_id`, query param `language_id`. | Cross-topic analysis payload. |
| `/analytics/student/{user_id}/recommendations` | GET | Learning recommendations for a student. | Path param `user_id`, query param `language_id`. | Recommendations payload. |
| `/analytics/class-insights` | GET | Aggregate class-level insights. | Query filters. | Class insights payload. |
| `/api/analytics/error-patterns` | GET | Error pattern analytics. | Query filters. | Error pattern payload. |
| `/api/progress/prediction` | GET | Predict progress over time. | Query filters. | Prediction payload. |
| `/question-bank/generate` | POST | Generate questions. | Generation request payload. | Generation response. |
| `/question-bank/select` | POST | Select questions for a session. | Selection request payload. | Selected questions response. |
| `/question-bank/poll/{session_id}` | GET | Poll for session question updates. | Path param `session_id`. | Selection response. |
| `/question-bank/session/{session_id}` | DELETE | Clean up a question session. | Path param `session_id`. | Success response. |
| `/question-bank/mark-seen` | POST | Mark generated questions as seen. | Request payload. | Success response. |
| `/question-bank/warehouse-status` | GET | Return question warehouse status. | None. | Warehouse status payload. |
| `/question-bank/admin/review` | POST | Submit admin review action. | Review payload. | Review response. |
| `/question-bank/admin/pending` | GET | Return pending review items. | Query filters. | Pending item list. |
| `/question-bank/admin/bulk-generate` | POST | Bulk-generate questions. | Bulk generation request payload. | Generation response. |
| `/question-bank/report` | POST | Report a question. | Report payload. | Report response. |
| `/question-bank/analytics/{question_id}` | GET | Analytics for a single question. | Path param `question_id`. | Analytics payload. |
| `/question-bank/analytics/summary` | GET | Aggregated question analytics summary. | Query filters. | Summary payload. |
| `/api/reports` | POST | Create a report. | `CreateQuestionReportRequest`. | `QuestionReportResponse`. |
| `/api/reports/user` | GET | Return reports created by the user. | Optional `session_id`. | `QuestionReportResponse[]`. |
| `/api/admin/reports` | GET | Admin report list. | Filters. | `ReportListResponse`. |
| `/api/admin/reports/stats` | GET | Report statistics. | None or filters. | `ReportStatsResponse`. |
| `/api/admin/reports/{report_id}/resolve` | PATCH | Resolve a report. | Path param `report_id`. | `QuestionReportResponse`. |
| `/api/admin/reports/{report_id}/dismiss` | PATCH | Dismiss a report. | Path param `report_id`. | `QuestionReportResponse`. |
| `/api/admin/reports/{report_id}` | DELETE | Delete a report. | Path param `report_id`. | No content. |
| `/api/tickets` | POST | Create a support ticket. | Ticket create payload. | `TicketResponse`. |
| `/api/tickets/my` | GET | List the current user’s tickets. | Query filters. | `TicketResponse[]`. |
| `/api/tickets/{ticket_id}` | GET | Fetch one ticket. | Path param `ticket_id`. | `TicketDetailResponse`. |
| `/api/tickets/{ticket_id}/messages` | POST | Add a ticket message. | Path param `ticket_id`, message payload. | `MessageResponse`. |
| `/api/tickets/admin/all` | GET | Admin ticket list. | Query filters. | `TicketResponse[]`. |
| `/api/tickets/admin/stats` | GET | Ticket statistics. | None. | `TicketStatsResponse`. |
| `/api/tickets/admin/{ticket_id}/status` | PATCH | Update ticket status. | Path param `ticket_id`, status payload. | Success response. |
| `/api/tickets/admin/{ticket_id}/assign` | PATCH | Assign ticket to an admin. | Path param `ticket_id`, assignment payload. | Success response. |
| `/api/tickets/admin/{ticket_id}` | DELETE | Delete a ticket. | Path param `ticket_id`. | No content. |
| `/api/code-execution/run` | POST | Run code through Judge0. | `CodeExecutionRequest`. | `CodeExecutionResponse`. |
| `/api/code-execution/validate-question` | POST | Validate a question against expected output. | Validation payload. | Validation response. |
| `/api/code-execution/health` | GET | Check code-execution service health. | None. | Health response. |
| `/api/admin/users` | GET | List users. | Filters. | Admin user list response. |
| `/api/admin/users/{user_id}/status` | PATCH | Change a user status. | Path param `user_id`, status payload. | Status update response. |
| `/api/admin/questions` | GET | List questions. | Filters. | Question list response. |
| `/api/admin/questions/low-quality` | GET | List low-quality questions. | Filters. | Low-quality response. |
| `/api/admin/questions/{question_id}` | GET | Fetch a question. | Path param `question_id`. | `AdminQuestion`. |
| `/api/admin/questions/{question_id}` | PATCH | Update a question. | Update payload. | Update response. |
| `/api/admin/questions/{question_id}` | DELETE | Delete a question. | Path param `question_id`. | Delete response. |
| `/api/admin/questions/bulk-action` | POST | Apply a bulk question action. | Bulk action payload. | Bulk action response. |
| `/api/admin/questions/{question_id}/analytics` | GET | Get analytics for one question. | Path param `question_id`. | Analytics response. |
| `/api/admin/metrics/high-failure-questions` | GET | High-failure analytics. | Filters. | High-failure response. |
| `/api/admin/metrics/most-reported-questions` | GET | Most-reported analytics. | Filters. | Most-reported response. |
| `/api/admin/metrics/concept-time-stats` | GET | Concept time statistics. | Filters. | Concept time stats response. |
| `/api/admin/metrics/error-pattern-trends` | GET | Error pattern trend analytics. | Filters. | Trend response. |
| `/api/admin/users/analytics` | GET | User analytics summary. | None. | User analytics response. |
| `/api/admin/users/{user_id}` | PATCH | Update a user. | Path param `user_id`, update payload. | Update response. |
| `/api/admin/users/{user_id}/reset-password` | POST | Reset a user password. | Path param `user_id`. | Reset response. |
| `/api/admin/users/{user_id}` | DELETE | Delete a user. | Path param `user_id`. | No content. |

## Quick Comparison

| Project | Main API Style | Notes |
|---|---|---|
| Flutter | Client calls to the backend REST API | Uses `AuthService`, `CourseService`, `DashboardService`, and `ExamService` as the network layer. |
| Next.js | Frontend API client wrapper | Exposes the same backend REST surface through TypeScript helper modules in `lib/api`. |
| Python server | FastAPI backend | Source of truth for most endpoints, auth, exams, analytics, admin, tickets, reports, and code execution. |

## Important Implementation Notes

- Authentication is token-based, with refresh tokens stored in an httpOnly cookie on the backend.
- Some endpoints are duplicated across the Flutter app and Next.js app because both clients consume the same backend.
- Several Python routes are mounted directly in `main.py`, while others live in dedicated router modules.
- For detailed request/response fields, use the corresponding client interfaces in Next.js or the Pydantic schema names in the Python backend.
