// Service worker requis par le plugin `firebase_messaging` pour le web.
// Doit impérativement être servi à la racine (http://<host>/firebase-messaging-sw.js)
// avec le type MIME "application/javascript" — c'est pourquoi ce fichier
// doit rester dans web/ (Flutter le copie tel quel dans build/web/ à la
// racine du site, contrairement à lib/ qui est compilé).

importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

// Doit correspondre exactement à DefaultFirebaseOptions.web dans
// lib/firebase_options.dart.
firebase.initializeApp({
  apiKey: 'AIzaSyBiHW6af5NqVD9bKI-tALb7_HO0N99xVvQ',
  appId: '1:254475674559:web:d30736e7230d291ac4370a',
  messagingSenderId: '254475674559',
  projectId: 'carpoollite',
  authDomain: 'carpoollite.firebaseapp.com',
  storageBucket: 'carpoollite.firebasestorage.app',
});

const messaging = firebase.messaging();

// Notifications reçues alors que l'onglet est en arrière-plan / fermé.
messaging.onBackgroundMessage((payload) => {
  const notificationTitle = payload.notification?.title ?? 'CarPool Lite';
  const notificationOptions = {
    body: payload.notification?.body ?? '',
    icon: 'icons/Icon-192.png',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
