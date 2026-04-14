//
// import 'dart:convert';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.dart';
// import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
// class Addwebsitelink extends StatefulWidget {
//   const Addwebsitelink({super.key});
//
//   @override
//   State<Addwebsitelink> createState() => _SlidebleListState1();
// }
//
//
//
//
//
//
// class _SlidebleListState1 extends State<Addwebsitelink> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController weblink = TextEditingController();
//   final TextEditingController username = TextEditingController();
//   final TextEditingController password = TextEditingController();
//   final TextEditingController description = TextEditingController();
//   bool obscure = false;
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.red,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//         ),
//         title: const Text(
//           'Add Weblink ',
//           style: TextStyle(color: Colors.red),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Container(
//             height: 500,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 TextFormField(
//                   enabled: true,
//                   controller: weblink,
//                   decoration: InputDecoration(
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.black, width: 1.5),
//                     ),
//                     hintText: " Weblink",
//                     hintStyle: TextStyle(
//                       color: const Color.fromARGB(255, 0, 0, 0),
//                     ),
//                     fillColor: const Color.fromARGB(0, 170, 30, 255),
//                     filled: true,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter Weblink';
//                     }
//                     return null;
//                   },
//                 ),
//
//
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   textAlign: TextAlign.end,
//                   enabled: true,
//                   controller: username,
//
//                   decoration: InputDecoration(
//                     hintStyle: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.black),
//                     ),
//                     hintText: "Enter Username",
//                     fillColor: Colors.transparent,
//                     filled: true,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please Enter Username';
//                     }
//                     if (double.tryParse(value) == null) {
//                       return 'Please Enter Username';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   textAlign: TextAlign.end,
//                   enabled: true,
//                   controller: password,
//                obscureText: true,
//                   decoration: InputDecoration(
//                     hintStyle: TextStyle(
//                       color: Colors.black,
//
//                       fontWeight: FontWeight.bold,
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.black),
//                     ),
//                     hintText: "Enter password",
//                     fillColor: Colors.transparent,
//                     filled: true,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please Enter Password';
//                     }
//                     if (double.tryParse(value) == null) {
//                       return 'Please Enter Password';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   textAlign: TextAlign.end,
//                   enabled: true,
//                   controller: description,
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     hintStyle: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.black),
//                     ),
//                     hintText: "Enter Description",
//                     fillColor: Colors.transparent,
//                     filled: true,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please Enter Description';
//                     }
//                     if (double.tryParse(value) == null) {
//                       return 'Please Enter Description';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 90),
//                 Column(
//                   children: [
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal,
//                         foregroundColor: Colors.white,
//                       ),
//                       onPressed: () async {
//                         if (_formKey.currentState!.validate()) {
//                           try {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Processing Data')),
//                             );
//
//                             final webdata = weblink.text;
//                            final uname = username.text;
//                            final passw = password.text;
//                             final des = description.text;
//
//         Map<String, dynamic> weblinkData = {
//           "weblink": weblink,
//           "username": username,
//           "password": password,
//           "desc": des,
//         };
//
//         // Save to database
//         await DatabaseHelper().addData(
//           "TABLE_WEBLINKS",
//           jsonEncode(weblinkData),
//         );
//
//         print('weblink is ...$weblink');
//                             // Show success message
//                             if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     'Weblink  added successfully!',
//                                   ),
//                                   backgroundColor: Colors.green,
//                                 ),
//                               );
//
//                               // Clear form fields
//                               // accountname.clear();
//                               // openingbalance.clear();
//                               // setState(() {
//                               //   dropdownvalu1 = 'Asset Account';
//                               //   dropdownvalu2 = 'Debit';
//                               // });
//
//                               // Return true to indicate success and pop the page
//                               Navigator.pop(context, true);
//                             }
//                           } catch (e) {
//                             print('Error saving account: $e');
//                             if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text('Error saving account: $e'),
//                                   backgroundColor: Colors.red,
//                                 ),
//                               );
//                             }
//                           }
//                         }
//                       },
//                       child: const Text(
//                         "Save",
//                         style: TextStyle(
//                           color: Color.fromARGB(255, 255, 255, 255),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
