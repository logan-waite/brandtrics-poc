# Brandtrics POC #

This a proof of concept application for brand management. It's built on a serverless stack using Elm and Firebase, and using Netlify for hosting and identity management.

## Serverless ##
### What is serverless? ###
Serverless is the idea that you can create an app that doesn't require a server that is always running in the background. It tends to lead to a separation of concerns, where each major part of your app (database, authentication, etc) is offloaded to a separate service. The benefit of this is scalability, where we only pay for what we use, also allows us to mix and max services as we need. Instead of taking the time to build our own and deal with any issues that arise from that, we can just focus on what we want to build and integrate with the other things we need. If we do get to the point were we need something more homegrown, it would, again, just be a matter of building the pieces we need when we need it, instead of doing it all at once up front.

At a small scale, all of the services I've currently set up are free, allowing us to prototype and experiment as much as we need to without having to constantly pay for what we are doing.

With that in mind, all of the following services are can be swapped out if better options become available.

## (Elm)[https://elm-lang.org] ##
Elm is a strongly-typed functional language. What this boils down to is that we are able to get:
- No run-time errors in production (i.e. the app shouldn't crash or break once it's been deployed)
- More confidence that things won't break when we add new features and refactor code
- A small and fast app, allowing for quick load times and snappy performance

## (Firebase)[https://firebase.google.com] ##
Firebase is a set of tools provided by Google. Specifically, this app uses (Firestore)[https://firebase.google.com/products/firestore] for data and will use (Cloud Storage)[https://firebase.google.com/products/storage] for images and files.
 
## (Netlify)[https://www.netlify.com] ##
Netlify is a hosting solution designed for developers. It includes tools like
- Automatic continuous integration (allowing for faster and easier deployments)
- Deployment history (so we can revert to a previous version if we need to)
- Other add-ons, like functions and identity

### (Functions)[https://www.netlify.com/products/functions/] ###
Netlify Functions are essentially little pieces of server that only run when they are needed. Instead of paying for a whole server to sit and wait for things to do, we only pay for when a function is actually being used.

Functions also appear just like normal endpoints, so if we decide to move to a server configuration, it only require superficial changes to change over the client side app to do so.

### (Identity)[https://docs.netlify.com/visitor-access/identity/#enable-identity-in-the-ui] ###
Instead of managing user identity data ourselves (i.e. passwords and the like) and having to worry about security, we are able to offload that to another service. Netlify Identity is built in to things like their functions, and so it's really easy to use their solution.
