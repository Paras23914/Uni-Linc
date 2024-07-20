
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/pages/user/home/subcategories/Events/AllEvents.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../login.dart';
import 'addevent.dart';
import 'ViewEvent.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime show=DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final firestore = FirebaseFirestore.instance;
  String name = "";
  String? branch;
  String? dept;
  String? utype;
  String? roll;
  String? img;
  String? contact;
  DocumentSnapshot? data;
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
      });
    }
    // print(show);

  }


  Widget ViewEvent(titleval,dateval,id){
    return ListTile(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context)=>ViewEventDetail(id: id)));
      },
      textColor: Colors.white70,
      title: Text(
          titleval,
      style: const TextStyle(
          color: Colors.white,
        fontWeight: FontWeight.bold
      ),),
      subtitle: Text(
        DateFormat('EEEE, dd MMMM, yyyy').format(dateval)
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
          "Events",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              formatAnimationDuration: Duration(milliseconds: 250),
              calendarStyle: CalendarStyle(
                weekendDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10)
                ),
                outsideDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10)
                ),
                cellPadding: const EdgeInsets.all(1),
                todayDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                todayTextStyle: const TextStyle(
                  fontSize: 17.5,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                selectedDecoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10), // Remove shape property
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.5,
                ),
                
                defaultTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                defaultDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), // Remove shape property
                ),
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                ),
                formatButtonDecoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.lightBlueAccent, Colors.purple],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                ),
                formatButtonPadding: const EdgeInsets.all(10),
                formatButtonTextStyle: const TextStyle(
                  color: Colors.white,
                ),
                leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2200, 1, 1),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    show = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },

            )
,
            const SizedBox(
              height: 20,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('events')
                  .where('Date', isEqualTo: show.millisecondsSinceEpoch - (show.millisecondsSinceEpoch % 86400000) - 19800000)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Events on this Date",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return ViewEvent(
                          snapshot.data?.docs[index]['Title'],
                          DateTime.fromMillisecondsSinceEpoch(snapshot.data?.docs[index]['Date']),
                          snapshot.data?.docs[index].id,
                        );
                      },
                    );
                  }
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return  Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                        color: Colors.white,
                        size: 20
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error loading events",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No Events on this Date",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
              },
            ),

          ],
        ),
      ),
      floatingActionButton: utype=="Admin"?
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "Edit",
            onPressed: (){

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AllEvents()
                  )
              );
            },
            child: const Icon(
                Icons.edit
            ),
          ),
          const SizedBox(height: 10,),
          FloatingActionButton(
            heroTag: "Add",
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddEvent(
                          arg:DateTime.fromMillisecondsSinceEpoch(show!.millisecondsSinceEpoch-(show!.millisecondsSinceEpoch%86400000)-19800000)
                      )
                  )
              );
            },
            child: const Icon(
                Icons.add
            ),
          ),
        ],
      )
          :
      Container()
    );
  }
}
