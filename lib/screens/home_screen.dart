import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddbusinessside/screens/manage_catalog.dart';
import 'package:ddbusinessside/screens/manage_orders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = <Widget>[ManageOrders(),ManageCatalog()];
  final firestore = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  bool _initialized = false;
  @override
  void initState() {
    FirebaseAuth _auth=FirebaseAuth.instance;
      _auth.signInWithEmailAndPassword(email: 'maithilibhuta@dripanddrizzle.com', password: 'IHateMeghGala@666').then((value){setState(() {});});
    _auth.currentUser().then((value) => _fcm.subscribeToTopic('Orders'));
    if (!_initialized) {
      _fcm.getToken().then((value) => print("FirebaseMessaging token: $value"));
      _initialized = true;
    }
    _fcm.configure(
      onMessage: (Map <String, dynamic> message) async{
        showDialog(context: context,
        builder: (context)=>AlertDialog(
          content: ListTile(
            title: Text(message['notification']['title']),
            subtitle: Text(message['notification']['body']),
          ),
          actions: <Widget>[
            FlatButton(child: Text('Go to Orders'),onPressed:(){_selectedIndex=1;Navigator.of(context).pop();},)
          ],
        ),
        );
      }
    );

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index){
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedItemColor: Color(0xfff368e0),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.store),
                title: Text('Orders'),
              ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_comfy),
            title: Text('Catalog'),
          ),

        ]),
      appBar: AppBar(
        title: Text('Drip&Drizzle Admin',style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
      ),
        body:_widgetOptions[_selectedIndex],//ManageOrders(),//ManageCatalog(),
      ),
    );
  }
}
