# Analytics and Practice Route Documentation

This document explains how the Analytics page and Practice/Test flow are connected from the Next.js frontend to the FastAPI backend. It is written as a handoff guide for a co-developer who needs to understand the full route, data, and state flow.

## 1. High-Level Architecture

The frontend is a Next.js app. The backend is a FastAPI API running separately, usually on port `8000`.

Frontend requests are made to same-origin paths such as `/api/dashboard/summary`, `/question-bank/select`, and `/curriculum/all`. Next.js proxies these requests to FastAPI through `next.config.ts`.

```ts
// next.config.ts
const BACKEND_URL = process.env.BACKEND_URL || "";
```

Proxy rules:

| Frontend path | Backend destination |
| --- | --- |
| `/api/:path*` | `${BACKEND_URL}/api/:path*` |
| `/question-bank/:path*` | `${BACKEND_URL}/question-bank/:path*` |
| `/curriculum/:path*` | `${BACKEND_URL}/curriculum/:path*` |

So when the frontend calls:

```ts
getDashboardSummary("python_3")
```

it becomes:

```http
GET /api/dashboard/summary?language_id=python_3
```

and Next.js proxies it to:

```http
GET /api/dashboard/summary?language_id=python_3
```

## 2. Authentication and API Client

Shared frontend API helpers are in:

```txt
lib/api/client.ts
```

The API client uses a hybrid auth approach:

| Auth item | Storage |
| --- | --- |
| Access token | In memory |
| Refresh token | HTTP-only cookie |

The request flow is:

1. If the request is not an auth endpoint and no access token is available, the client calls `POST /api/auth/refresh`.
2. If refresh succeeds, the access token is stored in memory.
3. The original request is sent with:

```http
Authorization: Bearer <access_token>
```

4. Cookies are always sent using:

```ts
credentials: "include"
```

5. If the backend returns `401`, the API client tries refresh once and retries the original request.
6. If refresh fails, the user is redirected to `/login`.

Most analytics and practice APIs require `get_current_active_user` on the backend, so the user must be logged in.

## 3. Analytics Route Overview

Frontend page:

```txt
app/analytics/page.tsx
```

Supporting API file:

```txt
lib/api/dashboard.ts
```

Backend route file:

```txt
backend/routers/dashboard_router.py
```

The Analytics page is protected:

```tsx
<ProtectedRoute>
  <AnalyticsContent />
</ProtectedRoute>
```

This means unauthenticated users should be redirected before analytics data is loaded.

## 4. Analytics Frontend Flow

When `/analytics` opens:

1. The page checks `localStorage.selectedLanguage`.
2. If not found, it falls back to `user.last_active_language`.
3. If no language is available, the user is redirected to:

```txt
/onboarding/language
```

4. It loads the user's language portfolio using:

```ts
getLanguagePortfolio()
```

5. It builds the language dropdown from portfolio data plus supported languages.
6. Once `currentLanguage` is set, it loads analytics data.

Main frontend state:

| State | Purpose |
| --- | --- |
| `currentLanguage` | Selected programming language, for example `python_3` |
| `languageOptions` | Dropdown language choices |
| `synergyWindowDays` | Time window for recent synergy bonuses |
| `masteryData` | Heatmap-ready mastery map |
| `recentSessions` | Recent practice/exam sessions |
| `transferBoostCount` | Number of active cross-language boosts |
| `synergyBonusCount` | Number of recent synergy bonuses |
| `isLoading` | Shows loading state |
| `error` | Shows retryable error state |

## 5. Analytics API Calls

`app/analytics/page.tsx` calls three backend APIs in parallel using `Promise.allSettled`.

```ts
const [summaryResult, transferResult, synergyResult] = await Promise.allSettled([
  getDashboardSummary(currentLanguage),
  getActiveTransferBoosts(currentLanguage),
  getRecentSynergyBonuses(currentLanguage, synergyWindowDays),
]);
```

These functions are defined in:

```txt
lib/api/dashboard.ts
```

| Frontend function | Backend endpoint | Purpose |
| --- | --- | --- |
| `getDashboardSummary(language_id)` | `GET /api/dashboard/summary?language_id=...` | Main analytics data |
| `getUserMastery(language_id)` | `GET /api/user/mastery/{language_id}` | Simplified mastery list |
| `getActiveTransferBoosts(language_id)` | `GET /api/transfer/active-boosts?language_id=...` | Cross-language transfer insights |
| `getRecentSynergyBonuses(language_id, days)` | `GET /api/synergy/recent-bonuses?language_id=...&days=...` | Recently applied topic synergy bonuses |

## 6. Dashboard Summary Backend Behavior

