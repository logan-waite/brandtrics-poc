// import './main.css';
import { Elm } from './Main.elm';
// import * as serviceWorker from '../serviceWorker';

var app = Elm.Main.init({
  node: document.getElementById('root'),
});

app.ports.openAuthModal.subscribe(function (data) {
  netlifyIdentity.open()
})

netlifyIdentity.on('login', user => {
  app.ports.userAuth.send({ action: 'login', payload: user })
  netlifyIdentity.close()
});

netlifyIdentity.on('logout', () => {
  app.ports.userAuth.send({ action: 'logout' })
})

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
// serviceWorker.unregister();
