import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:college_dashboard/pages/user/home/subcategories/OnlinePDF/EditPDFs.dart';
import 'package:college_dashboard/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllPDFs extends StatefulWidget {
  const AllPDFs({super.key});

  @override
  State<AllPDFs> createState() => _AllPDFsState();
}

class _AllPDFsState extends State<AllPDFs> {
  final email = FirebaseAuth.instance.currentUser?.email;
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  Widget viewPDF(String title, int date, String filename, String link, String id, DocumentReference data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              // colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple to Blue gradient
              // colors: [Color(0xFF009688), Color(0xFF2196F3)],
              colors: [Color(0xFFFF9A8B), Color(0xFFFF6A88)], // Peach to Pink gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.note_sharp,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
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
                    const SizedBox(height: 10),
                    Text(
                      DateFormat('EEEE, dd MMMM, yyyy').format(
                        DateTime.fromMillisecondsSinceEpoch(date),
                      ).toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                iconColor: Colors.white,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPDFs(
                            title: title,
                            fileName: filename,
                            fileLink: link,
                            id: id,
                          ),
                        ),
                      );
                    },
                    value: 1,
                    child: const ListTile(
                      leading: Icon(Icons.edit),
                      trailing: Text("Edit"),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      data.delete().then(
                            (doc) => Utils().toastmessage("Document deleted"),
                        onError: (e) => Utils().toastmessage("Error Deleting document $e"),
                      );
                    },
                    value: 2,
                    child: const ListTile(
                      leading: Icon(Icons.delete),
                      trailing: Text("Remove"),
                    ),
                  ),
                ],
              ),
            ],
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
          "All PDFs",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
            },
            icon: const Icon(
              Icons.logout_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xff191720),
      body: email == null
          ? const Center(
        child: Text(
          "User email not found.",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : StreamBuilder(
        stream: firestore.collection('PDFs')
            .orderBy('Date',descending: true)
            .where('UserID', isEqualTo: email)
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
                  return viewPDF(
                    snapshot.data!.docs[index]['Title'],
                    snapshot.data!.docs[index]['Date'],
                    snapshot.data!.docs[index]['FileName'],
                    snapshot.data!.docs[index]['URL'],
                    snapshot.data!.docs[index].id,
                    firestore.collection('PDFs').doc(snapshot.data!.docs[index].id),
                  );
                },
              );
            }
          } else {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Error loading PDFs",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    "No Online PDFs Shared by You",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }
}
