import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PendingApprovalsWidget extends StatelessWidget {
  const PendingApprovalsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    String token = '';
    Future<void> sendNotification(String sid) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(sid)
          .get()
          .then((value) {
        token = value.data()!['token'];
      });
      final data = {
        'notification': {
          'title': 'Approval',
          'body': 'Your account has been approved',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK'
        },
        'to': token
      };
      try {
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAA5WAIP5s:APA91bG2nI1ydw_eqUn5VuCJMEYZDJbIa3GF6o5Z9XlwXku3Vl2E57WupHnOdDiMoM-skrmKyqm1hNWsEa_oNr-veKPTLFPLLZWIpcRUoXDdBIUuDZXiCSCuTgs9VD6OrxqCKHlcXV04'
          },
          body: jsonEncode(data),
        );
      } catch (e) {
        print(e);
      }
    }

    return Scaffold(
      body: Column(
        children: [
          const Text(
            'Pending Approvals',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('parkings')
                .where('status', isEqualTo: 'pending')

                //or do not have status field

                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return snapshot.data == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : snapshot.data.docs.length == 0
                      ? const Center(
                          child: Text('No Pending Approvals'),
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: ListView.builder(
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(
                                    snapshot.data.docs[index]['parkingName']),
                                subtitle: Text(snapshot.data.docs[index]
                                    ['parkingAddress']),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('suppliers')
                                        .doc(snapshot.data.docs[index].id)
                                        .update({
                                      'status': 'active'
                                    }).whenComplete(() => sendNotification(
                                            snapshot.data.docs[index].id));
                                  },
                                  child: const Text('Approve'),
                                ),
                              );
                            },
                          ));
            },
          ),
        ],
      ),
    );
  }
}
