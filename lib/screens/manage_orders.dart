import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
class ManageOrders extends StatefulWidget {
  @override
  _ManageOrdersState createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders> {
  String _selectedItem='Orders';
  final firestore = Firestore.instance;
  final List<DropdownMenuItem> dropdownList = [
    DropdownMenuItem(
      child: Center(
        child: Text(
          'Orders'
          ,style:TextStyle(color: Colors.black),),),
      value: 'Orders',
    ),
    DropdownMenuItem(
        child: Center(
            child: Text(
                'Custom Orders',style:TextStyle(color: Colors.black)
            )),
        value: 'Custom Orders'),
    DropdownMenuItem(
      child: Center(
        child: Text(
          'Completed Orders'
          ,style:TextStyle(color: Colors.black),),),
      value: 'Completed Orders',
    ),
  ];
  void orderComplete(String documentID){
    Alert(
      context: context,
      type: AlertType.info,
      title: "Confirm order completion",
      buttons: [
        DialogButton(
          color: Colors.green,
          child: Text(
            "Confirm",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: (){
            print(documentID);
            Map data;
            firestore.collection(_selectedItem.replaceAll(" ", "")).document(documentID).get().then((value){
              data=value.data;
              data['orderStatus']='complete';
              print(value.data);
              firestore.collection('CompletedOrders').add(data).then((value) => 
            firestore.collection(_selectedItem.replaceAll(" ", "")).document(documentID).updateData({'orderStatus':'complete'}).then((value) => Navigator.pop(context))
            );});
            },
          width: 120,
        )
      ],
    ).show();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  items: dropdownList,
                  elevation: 16,
                  style: TextStyle(
                      color: Colors.black, fontSize: 20),
                  iconSize: 30,
                  hint: Text('Select Category'),
                  value: _selectedItem,
                  underline: Container(
                    padding: EdgeInsets.all(2),
                    height: 2,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedItem = value;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(_selectedItem,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),textAlign: TextAlign.left,),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore.collection(_selectedItem.replaceAll(" ", "")).snapshots(),
            builder: (context, snapshot) {
              final items = snapshot.data.documents;
              List<Card> orderCards=[];
              for(var item in items){
                  orderCards.add(
                    Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text('Customer Details: ',textAlign: TextAlign.left,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,)),
                          Expanded(child: Column(
                            mainAxisAlignment:MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                            children:<Widget>[Expanded(child:Text(item.data['customerName'])),
                              Expanded(child: Text(item.data['customerEmail'])),
                              Expanded(child:Text('+91 - ${item.data['customerMobileNumber']}')),Expanded(child:Text(item.data['customerAddress']))]
                          )),
                          Text('Order Details: ',textAlign: TextAlign.left,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,)),
                          Text('Delivery date: ${item.data['deliveryDate']}',textAlign: TextAlign.left,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,)),
                          _selectedItem=='Custom Orders'?
                            Expanded(child: Column(
                              mainAxisAlignment:MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text('Category:  ${item.data['category']}'),
                                Expanded(child:Text('Description: ${item.data['customDescription']}'))
                              ],
                            ),):
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: ListView(
                                    itemExtent: 40,
                                    children: <Widget>[
                                      for(var itemKey in item.data.keys)
                                      if(itemKey.contains('item'))
                                        
                                          ListTile(
                                            trailing: Text(item.data[itemKey],overflow: TextOverflow.ellipsis,),
                                            leading: Text(itemKey,style: TextStyle(fontWeight: FontWeight.bold),),
                                          )
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(child: Container(width:23,child: Center(child: Icon(Icons.arrow_drop_up,size: 28,)),color: Colors.black54,)),
                                    Expanded(child: Container(width:23,height:double.infinity,child: Center(child: Icon(Icons.arrow_drop_down,size: 28,)),color: Colors.black54,)),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Expanded(flex:1,child: Center(
                            child: item.data['orderStatus']=='complete'?Text('Order Complete',style: TextStyle(fontSize: 25,color: Colors.green),):GestureDetector(
                              onTap: (){
                                orderComplete(item.documentID);
                              },
                              child: Icon(Icons.check,color: Colors.green,size: 35,),
                            ),
                          ),)
                        ],
                      )
                    )
                  );

              }
              return ListView(
                shrinkWrap: true,
                itemExtent: 400,
                children: orderCards,
              );
            },
          ),
        )
      ],
    );
  }
}
