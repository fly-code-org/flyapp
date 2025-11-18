# Testing Login API Integration Guide

## 🧪 How to Test Login API Integration

### Method 1: Manual Testing in the App

#### Step 1: Run the App
```bash
flutter run
```

#### Step 2: Navigate to Register/Login Screen
- Open the register screen in your app
- Toggle to "Login" mode (if not already)

#### Step 3: Test Login
1. **Enter Test Credentials:**
   - Email: `sengar.workshopyy@gmail.com` (or any registered email)
   - Password: `Shaktiman@0` (or the correct password)

2. **Click "Log in" button**

3. **Observe the UI:**
   - ✅ Button should show loading spinner
   - ✅ Status message should appear (green for success, red for error)
   - ✅ On success, should navigate to home screen

#### Step 4: Check Console Logs
Look for these debug messages in your console:

```
🔐 Starting login process...
📧 Email: sengar.workshopyy@gmail.com
🚀 AuthController: Starting login API call
📧 Email: sengar.workshopyy@gmail.com
✅ Login API call successful
📨 Response message: [success message]
🎫 Token received: true
💾 Token saved to secure storage
🔧 API client updated with auth token
✅ Login successful!
🎫 Token stored: true
💾 Token in storage: true
🔑 Token preview: [first 20 chars]...
🏁 Login process completed
```

### Method 2: Using Flutter DevTools

1. **Open DevTools:**
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

2. **Connect to your running app**

3. **Check Network Tab:**
   - Look for POST request to `/users/external/v1/login`
   - Check request payload: `{"email": "...", "password": "..."}`
   - Check response: Should have `{"data": "token", "msg": "message"}`

4. **Check Logs Tab:**
   - See all the debug print statements

### Method 3: Verify Token Storage

#### Option A: Add a Debug Button (Temporary)
Add this to your screen temporarily:

```dart
ElevatedButton(
  onPressed: () async {
    final token = await _authController.getStoredToken();
    final isAuth = await _authController.isAuthenticated();
    print('🔍 Debug Check:');
    print('   Has Token: $isAuth');
    print('   Token: ${token ?? "null"}');
    Get.snackbar('Token Check', 'Has Token: $isAuth');
  },
  child: Text('Check Token'),
)
```

#### Option B: Use Terminal/Console
After login, check if token exists:

```dart
// In your code or debug console
final authController = Get.find<AuthController>();
final hasToken = await authController.isAuthenticated();
final token = await authController.getStoredToken();
print('Token exists: $hasToken');
print('Token: $token');
```

### Method 4: Test with Different Scenarios

#### ✅ Success Case
- Valid email and password
- Should return token and navigate

#### ❌ Error Cases
1. **Invalid Email:**
   - Email: `wrong@email.com`
   - Password: `anypassword`
   - Expected: Error message from API

2. **Wrong Password:**
   - Email: `sengar.workshopyy@gmail.com`
   - Password: `wrongpassword`
   - Expected: Error message from API

3. **Empty Fields:**
   - Leave email or password empty
   - Expected: Validation error message

4. **Network Error:**
   - Turn off internet
   - Expected: Network error message

### Method 5: Check API Client Logs

The `ApiClient` already has logging enabled. Check for:

```
Request: POST /users/external/v1/login
Headers: {Content-Type: application/json, ...}
Data: {email: ..., password: ...}
Response: 200 /users/external/v1/login
Data: {data: "...", msg: "..."}
```

### Method 6: Verify Token is Used in Future Requests

After successful login, make any authenticated API call and check:

1. **Request headers should include:**
   ```
   Authorization: Bearer [your_token]
   ```

2. **Check in ApiClient logs:**
   - The interceptor should automatically add the token

### Method 7: Test Logout

```dart
// After login, test logout
await _authController.logout();
final hasToken = await _authController.isAuthenticated();
// Should be false
```

## 🔍 What to Check

### ✅ Success Indicators:
1. ✅ Loading spinner appears during API call
2. ✅ Success message appears (green text)
3. ✅ Navigation happens (to home screen)
4. ✅ Token is stored in secure storage
5. ✅ Token is set in API client
6. ✅ Console shows success logs
7. ✅ No error messages

### ❌ Failure Indicators:
1. ❌ Error message appears (red text)
2. ❌ No navigation
3. ❌ Console shows error logs
4. ❌ Token not stored

## 🐛 Common Issues & Solutions

### Issue: "Connection timeout"
- **Solution:** Check internet connection
- **Solution:** Verify API base URL in `.env` file

### Issue: "Invalid response format"
- **Solution:** Check API response matches expected format
- **Solution:** Verify `AuthResponseModel.fromJson()` handles response correctly

### Issue: Token not stored
- **Solution:** Check `flutter_secure_storage` permissions
- **Solution:** Verify `TokenStorage.saveToken()` is called

### Issue: Navigation not working
- **Solution:** Check route name in `Get.offAllNamed('/')`
- **Solution:** Verify route exists in `AppPages.pages`

## 📝 Test Checklist

- [ ] Login with valid credentials works
- [ ] Loading state shows during API call
- [ ] Success message displays
- [ ] Navigation happens on success
- [ ] Token is stored securely
- [ ] Error handling works for invalid credentials
- [ ] Error handling works for network errors
- [ ] Validation works for empty fields
- [ ] Token is used in subsequent API calls
- [ ] Logout clears token

## 🎯 Quick Test Script

```dart
// Add this to a test button or run in debug console
Future<void> testLogin() async {
  final authController = Get.find<AuthController>();
  
  print('🧪 Testing Login API...');
  
  // Test login
  await authController.login(
    email: 'sengar.workshopyy@gmail.com',
    password: 'Shaktiman@0',
  );
  
  // Check results
  print('Loading: ${authController.isLoading.value}');
  print('Error: ${authController.errorMessage.value}');
  print('Message: ${authController.message.value}');
  print('Has Token: ${await authController.isAuthenticated()}');
  print('Token: ${await authController.getStoredToken()}');
}
```

---

**Note:** Remove debug print statements before production release, or use a proper logging package like `logger`.

