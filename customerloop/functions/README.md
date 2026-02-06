# Firebase Cloud Functions - CustomerLoop

This directory contains serverless functions for the CustomerLoop application.

## 📂 Structure

```
functions/
├── index.js          # Main functions file
├── package.json      # Node.js dependencies
├── .gitignore        # Git ignore rules
└── node_modules/     # Installed packages (auto-generated)
```

## 🚀 Functions Overview

### Callable Functions

#### 1. sayHello
**Type**: HTTPS Callable  
**Purpose**: Personalized greeting for demonstrating callable functions

**Input**:
```javascript
{
  name: string  // Optional, defaults to "User"
}
```

**Output**:
```javascript
{
  message: string,           // "Hello, {name}! Welcome to CustomerLoop 🎉"
  timestamp: Timestamp,      // Server timestamp
  success: boolean          // true
}
```

**Example Call from Flutter**:
```dart
final callable = FirebaseFunctions.instance.httpsCallable('sayHello');
final result = await callable.call({'name': 'Alex'});
print(result.data['message']);
```

---

#### 2. calculatePoints
**Type**: HTTPS Callable  
**Purpose**: Calculate loyalty points based on purchase amount

**Business Rules**:
- 1 point per $10 spent
- 2x multiplier for purchases over $100

**Input**:
```javascript
{
  amount: number  // Purchase amount in dollars
}
```

**Output**:
```javascript
{
  points: number,           // Calculated points
  purchaseAmount: number,   // Original amount
  bonusApplied: boolean,    // true if amount > $100
  message: string          // Status message
}
```

**Examples**:
- $50 purchase → 5 points
- $100 purchase → 10 points
- $150 purchase → 30 points (15 × 2 = 30)

---

### Event-Triggered Functions

#### 3. onNewCustomer
**Type**: Firestore onCreate Trigger  
**Trigger Path**: `customers/{customerId}`  
**Purpose**: Automatically initialize new customer accounts

**Automatic Actions**:
1. Assigns default loyalty tier: "Bronze"
2. Adds 10 welcome bonus points
3. Sets account creation timestamp
4. Marks account as active
5. Increments shop owner's total customer count
6. Updates shop owner's last customer timestamp

**No Flutter Code Needed**: Runs automatically when a new customer document is created!

**Example Trigger**:
```dart
// When you create a customer in Firestore...
await FirebaseFirestore.instance.collection('customers').add({
  'name': 'John Doe',
  'phone': '1234567890',
  'shopOwnerId': 'owner123',
});
// The function runs automatically! 🎉
```

---

#### 4. onCustomerVisit
**Type**: Firestore onCreate Trigger  
**Trigger Path**: `visits/{visitId}`  
**Purpose**: Track customer visits and award milestone bonuses

**Automatic Actions**:
1. Increments customer's visit count
2. Updates last visit timestamp
3. Checks for milestone achievements:
   - 5th visit → 25 bonus points 🎉
   - 10th visit → 50 bonus points 🌟
   - 25th visit → 100 bonus points 🏆
4. Awards bonus points if milestone reached
5. Records milestone achievement

---

### HTTP Functions

#### 5. healthCheck
**Type**: HTTPS onRequest (HTTP GET)  
**Purpose**: Verify Cloud Functions deployment and status

**Endpoint**: `https://[region]-[project-id].cloudfunctions.net/healthCheck`

**Response**:
```json
{
  "status": "healthy",
  "message": "CustomerLoop Cloud Functions are running! 🚀",
  "timestamp": "2026-02-06T12:00:00.000Z",
  "functions": [
    "sayHello (callable)",
    "calculatePoints (callable)",
    "onNewCustomer (firestore trigger)",
    "onCustomerVisit (firestore trigger)",
    "healthCheck (http)"
  ]
}
```

---

## 🛠️ Setup & Deployment

### Prerequisites
- Node.js 18 or higher
- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase project with Blaze plan (pay-as-you-go)

### Installation
```bash
cd customerloop/functions
npm install
```

### Deploy All Functions
```bash
# From customerloop/ directory
firebase deploy --only functions
```

### Deploy Specific Function
```bash
firebase deploy --only functions:sayHello
firebase deploy --only functions:calculatePoints
```

---

## 🧪 Testing

