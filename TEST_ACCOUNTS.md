# Test Accounts for Development

Your app now includes hardcoded test accounts that you can use to test authentication without Firebase errors.

## Available Test Accounts:

### 1. Test User
- **Email**: `test@example.com`
- **Password**: `password123`
- **Display Name**: Test User

### 2. Admin User  
- **Email**: `admin@example.com`
- **Password**: `admin123`
- **Display Name**: Admin User

### 3. Student User
- **Email**: `student@example.com`
- **Password**: `student123`
- **Display Name**: Student User

## How to Use:

1. **Sign Up**: Use any of the above email/password combinations
2. **Sign In**: Use the same credentials to sign in
3. **Password Validation**: The system will check passwords for test accounts

## Notes:

- Test mode is currently **ENABLED** in `AuthService`
- To switch back to Firebase: Set `_useTestMode = false` in `auth_service.dart`
- These accounts bypass all Firebase authentication
- Perfect for testing your app's UI and flow without Firebase issues

## Testing Authentication Flow:

1. Try signing up with `test@example.com` / `password123`
2. Try signing in with the same credentials
3. Test with wrong password to see error handling
4. Test your app's authenticated user experience

Happy testing! 🚀
