import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:college_dashboard/pages/user/home/subcategories/Tasks/AddTasks.dart';
import 'package:college_dashboard/pages/user/home/subcategories/Tasks/AllTasks.dart';
import 'package:college_dashboard/pages/user/home/subcategories/Tasks/ViewTask.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
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

  Widget ViewTasks(String title, String des, int date, String id) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewTaskDetail(
                    id: id,
                  )
              )
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF009688), Color(0xFF2196F3)], // Teal to Blue gradient
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.task,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10), // Added a SizedBox for spacing
                Text(
                  DateFormat('EEEE, dd MMMM, yyyy').format(
                    DateTime.fromMillisecondsSinceEpoch(date),
                  ).toString(),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10), // Added a SizedBox for spacing
                Text(
                  des,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.keyboard_arrow_left,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff191720),
        title: Text(
          "Tasks",
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "Tasks for " + (branch ?? "") + " " + (dept ?? ""),
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: firestore
                  .collection('Tasks')
                  .orderBy('Date', descending: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Tasks",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        if (snapshot.data!.docs[index]['Dept'] == dept ||
                            snapshot.data!.docs[index]['Dept'] == 'Admin' ||
                            dept=='Admin'){
                        if (snapshot.data!.docs[index]['Branch'] == branch ||
                            snapshot.data!.docs[index]['Branch'] == 'admin' ||
                        branch=='Admin') {
                          return ViewTasks(
                            snapshot.data!.docs[index]['Title'],
                            snapshot.data!.docs[index]['Description'],
                            snapshot.data!.docs[index]['Date'],
                            snapshot.data!.docs[index].id,
                          );
                          }
                        }
                        return Container(); // Return an empty container instead of null
                      },
                    );
                  }
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                        color: Colors.white,
                        size: 20
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error loading Tasks",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No Tasks",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: utype=="Admin"||utype=="Teacher"?
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "Edit",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AllTasks()
                  )
              );
            },
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "Add",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTasks()
                  )
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      )
          :
      Container()
    );
  }
}
