// Test de fumée minimal.
//
// Le test par défaut généré par Flutter (qui référence une classe `MyApp`
// avec un compteur) ne correspond pas à cette application : l'app réelle
// s'appelle `CarpoolLiteApp` (voir lib/main.dart) et ne contient pas de
// compteur.
//
// `CarpoolLiteApp` n'est volontairement pas testée ici directement : son
// arbre de routes (`app_router.dart`) construit `Injector.authProvider`,
// qui appelle `FirebaseAuth.instance` / `FirebaseFirestore.instance` dès son
// chargement. Sans `Firebase.initializeApp()` (ou un mock, ex. via les
// packages `firebase_auth_mocks` / `fake_cloud_firestore`, non installés
// dans ce dépôt), ce test échouerait à l'exécution alors même que le code
// est correct. À enrichir une fois ces mocks ajoutés au projet.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Affiche un écran de base', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Carpool Lite')),
        ),
      ),
    );

    expect(find.text('Carpool Lite'), findsOneWidget);
  });
}
