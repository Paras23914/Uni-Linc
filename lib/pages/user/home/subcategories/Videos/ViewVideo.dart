import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:college_dashboard/pages/login.dart';

class ViewVideoDetail extends StatefulWidget {
  const ViewVideoDetail({super.key, required this.id});
  final String id;

  @override
  State<ViewVideoDetail> createState() => _ViewVideoDetailState();
}

class _ViewVideoDetailState extends State<ViewVideoDetail> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  final firestore = FirebaseFirestore.instance;
  String title = "";
  String description = "";
  DateTime? date;
  String? fileName;
  String? fileLink;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchVideoDetails();
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> fetchVideoDetails() async {
    final videoDoc = firestore.collection('Videos').doc(widget.id);
    final snapshot = await videoDoc.get();
    if (snapshot.exists) {
      setState(() {
        title = snapshot['Title'];
        description = snapshot['Description'];
        fileName = snapshot['FileName'];
        fileLink = snapshot['URL'];
        userId = snapshot['UserID'];
        date = DateTime.fromMillisecondsSinceEpoch(snapshot['Date']);
        _controller = VideoPlayerController.networkUrl(Uri.parse(snapshot['URL']))
          ..initialize().then((_) {
            setState(() {
              _chewieController = ChewieController(
                videoPlayerController: _controller,
              );
            });
          });
      });
    } else {
      print("Error: Document does not exist.");
    }
  }


  Future<void> _downloadFile() async {
    // Request storage permissions

      // Get the download directory
      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        String downloadPath = path.join(directory.path, 'Download/Videos');
        Directory downloadDirectory = Directory(downloadPath);

        // Check if the directory exists, and if not, create it
        if (!await downloadDirectory.exists()) {
          await downloadDirectory.create(recursive: true);
        }

        // Full file path
        String filePath = path.join(downloadDirectory.path, fileName);

        // Download the file
        final response = await http.get(Uri.parse(fileLink!));
        if (response.statusCode == 200) {
          final file = File(filePath);
          Utils().toastmessage("Downloading Started");
          await file.writeAsBytes(response.bodyBytes);
          print('File downloaded to $filePath');
          Utils().toastmessage("Video Downloaded");
        } else {
          print('Error downloading file: ${response.statusCode}');
        }
      } else {
        print('Error: Download directory not found.');
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
          'Video Details',
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
          : SingleChildScrollView(
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
                      Icons.ondemand_video_rounded,
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
                Divider(color: Colors.white24),
                SizedBox(height: 10),
                Text(
                  "Description:",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20),
                Divider(color: Colors.white24),
                SizedBox(height: 10),
                Text(
                  "Posted On:",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('EEEE, dd MMMM, yyyy').format(date!),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                Divider(color: Colors.white24),
                SizedBox(height: 10),
                Text(
                  "Posted By:",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userId!,
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
                      onTap: _downloadFile,
                      child: Row(
                        children: [
                          Icon(
                            Icons.download,
                            color: Colors.blueAccent,
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              fileName ?? "Download Attachment",
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
                SizedBox(height: 20),
                Divider(color: Colors.white24),
                SizedBox(height: 10),
                _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                )
                    : Center(
                  child: Column(
                    children: [
                      LoadingAnimationWidget.threeRotatingDots(
                          color: Colors.white,
                          size: 20
                      ),
                      Text("Loading Video Lecture",style: TextStyle(color: Colors.white),),
                      Text("Please Wait..",style: TextStyle(color: Colors.white),),
                    ],
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
