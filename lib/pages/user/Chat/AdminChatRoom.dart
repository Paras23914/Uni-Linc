import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AdminChatRoom extends StatefulWidget {
  AdminChatRoom({super.key, required this.id});
  final String id;
  @override
  State<AdminChatRoom> createState() => _AdminChatRoomState();
}

class _AdminChatRoomState extends State<AdminChatRoom> {
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
  final msg = TextEditingController();

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
    } else {
      // Handle non-existent document and optionally create it
      await userdoc.set({
        'studentName': 'Unknown',
        'branchName': 'Unknown',
        'department': 'Unknown',
        'rollNo': 'Unknown',
        'image': '',
        'type': 'Unknown',
        'contact': 'Unknown',
        'rollNo': 'Unknown',
      });
      print("Created user document with default values");
      setState(() {
        name = "Unknown";
        branch = "Unknown";
        dept = "Unknown";
        roll = "Unknown";
        img = "";
        utype = "Unknown";
        contact = "Unknown";
        rollno = "Unknown";
      });
    }
    if(utype!="Admin"){
      Check();
    }
  }

  Check() async{
    final userdoc = firestore.collection('Admin').doc(email!+"_"+name);
    final snapshot = await userdoc.get();
    if (!snapshot.exists)
    {
      // Handle non-existent document and optionally create it
      await userdoc.set({
        'studentName': name,
        "email":email
      });
    }
  }

  void sendMessage() async {
    if (msg.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": email,
        "name": name,
        "image": img,
        "message": msg.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      msg.clear();
      await firestore
          .collection('Admin').doc(widget.id).collection("chats")
          .add(messages);
    } else {
      print("Enter Some Text");
    }
  }

  File? image;

  void sendImage() async {
    final ImagePicker _picker = ImagePicker();

    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
      uploadImage();
    }
  }

  Future uploadImage() async {
    if (image == null) return;

    String fileName = Uuid().v1();
    int status = 1;

    await firestore
        .collection('Admin')
        .doc(widget.id)
        .collection("chats")
        .doc(fileName)
        .set({
      "sendby": email,
      "name": name,
      "image": img,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref = FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(image!).catchError((error) async {
      await firestore
          .collection('Admin')
          .doc(widget.id)
          .collection("chats")
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await firestore
          .collection('Admin')
          .doc(widget.id)
          .collection("chats")
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  Widget message(Alignment align, DocumentSnapshot msg) {
    final isOwnMessage = align == Alignment.topRight;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isOwnMessage)
            msg['image'] == null || msg['image'] == ''
                ? Icon(CupertinoIcons.profile_circled, color: Colors.white,)
                : CircleAvatar(
              backgroundImage: NetworkImage(msg['image'] ?? ''),
              radius: 20,
            ),
          SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isOwnMessage
                    ? [Color(0xFF654ea3), Color(0xFFff5e62)] // Blue to Cyan for own messages
                    : [Color(0xFF11998e), Color(0xFF0072FF)], // Deep Purple to Pink for others
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: isOwnMessage
                  ? BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              )
                  : BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg['name'] ?? 'Anonymous',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (msg['type'] == 'text')
                  Text(
                    msg['message'] ?? '',
                    style: TextStyle(color: Colors.white),
                  )
                else if (msg['type'] == 'img')
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 3,
                        maxWidth: MediaQuery.of(context).size.width / 1.25
                    ),
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ShowImage(
                            imageUrl: msg['message'],
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: msg['message'] == null || msg['message'] == ""
                            ? Text("Loading the Image...", style: TextStyle(color: Colors.white),)
                            : Image.network(
                          msg['message'],
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 4),
                if (msg["time"] != null)
                  Text(
                    DateFormat('hh:mm a').format(
                      msg["time"].toDate(),
                    ),
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  )
                else
                  Text(
                    "Sending...",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8),
          if (isOwnMessage)
            img == null || img == ''
                ? Icon(CupertinoIcons.profile_circled, color: Colors.white,)
                : CircleAvatar(
              backgroundImage: NetworkImage(img!),
              radius: 20,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1f1f2e),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.keyboard_arrow_left,
            color: Colors.white,
          ),
        ),
        title: Text(
          email! + "_" + name != widget.id
              ?
              widget.id.substring(widget.id.indexOf("_")+1, widget.id.length)
          :
          "Admin",
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
          ),
        ],
      ),
      backgroundColor: const Color(0xff1f1b24),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection("Admin").doc(widget.id).collection("chats")
                  .orderBy("time", descending: false)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Something went wrong"),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("No messages found"),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    if (snapshot.data?.docs[index]["sendby"] == email) {
                      return message(Alignment.topRight, snapshot.data!.docs[index]);
                    }
                    return message(Alignment.topLeft, snapshot.data!.docs[index]);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msg,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Send a message...",
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black45,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: sendMessage,
                ),
                IconButton(
                  icon: Icon(Icons.image, color: Colors.greenAccent),
                  onPressed: sendImage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;
  ShowImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
