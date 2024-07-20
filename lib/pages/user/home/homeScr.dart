import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:college_dashboard/pages/user/home/addAdmin.dart';
import 'package:college_dashboard/pages/user/home/addTeacher.dart';
import 'package:college_dashboard/pages/user/home/subcategories/Announcements/Announcements.dart';
import 'package:college_dashboard/pages/user/home/subcategories/OnlinePDF/Pdf.dart';
import 'package:college_dashboard/pages/user/home/subcategories/Tasks/Tasks.dart';
import 'package:college_dashboard/pages/user/home/subcategories/Videos/Videos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'subcategories/Events/Events.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final firestore = FirebaseFirestore.instance;
  String name = "";
  String? branch;
  String? dept;
  String? utype;
  String? roll;
  String? img;
  String? contact;
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff191720),
        title: Text(
          'Dashboard',
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
      backgroundColor: const Color(0xff191720),
      body: name!=""?
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Card(
                elevation: 5,
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.lightBlueAccent,
                        Colors.blue,
                        Colors.purpleAccent,
                        Colors.purple,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Events",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                              MediaQuery.of(context).size.width * 0.08,
                              fontWeight: FontWeight.w400,
                            ),
                            textScaler: const TextScaler.linear(1),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: MediaQuery.of(context).size.width*.30,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Colors.amber,Colors.orange]
                              ),
                              borderRadius: BorderRadius.circular(50)
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context)=>const Events()
                                    )
                                );
                              },
                              child: const Text(
                                "Check Now",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: firestore
                              .collection('events')
                              .where('Date', isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch - (DateTime.now().millisecondsSinceEpoch % 86400000) - 19800000)
                              .snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.docs.isEmpty) {
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width / 3,
                                  height: MediaQuery.of(context).size.width / 3.5,
                                  child: const Center(
                                      child: Text(
                                          "No Events",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20
                                        ),
                                      )
                                  ),
                                );
                              } else {
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width / 3,
                                  height: MediaQuery.of(context).size.width / 3.5,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                              snapshot.data!.docs[index]['Title'],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "On " + DateFormat('EEEE, dd MMMM, yyyy').format(DateTime.fromMillisecondsSinceEpoch(snapshot.data!.docs[index]['Date'])),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              }
                            } else {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                height: MediaQuery.of(context).size.width / 3.5,
                                child: const Center(child: Text("Loading...")),
                              );
                            }
                          },
                        ),

                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15),
                alignment: Alignment.topLeft,
                child: Text(
                  "Resources",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                      fontWeight: FontWeight.bold),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  double cardWidth = constraints.maxWidth / 2.2;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          NewCard(
                            val: 0,
                            text: "Announcement",
                            color: const [Colors.red, Colors.orangeAccent],
                            icon: Icons.announcement,
                            width: cardWidth,
                          ),
                          NewCard(
                            val: 1,
                            text: "Tasks",
                            color: const [Colors.deepOrange, Colors.yellowAccent],
                            icon: Icons.task,
                            width: cardWidth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          NewCard(
                            val: 2,
                            text: "Online PDFs",
                            color: const [Colors.redAccent, Colors.pink],
                            icon: Icons.book_online,
                            width: cardWidth,
                          ),
                          NewCard(
                            val: 3,
                            text: "Video Lectures",
                            color: const [Colors.purple, Colors.blueGrey],
                            icon: Icons.video_collection_outlined,
                            width: cardWidth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      utype == 'Admin'
                          ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          NewCard(
                            val: 4,
                            text: "Add Teacher",
                            color: [Color(0xFFFF9A8B), Color(0xFFFF6A88)], // Peach to Pink gradient
                            // color: const [Colors.redAccent, Colors.pink],
                            icon: Icons.person_add_rounded,
                            width: cardWidth,
                          ),
                          NewCard(
                            val: 5,
                            text: "Add Admin",
                            color: [Color(0xFF6A1B9A), Color(0xFF311B92)], // Purple to Blue gradient
                            // color: const [Colors.purple, Colors.blueGrey],
                            icon: Icons.person_add_alt_rounded,
                            width: cardWidth,
                          ),
                        ],
                      )
                      : Container()
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      )
      : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.dotsTriangle(
                  color: Colors.white, size: 45),
              const Text(
                "Loading",
                style: TextStyle(fontSize: 15, color: Colors.white),
              )
            ],
          )
      ),
    );
  }
}

final List<Widget> _widgetOptions = <Widget>[

  const Announcements(),
  const Tasks(),
  const Pdfs(),
  const Videos(),
  const AddTeacher(),
  const AddAdmin(),
  // Add more pages as needed
];

class NewCard extends StatelessWidget {
  const NewCard({
    super.key,
    required this.val,
    required this.text,
    required this.color,
    required this.icon,
    required this.width,
  });

  final int val;
  final String text;
  final List<Color> color;
  final IconData icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => _widgetOptions[val]),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: color,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          width: width,
          height: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                icon,
                color: const Color(0xFFFFFFFF),
                size: MediaQuery.of(context).size.width * 0.09,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  color: const Color(0xFFFFFFFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