Endpoint:

```http
GET /api/dashboard/summary?language_id=python_3
```

Backend function:

```py
get_dashboard_summary()
```

File:

```txt
backend/routers/dashboard_router.py
```

Backend steps:

1. Reads the current authenticated user from the JWT token.
2. Generates the user's state vector using `StateVectorGenerator`.
3. Extracts `mastery_breakdown` from state vector metadata.
4. Applies time decay to mastery.
5. Builds decay alerts if mastery has dropped significantly.
6. Gets an RL recommendation using `get_rl_service()`.
7. Checks whether the RL-recommended topic is accessible based on prerequisites.
8. If the RL topic is locked, it falls back to the first accessible incomplete topic.
9. Loads the 5 most recent completed sessions from `exam_sessions`.
10. Returns one combined response.

Response shape:

```ts
type DashboardSummary = {
  mastery_data: MasteryData[];
  decay_alerts: DecayAlert[];
  recommendation: RecommendedTopic | null;
  recent_sessions: RecentSession[];
};
```

Important backend tables used:

| Table | Purpose |
| --- | --- |
| `student_state` | Mastery, confidence, fluency, last practiced data |
| `exam_sessions` | Completed session history |
| `user_question_history` | Question counts and previous question usage |

## 7. Analytics UI Mapping

The backend returns raw API data. The page converts it for UI components:

| Backend data | Frontend mapping | UI component |
| --- | --- | --- |
| `mastery_data` | `mapMasteryForHeatmap()` | `MasteryHeatmap` |
| `recent_sessions` | `mapSessionsForTimeline()` | `RecentSessions` |
| transfer boosts | `.length` | Cross-language insight stat |
| synergy bonuses | `.length` | Synergy insight stat |

The Analytics page also computes stats:

| Stat | Source |
| --- | --- |
| Concepts practiced | Count of mastery entries |
| Average mastery | Average `mastery` |
| Average fluency | Average `fluency` |
| Average confidence | Average `confidence` |
| Total sessions | Count of recent sessions |
| Average score | Average recent session score |

## 8. Analytics to Practice Navigation

Analytics is connected to practice through UI actions:

```tsx
<MasteryHeatmap
  onConceptClick={(conceptId) => router.push(`/practice?concept=${conceptId}`)}
/>
```

```tsx
<RecentSessions
  onPracticeAgain={(conceptId, subTopic) =>
    router.push(`/practice?concept=${conceptId}&subtopic=${encodeURIComponent(subTopic)}`)
  }
/>
```

Important caveat:

`app/practice/page.tsx` currently reads `concept`, `mode`, `difficulty`, and `rl_action_id` from the URL. It does not currently consume `subtopic`, even though Analytics sends it from recent sessions.

## 9. Practice Route Overview

Frontend page:

```txt
app/practice/page.tsx
```

Supporting API files:

```txt
lib/api/curriculum.ts
lib/api/exam.ts
```

Backend files:

```txt
backend/main.py
backend/routers/question_bank_router.py
backend/services/grading_service.py
```

The practice route is also protected:

```tsx
<ProtectedRoute>
  <Suspense>
    <PracticeContent />
  </Suspense>
</ProtectedRoute>
```

## 10. Practice URL Parameters

The practice page reads:

| Query param | Example | Purpose |
| --- | --- | --- |
| `concept` | `UNIV_LOOP` | Preselects a curriculum concept |
| `mode` | `exam` | Forces exam/review/practice flow |
| `difficulty` | `0.65` | Preselects target difficulty |
| `rl_action_id` | `12` | Links an exam session to an RL recommendation/action |

Example:

```txt
/practice?concept=UNIV_LOOP&mode=exam&difficulty=0.65&rl_action_id=12
```

Mode behavior:

| Condition | Allowed mode |
| --- | --- |
| Direct `/practice` | Practice |
| `mode=exam` | Exam only |
| `mode=review` | Review only |

## 11. Practice Frontend Flow

When `/practice` opens:

1. Reads `localStorage.selectedLanguage`.
2. If missing, redirects to `/onboarding/language`.
3. Loads curriculum using:

```ts
getCurriculum()
```

4. Reads URL params and preselects concept/difficulty/mode if available.
5. Lets user choose:

| Control | State |
| --- | --- |
| Concept | `selectedConcept` |
| Difficulty slider | `difficulty` |
| Question count | `questionCount` |
| Mode | `mode` |

6. On start, it creates a backend exam/practice session.

## 12. Curriculum Loading

Frontend:

```txt
lib/api/curriculum.ts
```

Function:

```ts
getCurriculum()
```

Backend:

