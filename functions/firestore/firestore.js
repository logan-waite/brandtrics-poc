const admin = require('firebase-admin')
const creds = require("./firestoreCreds.json")

admin.initializeApp({
  credential: admin.credential.cert(creds),
})

const db = admin.firestore();

exports.handler = async (event, context) => {
  try {
    console.log(event);
    const snapshot = await db.collection('colors').get()

    const colors = [];
    snapshot.forEach((doc) => {
      colors.push({ id: doc.id, ...doc.data() })
    })

    console.log(colors);

    return {
      statusCode: 200,
      body: JSON.stringify({ colors })
    }
  } catch (err) {
    return { statusCode: 500, body: err.toString() }
  }
}
