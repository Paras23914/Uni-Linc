import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:college_dashboard/pages/user/Chat/AdminChatRoom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final email = FirebaseAuth.instance.currentUser!.email;
  final firestore = FirebaseFirestore.instance;
  String name = "";
  String? branch;
  String? dept;
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
    }
  }

  Widget ViewGroup(String id, icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AdminChatRoom(id: id)));
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF0072FF)],
                // colors: [Color(0xFF654ea3), Color(0xFFff5e62)] ,
                // colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple to Blue gradient
                // colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)], // Blue to Light Blue gradient
                // colors: [Color(0xFF00c6ff), Color(0xFF0072ff)], // Light Blue to Dark Blue gradient
                // colors: [Color(0xFFf83600), Color(0xFFf9d423)], // Orange to Yellow gradient
                // colors: [Color(0xFFED4264), Color(0xFFFFEDBC)], // Pink to Peach gradient
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        id.substring(id.indexOf("_")+1, id.length),

                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        // "As",
                        id.substring(0, id.indexOf("_")),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
            'Queries',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Login()));
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
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  "All the Queries",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: firestore
                  .collection('Admin')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Text(
                          "No Queries",
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
                        print(snapshot.data!.docs[index].id);
                        return ViewGroup(
                            snapshot.data!.docs[index].id,
                            Icons.question_answer_rounded);
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
        )));
  }
}