```http
GET /curriculum/all
```

Backend file:

```txt
backend/main.py
```

The backend reads:

```txt
backend/core/final_curriculum.json
```

and returns all language roadmaps.

Helper functions:

| Function | Purpose |
| --- | --- |
| `getTopicsForLanguage(curriculum, languageId)` | Gets roadmap topics for selected language |
| `getTopicByMappingId(curriculum, languageId, mappingId)` | Finds a topic by universal mapping id |
| `getLanguageName(curriculum, languageId)` | Finds display language name |

Note:

`getCurriculum()` uses raw `fetch('/curriculum/all', { credentials: 'include' })` instead of the shared `apiClient`. That means it does not use the same automatic refresh/error formatting path as `lib/api/client.ts`.

## 13. Starting a Practice Session

When the user clicks Start, `handleStartPractice()` runs in:

```txt
app/practice/page.tsx
```

It validates:

1. A concept is selected.
2. `currentLanguage` exists.
3. `user.id` exists.
4. The selected concept can be mapped to a curriculum topic.

Then it builds:

```ts
const payload = {
  user_id: user.id,
  language_id: currentLanguage,
  major_topic_id: topic.major_topic_id,
  session_type: mode,
  rl_action_id: mode === "exam" ? rlActionId : undefined,
};
```

Frontend function:

```ts
startExamSession(payload)
```

Backend endpoint:

```http
POST /api/exam/start
```

Backend function:

```py
start_exam_session()
```

Backend behavior:

1. Verifies `payload.user_id` matches the authenticated user.
2. Generates a UUID `session_id`.
3. Inserts a new row into `exam_sessions`.
4. Sets `session_status = 'started'`.
5. Stores `rl_action_taken` if provided.
6. Returns `session_id` and `started_at`.

Database write:

```sql
INSERT INTO exam_sessions (
  id,
  user_id,
  language_id,
  major_topic_id,
  session_type,
  session_status,
  rl_action_taken,
  started_at,
  created_at
)
```

## 14. Local Session State

After `/api/exam/start` succeeds, the frontend stores the session config:

```ts
localStorage.setItem("currentSession", JSON.stringify({
  session_id,
  mapping_id: selectedConcept,
  major_topic_id: topic.major_topic_id,
  concept_name: topic.name,
  difficulty,
  question_count: questionCount,
  mode,
  language_id: currentLanguage,
}));
```

Then it navigates to:

```txt
/test/{session_id}
```

This localStorage record is important because the test page uses it to know which questions to request.

## 15. Test Route Overview

Frontend page:

```txt
app/test/[id]/page.tsx
```

Backend question route:

```txt
backend/routers/question_bank_router.py
```

The test route:

1. Reads `session_id` from URL params.
2. Reads `currentSession` from localStorage.
3. If missing, redirects back to `/practice`.
4. Calls the question bank selector.

## 16. Question Selection

Frontend function:

```ts
selectQuestions(request)
```

Backend endpoint:

```http
POST /question-bank/select
```

Request shape:

```ts
{
  user_id: string;
  session_id: string;
  language_id: string;
  mapping_id: string;
  target_difficulty: number;
  count: number;
  difficulty_tolerance: number;
  mode: "practice" | "exam" | "review";
  seen_ratio: number;
}
```

The frontend sends:

| Field | Value |
| --- | --- |
| `user_id` | Logged-in user's id |
| `session_id` | Session from `/api/exam/start` |
| `language_id` | From `currentSession` |
| `mapping_id` | Selected universal concept id |
| `target_difficulty` | Selected difficulty |
| `count` | Selected question count |
| `difficulty_tolerance` | `0.1` |
| `mode` | Practice/exam/review |
| `seen_ratio` | Practice `0.4`, review `0.2`, exam `0` |

Backend selection behavior:

1. Creates a `QuestionSelector`.
2. If mode is `review`, checks whether review is due or mastery is below maintenance threshold.
3. Selects questions using a waterfall strategy:
   - verified unseen questions
   - unverified unseen questions
   - verified seen questions as fallback
4. Tracks delivered question IDs in memory under `active_sessions[session_id]`.
5. Checks warehouse status.
6. If mode is `practice` or `exam` and fewer questions are available than requested, starts background generation.
7. Returns questions immediately, even if the full requested count is not ready yet.

Response shape:

```ts
{
  questions: QuestionResponse[];
  total_selected: number;
  total_requested: number;
  more_questions_loading: boolean;
  warehouse_status: Record<string, unknown>;
}
```

## 17. Background Question Generation and Polling

If the question warehouse is low, backend starts background generation.

Generation function:

```py
_background_generate()
```

