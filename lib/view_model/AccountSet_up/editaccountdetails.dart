import 'package:flutter/material.dart';
import '../../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class Editaccount1 extends StatefulWidget {
  final String keyid, year, accname, cat, obalance, actype;

  const Editaccount1({
    super.key,
    required this.keyid,
    required this.year,
    required this.accname,
    required this.cat,
    required this.obalance,
    required this.actype,
  });

  @override
  State<Editaccount1> createState() => _Editaccount1State();
}

/// 🔹 Models
class MenuItem {
  final String label;
  MenuItem(this.label);
}

class MenuItem1 {
  final String label1;
  MenuItem1(this.label1);
}

class MenuItem2 {
  final String label2;
  MenuItem2(this.label2);
}

/// 🔹 Data Lists
final List<MenuItem> menuItems = [
  MenuItem('Asset Account'),
  MenuItem('Bank'),
  MenuItem('Cash'),
  MenuItem('Credit Card'),
  MenuItem('Customers'),
  MenuItem('Expense Account'),
  MenuItem('Income Account'),
  MenuItem('Insurance'),
  MenuItem('Investment'),
  MenuItem('Liability Account'),
];

final List<MenuItem1> menuItems1 = [
  MenuItem1('Debit'),
  MenuItem1('Credit')
];

final List<MenuItem2> menuItems2 = [
  MenuItem2('2025'),
  MenuItem2('2026'),
  MenuItem2('2027'),
  MenuItem2('2028'),
  MenuItem2('2029'),
  MenuItem2('2030'),
];

/// 🔹 State
class _Editaccount1State extends State<Editaccount1> {
  late TextEditingController accountname;
  late TextEditingController openingbalance;

  MenuItem? selectedCategory;
  MenuItem1? selectedType;
  MenuItem2? selectedYear;

  @override
  void initState() {
    super.initState();

    accountname = TextEditingController(text: widget.accname);
    openingbalance = TextEditingController(text: widget.obalance);

    /// Preselect values
    selectedCategory = menuItems.firstWhere(
          (e) => e.label == widget.cat,
      orElse: () => menuItems.first,
    );

    selectedType = menuItems1.firstWhere(
          (e) => e.label1 == widget.actype,
      orElse: () => menuItems1.first,
    );

    selectedYear = menuItems2.firstWhere(
          (e) => e.label2 == widget.year,
      orElse: () => menuItems2.first,
    );
  }

