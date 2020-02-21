const fetch = require('node-fetch')
const auth0 = require('auth0-js')

exports.handler = async (event, context) => {
  var webAuth = new auth0.WebAuth({
    domain: 'brandtrics-poc.auth0.com',
    clientID: 'TixNPBIdar1NR6XLE3IUgsGol7rCf5P4'
  });

  return webAuth.authorize({
    redirectUri: "http://localhost:3000",
    scope: 'read:order write:order',
    responseType: 'token',
  });

  // callback(null, {
  //   statusCode: 200,
  //   headers: {
  //     "content-type": "application/json; charset=UTF-8",
  //     "access-control-allow-origin": "*",
  //     "access-control-expose-headers": "content-encoding,date,server,content-length"
  //   },
  //   body: JSON.stringify({
  //     "test": auth0.WebAuth.authorize
  //   })
  // })
}
