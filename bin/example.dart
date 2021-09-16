import 'greenpass.dart';

void main() {
  GreenPass greenPass = GreenPass();
  try {
    //Passo invece di greenPassString la stringa ottenuta dalla scansione di un green pass. Per ottenere la stringa, scansiona il green pass con un lettore qr e copia e incolla la stringa ottenuta al posto di greenPassString
    var payload = greenPass.decodeFromRaw("greenPassString");
    greenPass.validateGreenpass(payload).then((value) {
      if (value['message'] == 'valid') {
        //Il green pass non è scaduto
        print("green pass valido");
        print(greenPass.name + " " + greenPass.surname + " " + greenPass.dob);
      } else if (value['message'] == 'partially valid') {
        //Il green pass è scaduto
        print("green pass scaduto");
        print(greenPass.name + " " + greenPass.surname + " " + greenPass.dob);
      } else {
        //Il green pass non è valido
        print("green pass non valido");
      }
    });
  } catch (e) {
    //Qualocosa non è andata a buon fine e ritorna un messaggio di errore
    print("green pass non valido " + e.toString());
  }
}
