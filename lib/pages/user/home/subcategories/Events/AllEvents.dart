
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/login.dart';
import 'package:college_dashboard/pages/user/home/subcategories/Events/EditEvents.dart';
import 'package:college_dashboard/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AllEvents extends StatefulWidget {
  const AllEvents({super.key});

  @override
  State<AllEvents> createState() => _AllEventsState();
}

class _AllEventsState extends State<AllEvents> {

  final firestore = FirebaseFirestore.instance;
  final email= FirebaseAuth.instance.currentUser!.email;


  Widget ViewEvent(titleval,desval,dateval,id,data){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  titleval,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    DateFormat('EEEE, dd MMMM, yyyy').format(dateval),
                    style: const TextStyle(
                      color: Colors.white70,
                    )
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                    desval,
                    style: const TextStyle(
                      color: Colors.white70,
                    )
                ),
              ),
              PopupMenuButton(
                  iconColor: Colors.white,
                  itemBuilder: (context)=>[
                    PopupMenuItem(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder:
                                    (context)=>EditEvents(
                                        title: titleval,
                                        des: desval,
                                        date: dateval,
                                        id: id
                                    )
                            )
                        );
                      },
                      value: 1,
                      child: const ListTile(
                        leading: Icon(Icons.edit),
                        trailing: Text("Edit"),
                      ),
                    ),
                    PopupMenuItem(
                      onTap: (){
                        data.delete().then(
                              (doc) => Utils().toastmessage("Document deleted"),
                          onError: (e) => Utils().toastmessage("Error Deleting document $e"),
                        );
                      },
                      value: 2,
                      child: const ListTile(
                        leading: Icon(Icons.delete),
                        trailing: Text("Remove"),
                      ),
                    )
                  ]
              )
            ],
          ),
          const Divider()
        ],
      ),
    );
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
            'All Your Events',
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
          child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('events')
                  .where('UserID',isEqualTo:email)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if(snapshot.data!=null){
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context,index){
                      return ViewEvent(
                        snapshot.data?.docs[index]['Title'],
                        snapshot.data?.docs[index]['Description'],
                        DateTime.fromMillisecondsSinceEpoch(snapshot.data?.docs[index]['Date']),
                        snapshot.data?.docs[index].id,
                          firestore
                              .collection('events')
                              .doc(snapshot.data?.docs[index].id)
                        // _selectedDay!
                      );
                    },
                  );
                }
                else{
                  return const Center(
                    child: Text(
                      "No Events on this Date",
                      style: TextStyle(
                          color: Colors.white70
                      ),
                    ),
                  );
                }
              }
          ),
        )
    );
  }
}
