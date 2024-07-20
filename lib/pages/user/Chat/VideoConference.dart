import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VideoConference extends StatefulWidget {
  const VideoConference({super.key, required this.id});

  final String id;
  @override
  State<VideoConference> createState() => _VideoConferenceState();
}

class _VideoConferenceState extends State<VideoConference> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final email = FirebaseAuth.instance.currentUser!.email;
  final firestore = FirebaseFirestore.instance;
  late AgoraClient client;
  String name = "";
  String? branch = "";
  String? dept = "";
  String utype = '';
  String? roll;
  String? img;
  String? contact;
  String? rollno;
  DocumentSnapshot? data;
  bool isClientInitialized = false;

  @override
  void initState() {
    super.initState();
    update();
  }

  @override
  void dispose() {
    super.dispose();
    out();
  }

  Future<void> out() async {
    final vid = firestore.collection("VideoConf").doc(widget.id);
    await vid.update({'Video': false});
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

      client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
          appId: "53d76d222d184ec1a33c2ee060454e2f",
          channelName: widget.id,
          username: name,
        ),
      );

      await client.initialize();
      setState(() {
        isClientInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff191720),
      body: SafeArea(
        child: isClientInitialized
            ? Stack(
                children: [
                  AgoraVideoViewer(
                    client: client,
                    layoutType: Layout.floating,
                    showNumberOfUsers: true,
                    enableHostControls: true,
                  ),
                  AgoraVideoButtons(
                    client: client,
                    autoHideButtons: true,
                    addScreenSharing: true,
                    autoHideButtonTime: 5,
                    onDisconnect: out,
                  ),
                ],
              )
            : Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.beat(color: Colors.white, size: 30),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Joining the Video Conference",
                      style: TextStyle(color: Colors.white),
                    ),
                    const Text(
                      "Please Wait..",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
