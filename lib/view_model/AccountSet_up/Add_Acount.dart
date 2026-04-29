
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class Addaccountsdet extends StatefulWidget {
  final String? titl;
  const Addaccountsdet({super.key, this.titl});

  @override
  State<Addaccountsdet> createState() => _AddaccountsdetState();
}

class _AddaccountsdetState extends State<Addaccountsdet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController accountname = TextEditingController();
  final TextEditingController openingbalance = TextEditingController();

  List<String> items1 = [
    'Asset Account',
    'Bank',
    'Cash',
    'Credit Card',
    'Customers',
    'Expense Account',
    'Income Account',
    'Insurance',
    'Investment',
    'Liability Account',
  ];

  List<String> items2 = ['Debit', 'Credit'];

  String dropdownvalu1 = 'Asset Account';
  String dropdownvalu2 = 'Debit';

  @override
  void initState() {
    super.initState();
    if (widget.titl != null && items1.contains(widget.titl)) {
      dropdownvalu1 = widget.titl!;
    }
  }

  // SAVE
  void _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        "Accountname": accountname.text,
        "Accounttype": dropdownvalu1,
        "OpeningBalance": openingbalance.text,
        "Type": dropdownvalu2,
      };

      await DatabaseHelper().addData(
        "TABLE_ACCOUNTSETTINGS",
        jsonEncode(data),
      );

      Navigator.pop(context, true);
    }
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _dropdown(List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: SizedBox(),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff4f6fb),

      body: Column(
        children: [

          // 🔵 MODERN HEADER

          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.blue],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Add Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BODY
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("Account Name"),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: accountname,
                          decoration: _inputStyle("Enter account name"),
                          validator: (v) =>
                          v!.isEmpty ? "Enter account name" : null,
                        ),

                        SizedBox(height: 16),

                        Text("Category"),
                        SizedBox(height: 8),
                        _dropdown(items1, dropdownvalu1, (val) {
                          setState(() => dropdownvalu1 = val!);
                        }),

                        SizedBox(height: 16),

                        Text("Opening Balance"),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: openingbalance,
                          keyboardType: TextInputType.number,
                          decoration: _inputStyle("Enter opening balance"),
                        ),

                        SizedBox(height: 16),

                        Text("Type"),
                        SizedBox(height: 8),
                        _dropdown(items2, dropdownvalu2, (val) {
                          setState(() => dropdownvalu2 = val!);
                        }),

                        SizedBox(height: 25),

                        // SAVE BUTTON (GRADIENT)
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.teal, Colors.blue],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: _saveAccount,
                            child: Text(
                              "Save Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 12),

                        // CANCEL BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
//
// class Addaccountsdet extends StatefulWidget {
//   final String? tit;
//   const Addaccountsdet({super.key, this.tit});
//
//   @override
//   State<Addaccountsdet> createState() => _AddaccountsdetState();
// }
//
// class _AddaccountsdetState extends State<Addaccountsdet> {
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController accountname = TextEditingController();
//   final TextEditingController openingbalance = TextEditingController();
//
//   List<String> items1 = [
//     'Asset Account',
//     'Bank',
//     'Cash',
//     'Credit Card',
//     'Customers',
//     'Expense Account',
//     'Income Account',
//     'Insurance',
//     'Investment',
//     'Liability Account',
//   ];
//
//   List<String> items2 = ['Debit', 'Credit'];
//
//   String dropdownvalu1 = 'Asset Account';
//   String dropdownvalu2 = 'Debit';
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.tit != null && items1.contains(widget.tit)) {
//       dropdownvalu1 = widget.tit!;
//     }
//   }
//
//   // 🔥 SAVE FUNCTION
//   void _saveAccount() async {
//     if (_formKey.currentState!.validate()) {
//       final accname = accountname.text;
//
//       Map<String, dynamic> data = {
//         "Accountname": accname,
//         "Accounttype": dropdownvalu1,
//         "OpeningBalance": openingbalance.text,
//         "Type": dropdownvalu2,
//       };
//
//       await DatabaseHelper().addData(
//         "TABLE_ACCOUNTSETTINGS",
//         jsonEncode(data),
//       );
//
//       Navigator.pop(context, true); // 🔥 important for refresh
//     }
//   }
//
//   // 🔧 INPUT STYLE
//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: Colors.grey.shade100,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//     );
//   }
//
//   // 🔧 DROPDOWN STYLE
//   Widget _dropdown(List<String> items, String value, Function(String?) onChanged) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey),
//       ),
//       child: DropdownButton<String>(
//         value: value,
//         isExpanded: true,
//         underline: SizedBox(),
//         items: items.map((item) {
//           return DropdownMenuItem(
//             value: item,
//             child: Text(item),
//           );
//         }).toList(),
//         onChanged: onChanged,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       backgroundColor: Colors.purple[10],
//       body: Column(
//         children: [
//
//           // 🔷 HEADER
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
//             "Add Account",
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
//           // Container(
//           //   width: double.infinity,
//           //   padding: EdgeInsets.only(top: 45, left: 10, bottom: 15),
//           //   color: Colors.teal[500],
//           //
//           //   child: Row(
//           //     children: [
//           //       IconButton(
//           //         onPressed: () => Navigator.pop(context),
//           //         icon: Icon(Icons.arrow_back, color: Colors.white),
//           //       ),
//           //       SizedBox(width: 10),
//           //       Text(
//           //       "Add Account",
//           //
//           //         style: TextStyle(
//           //           color: Colors.white,
//           //           fontSize: 20,
//           //           fontWeight: FontWeight.bold,
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//
//           // 🔽 BODY
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//
//                     // Account Name
//                     Text("Account Name"),
//                     SizedBox(height: 6),
//                     TextFormField(
//                       controller: accountname,
//                       decoration: _inputDecoration("Enter account name"),
//                       validator: (value) =>
//                       value!.isEmpty ? 'Enter account name' : null,
//                     ),
//
//                     SizedBox(height: 15),
//
//                     // Category
//                     Text("Account Category"),
//                     SizedBox(height: 6),
//                     _dropdown(items1, dropdownvalu1, (val) {
//                       setState(() => dropdownvalu1 = val!);
//                     }),
//
//                     SizedBox(height: 15),
//
//                     // Opening Balance
//                     Text("Opening Balance"),
//                     SizedBox(height: 6),
//                     TextFormField(
//                       controller: openingbalance,
//                       keyboardType: TextInputType.number,
//                       decoration: _inputDecoration("Enter opening balance"),
//                     ),
//
//                     SizedBox(height: 15),
//
//                     // Type
//                     Text("Account Type (Nature)"),
//                     SizedBox(height: 6),
//                     _dropdown(items2, dropdownvalu2, (val) {
//                       setState(() => dropdownvalu2 = val!);
//                     }),
//
//                     SizedBox(height: 30),
//
//                     // SAVE BUTTON
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.teal,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: _saveAccount,
//                         child: Text(
//                           "Save Account",
//                           style: TextStyle(fontSize: 16,color: Colors.white),
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(height: 10),
//
//                     // CANCEL BUTTON
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: OutlinedButton(
//                         style: OutlinedButton.styleFrom(
//                           backgroundColor: Colors.purple, // 👈 your color
//                           //side: BorderSide(color: Colors.white), // optional border
//                         ),
//                         onPressed: () => Navigator.pop(context),
//                         child: Text("Cancel", style: TextStyle(fontSize: 16,color: Colors.white),),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // import 'dart:convert';
// //
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:path/path.dart';
// // import 'package:quickalert/models/quickalert_type.dart';
// // import 'package:quickalert/widgets/quickalert_dialog.dart';
// //
// // import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
// //
// // class Addaccountsdet extends StatefulWidget {
// //   final tit;
// //   const Addaccountsdet({super.key, this.tit});
// //
// //   @override
// //   State<Addaccountsdet> createState() => _SlidebleListState1();
// // }
// //
// // class MenuItem {
// //   final String label;
// //   MenuItem(this.label);
// // }
// //
// // class MenuItem1 {
// //   final String label1;
// //   MenuItem1(this.label1);
// // }
// //
// // var items1 = [
// //   'Asset Account',
// //   'Bank',
// //   'Cash',
// //   'Credit Card',
// //   'Customers',
// //   'Expense Account',
// //   'Income Account',
// //   'Insurance',
// //   'Investment',
// //   'Liability Account',
// // ];
// // var items2 = ['Debit', 'Credit'];
// // var items3 = ['2025', '2026', '2027', '2028', '2029', '2030'];
// //
// // final _formKey = GlobalKey<FormState>();
// // final TextEditingController accountname = TextEditingController();
// // final TextEditingController catogory = TextEditingController();
// // final TextEditingController openingbalance = TextEditingController();
// // var dropdownvalu = '2025';
// // var dropdownvalu1 = 'Asset Account';
// // var dropdownvalu2 = 'Debit';
// // String selectedvalue = 'Investment';
// //
// // class _SlidebleListState1 extends State<Addaccountsdet> {
// //   String generateEntryId() {
// //     return DateTime.now().millisecondsSinceEpoch.toString();
// //   }
// //   @override
// //   void initState() {
// //
// //     dropdownvalu1 = items1.contains(widget.tit )
// //         ? widget.tit
// //         : items1.first;
// //   }
// //
// //   String getOpeningBalanceContraSetupId(String accountType) {
// //     switch (accountType.toLowerCase()) {
// //       case 'bank':
// //       case 'cash':
// //         return '2';
// //       case 'asset account':
// //       case 'investment':
// //         return '2';
// //       case 'liability account':
// //       case 'credit card':
// //         return '2';
// //       case 'expense account':
// //         return '2';
// //       case 'income account':
// //         return '2';
// //       default:
// //         return '2';
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //
// //       // appBar: AppBar(
// //       //   backgroundColor: Colors.teal,
// //       //   leading: IconButton(
// //       //     onPressed: () {
// //       //       Navigator.pop(context);
// //       //     },
// //       //     icon: const Icon(Icons.arrow_back, color: Colors.white),
// //       //   ),
// //       //   title: const Text(
// //       //     'Add Account Setup',
// //       //     style: TextStyle(color: Colors.white),
// //       //   ),
// //       // ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20.0),
// //         child: Form(
// //           key: _formKey,
// //           child: Container(
// //             height: 500,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: [
// //                 TextFormField(
// //                   enabled: true,
// //                   controller: accountname,
// //                   decoration: InputDecoration(
// //                     enabledBorder: OutlineInputBorder(
// //                       borderSide: BorderSide(color: Colors.black, width: 1.5),
// //                     ),
// //                     hintText: "Account name",
// //                     hintStyle: TextStyle(
// //                       color: const Color.fromARGB(255, 0, 0, 0),
// //                     ),
// //                     fillColor: const Color.fromARGB(0, 170, 30, 255),
// //                     filled: true,
// //                   ),
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter account name';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 20),
// //                 Container(
// //                   decoration: ShapeDecoration(
// //                     shape: BeveledRectangleBorder(
// //                       side: BorderSide(width: .5, style: BorderStyle.solid),
// //                       borderRadius: BorderRadius.all(Radius.circular(0)),
// //                     ),
// //                   ),
// //                   child: DropdownButton(
// //                     isExpanded: true,
// //                     value: dropdownvalu1,
// //                     icon: const Icon(Icons.keyboard_arrow_down),
// //                     items:
// //                         items1.map((String items) {
// //                           return DropdownMenuItem(
// //                             value: items,
// //                             child: Text(items),
// //                           );
// //                         }).toList(),
// //                     onChanged: (String? newValue2) {
// //                       setState(() {
// //                         dropdownvalu1 = newValue2!;
// //                         print("Account type selected: $dropdownvalu1");
// //                       });
// //                     },
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 TextFormField(
// //                   textAlign: TextAlign.end,
// //                   enabled: true,
// //                   controller: openingbalance,
// //                   keyboardType: TextInputType.number,
// //                   decoration: InputDecoration(
// //                     hintStyle: TextStyle(
// //                       color: Colors.black,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                     enabledBorder: OutlineInputBorder(
// //                       borderSide: BorderSide(color: Colors.black),
// //                     ),
// //                     hintText: "Enter Opening Balance",
// //                     fillColor: Colors.transparent,
// //                     filled: true,
// //                   ),
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please add Opening Balance';
// //                     }
// //                     if (double.tryParse(value) == null) {
// //                       return 'Please enter a valid number';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 20),
// //                 InputDecorator(
// //                   decoration: InputDecoration(
// //                     contentPadding: EdgeInsets.symmetric(
// //                       horizontal: 20.0,
// //                       vertical: 5.0,
// //                     ),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(3.0),
// //                     ),
// //                   ),
// //                   child: DropdownButton(
// //                     isExpanded: true,
// //                     value: dropdownvalu2,
// //                     icon: const Icon(Icons.keyboard_arrow_down),
// //                     items:
// //                         items2.map((String items) {
// //                           return DropdownMenuItem(
// //                             value: items,
// //                             child: Text(items),
// //                           );
// //                         }).toList(),
// //                     onChanged: (String? newValue1) {
// //                       setState(() {
// //                         dropdownvalu2 = newValue1!;
// //                         print("Account side selected: $dropdownvalu2");
// //                       });
// //                     },
// //                   ),
// //                 ),
// //                 const SizedBox(height: 90),
// //                 Column(
// //                   children: [
// //                     ElevatedButton(
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.teal,
// //                         foregroundColor: Colors.white,
// //                       ),
// //                       onPressed: () async {
// //                         if (_formKey.currentState!.validate()) {
// //                           try {
// //                             ScaffoldMessenger.of(context).showSnackBar(
// //                               SnackBar(content: Text('Processing Data')),
// //                             );
// //
// //                             final accname = accountname.text;
// //                             final catogory = dropdownvalu1;
// //                             final openbalance = openingbalance.text;
// //                             final type = dropdownvalu2;
// //
// //                             Map<String, dynamic> accountsetupData = {
// //                               "Accountname": accname,
// //                               "Accounttype": catogory,
// //                               "OpeningBalance": openbalance,
// //                               "Type": type,
// //                             };
// //
// //                             // Save to database
// //                             await DatabaseHelper().addData(
// //                               "TABLE_ACCOUNTSETTINGS",
// //                               jsonEncode(accountsetupData),
// //                             );
// //
// //
// //                             // Show success message
// //                             if (mounted) {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 SnackBar(
// //                                   content: Text(
// //                                     'Account "$accname" added successfully!',
// //                                   ),
// //                                   backgroundColor: Colors.green,
// //                                 ),
// //                               );
// //
// //                               // Clear form fields
// //                              //// accountname.clear();
// //                               openingbalance.clear();
// //                               setState(() {
// //                                 dropdownvalu1 = 'Asset Account';
// //                                 dropdownvalu2 = 'Debit';
// //                               });
// //
// //                               // Return true to indicate success and pop the page
// //                               Navigator.pop(context, true);
// //                             }
// //                           } catch (e) {
// //                             print('Error saving account: $e');
// //                             if (mounted) {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 SnackBar(
// //                                   content: Text('Error saving account: $e'),
// //                                   backgroundColor: Colors.red,
// //                                 ),
// //                               );
// //                             }
// //                           }
// //                         }
// //                       },
// //                       child: const Text(
// //                         "Save",
// //                         style: TextStyle(
// //                           color: Color.fromARGB(255, 255, 255, 255),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
