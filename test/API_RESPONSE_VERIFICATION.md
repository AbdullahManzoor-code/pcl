# API Response Verification Guide

**Purpose**: Verify that login/registration API responses are correctly implemented and parsed in the Flutter app

**Status**: ✅ Ready for Testing  
**Date**: May 26, 2026  
**Backend URL**: https://traditional-honest-request-are.trycloudflare.com//api

---

## Console Logging Added

Comprehensive debug logging has been added to `AuthService` to track all API requests and responses. Console output will show:

```
🔐 LOGIN: Sending POST /auth/login for user@example.com
🔐 LOGIN RESPONSE: Status 200
🔐 LOGIN RESPONSE: Body {...}
✅ LOGIN SUCCESS: Got access token eyJhbGc...
✅ LOGIN RESPONSE DATA: access_token, token_type, user_id, email, last_active_language, is_admin, status
✅ LOGIN USER PARSED: ID=uuid, Email=user@example.com
```

---

## Test Cases

### Test 1: Login with Invalid Credentials ❌

**Expected Behavior**: 
- Error message shown to user
- No navigation
- No data stored

**Steps**:
1. Start Flutter app: `flutter run`
2. App opens to login screen
3. Enter invalid email: `invalid@test.com`
4. Enter invalid password: `WrongPassword123`
5. Tap "Sign In"

**Console Output Expected**:
```
🔐 LOGIN: Sending POST /auth/login for invalid@test.com
🔐 LOGIN RESPONSE: Status 401
❌ LOGIN ERROR: Invalid credentials
```

**User Sees**:
- Snackbar: "Login Failed - Invalid credentials"
- Remains on login screen

---

### Test 2: Login with Valid Credentials ✅

**Expected Behavior**:
- User data retrieved and stored
- Access token saved in memory
- Navigate to main screen
- Console shows successful parsing of all response fields

**Steps**:
1. Start Flutter app
2. Enter valid email: `test@example.com` (or your test account)
3. Enter password: `TestPassword123`
4. Tap "Sign In"

**Console Output Expected**:
```
🔐 LOGIN: Sending POST /auth/login for test@example.com
🔐 LOGIN RESPONSE: Status 200
🔐 LOGIN RESPONSE: Body {"access_token":"eyJhbGc...","token_type":"bearer","user_id":"...","email":"test@example.com","last_active_language":"python_3","is_admin":false,"status":"active"}
✅ LOGIN SUCCESS: Got access token eyJhbGc...
✅ LOGIN RESPONSE DATA: access_token, token_type, user_id, email, last_active_language, is_admin, status
✅ LOGIN USER PARSED: ID=uuid-here, Email=test@example.com
```

**Response Parsing Verification**:
- ✅ `access_token` extracted and stored in memory (`_accessToken`)
- ✅ `user_id` mapped to User.id
- ✅ `email` mapped to User.email
- ✅ `last_active_language` stored
- ✅ `is_admin` boolean flag stored
- ✅ `status` field stored

**User Sees**:
- Brief loading state
- Snackbar: "Logged in successfully"
- Navigates to Main/Dashboard screen

**GetStorage Data Persisted** (verify in app code):
```dart
storage.write('isLoggedIn', true);          // ✅
storage.write('userEmail', user.email);     // ✅
storage.write('userName', user.name ?? 'User');  // ✅
storage.write('userId', user.id);           // ✅
storage.write('userLanguage', user.lastActiveLanguage);  // ✅
```

---

### Test 3: Registration with Minimal Fields ✅

**Expected Behavior**:
- Registration succeeds with only email and password
- Optional language and experience level skipped
- User created in backend
- Auto-login after registration

**Steps**:
1. From login screen, tap "Sign Up"
2. Enter full name: `Test User`
3. Enter email: `newuser@example.com`
4. Enter password: `SecurePass123!`
5. Confirm password: `SecurePass123!`
6. Skip language selection (leave as "None")
7. Skip experience level (leave as "None")
8. Accept terms checkbox
9. Tap "Create Account"

**Console Output Expected**:
```
📝 REGISTER: Sending POST /auth/register for newuser@example.com
📝 REGISTER: Language=null, Level=null
📝 REGISTER RESPONSE: Status 201
📝 REGISTER RESPONSE: Body {"user_id":"...","message":"User created successfully","starting_topic":"Variables and Data Types","experience_level":null,"access_token":"eyJhbGc...","token_type":"bearer"}
✅ REGISTER SUCCESS: Got access token eyJhbGc...
✅ REGISTER RESPONSE DATA: user_id, message, starting_topic, experience_level, access_token, token_type
✅ REGISTER USER PARSED: ID=uuid-here, Email=null
```

