Questa classe Dart è stata scritta prendendo come esempio il codice di partenza per la decodifica del codice da https://github.com/loreberti89/flutter_ita_greenpass e completando tutte le regole di validazione traducendo direttamente da VerificaC19. Questa classe non verifica la validità della firma, ma ne calcola solo le scadenze considerando  e regole ufficiali da https://get.dgc.gov.it/v1/dgc/settings.

La repository di partenza https://github.com/loreberti89/flutter_ita_greenpass non riusciva a validare i green pass da tampone e quelli da ex positivi covid. Questa repo è invece completa e comprende tutte le regole per la validazione.

La classe GreenPass è inoltre funzionante offline.
