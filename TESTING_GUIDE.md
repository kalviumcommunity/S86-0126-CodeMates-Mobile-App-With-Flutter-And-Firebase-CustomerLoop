# Testing Guide: Persistent Login Implementation

**Date:** February 3, 2026  
**Feature:** Auto-Login with Firebase Session Persistence  
**Status:** Ready for Testing

---

## Pre-Testing Checklist

- [ ] Flutter dependencies updated: `flutter pub get`
- [ ] App builds without errors: `flutter run`
- [ ] Firebase initialized successfully (check debug console)
- [ ] Valid test account created in Firebase Console
- [ ] Device/emulator has stable internet connection

---

## Test Scenario 1: Login & Auto-Navigation ✅

**Objective:** Verify that login automatically navigates to DashboardScreen

### Steps:
1. **Launch the app**
   - Expected: SplashScreen shows with loading indicator
   - Duration: ~1-2 seconds
   - Console: `⏳ Verifying user session...`

2. **Wait for auth check**
   - Expected: Auto-navigates to LoginScreen
   - Console: `❌ No active session - showing login screen`

3. **Enter valid credentials**
   - Email: `test@example.com` (or valid test account)
   - Password: Your test password

4. **Click "Login" button**
   - Expected: Briefly shows SplashScreen
   - Then: Auto-navigates to DashboardScreen
   - SnackBar: "Login successful!"
   - Console: `✅ Login successful - StreamBuilder will auto-navigate`

5. **Verify DashboardScreen displays**
   - Should show: Customer list, stats, dashboard content
   - Should NOT have shown manual navigation animation

**Result:** ✅ PASS if auto-navigation occurs without manual screen tap

---

## Test Scenario 2: Logout & Auto-Navigation ✅

**Objective:** Verify that logout automatically navigates to LoginScreen

### Steps:
1. **From DashboardScreen, locate logout button**
   - Usually top-right corner (depends on UI)
   - Icon: Logout/Sign out icon

2. **Tap logout button**
   - Expected: Brief processing moment
   - SnackBar: "Logged out successfully!"
   - Console: `✅ Logout successful - StreamBuilder will auto-navigate`

3. **Verify navigation to LoginScreen**
   - Expected: Auto-navigates to LoginScreen
   - Should NOT require manual navigation
   - Should NOT show DashboardScreen anymore

4. **Try clicking back button**
   - Expected: Cannot go back to DashboardScreen
   - Session is truly cleared

**Result:** ✅ PASS if auto-navigation occurs without manual steps

---

## Test Scenario 3: Session Persistence After Close & Reopen ✅

**Objective:** Verify auto-login works after closing and reopening the app

### Steps:
1. **Login to the app** (from Test Scenario 1)
   - Verify you're on DashboardScreen
   - Console: `✅ User logged in: test@example.com`

2. **Close the app completely**
   - Android: Back button multiple times OR swipe app from recent
   - iOS: Swipe up from bottom or use multitasking
   - Make sure app is force-closed, not just backgrounded

3. **Wait 5 seconds**
   - Allow Firebase tokens to be saved to device storage

4. **Reopen the app**
   - Tap app icon from home screen
   - Do NOT use recent apps (to ensure fresh launch)

5. **Watch the sequence**
   - Expected: SplashScreen shows
   - Console: `⏳ Verifying user session...`
   - Duration: ~2-3 seconds (Firebase validating token)

6. **Verify auto-navigation**
   - Expected: Auto-navigates to DashboardScreen
   - User should be logged in
   - Console: `✅ User logged in: test@example.com`

7. **Verify data is intact**
   - Customers visible
   - Dashboard stats loaded
   - No login screen shown

**Result:** ✅ PASS if auto-login occurs without user input

**Critical:** This proves Firebase session persistence is working!

---

## Test Scenario 4: Session Cleared After Logout & Reopen ✅

**Objective:** Verify that logging out properly clears session

