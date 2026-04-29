import 'dart:convert';
import 'package:flutter/material.dart';
import 'Add_Acount.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'editaccountdetails.dart';

class Accountsetup extends StatefulWidget {
  const Accountsetup({super.key});

  @override
  State<Accountsetup> createState() => _AccountsetupState();
}

class _AccountsetupState extends State<Accountsetup> {
  int currentYear = DateTime.now().year;

  late Future<List<Map<String, dynamic>>> _accountsFuture;

  TextEditingController _searchController = TextEditingController();

  String name = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _accountsFuture =
        DatabaseHelper().getAllData1('TABLE_ACCOUNTSETTINGS');
  }

  // 🔍 SEARCH FILTER
  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> data) {
    if (name.isEmpty) return data.reversed.toList();

    return data.reversed.where((e) {
      final dat = jsonDecode(e["data"]);
      final acc = dat['Accountname'].toString().toLowerCase();
      return acc.contains(name.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [

          // 🔵 HEADER (SAME DESIGN)
          SafeArea(
            child:
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 15),
                  Text(
                    "Account Setup",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            //   color: Colors.blueGrey,
            //   child: Row(
            //     children: [
            //       IconButton(
            //         onPressed: () => Navigator.pop(context),
            //         icon: Icon(Icons.arrow_back, color: Colors.white),
            //       ),
            //       SizedBox(width: 10),
            //       Text(
            //         "Account Setup",
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 22,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ),

          // 🔍 SEARCH BOX
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              onChanged: (v) {
                setState(() {
                  name = v;
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search by Account Name",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 📋 LIST
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _accountsFuture,
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No Data Found"));
                }

                final items = _filter(snapshot.data!);
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final dat = jsonDecode(item["data"]);
                    final keyid = item['keyid'];

                    return Dismissible(
                      key: Key(keyid.toString()),

                      direction: DismissDirection.endToStart,

                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),

                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Delete Account?"),
                            content: Text("This action cannot be undone."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },

                      onDismissed: (direction) async {
                        await DatabaseHelper().deleteData(
                          "TABLE_ACCOUNTSETTINGS",
                          keyid.toString(),
                        );

                        setState(() {
                          _loadData();
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${dat['Accountname']} deleted"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },

                      child:
                      Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text("Account Name: ${dat['Accountname']}"),
                              Text("Category: ${dat['Accounttype']}"),
                              Text("Opening Balance: ${dat['OpeningBalance']}"),
                              Text("Type: ${dat['Type']}"),
                              Text("Year: $currentYear"),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () async {
                                    final res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Editaccount1(
                                          keyid: keyid.toString(),
                                          year: dat['year'] ?? "",
                                          accname: dat['Accountname'],
                                          cat: dat['Accounttype'],
                                          obalance: dat['OpeningBalance'],
                                          actype: dat['Type'],
                                        ),
                                      ),
                                    );

                                    if (res == true) {
                                      setState(() {
                                        _loadData();
                                      });
                                    }
                                  },
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
                // return ListView.builder(
                //   itemCount: items.length,
                //   itemBuilder: (context, index) {
                //
                //     final item = items[index];
                //     final dat = jsonDecode(item["data"]);
                //
                //     return Card(
                //       elevation: 4,
                //       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                //       child: Padding(
                //         padding: const EdgeInsets.all(12),
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //
                //             Text("Account Name: ${dat['Accountname']}"),
                //             Text("Category: ${dat['Accounttype']}"),
                //             Text("Opening Balance: ${dat['OpeningBalance']}"),
                //             Text("Type: ${dat['Type']}"),
                //             Text("Year: $currentYear"),
                //
                //             Align(
                //               alignment: Alignment.centerRight,
                //               child: TextButton(
                //                 onPressed: () async {
                //
                //                   final res = await Navigator.push(
                //                     context,
                //                     MaterialPageRoute(
                //                       builder: (context) => Editaccount1(
                //                         keyid: item['keyid'].toString(),
                //                         year: dat['year'] ?? "",
                //                         accname: dat['Accountname'],
                //                         cat: dat['Accounttype'],
                //                         obalance: dat['OpeningBalance'],
                //                         actype: dat['Type'],
                //                       ),
                //                     ),
                //                   );
                //
                //                   if (res == true) {
                //                     setState(() {
                //                       _loadData();
                //                     });
                //                   }
                //                 },
                //                 child: Text(
                //                   "Edit",
                //                   style: TextStyle(color: Colors.green),
                //                 ),
                //               ),
                //             )
                //           ],
                //         ),
                //       ),
                //     );
                //   },
                // );
              },
            ),
          ),
        ],
      ),

      // ➕ FLOAT BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Addaccountsdet()),
          );

          if (result == true) {
            setState(() {
              _loadData();
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// import 'dart:convert';
//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
//
// import '../../app/Modules/accounts/global.dart' as global;
//
// import 'Add_Acount.dart';
//
// import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
// import 'editaccountdetails.dart';
//
// queryall() async {
//   var allrows = await DatabaseHelper().queryallacc();
//
//   allrows.forEach((row) {
//     List valuesList = row.values.toList();
//     var a = valuesList[1];
//     print(a);
//   });
// }
//
// var id;
//
// List<String> _filteredItems = [];
// TextEditingController _searchController = TextEditingController();
//
// class Accountsetup extends StatefulWidget {
//   const Accountsetup({super.key});
//
//   @override
//   State<Accountsetup> createState() => _Home_ScreenState();
// }
//
// List<Map<String, dynamic>> _foundUsers = [];
//
// class _Home_ScreenState extends State<Accountsetup> {
//   int currentYear = DateTime.now().year;
//   late Future<List<Map<String, dynamic>>> _accountsFuture;
//   void _loadData() {
//     _accountsFuture =
//         DatabaseHelper().getAllData1('TABLE_ACCOUNTSETTINGS');
//   }
//   @override
//   initState() {
//     super.initState();
//     _loadData();
//   }
//
//   String name = "";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//
//       // appBar: AppBar(
//       //   backgroundColor: Colors.teal,
//       //
//       //   leading: IconButton(
//       //     onPressed: () {
//       //       Navigator.pop(context);
//       //     },
//       //     icon: Icon(Icons.arrow_back, color: Colors.white),
//       //   ),
//       //
//       //   title: Text(' Account Setup', style: TextStyle(color: Colors.white)),
//       // ),
//
//       body:
//       Column(
//           children: [
//
//       // 🔵 CUSTOM HEADER (REPLACES APPBAR)
//       SafeArea(
//       child: Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
//       color: Colors.blueGrey,
//       child: Row(
//         children: [
//
//           // 🔙 Back Button
//           IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(Icons.arrow_back, color: Colors.white),
//           ),
//
//           SizedBox(width: 10),
//
//
//           Text(
//             "Account Setup",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     ),
//     ),
// Expanded(child:
//       Container(
//         child: Column(
//           children: [
//             TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 prefixIcon: IconButton(
//                   onPressed: () {},
//                   icon: Icon(Icons.search),
//                 ),
//                 hintText: 'Search by Account Name',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(0.0),
//                   borderSide: BorderSide(color: Colors.black, width: 2.0),
//                 ),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   name = value;
//                 });
//               },
//
//             ),
//
//             Expanded(
//               child: FutureBuilder<List<Map<String, dynamic>>>(
//                 future:  _accountsFuture,
//                 //DatabaseHelper().getAllData1('TABLE_ACCOUNTSETTINGS'),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }
//
//                   List<Map<String, dynamic>> items = [];
//
//                   if (name.isEmpty) {
//                     items = snapshot.data ?? [];
//                   } else {
//                     final items1 = snapshot.data ?? [];
//                     items = snapshot.data!.reversed
//                         .where((e) => jsonDecode(e["data"])["Accountname"]
//                         .toString()
//                         .toLowerCase()
//                         .contains(name.toLowerCase()))
//                         .toList();
//                     // items = items1.reversed.toList();
//                     // for (var i in items1) {
//                     //   Map<String, dynamic> dat = jsonDecode(i["data"]);
//                     //   if (dat['Accountname'].toString().contains(name)) {
//                     //     items.add(i);
//                     //   }
//                     // }
//                   }
//
//                   return ListView.builder(
//                     itemCount: items.length,
//                     itemBuilder: (context, index) {
//                       final item = items[index];
//
//                       Map<String, dynamic> dat = jsonDecode(item["data"]);
//
//                       // Map<String,dynamic>id=jsonDecode(item['keyid'])  ;
//
//                       print('$dat');
//                       return Card(
//                         elevation: 50,
//                         child: Container(
//                           child: Column(
//                             children: <Widget>[
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 15.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                      Text('AccountName    '),
//                                      Text('  :  '),
//                                     Text("${dat['Accountname'].toString()}"),
//                                   ],
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 15.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text('Catogory '),
//                                     Text('              :   '),
//
//                                     Text("${dat['Accounttype'] ?? "0"}"),
//                                   ],
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 15.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'opening'
//                                       'balance ',
//                                     ),
//                                     Text('   :   '),
//
//                                     Text("${dat['OpeningBalance'] ?? "0"}"),
//                                   ],
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 15.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text('AccountType      '),
//                                     Text('   :   '),
//
//                                     Text("${dat['Type'] ?? "0"}"),
//                                   ],
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 15.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text('Year             '),
//                                     Text('           :   '),
//                                     Text('$currentYear'),
//                                   ],
//                                 ),
//                               ),
//                               Container(
//                                 child: Row(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                         left: 280.0,
//                                       ),
//                                       child: TextButton(
//                                         onPressed: () async{
//                                           final ob = dat['OpeningBalance'].toString();
//                                           print("ob is $ob");
//                                           Map<String, dynamic>
//                                           accountsetupData = {
//                                             // "id":items[0],
//                                             "accountname":
//                                                 dat['Accountname'].toString(),
//
//                                             "category":dat['Accounttype'].toString(),
//                                             "amount": ob,
//
//                                             "type": dat['Type'].toString(),
//                                             "year": dat['year'].toString(),
//                                             "keyid": item['keyid'].toString(),
//                                           };
//
//                                         final res =
//                                          await Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder:
//                                                   (context) => Editaccount1(
//                                                     keyid:
//                                                         item['keyid']
//                                                             .toString(),
//                                                    // year: accountsetupData['year'] ,
//                                                     year: accountsetupData['year'],
//                                                     accname:
//                                                         accountsetupData['accountname'],
//                                                     cat:
//                                                         accountsetupData['category'],
//                                                   obalance: accountsetupData['amount'],
//
//                                                     actype:
//                                                         accountsetupData['type'],
//                                                   ),
//                                             ),
//
//                                           );
//                                           if (res == true) {
//                                             setState(() {
//                                               _loadData();
//                                             });
//                                           }
//                                         },
//                                         child: Text(
//                                           'Edit',
//                                           style: TextStyle(
//                                             color: Colors.green,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
// ),
//       ],),
//       bottomNavigationBar: Container(
//         width: MediaQuery.of(context).size.width,
//         padding: const EdgeInsets.only(left: 40.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//
//           children: [
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Spacer(),
//             Container(
//               height: 65,
//
//               child: FloatingActionButton(
//                 backgroundColor: Colors.red,
//                 tooltip: 'Increment',
//                 shape: const CircleBorder(),
//                 onPressed: () async {
//                  final result =
//                  await Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => Addaccountsdet()),
//                   );
//                  if (result == true) {
//                    setState(() {
//                      _loadData();
//                    });
//                  }
//                 },
//                 child: const Icon(Icons.add, color: Colors.white, size: 25),
//               ),
//             ),
//             //  Text('Home'),
//             Spacer(),
//           ],
//         ),
//       ),
//     );
//
//     //  return   Placeholder();
//   }
// }
