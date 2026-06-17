# Flutter API Mapping: Mock → Real

## Current Mock API Structure

### Mock Service Location
- **File**: `/lib/app/data/services/mock_api_service.dart`
- **Status**: ✅ Analyzed (May 26, 2026)

## Service Methods to Migrate

### Authentication Services
| Mock Method | Real Endpoint | Response | Status | Notes |
|-------------|---------------|----------|--------|-------|
| `login(email, password)` | POST /auth/login | `{ access_token, user_id, email, is_admin, status }` | [ ] | Returns JWT token |
| `socialLogin(provider)` | Not in Next.js | N/A | [ ] | Need to verify if required |
| `sendPasswordReset(email)` | Not found | N/A | [ ] | Need to investigate |
| `resetPassword(password)` | Not found | N/A | [ ] | Need to investigate |

### Course Services
| Mock Method | Real Endpoint | Status | Notes |
|-------------|---------------|--------|-------|
| `mockGetCourses()` | GET /courses | [ ] | Not yet analyzed |
| `mockGetCourseDetail()` | GET /courses/:id | [ ] | Not yet analyzed |
| `mockEnrollCourse()` | POST /courses/:id/enroll | [ ] | Not yet analyzed |
| `mockGetEnrolledCourses()` | GET /user/courses | [ ] | Not yet analyzed |

### Exam Services
| Mock Method | Real Endpoint | Status | Notes |
|-------------|---------------|--------|-------|
| `mockGetExams()` | GET /exams | [ ] | Not yet analyzed |
| `mockGetExamDetail()` | GET /exams/:id | [ ] | Not yet analyzed |
| `mockRegisterExam()` | POST /exams/:id/register | [ ] | Not yet analyzed |
| `mockStartExam()` | POST /exams/:id/start | [ ] | Not yet analyzed |
| `mockGetQuestions()` | GET /exams/:id/questions | [ ] | Not yet analyzed |
| `mockSubmitAnswer()` | POST /exams/:id/submit-answer | [ ] | Not yet analyzed |
| `mockSubmitExam()` | POST /exams/:id/submit | [ ] | Not yet analyzed |

### Result Services
| Mock Method | Real Endpoint | Status | Notes |
|-------------|---------------|--------|-------|
| `mockGetResults()` | GET /results | [ ] | Not yet analyzed |
| `mockGetResultDetail()` | GET /results/:id | [ ] | Not yet analyzed |

### User Services
| Mock Method | Real Endpoint | Status | Notes |
|-------------|---------------|--------|-------|
| `mockGetProfile()` | GET /auth/me | [ ] | Not yet analyzed |
| `mockUpdateProfile()` | PUT /auth/profile | [ ] | Language & experience level only |
| `mockGetNotifications()` | GET /user/notifications | [ ] | Not yet analyzed |

## Data Model Mapping

### User Model
**Mock Data**:
```dart
{
  'name': 'Mian',
  'email': 'mian@example.com',
  'profile_pic': null,
  'bio': 'Passionate coder and Flutter enthusiast.',
  'stats': {
    'consecutive_days': 15,
    'total_hours': 30,
    'completed_courses': 2,
    'total_xp': 12500,
    'today_points': 8,
    'today_minutes': 12,
  },
}
```
**Real API Response (Login)**:
```json
{
  "access_token": "string",
  "token_type": "bearer",
  "user_id": "string",
  "email": "string",
  "last_active_language": "string | null",
  "is_admin": boolean,
  "status": "active|inactive|suspended"
}
```
**Real API Response (Get Profile - /auth/me)**:
```json
{
  "id": "string",
  "email": "string",
  "last_active_language": "string | null",
  "total_exams_taken": number,
  "created_at": "ISO timestamp"
}
```
**Differences**:
- ⚠️ Mock has 'name', real API only has 'email'
- ⚠️ Mock has 'stats' object, real API has 'total_exams_taken'
- ✅ 'email' field present in both
- ✅ 'last_active_language' field in both

### Course Model
**Status**: [ ] To be analyzed after authentication phase

### Exam Model
**Status**: [ ] To be analyzed after authentication phase

### Question Model
**Status**: [ ] To be analyzed after authentication phase

## API Response Differences

### Pagination
**Mock Implementation**: 
- [ ] Document current approach

**Real API Expected**: 
- [ ] Document expected approach

### Error Handling
**Mock Implementation**: 
- [ ] Document current error format

**Real API Expected**: 
- [ ] Document expected error format

## Service Files to Create/Modify

- [ ] `/lib/app/data/services/auth_service.dart`
- [ ] `/lib/app/data/services/course_service.dart`
- [ ] `/lib/app/data/services/exam_service.dart`
- [ ] `/lib/app/data/services/result_service.dart`
- [ ] `/lib/app/data/services/user_service.dart`
- [ ] `/lib/app/data/services/api_client.dart` (HTTP wrapper)

## Configuration Changes

### Environment Variables
```dart
// To be added to .env or config
const String PROD_API_URL = 'https://traditional-honest-request-are.trycloudflare.com//api';
const String DEV_API_URL = 'http://localhost:3000/api';
```

### HTTP Client Setup
- [ ] Add Dio/HTTP package
- [ ] Configure interceptors
- [ ] Implement error handling middleware
- [ ] Add request/response logging

## Testing Strategy

### Unit Tests
- [ ] Mock API responses
- [ ] Test data transformation
- [ ] Error handling

### Integration Tests
- [ ] Test against real backend
- [ ] Validate response times
- [ ] Test error scenarios

### End-to-End Tests
- [ ] Full user workflows
- [ ] Authentication flow
- [ ] Exam taking flow

## Rollback Plan

### If Issues Found
1. Keep mock service as fallback
2. Implement feature flag for real/mock switch
3. Document any incompatibilities
4. Create issue tickets for backend fixes

## Notes
- Compare mock and real implementations carefully
- Document all data transformations
- Create unit tests for each mapping
