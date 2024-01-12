import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:the_admin_panal/aprovals/aprovals.dart';
import 'package:the_admin_panal/home/box.dart';
import 'package:the_admin_panal/home/side_bar.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    String token = '';
    Future<void> sendNotification(String message, String sid) async {
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(sid)
            .get()
            .then((value) {
          token = value.data()!['token'];
        });
      } catch (e) {
        print('error getting token');
      }
      final data = {
        'notification': {
          'title': 'Approval',
          'body': message,
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
        debugPrint('Notification sent');
      } catch (e) {
        print(e);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Row(
        children: [
          const SideBar(),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => const Reports()));
                    //   },
                    //   child: const Mybox(
                    //     text: 'View All Reports',
                    //     icon: Icons.report_problem,
                    //     color: Colors.pinkAccent,
                    //   ),
                    // ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PendingApprovalsWidget()));
                      },
                      child: const Mybox(
                        text: 'Pending Approvals',
                        icon: Icons.pending_actions,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                ),
                child: Column(
                  children: [
                    const Text('Recent Aproval requests'),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('parkings')
                            .where('status', isEqualTo: 'pending')

                            //or do not have status field

                            .snapshots(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          return snapshot.data == null
                              ? const Center(
                                  child: SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircularProgressIndicator()),
                                )
                              : snapshot.data.docs.length == 0
                                  ? const Center(
                                      child: Text('No Pending Approvals'),
                                    )
                                  : SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.8,
                                      child: ListView.builder(
                                        itemCount: //first 10
                                            snapshot.data.docs.length > 10
                                                ? 10
                                                : snapshot.data.docs.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          debugPrint(snapshot.data.docs[index]
                                              ['ownerId']);

                                          return ListTile(
                                            title: Text(snapshot.data
                                                .docs[index]['parkingName']),
                                            subtitle: Text(snapshot.data
                                                .docs[index]['parkingAddress']),
                                            trailing: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('parkings')
                                                    .doc(snapshot
                                                        .data.docs[index].id)
                                                    .update({
                                                  'status': 'approved'
                                                }).whenComplete(() =>
                                                        sendNotification(
                                                            'Your parking ${snapshot.data.docs[index]['parkingName']} request has been approved',
                                                            snapshot.data
                                                                    .docs[index]
                                                                ['ownerId']));
                                              },
                                              child: const Text('Approve'),
                                            ),
                                          );
                                        },
                                      ));
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
        ],
      ),
    );
  }

  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>> getNames(
      String userType, String name, String id, int index) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection(userType).doc(id).get(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Text(userType == 'customers'
              ? 'Reported By:  ${snapshot.data!['name']}'
              : 'Store Name:  ${snapshot.data!['storename']}');
        } else {
          return const Text('Loading');
        }
      },
    );
  }
}
