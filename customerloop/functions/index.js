/**
 * Firebase Cloud Functions for CustomerLoop
 * 
 * This file contains two types of functions:
 * 1. Callable Function (sayHello) - Can be invoked directly from Flutter
 * 2. Firestore Trigger (onNewCustomer) - Automatically runs when a new customer is created
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

/**
 * CALLABLE FUNCTION: sayHello
 * 
 * This is an HTTPS callable function that can be invoked from Flutter.
 * It receives data from the client, processes it, and returns a response.
 * 
 * Use Case:
 * - Welcome messages for new users
 * - Custom greetings in the app
 * - Testing Cloud Functions integration
 * 
 * How to call from Flutter:
 * final callable = FirebaseFunctions.instance.httpsCallable('sayHello');
 * final result = await callable.call({'name': 'Alex'});
 * print(result.data['message']);
 */
exports.sayHello = functions.https.onCall((data, context) => {
  // Extract the name from the request data
  const name = data.name || "User";
  
  // Log the function execution
  console.log(`sayHello function called with name: ${name}`);
  
  // Return a personalized message
  return {
    message: `Hello, ${name}! Welcome to CustomerLoop 🎉`,
    timestamp: admin.firestore.Timestamp.now(),
    success: true
  };
});

/**
 * CALLABLE FUNCTION: calculatePoints
 * 
 * Business logic function to calculate loyalty points based on purchase amount.
 * This demonstrates how serverless functions handle backend calculations.
 * 
 * Use Case:
 * - Calculate loyalty points for purchases
 * - Apply business rules on the server
 * - Prevent client-side manipulation of points
 */
exports.calculatePoints = functions.https.onCall((data, context) => {
  const purchaseAmount = data.amount || 0;
  
  // Business Rule: 1 point for every $10 spent
  // Bonus: 2x points for purchases over $100
  let points = Math.floor(purchaseAmount / 10);
  
  if (purchaseAmount > 100) {
    points = points * 2; // Double points for large purchases
  }
  
  console.log(`Calculated ${points} points for purchase of $${purchaseAmount}`);
  
  return {
    points: points,
    purchaseAmount: purchaseAmount,
    bonusApplied: purchaseAmount > 100,
    message: purchaseAmount > 100 ? 
      "Bonus! You earned 2x points!" : 
      "Points calculated successfully"
  };
});

/**
 * FIRESTORE TRIGGER: onNewCustomer
 * 
 * This is an event-based function that automatically runs whenever
 * a new customer document is created in the 'customers' collection.
 * 
 * Use Cases:
 * - Send welcome notifications to shop owners
 * - Auto-generate customer welcome messages
 * - Initialize default values (loyalty tier, points, etc.)
 * - Track analytics (new customer count)
 * - Validate and sanitize customer data
 * 
 * This function runs serverside automatically - no Flutter code needed!
 */
exports.onNewCustomer = functions.firestore
  .document("customers/{customerId}")
  .onCreate(async (snap, context) => {
    // Get the customer data that was just created
    const customerData = snap.data();
    const customerId = context.params.customerId;
    
    console.log("=== NEW CUSTOMER CREATED ===");
    console.log(`Customer ID: ${customerId}`);
    console.log(`Customer Name: ${customerData.name}`);
    console.log(`Customer Phone: ${customerData.phone}`);
    
    try {
      // Auto-assign initial loyalty tier and welcome bonus
      await snap.ref.update({
        loyaltyTier: "Bronze", // Default tier for new customers
        welcomeBonus: 10, // Give 10 bonus points to new customers
        accountCreatedAt: admin.firestore.FieldValue.serverTimestamp(),
        isActive: true
      });
      
      console.log(`✅ Welcome bonus and tier assigned to ${customerData.name}`);
      
      // Update shop owner's customer count
      if (customerData.shopOwnerId) {
        const ownerRef = admin.firestore()
          .collection("shops")
          .doc(customerData.shopOwnerId);
        
        await ownerRef.update({
          totalCustomers: admin.firestore.FieldValue.increment(1),
          lastCustomerAddedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        
        console.log(`✅ Shop owner's customer count incremented`);
      }
      
      return null;
    } catch (error) {
      console.error("Error processing new customer:", error);
      return null;
    }
  });

/**
 * FIRESTORE TRIGGER: onCustomerVisit
 * 
 * Automatically triggered when a visit is recorded.
 * Updates customer statistics and checks for milestone achievements.
 */
exports.onCustomerVisit = functions.firestore
  .document("visits/{visitId}")
  .onCreate(async (snap, context) => {
    const visitData = snap.data();
    const visitId = context.params.visitId;
    
    console.log("=== NEW VISIT RECORDED ===");
    console.log(`Visit ID: ${visitId}`);
    console.log(`Customer ID: ${visitData.customerId}`);
    console.log(`Points Earned: ${visitData.pointsEarned}`);
    
    try {
      // Get customer document
      const customerRef = admin.firestore()
        .collection("customers")
        .doc(visitData.customerId);
      
      const customerDoc = await customerRef.get();
      
      if (customerDoc.exists) {
        const currentVisits = customerDoc.data().visitCount || 0;
        const newVisitCount = currentVisits + 1;
        
        // Check for milestones (5th, 10th, 25th visit)
        let milestone = null;
        let bonusPoints = 0;
        
        if (newVisitCount === 5) {
          milestone = "5 Visits! 🎉";
          bonusPoints = 25;
        } else if (newVisitCount === 10) {
          milestone = "10 Visits! 🌟";
          bonusPoints = 50;
        } else if (newVisitCount === 25) {
          milestone = "25 Visits! 🏆";
          bonusPoints = 100;
        }
        
        // Update customer with milestone
        await customerRef.update({
          visitCount: admin.firestore.FieldValue.increment(1),
          lastVisitAt: admin.firestore.FieldValue.serverTimestamp(),
          ...(milestone && { 
            milestoneAchieved: milestone,
            milestoneDate: admin.firestore.FieldValue.serverTimestamp()
          })
        });
        
        // Add bonus points if milestone reached
        if (bonusPoints > 0) {
          await customerRef.update({
            points: admin.firestore.FieldValue.increment(bonusPoints)
          });
          
          console.log(`🎁 Milestone bonus: ${bonusPoints} points for ${milestone}`);
        }
        
        console.log(`✅ Customer visit count updated to ${newVisitCount}`);
      }
      
      return null;
    } catch (error) {
      console.error("Error processing customer visit:", error);
      return null;
    }
  });

/**
 * HTTP FUNCTION: healthCheck
 * 
 * Simple health check endpoint to verify Cloud Functions are deployed and working.
 * Access via: https://[region]-[project-id].cloudfunctions.net/healthCheck
 */
exports.healthCheck = functions.https.onRequest((req, res) => {
  res.status(200).json({
    status: "healthy",
    message: "CustomerLoop Cloud Functions are running! 🚀",
    timestamp: new Date().toISOString(),
    functions: [
      "sayHello (callable)",
      "calculatePoints (callable)",
      "onNewCustomer (firestore trigger)",
      "onCustomerVisit (firestore trigger)",
      "healthCheck (http)"
    ]
  });
});
