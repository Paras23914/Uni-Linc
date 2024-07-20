import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:college_dashboard/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class EditEvents extends StatefulWidget {
  EditEvents({super.key, required this.id, required this.title, required this.des, required this.date});
  final String id;
  final DateTime date;
  final String des;
  final String title;
  @override
  State<EditEvents> createState() => _EditEventsState();
}

class _EditEventsState extends State<EditEvents> {
  final firestore = FirebaseFirestore.instance;
  final emailvals = FirebaseAuth.instance.currentUser!.email;
  final _formkey = GlobalKey<FormBuilderState>();
  late final data;
  bool loading = false;

  update() async {
    final eventdata = firestore.collection('events').doc(widget.id);
    try {
      await eventdata.update(data);
      Utils().toastmessage("Event Updated Successfully");
    } on FirebaseException catch (e) {
      Utils().toastmessage("Error Updating");
      print(e.message);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff191720),
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
          'Edit Event',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Card(
                color: const Color(0xff282828),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FormBuilder(
                    key: _formkey,
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          initialValue: widget.title,
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
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Colors.red,
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
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.description,
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.all(20),
                            hintText: 'Enter Your Description',
                            hintStyle: const TextStyle(
                                fontSize: 16.0, color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Colors.red,
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
                        FormBuilderDateTimePicker(
                          name: "Date",
                          validator: (value) {
                            if (value == null) {
                              return '❗   Please Enter Date';
                            }
                            return null;
                          },
                          format: DateFormat('EEEE, dd MMM, yyyy'),
                          initialValue: widget.date,
                          inputType: InputType.date,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                            fontFamily: 'Cardo',
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.all(20),
                            hintText: 'Enter Date',
                            hintStyle: const TextStyle(
                                fontSize: 16.0, color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Colors.red,
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
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                        _formkey.currentState!.save();
                        data = Map<String, dynamic>.from(
                            _formkey.currentState!.value);
                        data['Date'] = (data['Date'] as DateTime)
                            .millisecondsSinceEpoch;
                        data['UserID'] = emailvals;
                        loading = true;
                      });
                      update();
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.transparent),
                    shadowColor:
                    MaterialStateProperty.all<Color>(Colors.transparent),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  )
                      : const Text(
                    'Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
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