### Local Testing with Emulator
```bash
# Install emulator
firebase init emulators

# Start emulator
firebase emulators:start

# Functions available at:
# http://localhost:5001/[project-id]/us-central1/[functionName]
```

### Test Callable Functions
```bash
# Using curl
curl -X POST https://us-central1-[project-id].cloudfunctions.net/sayHello \
  -H "Content-Type: application/json" \
  -d '{"data": {"name": "Test User"}}'
```

### View Logs
```bash
# Real-time logs
firebase functions:log --only sayHello

# All function logs
firebase functions:log
```

---

## 📊 Monitoring

### Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Functions**
4. View:
   - Deployed functions
   - Execution count
   - Error rate
   - Memory usage
   - Execution time

### Logs
```javascript
// In function code
console.log('Info message');
console.error('Error message');
console.warn('Warning message');
```

View in Firebase Console → Functions → Logs

---

## 💰 Pricing

### Free Tier (Spark Plan)
- ❌ Cloud Functions not available
- Need Blaze plan (pay-as-you-go)

### Blaze Plan Free Quota (Monthly)
- ✅ 2 million invocations
- ✅ 400,000 GB-seconds compute time
- ✅ 200,000 CPU-seconds
- ✅ 5 GB outbound networking

### Beyond Free Quota
- $0.40 per million invocations
- $0.0000025 per GB-second
- $0.00001 per CPU-second

**Example Cost**:
- 5 million invocations/month
-  Average 200ms execution @ 256MB memory
- **Cost**: ~$2.50/month

Most small apps stay within free tier! 🎉

---

## 🔐 Security

### Authentication
```javascript
// Check if user is authenticated
if (context.auth) {
  const userId = context.auth.uid;
  const email = context.auth.token.email;
}
```

### Authorization
```javascript
// Verify user has permission
if (context.auth.uid !== data.userId) {
  throw new functions.https.HttpsError(
    'permission-denied',
    'Unauthorized access'
  );
}
```

---

## 🐛 Troubleshooting

### Function Not Deploying
```bash
# Check syntax
npm run lint

# Deploy with debug logs
firebase deploy --only functions --debug
```

### Function Not Executing
1. Check Firebase Console → Functions → Logs
2. Verify IAM permissions
3. Ensure Blaze plan is active
4. Check function timeout (default: 60s)

### Cold Start Delays
- First invocation: 1-2 seconds (cold start)
- Subsequent invocations: <100ms
- Solution: Keep functions "warm" with scheduled pings

---

## 📚 Resources

- [Cloud Functions Docs](https://firebase.google.com/docs/functions)
- [Node.js Admin SDK](https://firebase.google.com/docs/reference/admin/node)
- [Callable Functions](https://firebase.google.com/docs/functions/callable)
- [Firestore Triggers](https://firebase.google.com/docs/functions/firestore-events)

---

## 🎯 Best Practices

✅ **Keep functions small and focused**  
✅ **Use async/await for promises**  
✅ **Add comprehensive error handling**  
✅ **Log important events**  
✅ **Set appropriate timeouts**  
✅ **Use typed parameters (TypeScript)**  
✅ **Test locally before deploying**  
✅ **Monitor execution time and costs**  
✅ **Use environment variables for config**  
✅ **Version your functions**

---

## 🔄 Continuous Deployment

### GitHub Actions Example
```yaml
name: Deploy Functions
on:
  push:
    branches: [main]
    paths:
      - 'functions/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: npm ci
        working-directory: ./functions
      - run: firebase deploy --only functions
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

---

## 📝 Development

### Adding a New Function

1. **Edit `index.js`**:
```javascript
exports.myNewFunction = functions.https.onCall((data, context) => {
  return { message: "Hello!" };
});
```

2. **Deploy**:
```bash
firebase deploy --only functions:myNewFunction
```

3. **Call from Flutter**:
```dart
final callable = FirebaseFunctions.instance.httpsCallable('myNewFunction');
final result = await callable.call();
```

---

## ✨ Summary

This functions directory contains **5 serverless functions** that:
- ✅ Handle business logic securely
- ✅ Automatically process Firestore events
- ✅ Scale automatically with user demand
- ✅ Cost $0 for most usage levels
- ✅ Integrate seamlessly with Flutter

**Ready to deploy!** 🚀
