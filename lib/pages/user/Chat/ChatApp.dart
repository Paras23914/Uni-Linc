import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:college_dashboard/pages/user/Chat/Admin.dart';
import 'package:college_dashboard/pages/user/Chat/AdminChatRoom.dart';
import 'package:college_dashboard/pages/user/Chat/Chatroom.dart';
import 'package:college_dashboard/pages/user/Chat/VideoConference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final email = FirebaseAuth.instance.currentUser!.email;
  final firestore = FirebaseFirestore.instance;
  String name = "";
  String? branch="";
  String? dept="";
  String utype = '';
  String? roll;
  String? img;
  String? contact;
  String? rollno;
  DocumentSnapshot? data;

  @override
  void initState() {
    super.initState();
    update();
  }

  Future<void> update() async {
    final userdoc = firestore.collection('user').doc(uid);
    final snapshot = await userdoc.get();
    if (snapshot.exists) {
      setState(() {
        name = snapshot.data()!['studentName'];
        branch = snapshot.data()!['branchName'];
        dept = snapshot.data()!['department'];
        roll = snapshot.data()!['rollNo'];
        img = snapshot.data()!['image'];
        utype = snapshot.data()!['type'];
        contact = snapshot.data()!['contact'];
        rollno = snapshot.data()!['rollNo'];
      });

      if (utype != "Student") {
        final vid = firestore.collection("VideoConf").doc(branch! + dept!);
        final vidsnap = await vid.get();
        if (vidsnap.exists) {
          try {
            await vid.update({'Video': false});
          } on FirebaseException catch (e) {
            print(e.message);
          }
        } else {
          try {
            await vid.set({'Video': false});
          } on FirebaseException catch (e) {
            print(e.message);
          }
        }
      }
    }
  }

  Widget ViewGroup(String id, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GestureDetector(
        onTap: () {
          if (!id.contains("Queries")) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatRoom(
                      id: id,
                    )));
          } else {
            if (utype == "Admin") {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Admin()));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminChatRoom(
                        id: email! + "_" + name,
                      )));
            }
          }
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF0072FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    id.replaceAll("_", " "),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1f1b24),
        title: Text(
          'Chats',
          style:
          Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const Login()));
            },
            icon: const Icon(
              Icons.logout_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xff1f1b24),
      body: SingleChildScrollView(
        child: utype != 'Student'
            ? Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: GestureDetector(
                onTap: () async {
                  if (utype != "Student") {
                    final vid = firestore.collection("VideoConf").doc(branch! + dept!);
                    await vid.update({'Video': true});
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VideoConference(
                            id: branch! + dept!,
                          )));
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF11998e), Color(0xFF0072FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.video_call_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Start Video Conference",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  "Message Groups",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 10),
            ViewGroup(utype=="Admin"?"All The Queries":"Ask the Queries", Icons.question_answer_rounded),
            Divider(
              color: Colors.white54,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              height: 32,
            ),
            StreamBuilder(
              stream: firestore.collection('Chats').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Text(
                          "No Groups",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        if (snapshot.data!.docs[index].id != "Admin") {
                          return ViewGroup(
                              snapshot.data!.docs[index].id,
                              Icons.groups_rounded);
                        } else {
                          return Container();
                        }
                      },
                    );
                  }
                } else {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Text(
                          "Error loading Groups",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Text(
                          "No Message Groups",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        )
            : utype != ''
            ? Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  "Message Groups",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 10),
            ViewGroup("Ask any Queries", Icons.question_answer_rounded),
            Divider(
              color: Colors.white54,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              height: 32,
            ),
            SizedBox(height: 10),
            ViewGroup(branch! + "_" + dept!, Icons.groups_rounded),
          ],
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.threeArchedCircle(
                  color: Colors.white, size: 45),
              const Text(
                "Loading",
                style: TextStyle(fontSize: 15, color: Colors.white),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder(
        stream: firestore.collection("VideoConf").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Container(); // No data, return an empty container
          }

          bool showFAB = false;
          String? conferenceId;

          for (var doc in snapshot.data!.docs) {
            if (doc['Video'] == true) {
              if (doc.id == branch! + dept!) {
                showFAB = true;
                conferenceId = branch! + dept!;
                break;
              } else if (doc.id.contains("Admin")) {
                showFAB = true;
                conferenceId = "AdminAdmin";
                break;
              }
            }
          }

          if (showFAB && conferenceId != null) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoConference(
                          id: conferenceId!,
                        )));
              },
              child: Icon(Icons.video_call),
            );
          }

          return Container(); // Default case, return an empty container
        },
      ),
    );
  }
}
