import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:the_admin_panal/aprovals/aprovals.dart';
import 'package:the_admin_panal/home/box.dart';
import 'package:the_admin_panal/home/side_bar.dart';
import 'package:http/http.dart' as http;
import 'package:the_admin_panal/reports/reports.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    String token = '';
    Future<void> sendNotification(String message, String sid) async {
      try {
        await FirebaseFirestore.instance
            .collection('suppliers')
            .doc(sid)
            .get()
            .then((value) {
          token = value.data()!['token'];
        });
      } catch (e) {
        print(e);
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
                'key=AAAAV2OaltE:APA91bFdRb9lHBTieJhv3sKIDbdQCdrrQkarHM9NF0j71EdP7Row40AQ6eOl9v1fqK6QTbCR2hEdkJPL98fNbDTbDX0ps7nSlR8YNXX46v2uRWYyTaQtfdNtA2v68mtabnTBqHMOZcSm'
          },
          body: jsonEncode(data),
        );
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Reports()));
                      },
                      child: const Mybox(
                        text: 'View All Reports',
                        icon: Icons.report_problem,
                        color: Colors.pinkAccent,
                      ),
                    ),
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
                    const Text('Recent Reports'),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child:
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('reports')
                              .orderBy('time', descending: true)
                              .snapshots(), // replace with your stream
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return ListView.builder(
                                itemCount: //first 10 items
                                    snapshot.data!.docs.length > 4
                                        ? 10
                                        : snapshot.data!.docs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  //get user details

                                  return ListTile(
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        getNames(
                                            'customers',
                                            'name',
                                            snapshot.data!.docs[index]
                                                ['reportedby'],
                                            index),
                                        getNames(
                                            'suppliers',
                                            'storename',
                                            snapshot.data!.docs[index]
                                                ['reportedto'],
                                            index),
                                        Text(
                                            'Report Message: ${snapshot.data!.docs[index]['report']}')
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('suppliers')
                                                .doc(snapshot.data!.docs[index]
                                                    ['reportedto'])
                                                .update({
                                              'status': 'blocked'
                                            }).whenComplete(() async {
                                              debugPrint(snapshot.data!
                                                  .docs[index]['reportedto']
                                                  .toString());
                                              sendNotification(
                                                  'Your account has been blocked for violating our terms and conditions.',
                                                  snapshot.data!.docs[index]
                                                      ['reportedto']);
                                            });
                                          },
                                          child: const Text('Block User'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            int warnings = 0;
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('suppliers')
                                                  .doc(snapshot.data!
                                                      .docs[index]['reportedto']
                                                      .toString())
                                                  .get()
                                                  .then((value) async {
                                                debugPrint(snapshot.data!
                                                    .docs[index]['reportedto']
                                                    .toString());
                                                if (value
                                                        .data()!['warncount'] ==
                                                    null) {
                                                  warnings = 1;
                                                } else {
                                                  warnings = value.data()![
                                                          'warncount'] +
                                                      1;
                                                }

                                                await FirebaseFirestore.instance
                                                    .collection('suppliers')
                                                    .doc(snapshot
                                                        .data!
                                                        .docs[index]
                                                            ['reportedto']
                                                        .toString())
                                                    .update({
                                                  'warncount': warnings,
                                                  'warnmsg':
                                                      'You have been warned $warnings times for violating our terms and conditions. If you continue to do so, your account will be blocked. you have only ${2 - warnings} warnings left.'
                                                }).whenComplete(() =>
                                                        sendNotification(
                                                            'You have been warned $warnings times for violating our terms and conditions.',
                                                            snapshot.data!
                                                                    .docs[index]
                                                                [
                                                                'reportedto']));
                                              });
                                            } catch (e) {
                                              print(e);
                                            }
                                          },
                                          child: const Text('Warn User'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return const CircularProgressIndicator(); // show a loading spinner when data is loading
                            }
                          },
                        )),
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