**Response Parsing Verification**:
- ✅ `user_id` extracted and stored
- ✅ `access_token` stored in memory
- ✅ `message` logged (registration confirmation)
- ✅ `starting_topic` available for UI (can show recommended course)
- ✅ `experience_level` captured (may be null if not provided)

**User Sees**:
- Brief loading state
- Snackbar: "Account created successfully"
- Navigates to Assessment screen

---

### Test 4: Registration with Language Selection ✅

**Expected Behavior**:
- Language preference sent to backend
- Backend returns experience_level and starting_topic based on selection
- User preferences stored for future personalization

**Steps**:
1. From login screen, tap "Sign Up"
2. Enter full name: `Python Learner`
3. Enter email: `python@example.com`
4. Enter password: `SecurePass123!`
5. Confirm password: `SecurePass123!`
6. **Select Language: "python_3"**
7. Leave experience level as "None"
8. Accept terms
9. Tap "Create Account"

**Console Output Expected**:
```
📝 REGISTER: Sending POST /auth/register for python@example.com
📝 REGISTER: Language=python_3, Level=null
📝 REGISTER RESPONSE: Status 201
📝 REGISTER RESPONSE: Body {"user_id":"...","message":"...","starting_topic":"Python Basics","experience_level":null,"access_token":"...","token_type":"bearer"}
✅ REGISTER SUCCESS: Got access token eyJhbGc...
✅ REGISTER RESPONSE DATA: user_id, message, starting_topic, experience_level, access_token, token_type
```

**Verify GetStorage Saved**:
```dart
storage.write('userLanguage', 'python_3');
storage.write('userExperienceLevel', null);
```

---

### Test 5: Registration with Language + Experience Level ✅

**Expected Behavior**:
- Both preferences sent to backend
- Backend tailors starting_topic based on experience level
- All preferences saved for future personalization

**Steps**:
1. From login screen, tap "Sign Up"
2. Enter full name: `Advanced Developer`
3. Enter email: `advanced@example.com`
4. Enter password: `SecurePass123!`
5. Confirm password: `SecurePass123!`
6. **Select Language: "javascript_es6"**
7. **Select Experience Level: "advanced"**
8. Accept terms
9. Tap "Create Account"

**Console Output Expected**:
```
📝 REGISTER: Sending POST /auth/register for advanced@example.com
📝 REGISTER: Language=javascript_es6, Level=advanced
📝 REGISTER RESPONSE: Status 201
📝 REGISTER RESPONSE: Body {"user_id":"...","message":"...","starting_topic":"Advanced ES6 Patterns","experience_level":"advanced","access_token":"...","token_type":"bearer"}
✅ REGISTER SUCCESS: Got access token eyJhbGc...
```

**Verify GetStorage Saved**:
```dart
storage.write('userLanguage', 'javascript_es6');
storage.write('userExperienceLevel', 'advanced');
```

---

### Test 6: Logout ✅

**Expected Behavior**:
- Logout API call made to backend
- Local token cleared from memory
- All user data removed from storage
- Redirect to login screen

**Steps**:
1. After successful login, navigate to main/dashboard
2. Find logout button (check navigation menu)
3. Tap logout

**Console Output Expected**:
```
🚪 LOGOUT: Logging out user
✅ LOGOUT: API call successful
✅ LOGOUT: Local data cleared
```

**Verify**:
- Redirects to login screen
- Pressing back doesn't show previous screens (proper logout)
- GetStorage cleared: `isLoggedIn=false`, no user data

---

## Response Fields Verification Checklist

### Login Response (POST /auth/login)
- [ ] `access_token` - Stored in memory (`_accessToken`)
- [ ] `token_type` - Logged (should be "bearer")
- [ ] `user_id` - Parsed to User.id
- [ ] `email` - Parsed to User.email
- [ ] `last_active_language` - Parsed to User.lastActiveLanguage
- [ ] `is_admin` - Parsed to User.isAdmin
- [ ] `status` - Parsed to User.status

### Registration Response (POST /auth/register)
- [ ] `user_id` - Parsed to User.id
- [ ] `message` - Logged for confirmation
- [ ] `starting_topic` - Can be used to recommend first course
- [ ] `experience_level` - Stored in GetStorage
- [ ] `access_token` - Stored in memory
- [ ] `token_type` - Logged (should be "bearer")

### Profile Response (GET /auth/me)
- [ ] `id` - Parsed to User.id
- [ ] `email` - Parsed to User.email
- [ ] `last_active_language` - Parsed to User.lastActiveLanguage
- [ ] `total_exams_taken` - Parsed to User.totalExamsTaken
- [ ] `created_at` - Parsed to User.createdAt (DateTime)

---

