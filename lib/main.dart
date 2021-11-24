// ignore_for_file: prefer_const_literals_to_create_immutables
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => const GirisEkrani(title: 'Blog Giriş Ekranı'),
        "/BlogSayfasiRotasi": (context) =>
            const MyHomePage(title: 'Firebase Blog Uygulaması'),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _GirisEkraniState createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();

  Future<void> kayiyOl() async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: t1.text, password: t2.text)
        .then((kullanici) {
      FirebaseFirestore.instance
          .collection("Kullanicilar")
          .doc(t1.text)
          .set({"KullaniciEposta": t1.text, "KullaniciSifre": t2.text});
    }).catchError((error) => showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Kayıtda Hata'),
                  content: Text('${error}'),
                )));
  }

  Future<void> girisYap() async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: t1.text, password: t2.text)
        .then((kullanici) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MyHomePage(title: widget.title)),
          (route) => false);
    }).catchError((error) => showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Girişde Hata'),
                  content: Text('${error}'),
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: EdgeInsets.all(45),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: t1,
              ),
              TextField(
                controller: t2,
              ),
              Row(
                children: [
                  ElevatedButton(child: Text("Kaydol"), onPressed: kayiyOl),
                  ElevatedButton(child: Text("Giriş Yap"), onPressed: girisYap),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var gelenYaziBasligi = "";
  var gelenYaziIcerigi = "";
  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();

  yaziEkle() {
    FirebaseFirestore.instance
        .collection('Yazilar')
        .doc(t1.text)
        .set({'baslik': t1.text, 'icerik': t2.text}).whenComplete(
            () => print("Yazı eklendi"));
  }

  yaziGuncelle() {
    FirebaseFirestore.instance
        .collection('Yazilar')
        .doc(t1.text)
        .update({'baslik': t1.text, 'icerik': t2.text}).whenComplete(
            () => print("Yazı güncellendi"));
  }

  yaziSil() {
    FirebaseFirestore.instance.collection('Yazilar').doc(t1.text).delete();
  }

  yaziGetir() {
    FirebaseFirestore.instance
        .collection("Yazilar")
        .doc(t1.text)
        .get()
        .then((gelenVeri) {
      setState(() {
        gelenYaziBasligi = gelenVeri.data()?['baslik'];
        gelenYaziIcerigi = gelenVeri.data()?['icerik'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) =>
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GirisEkrani(title: widget.title)),
                        (route) => false));
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(45),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: t1,
              ),
              TextField(
                controller: t2,
              ),
              Row(
                children: [
                  ElevatedButton(child: Text("Ekle"), onPressed: yaziEkle),
                  ElevatedButton(
                      child: Text("Güncelle"), onPressed: yaziGuncelle),
                  ElevatedButton(child: Text("Sil"), onPressed: yaziSil),
                  ElevatedButton(child: Text("Göster"), onPressed: yaziGetir),
                ],
              ),
              Flexible(
                child: ListTile(
                  title: Text(gelenYaziBasligi),
                  subtitle: Text(gelenYaziIcerigi),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
