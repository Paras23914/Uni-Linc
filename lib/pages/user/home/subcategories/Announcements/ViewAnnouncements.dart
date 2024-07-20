import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewAnnouncementDetail extends StatefulWidget {
  const ViewAnnouncementDetail({super.key, required this.id});
  final String id;

  @override
  State<ViewAnnouncementDetail> createState() => _ViewAnnouncementDetailState();
}

class _ViewAnnouncementDetailState extends State<ViewAnnouncementDetail> {
  final firestore = FirebaseFirestore.instance;
  String title = "";
  String? description;
  DateTime? date;
  String? fileName;
  String? fileLink;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchAnnouncementDetails();
  }

  Future<void> fetchAnnouncementDetails() async {
    final announcementDoc = firestore.collection('announcements').doc(widget.id);
    final snapshot = await announcementDoc.get();
    if (snapshot.exists) {
      setState(() {
        title = snapshot['Title'];
        description = snapshot['Description'];
        fileName = snapshot['FileName'];
        fileLink = snapshot['URL'];
        userId = snapshot['UserID'];
        date = DateTime.fromMillisecondsSinceEpoch(snapshot['Date']);
      });
    } else {
      print("Error: Document does not exist.");
    }
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(fileLink!))) {
      throw Exception('Could not launch');
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
          'Announcement',
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
          )
        ],
      ),
      backgroundColor: const Color(0xff191720),
      body: title.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.dotsTriangle(color: Colors.white, size: 45),
            const SizedBox(height: 10),
            const Text(
              "Loading",
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          color: const Color(0xff2C2C34),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.announcement,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  DateFormat('EEEE, dd MMMM, yyyy').format(date!),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  description!,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
                if (fileLink != null && fileLink!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: GestureDetector(
                      onTap: () {

                        _launchUrl();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.link,
                            color: Colors.blueAccent,
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              fileName ?? "Open Attachment",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
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
}
