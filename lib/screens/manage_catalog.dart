import 'package:ddbusinessside/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ManageCatalog extends StatefulWidget {
  @override
  _ManageCatalogState createState() => _ManageCatalogState();
}

class _ManageCatalogState extends State<ManageCatalog> {
  File sampleImage;
  String _selectedItem = "Cakes";
  final firestore = Firestore.instance;
  final List<DropdownMenuItem> dropdownList = [
    DropdownMenuItem(
      child: Center(
        child: Text(
          'Cakes',
          style: TextStyle(color: Colors.black),
        ),
      ),
      value: 'Cakes',
    ),
    DropdownMenuItem(
        child: Center(
            child: Text('Cookies', style: TextStyle(color: Colors.black))),
        value: 'Cookies'),
    DropdownMenuItem(
        child: Center(
            child: Text('Cupcakes & Muffins',
                style: TextStyle(color: Colors.black))),
        value: 'Cupcakes & Muffins'),
    DropdownMenuItem(
        child:
            Center(child: Text('Tarts', style: TextStyle(color: Colors.black))),
        value: 'Tarts'),
    DropdownMenuItem(
        child: Center(
            child: Text('Tea Cakes', style: TextStyle(color: Colors.black))),
        value: 'Tea Cakes'),
  ];
  void addItem() {
    String title, description, price, imgID;
    String fileName;
	File selectedImage;
    Alert(
        context: context,
        title: "Add an item in $_selectedItem",
        content: Column(
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                icon: Icon(Icons.title),
                labelText: 'Title',
              ),
              onChanged: (value) {
                title = value;
              },
            ),
            TextField(
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                icon: Icon(Icons.description),
                labelText: 'Description',
              ),
              onChanged: (value) {
                description = value;
              },
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                icon: Icon(Icons.attach_money),
                labelText: 'Price',
              ),
              onChanged: (value) {
                price = value;
              },
            ),
            FlatButton(
              onPressed:
                   () {
                      fileName =
                          title.toLowerCase().replaceAll(" ", "-") + '.jpg';
                          final _picker=ImagePicker();
                      // ImagePicker.pickImage(source: ImageSource.gallery)
                      //     .then((onValue) => setState(() {
                      //           selectedImage = onValue;
                      //           imgID=fileName;
                      //         }));
                       _picker.getImage(source: ImageSource.gallery,imageQuality: 75).then((value) => setState((){selectedImage=File(value.path);imgID=fileName;}));       
                      //final StorageReference firebaseRef =
                      //firebaseRef.putFile(sampleImage);
                      //imgID = fileName;
                    }
                  ,
              color: Colors.blue,
              child: Icon(
                Icons.add_a_photo,
                size: 27,
                color: Colors.white,
              ),
            )
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () {
		         FirebaseStorage.instance.ref().child(fileName).putFile(selectedImage);
              firestore.collection(_selectedItem.replaceAll(" ", "")).add({
                'title': title,
                'description': description,
                'price': price,
                'imgID': imgID
              }).then((value) => Navigator.pop(context));
			  
            },
            color: Color(0xfff368e0),
            child: Text(
              "Add Item",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void updateField(String fieldName, String documentID) {
    String fieldValue;
    Alert(
        context: context,
        title: "Update $fieldName",
        content: Column(
          children: <Widget>[
            TextField(
              keyboardType: fieldName == 'price'
                  ? TextInputType.number
                  : (fieldName == 'description'
                      ? TextInputType.multiline
                      : TextInputType.text),
              decoration: InputDecoration(
                icon: Icon(Icons.edit),
                labelText: 'New $fieldName',
              ),
              onChanged: (value) {
                fieldValue = value;
              },
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () {
				if(fieldValue.length>2)
              firestore
                  .collection(_selectedItem.replaceAll(" ", ""))
                  .document(documentID)
                  .updateData({fieldName: fieldValue}).then(
                      (value) => Navigator.pop(context));
					  else{
						  Scaffold.of(context).showSnackBar( SnackBar(content: Text('No value provided'),duration: Duration(seconds: 2),));
				  			Navigator.pop(context);
					  }
            },
            color: Color(0xfff368e0),
            child: Text(
              "Update $fieldName",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void deleteItem(String documentID,String imgID) {
    
    Alert(
      context: context,
      type: AlertType.error,
      title: "Confirm Deletion",
      buttons: [
        DialogButton(
          color: Colors.red,
          child: Text(
            "Delete item",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            final StorageReference firebaseRef =
        FirebaseStorage.instance.ref().child(imgID);
		firebaseRef.delete().then((value) => 
            firestore
                .collection(_selectedItem.replaceAll(" ", ""))
                .document(documentID)
                .delete()
                .then(
                  (value)=>Navigator.pop(context),
                ));
            
          },
          width: 120,
        )
      ],
    ).show();
  }

  void viewImage(String imgID, String title) {
    Alert(
        context: context,
        title: title,
        image: Image(
          image: FirebaseImage('gs://dripanddrizzle-327f9.appspot.com/$imgID',
              shouldCache: false),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.red,
            child: Text(
              "Close",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void updateImage(String imgID, String documentID) {
	  
    File updatedImage;
    final StorageReference firebaseRef =
        FirebaseStorage.instance.ref().child(imgID);
    Alert(
        context: context,
        title: "Update Image",
        content: FlatButton(
              onPressed: () {
                final _picker = ImagePicker();
                //String fileName=title.toLowerCase().replaceAll(" ","-")+'.jpg';
                _picker.getImage(source: ImageSource.gallery,imageQuality: 75).then((value) => updatedImage=File(value.path));
                // ImagePicker.pickImage(source: ImageSource.gallery)
                //     .then((onValue) => updatedImage=onValue);
                //final StorageReference firebaseRef=FirebaseStorage.instance.ref().child(fileName);
                //StorageUploadTask task=firebaseRef.putFile(sampleImage);
                // sleep(Duration(seconds: 5));
              },
              color: Colors.blue,
              child: Icon(
                Icons.add_a_photo,
                size: 27,
                color: Colors.white,
              ),
            ),
        
        buttons: [
          DialogButton(
            onPressed:() {
				  firebaseRef.delete().then((value){
                firebaseRef.putFile(updatedImage);
				}
             );
             Navigator.pop(context);
            },
            color: Color(0xfff368e0),
            child: Text(
              "Update image",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
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
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  iconSize: 30,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _selectedItem,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                textAlign: TextAlign.left,
              ),
              GestureDetector(
                onTap: addItem,
                child: Icon(
                  Icons.add_circle,
                  size: 35,
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection(_selectedItem.replaceAll(' ', ''))
                .snapshots(),
            builder: (context, snapshot) {
              final items = snapshot.data.documents;
              List<Card> orderCards = [];
              for (var item in items) {
                orderCards.add(Card(
                    child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                              child: Text(
                            '${item.data['title']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          )),
                          GestureDetector(
                            onTap: () {
                              updateField('title', item.documentID);
                            },
                            child: Text('Update',
                                style: TextStyle(color: Colors.blue)),
                          )
                        ],
                      )),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                              child: Text('${item.data['description']}',
                                  style: TextStyle(fontSize: 17))),
                          GestureDetector(
                            onTap: () {
                              updateField('description', item.documentID);
                            },
                            child: Text('Update',
                                style: TextStyle(color: Colors.blue)),
                          )
                        ],
                      )),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('$kRupeeSymbol ${item.data['price']}',
                              style: TextStyle(fontSize: 17)),
                          GestureDetector(
                              onTap: () {
                                updateField('price', item.documentID);
                              },
                              child: Text(
                                'Update',
                                style: TextStyle(color: Colors.blue),
                              ))
                        ],
                      )),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                viewImage(
                                    item.data['imgID'], item.data['title']);
                              },
                              child: Text(
                                'View ${item.data['imgID']}',
                                style: TextStyle(color: Colors.blue,fontSize: 17),
                              )),
                          GestureDetector(
                              onTap: () {
                                updateImage(
                                    item.data['imgID'], item.documentID);
								setState(() {
								});
                              },
                              child: Text(
                                'Update ${item.data['imgID']}',
                                style: TextStyle(color: Colors.blue,fontSize: 17),
                              )),
                        ],
                      )),
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              //firestore.collection(_selectedItem).document(item.documentID).delete().then((value) =>  print('Successfully Deleted'),);
                              deleteItem(item.documentID,item.data['imgID']);
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )));
              }
              return ListView(
                shrinkWrap: true,
                itemExtent: 350,
                children: orderCards,
              );
            },
          ),
        )
      ],
    );
  }
}
