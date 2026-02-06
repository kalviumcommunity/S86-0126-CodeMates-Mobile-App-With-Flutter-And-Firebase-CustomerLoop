# Firebase Storage Setup Guide

## Current Issue
Your app is crashing when trying to upload images because **Firebase Storage is not enabled** in your Firebase project.

## Error Details
```
StorageException: Object does not exist at location.
Code: -13010 HttpResult: 404
The server has terminated the upload session
```

## Solution - Enable Firebase Storage (5 minutes)

### Step 1: Open Firebase Console
1. Go to: https://console.firebase.google.com/project/customerloop-4b038/storage
2. Or navigate manually:
   - Go to https://console.firebase.google.com
   - Select project: **customerloop-4b038**
   - Click **Storage** in the left sidebar

### Step 2: Enable Storage
1. Click the **"Get Started"** button
2. **Security Rules Dialog**:
   - Default rules will be shown
   - Click **"Next"**
3. **Choose Location**:
   - Select the same region as your Firestore database
   - Recommended: **us-central1** (or your current Firestore region)
   - Click **"Done"**
4. Wait 10-30 seconds for Storage to be enabled

### Step 3: Deploy Secure Storage Rules
After Storage is enabled, run this command to deploy the secure rules:

```bash
cd customerloop
firebase deploy --only storage
```

**Expected Output:**
```
✔ Deploy complete!

Project Console: https://console.firebase.google.com/project/customerloop-4b038/storage
```

### Step 4: Verify Storage is Working
1. **Hot Restart the App:**
   - Stop the current app (if running)
   - Run: `flutter run`
   - Or press `R` in the terminal for full restart

2. **Test Upload:**
   - Open the app
   - Go to Profile screen
   - Tap "Upload Profile Picture"
   - Select an image
   - ✅ Upload should now work!

## What Was Fixed

### 1. Created Storage Security Rules
File: `customerloop/storage.rules`

**Rules Created:**
- ✅ Profile images: Users can upload their own profile picture (max 5MB)
- ✅ Customer images: Authenticated users can upload (max 5MB)
- ✅ Product/Reward images: Authenticated users can upload (max 5MB)
- ✅ Public read access for profile images
- ✅ Authenticated read access for other folders

### 2. Added Error Handling
File: `lib/screens/profile_screen.dart`

**Changes:**
- ✅ Wrapped `_loadUserImages()` in try-catch blocks
- ✅ Graceful handling when Storage isn't set up
- ✅ User-friendly error messages
- ✅ Prevents app crashes when Storage is unavailable

### 3. Updated Firebase Configuration
File: `firebase.json`

**Added:**
```json
"storage": {
  "rules": "storage.rules"
}
```

## Storage Folder Structure

After setup, your uploads will be organized as:

```
customerloop-4b038.firebasestorage.app/
├── profile_images/
│   └── {userId}/
│       └── {timestamp}.jpg
├── customer_images/
│   └── {customerId}.jpg
├── product_images/
│   └── {productId}.jpg
├── reward_images/
│   └── {rewardId}.jpg
└── logos/
    └── {businessId}.jpg
```

## Troubleshooting

### Error: "Firebase Storage has not been set up"
**Solution:** Follow Step 2 above - Enable Storage in Firebase Console

### Error: "Permission denied"
**Solution:** 
1. Make sure you're logged in (authenticated)
2. Check if rules were deployed: `firebase deploy --only storage`
3. Verify rules in Console: https://console.firebase.google.com/project/customerloop-4b038/storage/rules

### Upload Still Failing After Setup
**Solution:**
1. Hot restart the app completely:
   ```bash
   flutter run
   ```
2. Check Firebase Console → Storage → Files to see if files are uploading
3. Check Firebase Console → Storage → Rules to verify rules are deployed

## Storage Rules Explanation

### Rule: Profile Images
```javascript
match /profile_images/{userId}/{allPaths=**} {
  allow read: if true; // Anyone can view profile pictures
  allow write: if isAuthenticated() 
               && request.auth.uid == userId  // Only owner can upload
               && isImage()                   // Must be an image
               && isValidSize();              // Max 5MB
}
```

### Rule: Other Images
```javascript
match /customer_images/{allPaths=**} {
  allow read: if isAuthenticated();  // Authenticated users can view
  allow write: if isAuthenticated()  // Authenticated users can upload
               && isImage()           // Must be an image
               && isValidSize();      // Max 5MB
}
```

## Testing Image Upload

### Via Profile Screen:
1. Open app → Go to Profile
2. Tap "Upload Profile Picture" or "Upload Business Logo"
3. Select image from gallery or take photo
4. See upload progress (0% → 100%)
5. Image appears in UI

### Via Firebase Console:
1. Go to https://console.firebase.google.com/project/customerloop-4b038/storage
2. Navigate to folders: `profile_images/`, `customer_images/`, etc.
3. See uploaded files with metadata

## Cost Information

### Firebase Storage Pricing (Free Tier):
- **Storage:** 5 GB free
- **Downloads:** 1 GB/day free
- **Uploads:** 20,000/day free

Your customer loyalty app should easily stay within free limits.

## Next Steps

1. ✅ Enable Firebase Storage (Step 1-2)
2. ✅ Deploy storage rules (Step 3)
3. ✅ Test image upload (Step 4)
4. 📸 Take screenshots for documentation
5. 🚀 Deploy Cloud Functions (if not done yet)

## Quick Commands

```bash
# Deploy storage rules only
firebase deploy --only storage

# Deploy everything (Storage + Functions)
firebase deploy

# View deployment status
firebase list

# Hot restart Flutter app
flutter run
```

## Support Links

- Firebase Storage Console: https://console.firebase.google.com/project/customerloop-4b038/storage
- Firebase Storage Docs: https://firebase.google.com/docs/storage
- Security Rules Guide: https://firebase.google.com/docs/storage/security

---

**Status:** ⚠️ **ACTION REQUIRED** - Enable Firebase Storage in Console (5 min)

After enabling Storage, your image uploads will work perfectly! 🎉
