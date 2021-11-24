import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnaSayfa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Anasayfa")),
      body: TumYazilar(),
    );
  }
}

class TumYazilar extends StatefulWidget {
  @override
  _TumYazilarState createState() => _TumYazilarState();
}

class _TumYazilarState extends State<TumYazilar> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Yazilar').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return ListTile(
              title: Text(data['baslik']),
              subtitle: Text(data['icerik']),
            );
          }).toList(),
        );
      },
    );
  }
}
