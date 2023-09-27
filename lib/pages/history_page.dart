import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final CollectionReference collectionReference = FirebaseFirestore.instance.collection('translations');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translation History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: collectionReference.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No translations found.'));
          }

          List<QueryDocumentSnapshot> translations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: translations.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(translations[index]['originalText'] ?? 'No original text'),
                subtitle: Text(translations[index]['translatedText'] ?? 'No translation'),
              );
            },
          );
        },
      ),
    );
  }
}
