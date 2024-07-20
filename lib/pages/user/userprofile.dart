import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/constant.dart';
import 'package:college_dashboard/pages/user/change_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:uuid/uuid.dart';

import '../login.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final email = FirebaseAuth.instance.currentUser!.email;
  final firestore = FirebaseFirestore.instance;
  String name = "";
  String? branch;
  String? dept;
  String? utype;
  String? roll;
  String? img;
  String? contact;
  String? rollno;
  DocumentSnapshot? data;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    update();
  }


  File? image;

  void sendImage() async {
    ImagePicker pick=ImagePicker();
    await pick.pickImage(source: ImageSource.gallery).then((value){
      if(value!=null){
        image=File(value.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async{
    String filename=const Uuid().v1();
    int status=1;
    var reference=
    FirebaseStorage.instance.ref().child('users').child("$filename.jpg");
    setState(() {
      name='';
    });
    var uploadTask = await reference.putFile(image!).catchError((error) async {
      // Utils().toastmessage("Error in Uploading Image");
      print("This is error $error");
      status = 0;
      return 0;
    });
    print("Status is $status");
    if(status==1){
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await firestore
          .collection('user')
          .doc(uid)
          .update({"image": imageUrl});
      update();
    }
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
        rollno=snapshot.data()!['rollNo'];
      });
    }
  }

  verify() {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Verification Email has been sent",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: const Icon(
          CupertinoIcons.profile_circled,
          color: kBackgroundColor,
        ),
        title: Center(
          child: Text(
            'Profile',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white),
          ),
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
              ))
        ],
      ),
      body: name == ''
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white, size: 45),
                const Text(
                  "Loading",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                )
              ],
            ))
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: img == ""
                                ?
                            const Icon(
                                    CupertinoIcons.profile_circled,
                                    color: Colors.white,
                                    size: 120,
                                  )
                                // Image(image: AssetImage("5.png"),)
                                :
                            Image.network(
                                img!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: sendImage,
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.yellowAccent
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      name,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width*0.08,
                          color: Colors.white),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          email!,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width*0.04),
                        ),
                        FirebaseAuth.instance.currentUser!.emailVerified
                            ? const Icon(
                                Icons.verified,
                                color: Colors.green,
                              )
                            : Row(
                                children: [
                                  const SizedBox(width: 5),
                                  ElevatedButton(
                                    onPressed: () {
                                      verify();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.yellowAccent,
                                        side: BorderSide.none,
                                        shape: const StadiumBorder()),
                                    child: const Text(
                                      "Verify Now",
                                      style: TextStyle(color: kBackgroundColor),
                                    ),
                                  ),
                                ],
                              )
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellowAccent),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const changePass()),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_note,
                                color: kBackgroundColor,
                              ),
                              Text(
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                "Change Password",
                                style: TextStyle(

                                    color: kBackgroundColor,
                                    fontSize: MediaQuery.of(context).size.width*0.035,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          )),
                    ),
                    const SizedBox(height: 30),
                    const Divider(
                      indent: 40,
                      endIndent: 40,
                      thickness: 0.25,
                    ),
                    const SizedBox(height: 10),

                    //MENU

                    ListTile(
                      leading: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.blueAccent.withOpacity(0.1)),
                          child: Icon(
                            CupertinoIcons.profile_circled,
                            color: Colors.amber,
                            size: MediaQuery.of(context).size.width*0.09,
                          )),
                      title: Text(
                        "Type",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width*0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          child: Text(
                            utype!,
                            style:
                                TextStyle(fontSize: MediaQuery.of(context).size.width*0.04, color: Colors.white),
                          )),
                    ),
                    ListTile(
                      leading: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.blueAccent.withOpacity(0.1)),
                          child: Icon(
                            Icons.email,
                            color: Colors.amber,
                            size: MediaQuery.of(context).size.width*0.09,
                          )),
                      title: Text(
                        "Email",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width*0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          child: Text(
                            email!,
                            style:
                                TextStyle(fontSize: MediaQuery.of(context).size.width*0.04, color: Colors.white),
                          )),
                    ),
                    ListTile(
                      leading: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.blueAccent.withOpacity(0.1)),
                          child: Icon(
                            Icons.call,
                            color: Colors.amber,
                            size: MediaQuery.of(context).size.width*0.09,
                          )),
                      title: Text(
                        "Contact Number",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width*0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          child: Text(
                            contact!,
                            style:
                                TextStyle(fontSize: MediaQuery.of(context).size.width*0.04, color: Colors.white),
                          )),
                    ),
                    ListTile(
                      leading: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.blueAccent.withOpacity(0.1)),
                          child: Icon(
                            Icons.perm_identity,
                            color: Colors.amber,
                            size: MediaQuery.of(context).size.width*0.09,
                          )),
                      title: Text(
                        utype=="Student"?"Roll Number":"Employee ID",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width*0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          child: Text(
                            rollno!,
                            style:
                            TextStyle(fontSize: MediaQuery.of(context).size.width*0.04, color: Colors.white),
                          )),
                    ),
                    utype=="Student"||utype=="Teacher"?
                    ListTile(
                      leading: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.blueAccent.withOpacity(0.1)),
                          child: Icon(
                            CupertinoIcons.building_2_fill,
                            color: Colors.amber,
                            size: MediaQuery.of(context).size.width*0.09,
                          )),
                      title: Text(
                        "Degree",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width*0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          child: Text(
                            branch!,
                            style:
                                TextStyle(fontSize: MediaQuery.of(context).size.width*0.04, color: Colors.white),
                          )),
                    ):
                    Container(),
                    utype=="Student"||utype=="Teacher"?
                    ListTile(
                      leading: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.blueAccent.withOpacity(0.1)),
                          child: Icon(
                            Icons.book,
                            color: Colors.amber,
                            size: MediaQuery.of(context).size.width*0.09,
                          )),
                      title: Text(
                        "Branch",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width*0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          child: Text(
                            dept!,
                            style:
                                TextStyle(fontSize: MediaQuery.of(context).size.width*0.04, color: Colors.white),
                          )),
                    )
                      :
                        Container()

                  ],
                ),
              ),
            ),
    );
  }
}
