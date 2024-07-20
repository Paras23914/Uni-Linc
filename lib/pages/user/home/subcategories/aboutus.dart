import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant.dart';

class aboutus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: kBackgroundColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset(
              'assets/images/back_arrow.svg',
              width: 24,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: Stack(
                children: <Widget>[
                  Text(
                    'About US',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontFamily: 'Cardo',
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        child: Column(children: const [
                          SizedBox(
                            height: 80,
                          ),
                          CircleAvatar(
                            radius: 65.0,
                            backgroundImage:
                                AssetImage('assets/images/kartik.jpg'),
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Kartik Sharma',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                              )),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            '2007520',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 15.0,
                            ),
                          )
                        ]),
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      Container(
                        child: Column(children: const [
                          SizedBox(
                            height: 80,
                            width: 80,
                          ),
                          CircleAvatar(
                            radius: 65.0,
                            backgroundImage:
                                AssetImage('assets/images/paras.jpg'),
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text('Paras Sharma',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                              )),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            '2007544',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 15.0,
                            ),
                          )
                        ]),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 500,
                        ),
                        Text(
                          'Motivation',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontFamily: 'Cardo',
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "We created this app together to assist student - college communication. We are a team of twp students from the same college and we know the problems faced by students in their college life. We have created this app to help students in their college life. We hope you like our app and it helps you in your college life.",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
