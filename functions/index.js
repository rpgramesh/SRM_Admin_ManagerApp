const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

// Kitchen → Dasher notification trigger
exports.notifyDasherOrderReady = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.status !== "readyForPickup" && after.status === "readyForPickup") {
      try {
        // 1. Log status change event
        await getFirestore()
          .collection("order_status_events")
          .add({
            orderId: event.params.orderId,
            oldStatus: before.status,
            newStatus: "readyForPickup",
            kitchenId: after.kitchenId || "default_kitchen",
            kitchenName: after.kitchenName || "Delhi Nights",
            timestamp: new Date(),
            triggeredNotification: true,
          });

        // 2. Send push notification to assigned Dasher
        const payload = {
          notification: {
            title: "Order Ready! 🎯",
            body: `Order #${event.params.orderId.slice(-4)} ready for pickup from ${after.kitchenName || "Delhi Nights"}`,
          },
          data: {
            orderId: event.params.orderId,
            customerName: after.customerName || "",
            customerAddress: after.customerAddress || "",
            customerPhone: after.customerPhone || "",
            pickupLocation: after.kitchenLocation || "-37.71112804668473,144.5917238006204", // Delhi Nights
            estimatedFoodReadyTime: after.estimatedReadyTime || "",
            orderTotal: String(after.totalAmount || 0),
          },
        };

        // Send to assigned Dasher's topic
        await getMessaging().send({
          ...payload,
          topic: `dasher_${after.dasherId || "unassigned"}`,
        });

        console.log(`Sent pickup alert to dasher_${after.dasherId} for order ${event.params.orderId}`);
      } catch (error) {
        console.error("Cloud function error:", error);
      }
    }
  }
);

// Additional helper function for manual trigger if needed
exports.manualDasherNotify = onCall({
  region: "australia-southeast1" 
}, async (request) => {
  const {orderId} = request.data;
  const order = await getFirestore().collection("orders").doc(orderId).get();
  
  if (!order.exists || order.data().status !== "readyForPickup") {
    throw new functions.https.HttpsError("invalid-argument", "Invalid order status");
  }

  await getMessaging().send({
    notification: {
      title: "Manual Ready Notice",
      body: "Kitchen requested immediate pickup",
    },
    topic: `dasher_${order.data().dasherId || "all"}`,
  });
  
  return {success: true};
});