It uses:

| Service | Purpose |
| --- | --- |
| `OpenAIFactory` | Generates questions using the LLM |
| `MultiLanguageValidator` | Validates and hashes question content |
| `JSONLBackup` | Writes backup copy of generated questions |
| `QuestionBank` model | Saves questions in DB |

Questions with `quality_score >= 0.70` are auto-approved by setting:

```py
is_verified = True
```

Frontend polling:

```ts
pollNewQuestions(sessionId)
```

Backend endpoint:

```http
GET /question-bank/poll/{session_id}
```

Polling behavior:

1. Looks up the active selection session from backend memory.
2. Selects questions again using the same parameters.
3. Filters out questions already delivered.
4. Adds new question IDs to `active_sessions[session_id].delivered_ids`.
5. Returns only newly available questions.
6. Keeps `more_questions_loading = true` while generation is still running.

Frontend behavior:

| Condition | UI behavior |
| --- | --- |
| Some questions returned immediately | Show test and poll in background |
| Zero questions returned but loading | Show generation/loading screen |
| New questions found during polling | Append to current test |
| Polling ends with no questions | Show error state |

The frontend polls every 2 seconds, up to roughly 3 minutes.

## 18. Closing Question Loading Session

After submission, frontend calls:

```ts
closeQuestionSession(sessionId)
```

Backend endpoint:

```http
DELETE /question-bank/session/{session_id}
```

This removes the in-memory `active_sessions` entry for that test. It is a cleanup endpoint.

## 19. Answer Tracking on Test Page

The test page tracks:

| State | Purpose |
| --- | --- |
| `questions` | Questions loaded from backend |
| `answers` | User-selected options |
| `questionTimeSpent` | Time spent per question |
| `currentQuestion` | Current UI index |
| `timeLeft` | Test timer |
| `isSubmitting` | Submission loading state |

Timer rules:

| Mode | Timer |
| --- | --- |
| `exam` | `question_count * 90` seconds |
| `practice` / `review` | `question_count * 180` seconds |

If the timer expires, the page force-submits.

## 20. Submitting a Practice/Test Session

Frontend function:

```ts
submitExam(payload)
```

Backend endpoint:

```http
POST /api/exam/submit
```

The test page builds `results` from every question:

```ts
{
  q_id,
  sub_topic,
  difficulty,
  is_correct,
  selected_choice,
  correct_choice,
  time_spent,
  expected_time,
  error_type,
  question_text,
  code_snippet,
  options,
  explanation
}
```

Submission payload:

```ts
{
  user_id,
  session_id,
  language_id,
  major_topic_id,
  session_type,
  results,
  total_time_seconds
}
```

Backend function:

```py
submit_exam()
```

Backend validation:

1. `payload.user_id` must match authenticated user.
2. `session_id` must exist.
3. Session must belong to that user.
4. Session status must still be `started`.

If valid, backend sends the payload to:

```py
GradingService.process_submission()
```

## 21. Grading Service Side Effects

File:

```txt
backend/services/grading_service.py
```

`process_submission()` does the main learning update work:

1. Calculates accuracy.
2. Calculates fluency ratio.
3. Detects soft gate/prerequisite violations.
4. Updates mastery, fluency, and confidence.
5. Applies synergy bonuses when accuracy is at least 70%.
6. Applies cross-language transfer bonuses where available.
7. Updates `exam_sessions` from `started` to `completed`.
8. Saves question snapshots in `exam_details`.
9. Records question history for exam mode.
10. Schedules spaced review for the topic.
11. Marks review complete if this was a review session.
12. Generates recommendations.
13. Commits the transaction.
14. Starts background exam analysis if background tasks are available.

Important database writes:

| Table | What is written |
| --- | --- |
| `student_state` | Updated mastery, fluency, confidence, last practiced |
| `exam_sessions` | Score, difficulty, time taken, completed status |
| `exam_details` | Question snapshot and recommendations |
| `user_question_history` | Seen question history for future selection |
| review schedule tables | Review due/completed scheduling |

Important caveat:

`user_question_history` is recorded by `GradingService` only when `session_type` is not `practice` and not `review`. This means exam mode affects future unseen-question filtering more strongly than practice/review mode.

## 22. Results Navigation

After submit succeeds:

1. Frontend closes the question-bank session with:

```http
DELETE /question-bank/session/{session_id}
```

2. Frontend navigates to:

```txt
/results/{session_id}
```

Results endpoint:

```http
GET /api/exam/results/{session_id}
```

Backend returns:

