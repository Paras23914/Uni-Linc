import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ViewEventDetail extends StatefulWidget {
  ViewEventDetail({super.key, required this.id});
  final String id;

  @override
  State<ViewEventDetail> createState() => _ViewEventDetailState();
}

class _ViewEventDetailState extends State<ViewEventDetail> {
  final firestore = FirebaseFirestore.instance;
  String title = "";
  String? description;
  DateTime? date;
  DocumentSnapshot? data;

  @override
  void initState() {
    super.initState();
    update();
  }

  Future<void> update() async {
    final userdoc = firestore.collection('events').doc(widget.id);
    final snapshot = await userdoc.get();
    if (snapshot.exists) {
      setState(() {
        title = snapshot.data()!['Title'];
        description = snapshot.data()!['Description'];
        date = DateTime.fromMillisecondsSinceEpoch(snapshot.data()!['Date']);
      });
    } else {
      print("Error");
    }
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
          'Event Details',
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
      body: title.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.dotsTriangle(
                color: Colors.white, size: 45),
            const SizedBox(height: 10),
            const Text(
              "Loading",
              style: TextStyle(fontSize: 15, color: Colors.white),
            )
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event,
                    color: Colors.white,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('EEEE, dd MMMM, yyyy').format(date!),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                description!,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
