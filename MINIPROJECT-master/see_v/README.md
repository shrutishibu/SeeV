#SHRUTI
To add firebase: flutter pub add firebase_core

To add firestore: flutter pub add cloud_firestore
Use this import statement wherever firestore is required: import 'package:cloud_firestore/cloud_firestore.dart';

Firebase setup
    npm install -g firebase-tools
    firebase login
    flutter pub global activate flutterfire_cli
    flutterfire configure
    flutter pub add firebase_core

main.dart
    void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    runApp(const MyApp());
    }

Firestore setup
    Rules
        rules_version = '2';
        service cloud.firestore {
            match /databases/{database}/documents {
                match /{document=**} {
                    allow read, write: if true;
                }
            }
        }

    flutter pub add cloud_firestore