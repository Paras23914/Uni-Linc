import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constant.dart';
import 'login.dart';


// ignore: camel_case_types
class signUp extends StatefulWidget {
  const signUp({Key? key}) : super(key: key);

  @override
  _signUpState createState() => _signUpState();
}

// ignore: camel_case_types
class _signUpState extends State<signUp> {
  final firestore = FirebaseFirestore.instance;
  final _formkey = GlobalKey<FormState>();
  var email = "";
  var password = "";
  var confirmPassword = "";
  String? branchName;
  String? department;
  bool loading=false;
  var rollNo = "";
  var studentName = "";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final branchController = TextEditingController();
  final departmentController = TextEditingController();
  final rollnoController = TextEditingController();
  final contactController = TextEditingController();
  final studentNameController = TextEditingController();

  List<String> branchval = <String>['B.Tech','M.Tech','M.Sc','B.Sc'];
  List<String> deptval=<String>[""];

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please Enter Your Email";
    }
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value.isEmpty || !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }
  /*
void printFireBase() {
    branchName.child('branch').once().then((DatabaseEvent databaseEvent) {
      print('Data: ${databaseEvent.snapshot.value}');
    });
  }

  void addData(String bra) {
    branchName
        .child('branch')
        .push()
        .set({'Branch Name': bra, 'comment': 'This is Branch'});
  }

  void printFireBase1() {
    rollNo.child('rollno').once().then((DatabaseEvent databaseEvent) {
      print('Data: ${databaseEvent.snapshot.value}');
    });
  }

  void addData1(String roll) {
    rollNo
        .child('rollno')
        .push()
        .set({'Roll No': roll, 'comment': 'This is Roll no'});
  }


  void printFireBase2() {
    studentName.child('studName').once().then((DataSnapshot snapshot) {
      print('Data: ${snapshot.value}');
    });
  }
 
  void printFireBase2() {
    studentName.child('studName').once().then((DatabaseEvent databaseEvent) {
      print('Data: ${databaseEvent.snapshot.value}');
    });
  }

  void addData2(String studName) {
    studentName
        .child('studName')
        .push()
        .set({'Student Name': studName, 'comment': 'This is student name'});
  }
 */
  registration() async {
    if (password == confirmPassword) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        // print(userCredential);

        // Create a user document in the "users" collection , jisme user cred kae hisab sae users collection mae jaye
        final uuid = userCredential.user!.uid;

        final userDocRef = firestore.collection('user').doc(uuid);

        try {
          await userDocRef.set({
            'studentName':
                studentNameController.text, // Assuming you have a controller
            'branchName': branchName,
            'department': department,
            'rollNo': rollnoController.text,
            'type':'Student',
              'image':'',
            'contact':contactController.text,
            'email':
                email, // Store email for potential future use cases (avoid using it for authentication)
          });
          loading=false;
          // Show success message or navigate to another screen
        } on FirebaseException catch (e) {
          // Handle Firebase errors (e.g., email already in use)
          loading=false;
          // print(e.message);
          Utils().toastmessage(e.message!);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Registered Successfully, Please Login....",
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                'Password provided is too weak',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                'Account Already Exists',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Password and confirm password doesn't match",
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ),
      );
    }
    setState(() {
      loading=false;
    });
  }

  late bool _passwordVisible;
  late bool _passwordVisible2;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    branchController.dispose();
    departmentController.dispose();
    rollnoController.dispose();
    studentNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
    _passwordVisible2 = true;
  }

  @override
  Widget build(BuildContext context) {
    //printFireBase();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          },
          icon: const Icon(Icons.arrow_back_ios,color: Colors.white,)
        ),
      ),
      body: Container(
        color: kBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Stack(children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width/2.65, 0,0,0
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontFamily: 'Cardo',
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Form(
                  key: _formkey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 30.0),
                    child: ListView(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17.0,
                                fontFamily: 'Cardo',
                              ),
                              cursorColor: Colors.grey,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofocus: false,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Colors.grey,
                                ),
                                contentPadding: const EdgeInsets.all(20),
                                hintText: 'Please Enter Your Email ID',
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
                              controller: emailController,
                              validator: validateEmail
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            enableInteractiveSelection: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontFamily: 'Cardo',
                            ),
                            cursorColor: Colors.grey,
                            autofocus: false,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: _passwordVisible,
                            decoration: InputDecoration(
                              suffixIcon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: IconButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
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
                              prefixIcon: const Icon(
                                Icons.vpn_key,
                                color: Colors.grey,
                              ),
                              contentPadding: const EdgeInsets.all(20),
                              hintText: 'Enter Your Password',
                              hintStyle: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
                                fontFamily: 'Cardo',
                              ),
                              border: const OutlineInputBorder(),
                              errorStyle: const TextStyle(
                                color: Colors.red,
                                fontSize: 16.0,
                                fontFamily: 'Cardo',
                              ),
                            ),
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '❗   Please Enter Password';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            enableInteractiveSelection: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontFamily: 'Cardo',
                            ),
                            cursorColor: Colors.grey,
                            autofocus: false,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.next,
                            obscureText: _passwordVisible2,
                            decoration: InputDecoration(
                              suffixIcon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: IconButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible2 = !_passwordVisible2;
                                    });
                                  },
                                  icon: Icon(
                                    _passwordVisible2
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
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
                              prefixIcon: const Icon(
                                Icons.vpn_key,
                                color: Colors.grey,
                              ),
                              contentPadding: const EdgeInsets.all(20),
                              hintText: 'Confirm your password',
                              hintStyle: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
                                fontFamily: 'Cardo',
                              ),
                              border: const OutlineInputBorder(),
                              errorStyle: const TextStyle(
                                color: Colors.red,
                                fontSize: 16.0,
                                fontFamily: 'Cardo',
                              ),
                            ),
                            controller: confirmPasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '❓   Please Re-enter Password';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.characters,
                            enableInteractiveSelection: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontFamily: 'Cardo',
                            ),
                            cursorColor: Colors.grey,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.person_sharp,
                                color: Colors.grey,
                              ),
                              contentPadding: const EdgeInsets.all(20),
                              hintText: 'Please Enter Student Name',
                              hintStyle:
                                  const TextStyle(fontSize: 16.0, color: Colors.grey),
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
                            controller: studentNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '⁉   Please Enter Student Name';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: DropdownButtonFormField<String>(
                            dropdownColor: Colors.blueGrey,
                            style: const TextStyle(color: Colors.white),
                            value: branchName,
                            hint: const Text(
                              'Please Enter Your Degree',
                              style: TextStyle(fontSize: 16.0, color: Colors.grey),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                branchName = newValue!;
                                department="";
                                // print(branchName);
                                switch(branchName){
                                  case 'B.Tech':
                                  case 'M.Tech':
                                    // print("!");
                                    deptval=<String>['CSE','ECE','Civil','Mech','ITE'];
                                    break;
                                  case 'B.Sc':
                                  case 'M.Sc':
                                    // print("W");
                                    deptval=<String>['Computers','Agriculture','Chemistry','Maths','Physics'];
                                    break;
                                }
                              });
                            },
                            items: branchval.map<DropdownMenuItem<String>>((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.book,
                                color: Colors.grey,
                              ),

                              contentPadding: const EdgeInsets.all(20),
                              hintStyle: const TextStyle(fontSize: 16.0, color: Colors.grey),
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '📛   Please Enter Your Degree';
                              }
                              return null;
                            },
                          )
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: DropdownButtonFormField<String>(
                            dropdownColor: Colors.blueGrey,
                            style: const TextStyle(color: Colors.white),
                            value: department==""?null:department,
                            hint: const Text(
                              'Please Enter Your Branch',
                              style: TextStyle(fontSize: 16.0, color: Colors.grey),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                department = newValue!;
                                // print(branchName);
                              });
                            },
                            items: deptval.map<DropdownMenuItem<String>>((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.book,
                                color: Colors.grey,
                              ),

                              contentPadding: const EdgeInsets.all(20),
                              hintStyle: const TextStyle(fontSize: 16.0, color: Colors.grey),
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '📛   Please Enter Your Branch Name';
                              }
                              return null;
                            },
                          )
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            enableInteractiveSelection: true,
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontFamily: 'Cardo',
                            ),
                            cursorColor: Colors.grey,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.format_list_numbered_rounded,
                                color: Colors.grey,
                              ),
                              contentPadding: const EdgeInsets.all(20),
                              hintText: 'Please Enter Your Roll no.',
                              hintStyle:
                              const TextStyle(fontSize: 16.0, color: Colors.grey),
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
                            controller: rollnoController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '🚫  Please Enter Roll No';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            enableInteractiveSelection: true,
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontFamily: 'Cardo',
                            ),
                            cursorColor: Colors.grey,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.phone,
                                color: Colors.grey,
                              ),
                              contentPadding: const EdgeInsets.all(20),
                              hintText: 'Please Enter Your Contact Number.',
                              hintStyle:
                              const TextStyle(fontSize: 16.0, color: Colors.grey),
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
                            controller: contactController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '🚫  Please Enter Contact No';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          height: 60,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              /*
                              addData(branchController.text);
                              addData1(rollnoController.text);
                              addData2(studentNameController.text);
                              */
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = emailController.text;
                                  password = passwordController.text;
                                  confirmPassword = passwordController.text;
                                  studentName = studentNameController.text;
                                  rollNo = rollnoController.text;
                                  loading=true;
                                });
                                registration();
                              }
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              )),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              overlayColor: MaterialStateProperty.resolveWith(
                                (states) => Colors.grey,
                              ),
                            ),
                            child: !loading?const Text(
                              'Sign Up',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 18),
                            ):
                                const CircularProgressIndicator(),
                          ),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: kBodyText,
                              ),
                              TextButton(
                                  onPressed: () => {
                                        Navigator.pushReplacement(
                                          context,
                                          PageRouteBuilder(
                                              pageBuilder: (context, animation1,
                                                      animation2) =>
                                                  const Login(),
                                              transitionDuration:
                                                  const Duration(seconds: 0)),
                                        )
                                      },
                                  child: const Text('Login',
                                      style: TextStyle(color: Colors.white)))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