  @override
  void dispose() {
    accountname.dispose();
    openingbalance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
     // backgroundColor: isDark ? Colors.black : Colors.grey[100],
backgroundColor: Color(0xfff4f6fb),

      // appBar: AppBar(
      //   title: const Text("Edit Account"),
      //   centerTitle: true,
      //   elevation: 0,
      //   flexibleSpace: Container(
      //     decoration: const BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [Color(0xFF0F9D9D), Color(0xFF3B82F6)],
      //       ),
      //     ),
      //   ),
      // ),

      body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
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
              "Edit Account",
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

      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.9),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black12,
                offset: Offset(0, 5),
              )
            ],
          ),
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              /// Account Name
              _inputField(accountname, "Account Name", Icons.person),

              const SizedBox(height: 15),

              /// Category
              _dropdown<MenuItem>(
                value: selectedCategory,
                hint: "Category",
                items: menuItems,
                label: (e) => e.label,
                onChanged: (val) => setState(() => selectedCategory = val),
              ),

              const SizedBox(height: 15),

              /// Opening Balance
              _inputField(openingbalance, "Opening Balance", Icons.currency_rupee),

              const SizedBox(height: 15),

              /// Type
              _dropdown<MenuItem1>(
                value: selectedType,
                hint: "Type",
                items: menuItems1,
                label: (e) => e.label1,
                onChanged: (val) => setState(() => selectedType = val),
              ),

              const SizedBox(height: 15),

              /// Year
              _dropdown<MenuItem2>(
                value: selectedYear,
                hint: "Year",
                items: menuItems2,
                label: (e) => e.label2,
                onChanged: (val) => setState(() => selectedYear = val),
              ),

              const SizedBox(height: 30),

              /// Update Button
              GestureDetector(
                onTap: _updateAccount,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F9D9D), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Update Account",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              )
            ],
          ),
        ),
      ),
      ],
      ),
    );
  }

  /// 🔹 Update Logic
  void _updateAccount() {
    if (accountname.text.isEmpty || openingbalance.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    DatabaseHelper().updateaccountdet(
      accountname.text,
      selectedCategory!.label,
      openingbalance.text,
      selectedType!.label1,
      selectedYear!.label2,
      widget.keyid,
    );

    Navigator.pop(context, true);
  }

  /// 🔹 Input Field
  Widget _inputField(
      TextEditingController controller, String hint, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// 🔹 Dropdown
  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) label,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text(hint),
      items: items.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(label(e)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:get/utils.dart';
// import 'package:new_project_2025/app/Modules/accounts/global.dart';
//
// import '../../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
//
// String? selectedValue;
//
// class Editaccount1 extends StatefulWidget {
//   //const Editaccount({super.key, required String accname, required String cat, required String obalance, required String actype,});
//   //const Editaccount({super.key});
//   final String keyid, year, accname, cat, obalance, actype;
//   //Editaccount({super.key, required this.accname, required this.cat, required this.obalance,required this.actype,});
//   Editaccount1({
//     required this.keyid,
//     required this.year,
//     required this.accname,
//     required this.cat,
//     required this.obalance,
//     required this.actype,
//   }) {
//     print(keyid);
//     print(year);
//     print(accname);
//     print(cat);
//     print(obalance);
//     print(actype);
//   }
//   @override
//   State<Editaccount1> createState() => _SlidebleListState3(
//     this.keyid,
//     this.year,
//     this.accname,
//     this.cat,
//     this.obalance,
//     this.actype,
//   );
// }
//
// class MenuItem {
//   // final int id;
//   final String label;
//   // final IconData icon;
//
//   MenuItem(this.label);
// }
//
// class MenuItem1 {
//   // final int id;
//   final String label1;
//   // final IconData icon;
//
//   MenuItem1(this.label1);
// }
//
// class MenuItem2 {
//   // final int id;
//   final String label2;
//   // final IconData icon;
//
//   MenuItem2(this.label2);
// }
//
// List<MenuItem2> menuItems2 = [
//   MenuItem2('2025'),
//   MenuItem2('2026'),
//   MenuItem2('2027'),
//   MenuItem2('2028'),
//   MenuItem2('2029'),
//   MenuItem2('2030'),
// ];
//
// List<MenuItem> menuItems = [
//   MenuItem('Asset Account'),
//   MenuItem('Bank'),
//   MenuItem('Cash'),
//   MenuItem('Credit Card'),
//   MenuItem('Customers'),
//   MenuItem('Expense Account'),
//   MenuItem('Income Account'),
//   MenuItem('Insurance'),
//   MenuItem('Investment'),
//   MenuItem('Liability Account'),
// ];
// List<MenuItem1> menuItems1 = [MenuItem1('Debit'), MenuItem1('Credit')];
//
// var i;
// var itm;
// final String catvalue = "";
// String? selectedvalue;
// final TextEditingController accountname = TextEditingController();
// final TextEditingController catogory = TextEditingController();
// final TextEditingController openingbalance = TextEditingController();
// var dropdownvalu = '2025';
// // var dropdownvalu1 = 'Debit';
// final TextEditingController menuController = TextEditingController();
//
// MenuItem? selectedMenu;
// final TextEditingController menuController1 = TextEditingController();
// var stat = "1";
//
// MenuItem1? selectedMenu1;
//
// final TextEditingController menuController2 = TextEditingController();
// MenuItem2? selectedMenu2;
//
// MenuItem? menutitem_category;
//
// class _SlidebleListState3 extends State<Editaccount1> {
//   final String  keyid, year, accname, cat, obalance, actype;
//
//   _SlidebleListState3(
//     this.keyid,
//     this.year,
//     this.accname,
//     this.cat,
//     this.obalance,
//     this.actype,
//   );
//   late int kid;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     print("opebalance is : $obalance");
//
//     kid = int.tryParse(widget.keyid) ?? 0;
//
//     print("keyid is : $kid");
//     setState(() {
//       accountname.text = accname;
//       print('Account name is ${accname}');
//       print("Year is : " + year);
//
//       for (MenuItem i in menuItems) {
//         print(i.label);
//         print("current : " + cat);
//         if (i.label.toString().compareTo(cat) == 0) {
//           catogory.text = cat;
//           menutitem_category = i;
//           break;
//         }
//       }
//       for (MenuItem1 i in menuItems1) {
//         print(i.label1);
//
//         if (i.label1.toString().trim().compareTo(actype) == 0) {
//           selectedMenu1 = i;
//           print("Type is : " + actype);
//           break;
//         }
//       }
//       for (MenuItem2 i in menuItems2) {
//         if ((year ?? "").trim() == i.label2.trim()) {
//           selectedMenu2 = i;
//           break;
//         }
//       }
//       selectedMenu2 ??= menuItems2.first;
//       // for (MenuItem2 i in menuItems2) {
//       //   print(i.label2);
//
//         // if (i.label2.toString().trim().compareTo(year.trim()) == 0) {
//         //   selectedMenu2 = i;
//         //   print("current year : " + year);
//         //   break;
//         // }
//     //  }
//
//       openingbalance.text = obalance;
//       print('openingbalance is ${obalance}');
//
//       //  menuController.text = value;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // print("sdfsdfsdfdsf"+'${global.accname}');
//     //    accountname.text = accname;
//     //TextEditingController accountname = TextEditingController(text: accname);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit')),
//
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Container(
//           height: double.infinity,
//           // height: MediaQuery.of(context).size.height,
//           //   width: MediaQuery.of(context).size.width,
//           color: const Color.fromARGB(255, 255, 255, 255),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 enabled: true,
//                 controller: accountname,
//                 decoration: InputDecoration(
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: const Color.fromARGB(255, 5, 5, 5),
//                       width: .5,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: const Color.fromARGB(255, 254, 255, 255),
//                       width: .5,
//                     ),
//                   ),
//                   hintText: "Accountname",
//
//                   // hintText: 'MObile',
//                   hintStyle: TextStyle(
//                     color: const Color.fromARGB(255, 0, 0, 0),
//                   ),
//
//                   fillColor: const Color.fromARGB(0, 170, 30, 30),
//                   filled: true,
//                   // prefixIcon: const Icon(Icons.person,color:Colors.white)),
//                 ),
//                 validator: (value) {
//                   if (value == "") {
//                     return 'Account name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//
//               Column(
//                 children: [
//                   DropdownMenu<MenuItem>(
//                     width: double.infinity,
//
//                     initialSelection: menutitem_category,
//
//                     controller: menuController,
//                     //  width: 600,
//                     hintText: "Select Menu",
//                     requestFocusOnTap: true,
//                     enableFilter: true,
//                     label: const Text('Select Category '),
//                     onSelected: (MenuItem? menu) {
//                       setState(() {
//                         selectedMenu = menu;
//                       });
//                     //  selectedMenu = menu;
//                     },
//                     dropdownMenuEntries:
//                         menuItems.map<DropdownMenuEntry<MenuItem>>((
//                           MenuItem menu,
//                         ) {
//                           return DropdownMenuEntry<MenuItem>(
//                             value: menu,
//                             label: menu.label,
//                             // leadingIcon: Icon(menu.icon));
//                           );
//                         }).toList(),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 10),
//
//               TextFormField(
//                 enabled: true,
//                 controller: openingbalance,
//                 decoration: InputDecoration(
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: const Color.fromARGB(255, 5, 5, 5),
//                       width: .5,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: const Color.fromARGB(255, 254, 255, 255),
//                       width: .5,
//                     ),
//                   ),
//                   hintText: "Opening Balance",
//
//                   // hintText: 'MObile',
//                   hintStyle: TextStyle(
//                     color: const Color.fromARGB(255, 0, 0, 0),
//                   ),
//
//                   fillColor: const Color.fromARGB(0, 170, 30, 30),
//                   filled: true,
//                   // prefixIcon: const Icon(Icons.person,color:Colors.white)),
//                 ),
//                 validator: (value) {
//                   if (value == "") {
//                     return 'Opening Balance';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),
//               DropdownMenu<MenuItem1>(
//                 width: double.infinity,
//
//                 initialSelection: selectedMenu1,
//
//                 //  width: 600,
//                 hintText: "Select Type",
//                 requestFocusOnTap: true,
//                 enableFilter: true,
//
//                 onSelected: (MenuItem1? menu) {
//                   selectedMenu1 = menu;
//                 },
//                 dropdownMenuEntries:
//                     menuItems1.map<DropdownMenuEntry<MenuItem1>>((
//                       MenuItem1 menu,
//                     ) {
//                       return DropdownMenuEntry<MenuItem1>(
//                         value: menu,
//                         label: menu.label1,
//                         // leadingIcon: Icon(menu.icon));
//                       );
//                     }).toList(),
//               ),
//
//               const SizedBox(height: 10),
//               DropdownMenu<MenuItem2>(
//                 width: double.infinity,
//
//                 initialSelection: selectedMenu2,
//
//                 //  width: 600,
//                 hintText: "Select Year",
//                 requestFocusOnTap: true,
//                 enableFilter: true,
//
//                 onSelected: (MenuItem2? menu) {
//                   selectedMenu2 = menu;
//                 },
//                 dropdownMenuEntries:
//                     menuItems2.map<DropdownMenuEntry<MenuItem2>>((
//                       MenuItem2 menu,
//                     ) {
//                       return DropdownMenuEntry<MenuItem2>(
//                         value: menu,
//                         label: menu.label2,
//                         // leadingIcon: Icon(menu.icon));
//                       );
//                     }).toList(),
//               ),
//
//               const SizedBox(height: 10),
//
//               const SizedBox(height: 20),
//
//               // Container(
//               //   decoration: ShapeDecoration(
//               //     shape: RoundedRectangleBorder(
//               //       side: BorderSide(width: .7, style: BorderStyle.solid),
//               //       borderRadius: BorderRadius.all(Radius.circular(0.0)),
//               //
//               //     ),
//               //   ),
//               //   child: DropdownButton(
//               //     menuWidth: 400,
//               //     value: selectedValue,
//               //     isExpanded: true,
//               //
//               //
//               //     icon:  Padding(
//               //       padding: const EdgeInsets.only(left: 200.0,right: 10),
//               //       child: Icon(Icons.keyboard_arrow_down),
//               //
//               //     ),
//               //     items: <String>['2025', '2026', '2027', '2028', '2029', '2030']
//               //
//               //         .map<DropdownMenuItem<String>>((String value) {
//               //
//               //
//               //       return DropdownMenuItem<String>(
//               //
//               //         value: value,
//               //         child: Text(value),
//               //
//               //       );
//               //     }).toList(),
//               //     // value: dropdownvalu,
//               //
//               //
//               //     onChanged: (values) {
//               //       setState(() {
//               //         dropdownvalu = values.toString();
//               //       });
//               //     },
//               //   ),
//               //
//               //
//               // ),
//               //
//               SizedBox(height: 70),
//               Container(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(
//                       255,
//                       57,
//                       216,
//                       62,
//                     ), // background (button) color
//                     foregroundColor: Colors.white, // foreground (text) color
//                   ),
//
//                   onPressed: () {
//                     DatabaseHelper().updateaccountdet(
//                       accountname.text,
//                       selectedMenu?.label ?? menutitem_category!.label,
//                     //  menutitem_category!.label,
//                       openingbalance.text,
//                       selectedMenu1!.label1,
//                       selectedMenu2!.label2,
//                        keyid,
//                     );
//                     print("updateddddddddddddd");
//                     Navigator.pop(context, true);
//                   },
//                   child: Text(
//                     "Update",
//                     style: TextStyle(
//                       color: const Color.fromARGB(255, 255, 255, 255),
//                     ),
//                   ),
//                   //   color: const Color(0xFF1BC0C5),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