### Steps:
1. **From Test Scenario 2, you should be at LoginScreen**
   - Already logged out

2. **Close and reopen the app**
   - Same as Test Scenario 3

3. **Watch the sequence**
   - Expected: SplashScreen shows
   - Expected: Auto-navigates to LoginScreen
   - Console: `❌ No active session - showing login screen`

4. **Verify login is required**
   - Cannot access dashboard without login
   - Must enter credentials again

**Result:** ✅ PASS if logout properly clears session

---

## Test Scenario 5: Sign Up & Auto-Navigation ✅

**Objective:** Verify that signup automatically navigates after account creation

### Steps:
1. **From LoginScreen, click "Sign Up" or "Create Account"**
   - Expected: Navigation to SignupScreen

2. **Fill signup form**
   - Name: Test User
   - Email: `newtest@example.com` (unique email)
   - Password: Valid password (8+ chars)
   - Confirm Password: Same password

3. **Click "Sign Up" button**
   - Expected: Brief processing
   - Validation occurs
   - SnackBar: "Account created successfully!"

4. **Verify auto-navigation**
   - Expected: Auto-navigates to DashboardScreen
   - Console: `✅ Signup successful - StreamBuilder will auto-navigate`
   - New user is now logged in

5. **Close and reopen**
   - Should still be logged in to new account
   - Session persisted

**Result:** ✅ PASS if signup auto-navigates and session persists

---

## Test Scenario 6: Multiple Restarts (Stress Test) ✅

**Objective:** Verify consistency across multiple app restarts

### Steps:
1. **Login to account**
   - Verify DashboardScreen

2. **Close and reopen app (3x)**
   - Restart 1: DashboardScreen? ✅
   - Restart 2: DashboardScreen? ✅
   - Restart 3: DashboardScreen? ✅

3. **Logout**
   - Verify LoginScreen

4. **Close and reopen app (3x)**
   - Restart 1: LoginScreen? ✅
   - Restart 2: LoginScreen? ✅
   - Restart 3: LoginScreen? ✅

**Result:** ✅ PASS if behavior is consistent across all restarts

---

## Test Scenario 7: Invalid Credentials ✅

**Objective:** Verify error handling for invalid login

### Steps:
1. **From LoginScreen, enter invalid credentials**
   - Email: `nonexistent@example.com`
   - Password: `wrongpassword`

2. **Click "Login"**
   - Expected: Error SnackBar shows
   - Message: "No user found for that email." or similar
   - Should NOT navigate (user still on LoginScreen)

3. **Verify you're still on LoginScreen**
   - Can try again with correct credentials
   - No broken state

**Result:** ✅ PASS if error is shown and user stays on LoginScreen

---

## Test Scenario 8: Network Connectivity (Optional) ⚠️

**Objective:** Verify behavior with poor/no network

### Steps:
1. **Turn OFF internet connection**
   - Airplane mode OR disable WiFi

2. **Restart app**
   - Expected: SplashScreen shows for longer (~5-10 seconds)
   - Reason: Firebase timeout waiting for network

3. **Result depends on Firebase behavior:**
   - May show timeout error
   - May fall back to cached session
   - May navigate to LoginScreen

4. **Turn ON internet**
   - Try login again
   - Should work normally once network is available

**Result:** Note the behavior for offline scenarios

---

## Console Logging Guide

Watch for these messages:

### ✅ Expected Logs:
```
🚀 CustomerLoop App Starting...
🔥 Initializing Firebase...
✅ Firebase initialized successfully
📱 Launching app...
🔍 Auth State Check - Connection: ConnectionState.waiting
⏳ Verifying user session...
✅ User logged in: test@example.com
(or)
❌ No active session - showing login screen
```

### ❌ Error Logs to Watch For:
```
Firebase initialization failed
Auth state error
Stream error in StreamBuilder
```

If you see error logs, debugging may be needed.

---

## Screenshots to Capture

For documentation, capture:

