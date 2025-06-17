/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// functions/index.js
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Firebase Authentication에서 사용자가 삭제될 때마다 트리거되어,
 * Firestore의 해당 users 컬렉션 문서를 함께 삭제합니다.
 */
exports.deleteUserDocumentOnAuthDelete = functions.auth.user().onDelete(async (user) => {
  const uid = user.uid;
  const userDocRef = admin.firestore().collection("users").doc(uid);

  try {
    await userDocRef.delete();
    console.log(`성공: Firestore에서 사용자 문서(uid: ${uid})를 삭제했습니다.`);
    return null;
  } catch (error) {
    console.error(`실패: Firestore에서 사용자 문서(uid: ${uid}) 삭제 중 오류 발생`, error);
    // 오류 로깅. 필요시 재시도 로직 추가 가능
    return null;
  }
});
