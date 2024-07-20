import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:college_dashboard/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class EditVideos extends StatefulWidget {
  const EditVideos({
    super.key,
    required this.title,
    required this.des,
    required this.id,
    required this.fileName,
    required this.fileLink,
  });

  final String title;
  final String des;
  final String id;
  final String fileName;
  final String fileLink;
  @override
  State<EditVideos> createState() => _EditVideosState();
}

class _EditVideosState extends State<EditVideos> {
  PlatformFile? pickedfile;
  UploadTask? upload;
  final firestore = FirebaseFirestore.instance;
  final emailvals = FirebaseAuth.instance.currentUser!.email;
  final _formkey = GlobalKey<FormBuilderState>();
  Map<String, dynamic>? data;
  bool loading = false;
  String download = "";
  String name = "";

  selectfile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        pickedfile = result.files.first;
      });
    }
    fileUpload();
  }

  Future<void> fileUpload() async {
    if (pickedfile != null) {
      setState(() {
        name = pickedfile!.name;
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

  updateVideo() async {
    final videodata = firestore.collection('Videos').doc(widget.id);
    try {
      await videodata.update(data!);
      Utils().toastmessage("Video Updated Successfully");
    } on FirebaseException catch (e) {
      print(e.message);
      Utils().toastmessage("Error");
    }
    setState(() {
      loading = false;
    });
  }

  Widget progress() => StreamBuilder(
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
          'Edit Video',
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
                    boxShadow: const [
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
                        initialValue: widget.title,
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
                      FormBuilderTextField(
                        initialValue: widget.des,
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
                            onPressed: selectfile,
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
                              pickedfile?.name ?? widget.fileName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      progress(),
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
                        data!['UserID'] = emailvals;
                        data!['FileName'] = name==""?widget.fileName:name;
                        data!['URL'] = download==""?widget.fileLink:download;
                        loading = true;
                      });
                      updateVideo();
                      // Reset form and data after submission
                      _formkey.currentState!.reset();
                      data = null;
                      pickedfile = null;
                      name = "";
                      download = "";
                      Navigator.pop(context);
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
                    'Update',
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
