const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.processSignUp = functions.auth.user().onCreate(async (user) => {
  // Retrieve user data from Firestore
  const userDoc = await admin.firestore().collection("users").doc(user.uid).get();
  const userRole = userDoc.data().role;

  // Set custom claims based on the user's role
  let customClaims = {};
  if (userRole === "registered_users") {
    customClaims = {registered_user: true};
  } else if (userRole === "employers") {
    customClaims = {employer: true};
  }

  // Set custom claims
  await admin.auth().setCustomUserClaims(user.uid, customClaims);

  return null;
});
