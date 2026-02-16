const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Send push notification when a new notification is created
exports.sendNotificationOnCreate = functions.firestore
  .document('shops/{shopId}/notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    try {
      const notification = snap.data();
      const userId = notification.userId;
      
      console.log(`New notification created for user: ${userId}`);

      // Get user's FCM token from Firestore
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        console.log('User document not found');
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        console.log('No FCM token found for user');
        return null;
      }

      // Prepare the FCM message
      const message = {
        notification: {
          title: notification.title || 'New Notification',
          body: notification.body || '',
        },
        data: {
          notificationId: snap.id,
          shopId: context.params.shopId,
          type: notification.type || 'general',
          ...notification.data,
        },
        token: fcmToken,
        android: {
          priority: 'high',
          notification: {
            channelId: 'high_importance_channel',
            sound: 'default',
            priority: 'high',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      // Send the notification
      const response = await admin.messaging().send(message);
      console.log('Successfully sent notification:', response);
      
      return response;
    } catch (error) {
      console.error('Error sending notification:', error);
      return null;
    }
  });