1. **SplashScreen**
   - App showing loading indicator
   - Logo and "Verifying your session..." text

2. **Auto-Login Sequence**
   - SplashScreen → DashboardScreen (no manual tap)
   - Timestamp shows immediate transition

3. **Auto-Logout Sequence**
   - DashboardScreen → LoginScreen after logout click
   - Logout button → Auto-navigate (no manual tap)

4. **Closed App Reopening**
   - Close app notification
   - Reopen from home screen
   - SplashScreen → DashboardScreen (auto-login)

---

## Quick Checklist

| Test | Scenario | Expected Result | Status |
|------|----------|-----------------|--------|
| 1 | Login | Auto-navigate to Dashboard | [ ] |
| 2 | Logout | Auto-navigate to Login | [ ] |
| 3 | Close & Reopen (Logged In) | Auto-login to Dashboard | [ ] |
| 4 | Close & Reopen (Logged Out) | Stay at Login | [ ] |
| 5 | Sign Up | Auto-navigate to Dashboard | [ ] |
| 6 | Multiple Restarts | Consistent behavior | [ ] |
| 7 | Invalid Credentials | Show error, stay on Login | [ ] |
| 8 | SplashScreen Shows | During session verification | [ ] |

---

## Troubleshooting

### Problem: Always shows LoginScreen after restart
**Cause:** Session tokens expired or invalid  
**Solution:** 
- Clear app cache: Settings → Apps → CustomerLoop → Clear Cache
- Logout and login again
- Check Firebase Console for user status

### Problem: SplashScreen doesn't show
**Cause:** Firebase initialization too fast or skipped  
**Solution:**
- Increase SplashScreen timeout
- Check internet connection
- Verify Firebase initialization in main.dart

### Problem: Manual navigation still happening
**Cause:** Old code still in place, or changes not saved  
**Solution:**
- Clean build: `flutter clean && flutter pub get`
- Rebuild: `flutter run`
- Verify main.dart has StreamBuilder
- Check LoginScreen doesn't have Navigator.pushReplacement()

### Problem: Logout doesn't navigate to LoginScreen
**Cause:** authStateChanges() not detecting logout  
**Solution:**
- Verify logout() in AuthService calls _auth.signOut()
- Check Firebase signOut() works: `debugPrint` in logout method
- Rebuild and test again

### Problem: Infinite loading/SplashScreen
**Cause:** Firebase auth check hanging  
**Solution:**
- Check internet connection
- Verify Firebase project is active
- Check Firebase Console for errors
- Add timeout to StreamBuilder (advanced)

---

## Success Criteria

✅ **Test passes when:**
- SplashScreen shows on app launch
- Auto-login works after app restart
- Auto-logout works after logout button
- Sign up auto-navigates
- Error handling shows SnackBars
- Console logs are correct
- No manual navigation needed

✅ **All 8 test scenarios should PASS**

---

## Notes for Testers

1. **Use a real device or Android Emulator** (iOS Simulator may not persist tokens correctly in some cases)

2. **Clear app data between test runs** if you want to test "logged out" state
   - Settings → Apps → CustomerLoop → Storage → Clear Cache & Clear Data

3. **Check Firebase Console** to verify users are created
   - Firebase Console → Authentication → Users
   - Look for your test accounts

4. **Network is important** - Firebase needs to verify tokens
   - Use WiFi or mobile data
   - Airplane mode may cause issues

5. **Keep internet stable** during testing
   - Switching networks during auth may cause issues
   - Wait for app to fully load before closing

---

## Reporting Results

When reporting test results, include:

1. ✅ Which test scenarios passed
2. ❌ Which test scenarios failed
3. 🖼️ Screenshots of key moments
4. 📝 Console log output
5. 📱 Device info: OS version, device model
6. 🌐 Network type: WiFi, 4G, etc.
7. 💭 Any unusual observations

---

**Once all tests pass, the assignment is ready for submission!** 🎉

