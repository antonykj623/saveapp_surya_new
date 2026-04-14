


import 'package:flutter/material.dart';

class WebLinkDialog extends StatelessWidget {
  final TextEditingController webLinkController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField("Web Link", webLinkController),
            SizedBox(height: 10),
            _buildTextField("User Name", userNameController),
            SizedBox(height: 10),
            _buildTextField("Password", passwordController, obscure: true),
            SizedBox(height: 10),
            _buildTextField("Description", descriptionController, maxLines: 3),
            SizedBox(height: 20),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool obscure = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return InkWell(
      onTap: () {



        // Implement save logic here
        Navigator.pop(context);
      },
      child: Container(
        width: 100,
        padding: EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade900, Colors.teal.shade400],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          'Save',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

}



// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:new_project_2025/view/home/widget/website_link_page/Website_link_page.dart';
// import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
//
//
// class AddEditWebLinkPage extends StatefulWidget {
//   final WebLink? webLink;
//   final bool isEdit;
//   final Function(WebLink) onSave;
//
//   AddEditWebLinkPage({this.webLink, this.isEdit = false, required this.onSave});
//
//   @override
//   _AddEditWebLinkPageState createState() => _AddEditWebLinkPageState();
// }
//
// class _AddEditWebLinkPageState extends State<AddEditWebLinkPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _websiteLinkController;
//   late TextEditingController _usernameController;
//   late TextEditingController _passwordController;
//   late TextEditingController _descriptionController;
//
//   @override
//   void initState() {
//     super.initState();
//     _websiteLinkController = TextEditingController(
//       text: widget.webLink?.websiteLink ?? '',
//     );
//     _usernameController = TextEditingController(
//       text: widget.webLink?.username ?? '',
//     );
//     _passwordController = TextEditingController(
//       text: widget.webLink?.password ?? '',
//     );
//     _descriptionController = TextEditingController(
//       text: widget.webLink?.description ?? '',
//     );
//   }
//
//   @override
//   void dispose() {
//     _websiteLinkController.dispose();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[400],
//       appBar: AppBar(
//         backgroundColor: Colors.teal[600],
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Web Links',
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ),
//         elevation: 0,
//       ),
//       body: Center(
//         child: Card(
//           margin: EdgeInsets.all(24),
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildTextField(
//                     controller: _websiteLinkController,
//                     label: 'WebLink',
//                   ),
//                   SizedBox(height: 20),
//                   _buildTextField(
//                     controller: _usernameController,
//                     label: 'User Name',
//                   ),
//                   SizedBox(height: 20),
//                   _buildTextField(
//                     controller: _passwordController,
//                     label: 'Password',
//                     obscureText: true,
//                   ),
//                   SizedBox(height: 20),
//                   _buildTextField(
//                     controller: _descriptionController,
//                     label: 'Description',
//                     maxLines: 3,
//                   ),
//                   SizedBox(height: 32),
//                   Container(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: (){},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal[600],
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       ),
//                       child: Text(
//                          'Save',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         backgroundColor: Colors.pink[600],
//         child: Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     bool obscureText = false,
//     int maxLines = 1,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[400]!),
//       ),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscureText,
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(color: Colors.grey[600]),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'This field is required';
//           }
//           return null;
//         },
//       ),
//     );
//   }
//
//   void _saveWebLink() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Processing Data')),
//         );
//
//         final weblink = _websiteLinkController.text;
//         final username = _usernameController.text;
//         final password = _passwordController.text;
//         final desc = _descriptionController.text;
//
//         Map<String, dynamic> weblinkData = {
//           "weblink": weblink,
//           "username": username,
//           "password": password,
//           "desc": desc,
//         };
//
//         // Save to database
//         await DatabaseHelper().addData(
//           "TABLE_WEBLINKS",
//           jsonEncode(weblinkData),
//         );
//
//         print('weblink is ...$weblink');
//
//         // Show success message
// //         if (mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //               content: Text(
// //                 'Weblink data added successfully!',
// //               ),
// //               backgroundColor: Colors.green,
// //             ),
// //           );
// // //Clear Data
// //
// //
// //           // Return true to indicate success and pop the page
// //           Navigator.pop(context, true);
// //         }
//       } catch (e) {
//         print('Error saving account: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error saving account: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//     // if (_formKey.currentState!.validate()) {
//     //   final webLink = WebLink(
//     //     websiteLink: _websiteLinkController.text,
//     //     username: _usernameController.text,
//     //     password: _passwordController.text,
//     //     description: _descriptionController.text,
//     //   );
//     //
//     //   widget.onSave(webLink);
//     //   Navigator.pop(context);
//     // }
//   }
// }