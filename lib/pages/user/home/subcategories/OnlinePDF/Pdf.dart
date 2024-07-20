import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:college_dashboard/pages/user/home/subcategories/OnlinePDF/AddPdfs.dart';
import 'package:college_dashboard/pages/user/home/subcategories/OnlinePDF/AllPDFs.dart';
import 'package:college_dashboard/pages/user/home/subcategories/OnlinePDF/ViewPDF.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Pdfs extends StatefulWidget {
  const Pdfs({super.key});

  @override
  State<Pdfs> createState() => _PdfsState();
}

class _PdfsState extends State<Pdfs> {
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
  String searchValue = "";

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

  Widget ViewPdfs(String title, int date, String id) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewPDFDetail(
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
                // colors: [Color(0xFF009688), Color(0xFF2196F3)], // Teal to Blue gradient
                // colors: [Color(0xFF00B4DB), Color(0xFF0083B0)], // Cyan to Green gradient
                // colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)], // Red to Orange gradient
                // colors: [Color(0xFF6A1B9A), Color(0xFF311B92)], // Purple to Blue gradient
                // colors: [Color(0xFF00C6FF), Color(0xFF0072FF)], // Light Blue to Light Green gradient
                // colors: [Color(0xFFFF8C00), Color(0xFFFF0080)], // Orange to Pink gradient
                colors: [Color(0xFFFF9A8B), Color(0xFFFF6A88)], // Peach to Pink gradient
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
                      Icons.note,
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
          "Online PDFs",
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
                "Online PDFs for ${branch ?? ""} ${dept ?? ""}",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (textval) {
                setState(() {
                  searchValue = textval;
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                hintText: 'Search PDFs...',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xff292B37),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: firestore
                  .collection('PDFs')
                  .orderBy('Date', descending: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No PDFs",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        if ((snapshot.data!.docs[index]['Dept'] == dept ||
                            snapshot.data!.docs[index]['Dept'] == 'Admin' ||
                            dept == 'Admin') &&
                            (snapshot.data!.docs[index]['Branch'] == branch ||
                                snapshot.data!.docs[index]['Branch'] == 'Admin' ||
                                branch == 'Admin')) {
                          if (snapshot.data!.docs[index]['Title']
                              .toString()
                              .toLowerCase()
                              .contains(searchValue.toLowerCase()) ||
                              searchValue == '') {
                            return ViewPdfs(
                              snapshot.data!.docs[index]['Title'],
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
                      "Error loading PDFs",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No PDFs",
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
                      builder: (context) => const AllPDFs()
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
                      builder: (context) => AddPdfs()
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
