Questa classe Dart è stata scritta prendendo come esempio il codice di partenza per la decodifica del codice da https://github.com/loreberti89/flutter_ita_greenpass e completando tutte le regole di validazione traducendo direttamente da VerificaC19. Questa classe non verifica la validità della firma, ma ne calcola solo le scadenze considerando  e regole ufficiali da https://get.dgc.gov.it/v1/dgc/settings.

La repository di partenza https://github.com/loreberti89/flutter_ita_greenpass non riusciva a validare i green pass da tampone e quelli da ex positivi covid. Questa repo è invece completa e comprende tutte le regole per la validazione.

La classe GreenPass è inoltre funzionante offline.

Basta importare le dipendenze dal file pubspec.yaml, copiare e incollare il file greenpass.dart nella propria direcoty lib e utilizzare la classe come visto nel file example.dart nella cartella bin di questo progetto.

Questa classe è utilizzabile per:
1. Applicazioni da console PC in Dart
2. Dart per il Web
3. Flutter per tutte le piattaforme (Android, IOS, Web, Windows, Linux, MACOS)
