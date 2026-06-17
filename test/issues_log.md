# Issues & Blockers Log

## Active Issues

### Issue #0: Backend Connectivity Verification
- **Status**: ✅ Resolved
- **Severity**: 🔴 CRITICAL
- **Component**: Backend API
- **Description**: Verify backend accessibility and API structure
- **URL**: https://traditional-honest-request-are.trycloudflare.com//api
- **Date Reported**: May 26, 2026
- **Last Updated**: May 26, 2026
- **Resolution**: ✅ Backend verified running (HTTP 200 on /api/health endpoint)

---

### Issue #1: User Data Model Mismatch
- **Status**: ✅ Resolved
- **Severity**: 🟠 HIGH
- **Component**: Authentication / User Model
- **Description**: Flutter mock API uses different user data structure than Next.js real API
- **Resolved With**:
  - ✅ Updated User model to support both real API fields (id, email, last_active_language, etc.) and mock fields (name, bio, stats)
  - ✅ Created ApiAdapterService to merge real API responses with mock data
  - ✅ Updated mock API login to return real API response format + mock fields
  - ✅ Implemented UserStats.defaultMock() for stats when not provided by real API
  - ✅ Added User.mergeWithMockData() to combine real API user with mock data
- **Files Modified**:
  - [user_model.dart](../lib/app/data/models/user_model.dart) - Added real API fields
  - [api_adapter_service.dart](../lib/app/data/services/api_adapter_service.dart) - NEW adapter service
  - [mock_api_service.dart](../lib/app/data/services/mock_api_service.dart) - Updated login response
- **Impact**: ✅ Flutter UI now receives both real API user data AND mock stats seamlessly
- **Completed By**: Task 1.2 - Implement Login Service
- **Date Reported**: May 26, 2026
- **Date Resolved**: May 26, 2026

---

### Issue #2: Missing Next.js Authentication Endpoints
- **Status**: 🟡 In Progress
- **Severity**: 🟡 MEDIUM
- **Component**: Authentication
- **Description**: Some authentication features from mock API aren't in Next.js API analysis yet
- **Missing Features**:
  - [ ] Social login (Google, GitHub, etc.)
  - [ ] Password reset with email verification
  - [ ] Two-factor authentication
  - [ ] Admin user detection
  - [ ] Account status handling (active/inactive/suspended)
- **Assigned To**: Task 1.1 - Complete API analysis
- **Date Reported**: May 26, 2026
- **Last Updated**: May 26, 2026
- **Action**: Need to verify if these features exist in Next.js backend or are future enhancements 

---

## Issue Tracking Template

### Issue #{N}: [Title]
- **Status**: 🟡 Open / 🟢 In Progress / 🔵 Resolved / 🔴 Blocked
- **Severity**: 🔴 CRITICAL / 🟠 HIGH / 🟡 MEDIUM / 🟢 LOW
- **Component**: [Auth/Courses/Exams/Results/Other]
- **Description**: [Detailed description]
- **Error Message**: [If applicable]
- **Steps to Reproduce**: [If applicable]
- **Assigned To**: [Name]
- **Date Reported**: [Date]
- **Last Updated**: [Date]
- **Resolution**: [Solution/Workaround]

---

## Resolved Issues

(None yet)

---

## Blocked Tasks

(None yet)

---

## Known Limitations

1. **Mock API Dependencies**
   - Current system relies entirely on mock API
   - Real API endpoints may have different data structures
   - Gradual migration required

---

## Risk Assessment

### High Priority Risks
- [ ] Backend API incompatibility with Flutter client
- [ ] Data model mismatch between mock and real API
- [ ] Authentication method differences

### Medium Priority Risks
- [ ] Network/Performance issues
- [ ] Error handling differences
- [ ] Rate limiting

### Low Priority Risks
- [ ] UI adjustments needed
- [ ] Documentation gaps
- [ ] Testing coverage

---

## Investigation Checklist

- [ ] Verify backend is running and accessible
- [ ] Document all API endpoints
- [ ] Check response formats
- [ ] Test authentication flow
- [ ] Verify data models match
- [ ] Check error responses
- [ ] Test pagination
- [ ] Verify performance

---

## Communication Log

| Date | Issue | Contact | Resolution |
|------|-------|---------|-----------|
| | | | |

---

## Notes
- Document all discovered issues immediately
- Link issues to specific tasks in api_integration_plan.md
- Update severity as new information emerges
- Close issues only when fully tested in production
