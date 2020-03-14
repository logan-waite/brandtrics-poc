const store = initializeFirestore();

exports.handler = async (event, context) => {
  const path = event.path.replace(/\.netlify\/functions\/[^\/]+/, '')
  const segments = path.split('/').filter(e => e)
  switch (event.httpMethod) {
    case "GET":
      return getRequest();
    case "DELETE":
      return deleteRequest(event.body);
    case "PUT":
      return putRequest(event.body);
    default:
      console.log(`${path} does not support the '${event.httpMethod}' HTTP method.`)
      return error(`${path} does not support the '${event.httpMethod}' HTTP method.`)
  }
}

async function putRequest (body) {
  const color = JSON.parse(body)
  const colorId = color.id
  delete color.id
  try {
    const updated = await store.collection('colors').doc(colorId).set(color)
    return getRequest();
  } catch (err) {
    return error(err.toString())
  }
}

async function deleteRequest (id) {
  try {
    await store.collection('colors').doc(id).delete();
    return getRequest();
  } catch (err) {
    return error(err.toString())
  }
}

// We call this after every request. Maybe don't?
async function getRequest () {
  try {
    const snapshot = await store.collection('colors').get()
    const colors = [];
    snapshot.forEach((doc) => {
      colors.push({ id: doc.id, ...doc.data() })
    })
    return success(JSON.stringify({ colors }))
  } catch (err) {
    return error(err.toString())
  }
}

function initializeFirestore () {
  const admin = require('firebase-admin')
  const creds = require("./firestoreCreds.json")

  admin.initializeApp({
    credential: admin.credential.cert(creds),
  })

  return admin.firestore();
}

const success = response(200);
const error = response(500);

function response (statusCode) {
  return function responseBody (body) {
    return { statusCode, body }
  }
}
