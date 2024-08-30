import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_flutter_app/Components/ChatWithRecruiter.dart';

class ChatWithRecruiterPage extends StatelessWidget {
  final String jobId;
  final String userId;

  ChatWithRecruiterPage({required this.jobId, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Use the jobId and userId to set up the chat with the recruiter.
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Recruiter'),
      ),
      body: Center(
        child: Text('Job ID: $jobId\nUser ID: $userId'),
      ),
    );
  }
}

class JobsPostedPage extends StatefulWidget {
  @override
  _JobsPostedPageState createState() => _JobsPostedPageState();
}

class _JobsPostedPageState extends State<JobsPostedPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    currentUser = _auth.currentUser!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.amber,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('All Job Applied', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 3, 53, 41),
      ),
      body: currentUser == null
          ? CircularProgressIndicator()
          : StreamBuilder(
              stream: _firestore.collection('jobsposted').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final jobDocs = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: jobDocs.length,
                  itemBuilder: (context, index) {
                    final jobDoc = jobDocs[index];
                    final applicationsCollection =
                        jobDoc.reference.collection('applications');
                    final applicationDoc =
                        applicationsCollection.doc(currentUser.uid);

                    return FutureBuilder(
                      future: applicationDoc.get(),
                      builder: (context,
                          AsyncSnapshot<DocumentSnapshot> applicationSnapshot) {
                        if (applicationSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        final jobId = jobDoc.id;

                        if (applicationSnapshot.hasError) {
                          return Text('Error: ${applicationSnapshot.error}');
                        }

                        if (applicationSnapshot.hasData &&
                            applicationSnapshot.data!.exists) {
                          final jobData = jobDoc.data() as Map<String, dynamic>;
                          final companyName = jobData['companyName'] as String?;
                          final jobTitle = jobData['jobTitle'] as String?;

                          if (companyName != null && jobTitle != null) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      jobId: jobId,
                                      applicationId: currentUser.uid,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.all(6),
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 132, 227, 127),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: ListTile(
                                  title: Text('Company: $companyName'),
                                  subtitle: Text('Job Title: $jobTitle'),
                                  trailing: Icon(
                                    Icons.chat,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return ListTile(
                              title: Text('Job ID: $jobId (No Application)'),
                            );
                          }
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: JobsPostedPage(),
  ));
}
