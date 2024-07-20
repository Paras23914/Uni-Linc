import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:college_dashboard/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:uuid/uuid.dart';

class AddVideos extends StatefulWidget {
  const AddVideos({super.key});

  @override
  State<AddVideos> createState() => _AddVideosState();
}

class _AddVideosState extends State<AddVideos> {
  PlatformFile? pickedfile;
  UploadTask? upload;
  final firestore = FirebaseFirestore.instance;
  final emailvals = FirebaseAuth.instance.currentUser!.email;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final _formkey = GlobalKey<FormBuilderState>();
  Map<String, dynamic>? data;
  bool loading = false;
  String download = "";
  String name = "";
  String stdname = "";
  String? branch;
  String? dept;
  String? utype;
  String? roll;
  String? img;
  String? contact;
  bool errorcheck = false;

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
        stdname = snapshot.data()!['studentName'];
        branch = snapshot.data()!['branchName'];
        dept = snapshot.data()!['department'];
        roll = snapshot.data()!['rollNo'];
        img = snapshot.data()!['image'];
        utype = snapshot.data()!['type'];
        contact = snapshot.data()!['contact'];
      });
    }
  }

  Widget displayError() {
    return const Text(
      "❗Please Attach a PDF File",
      style: TextStyle(
        color: Colors.red,
        fontSize: 16.0,
        fontFamily: 'Cardo',
      ),
    );
  }

  bool validate() {
    return name.isNotEmpty;
  }

  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        pickedfile = result.files.first;
      });
      await fileUpload();
    }
  }

  Future<void> fileUpload() async {
    if (pickedfile != null) {
      setState(() {
        name = pickedfile!.name;
        errorcheck = false;
      });

      if (!name.endsWith(".mp4")) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text("Only Videos Should be Uploaded as Lectures in MP4 Format"),
          ),
        );
        return;
      }

      final file = File(pickedfile!.path!);
      final ref = FirebaseStorage.instance.ref().child('Videos').child(name);
      setState(() {
        upload = ref.putFile(file);
      });

      upload!.snapshotEvents.listen((event) {
        setState(() {});
      });

      try {
        await upload!.whenComplete(() {});
        download = await ref.getDownloadURL();
        Utils().toastmessage("File Uploaded Successfully");
      } catch (e) {
        Utils().toastmessage("Error Uploading File: ${e.toString()}");
      }
    }
  }

  Future<void> addVideos() async {
    final uuid = Uuid().v1();
    final videodata = firestore.collection('Videos').doc(uuid);
    try {
      await videodata.set(data!);
      Utils().toastmessage("Video Lecture Added Successfully");
    } on FirebaseException catch (e) {
      Utils().toastmessage("Error: ${e.message}");
    }
    setState(() {
      loading = false;
    });
  }

  Widget progress() => StreamBuilder<TaskSnapshot>(
    stream: upload?.snapshotEvents,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final data = snapshot.data!;
        double progress = data.bytesTransferred / data.totalBytes;
        return Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              color: Colors.purple,
            ),
            Center(
              child: Text(
                '${(100 * progress).roundToDouble()}%',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      } else {
        return const SizedBox();
      }
    },
  );

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
          'Add Video Lectures',
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
      backgroundColor: const Color(0xff1f1f2e),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              FormBuilder(
                key: _formkey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        keyboardType: TextInputType.name,
                        name: 'Title',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '❗   Please Enter Title';
                          }
                          return null;
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontFamily: 'Cardo',
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.text_snippet_outlined,
                            color: Colors.grey,
                          ),
                          contentPadding: const EdgeInsets.all(20),
                          hintText: 'Enter Your Title',
                          hintStyle: const TextStyle(
                              fontSize: 16.0, color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            fontFamily: 'Cardo',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        keyboardType: TextInputType.name,
                        name: "Description",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '❗   Please Enter Description';
                          }
                          return null;
                        },
                        maxLines: 10,
                        minLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontFamily: 'Cardo',
                        ),
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.description,
                            color: Colors.grey,
                          ),
                          contentPadding: const EdgeInsets.all(20),
                          hintText: 'Enter Your Description',
                          hintStyle:
                          const TextStyle(fontSize: 16.0, color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            fontFamily: 'Cardo',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: selectFile,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              backgroundColor: Colors.lightBlueAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Upload File",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              pickedfile?.name ?? "No File Selected",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      progress(),
                      const SizedBox(height: 10),
                      errorcheck ? displayError() : Container(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                height: 60,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                        _formkey.currentState!.save();
                        data = Map<String, dynamic>.from(
                            _formkey.currentState!.value);
                        data!['Date'] = DateTime.now().millisecondsSinceEpoch;
                        data!['UserID'] = emailvals;
                        data!['FileName'] = name;
                        data!['URL'] = download;
                        data!['Dept'] = dept;
                        data!['Branch'] = branch;
                        loading = true;
                      });
                      if (validate()) {
                        addVideos();
                        // Reset form and data after submission
                        _formkey.currentState!.reset();
                        data = null;
                        pickedfile = null;
                        name = "";
                        download = "";
                      } else {
                        Utils().toastmessage("Kindly Attach the PDF File");
                        setState(() {
                          loading = false;
                          errorcheck = true;
                        });
                      }
                    } else {
                      setState(() {
                        errorcheck = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  )
                      : const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