## API Request/Response Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ LOGIN FLOW                                                    │
├─────────────────────────────────────────────────────────────┤
│ User Input                                                    │
│ ├─ Email: test@example.com                                   │
│ └─ Password: TestPassword123                                 │
│                ↓                                              │
│ AuthService.login(email, password)                           │
│                ↓                                              │
│ 🔐 HTTP POST /api/auth/login                               │
│ {                                                             │
│   "email": "test@example.com",                               │
│   "password": "TestPassword123"                              │
│ }                                                             │
│                ↓                                              │
│ Backend Response (200 OK)                                     │
│ {                                                             │
│   "access_token": "eyJhbGc...",                              │
│   "token_type": "bearer",                                    │
│   "user_id": "550e8400-e29b-41d4-a716-446655440000",       │
│   "email": "test@example.com",                               │
│   "last_active_language": "python_3",                        │
│   "is_admin": false,                                         │
│   "status": "active"                                         │
│ }                                                             │
│                ↓                                              │
│ AuthService Parse Response:                                  │
│ • Store access_token in memory (_accessToken)                │
│ • Create User from response via convertLoginResponse()       │
│ • Merge with mock data via ApiAdapterService                 │
│                ↓                                              │
│ GetStorage Persist:                                          │
│ • isLoggedIn: true                                           │
│ • userEmail: test@example.com                                │
│ • userId: 550e8400-...                                       │
│ • userLanguage: python_3                                     │
│                ↓                                              │
│ AuthController Finish:                                       │
│ • Show success snackbar                                      │
│ • Navigate to main screen                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Debugging Tips

### View Console Logs
Run app with verbose logging:
```bash
flutter run -v 2>&1 | grep -E "🔐|📝|✅|❌|👤|🔄|🚪"
```

### Check GetStorage Data
Add this to onInit of any controller to see stored data:
```dart
final storage = GetStorage();
print('=== GetStorage ===');
print('isLoggedIn: ${storage.read('isLoggedIn')}');
print('userEmail: ${storage.read('userEmail')}');
print('userId: ${storage.read('userId')}');
print('userLanguage: ${storage.read('userLanguage')}');
```

### Verify Access Token
Add this in AuthService:
```dart
if (kDebugMode) print('🔑 Current Access Token: ${_accessToken?.substring(0, 50)}...');
```

### Test with curl
```bash
# Login test
curl -X POST https://traditional-honest-request-are.trycloudflare.com//api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"TestPassword123"}'

# Register test
curl -X POST https://traditional-honest-request-are.trycloudflare.com//api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"newuser@example.com","password":"SecurePass123!","language_id":"python_3","experience_level":"beginner"}'
```

---

## Expected Test Results

| Test | Expected | Status |
|------|----------|--------|
| Invalid login | Error shown | 🟢 Pending |
| Valid login | User data stored, navigate | 🟢 Pending |
| Register (minimal) | Account created, auto-login | 🟢 Pending |
| Register (with language) | Language saved | 🟢 Pending |
| Register (with level) | Level saved | 🟢 Pending |
| Logout | Session cleared | 🟢 Pending |

---

## Common Issues & Solutions

### Issue: "Login request timeout"
**Cause**: Network connectivity or backend down  
**Solution**: 
- Check internet connection
- Verify backend: `curl https://traditional-honest-request-are.trycloudflare.com//api/health`
- Check firewall/VPN settings

### Issue: "No access token available" when calling getMe()
**Cause**: AuthService not initialized or token not stored  
**Solution**:
- Verify login completed successfully
- Check console for "✅ LOGIN SUCCESS" message
- Verify `_accessToken` is not null

### Issue: User data not persisting after app restart
**Cause**: GetStorage not working or wrong keys  
**Solution**:
- Check GetStorage initialization in main.dart
- Verify console shows "Storage initialized"
- Use debugger to inspect GetStorage values

### Issue: Response parsing errors
**Cause**: API response format doesn't match code expectations  
**Solution**:
- Check console for full response body
- Verify response has expected fields
- Compare with API documentation

---

## Files Modified for Logging

- `lib/app/data/services/auth_service.dart` - Added console logging for all auth methods
- `lib/app/data/models/user_model.dart` - Response parsing factories (no changes needed)
- `lib/app/data/services/api_adapter_service.dart` - Response conversion (no changes needed)

---

## Next Steps After Verification

Once all tests pass:
1. **Remove debug logging** (optional) for production build
2. **Proceed to Task 1.4** - Token Management & Auto-Refresh
3. **Task 1.5** - Session Persistence & Auto-Login
4. **Task 1.8** - Logout verification (already implemented ✅)

---

## Summary

This document provides:
- ✅ 6 comprehensive test cases
- ✅ Console output examples for each test
- ✅ Response field verification checklist
- ✅ Debugging tips and curl commands
- ✅ Common issues and solutions

**Status**: Ready for manual testing by developer