| Field | Purpose |
| --- | --- |
| `overall_score` / `accuracy` | Final score |
| `questions` | Snapshot of answered questions |
| `strong_topics` | Topics with strong performance |
| `error_patterns` | Mistake categories and explanations |
| `recommendations` | Learning resources/recommendations |
| `analysis_status` | LLM analysis state |
| `analysis_bullets` | Generated feedback bullets |
| `prerequisite_gaps` | Optional phase 2 prerequisite data |
| `overall_readiness` | Optional readiness value |

## 23. Backend Route Summary

| Route | Method | Frontend caller | Backend file | Purpose |
| --- | --- | --- | --- | --- |
| `/curriculum/all` | GET | `getCurriculum()` | `backend/main.py` | Loads curriculum roadmap |
| `/api/dashboard/summary` | GET | `getDashboardSummary()` | `dashboard_router.py` | Main analytics data |
| `/api/user/mastery/{language_id}` | GET | `getUserMastery()` | `dashboard_router.py` | Mastery list |
| `/api/transfer/active-boosts` | GET | `getActiveTransferBoosts()` | `dashboard_router.py` | Transfer insights |
| `/api/synergy/recent-bonuses` | GET | `getRecentSynergyBonuses()` | `dashboard_router.py` | Synergy insight count |
| `/api/exam/start` | POST | `startExamSession()` | `backend/main.py` | Creates started session |
| `/question-bank/select` | POST | `selectQuestions()` | `question_bank_router.py` | Selects/generates questions |
| `/question-bank/poll/{session_id}` | GET | `pollNewQuestions()` | `question_bank_router.py` | Gets newly generated questions |
| `/question-bank/session/{session_id}` | DELETE | `closeQuestionSession()` | `question_bank_router.py` | Cleans active question session |
| `/api/exam/submit` | POST | `submitExam()` | `backend/main.py` | Grades and updates mastery |
| `/api/exam/results/{session_id}` | GET | `getExamResults()` | `backend/main.py` | Loads final result page data |

## 24. End-to-End Practice Flow

```txt
User opens /practice
  -> ProtectedRoute checks auth
  -> Reads selectedLanguage from localStorage
  -> GET /curriculum/all
  -> User selects concept/difficulty/count/mode
  -> POST /api/exam/start
  -> Backend inserts exam_sessions row with status started
  -> Frontend stores currentSession in localStorage
  -> Frontend navigates to /test/{session_id}
  -> Test page reads currentSession
  -> POST /question-bank/select
  -> Backend selects existing questions
  -> If warehouse low, backend starts background LLM generation
  -> Frontend shows questions or loading screen
  -> GET /question-bank/poll/{session_id} until enough/new questions arrive
  -> User answers questions
  -> POST /api/exam/submit
  -> Backend grades, updates mastery, saves details, schedules review
  -> DELETE /question-bank/session/{session_id}
  -> Frontend navigates to /results/{session_id}
  -> GET /api/exam/results/{session_id}
```

## 25. End-to-End Analytics Flow

```txt
User opens /analytics
  -> ProtectedRoute checks auth
  -> Reads selectedLanguage or user.last_active_language
  -> Loads language portfolio
  -> GET /api/dashboard/summary?language_id=...
  -> GET /api/transfer/active-boosts?language_id=...
  -> GET /api/synergy/recent-bonuses?language_id=...&days=...
  -> Maps mastery_data into heatmap data
  -> Maps recent_sessions into timeline data
  -> Computes stat cards
  -> User clicks a concept
  -> Navigates to /practice?concept={mapping_id}
```

## 26. Developer Notes and Caveats

1. The backend must be running on `` unless `BACKEND_URL` is changed.

4. Analytics uses `Promise.allSettled`, so one failed analytics request does not automatically cancel all others.
5. `/practice?subtopic=...` is currently generated from Analytics recent sessions, but Practice does not read/use the `subtopic` param yet.
6. Question generation is asynchronous. The test UI must handle partial question availability.
7. `active_sessions` and `active_generation_tasks` in `question_bank_router.py` are in-memory. They reset when the backend restarts.
8. `getCurriculum()` does not currently use the shared API client, so its error/refresh behavior is different from `/api/*` calls.
9. Review mode can be blocked by the backend if the selected topic is not due and mastery is above the maintenance threshold.
10. Exam submission is one-time per started session. If the same session is submitted again, backend returns an error like `Session already completed`.

## 27. Local Run Commands

Backend:

```powershell
cd D:\Projects\fyp\backend
uvicorn main:app --reload
```

Frontend:

```powershell
cd D:\Projects\fyp
npm run dev
```

Expected local URLs:

```txt
Frontend: http://localhost:3000
Backend:  
Swagger:  /api/docs
```

