import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:new_project_2025/view/home/widget/Resgistration_page/Resgistration_page.dart';

import '../../../nativestorage.dart';
import '../../../view_model/Resgistration_page/Resgistration_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAVE App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _mobilenumber = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool isLoading = false;

  /// ==========================
  /// LOGIN FUNCTION
  /// ==========================
  Future<void> loginUser() async {
    setState(() => isLoading = true);

    var uuid = const Uuid().v4();
    String timestamp =
    DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    Map<String, String> logdata = {
      "mobile": _mobilenumber.text.trim(),
      "password": _passwordController.text.trim(),
      "uuid": uuid,
      "timestamp": timestamp,
    };

    try {
      ApiHelper api = ApiHelper();

      String response =
      await api.postApiResponse("userLoginPremium.php", logdata);

      print("RAW RESPONSE: $response");

      await handleLoginResponse(response);
    } catch (e) {
      print("Login Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ==========================
  /// HANDLE RESPONSE
  /// ==========================
  Future<void> handleLoginResponse(String response) async {
    try {
      final data = jsonDecode(response);

      print("DECODED: $data");

      int status = int.parse(data['status'].toString());
      String message = data['message'] ?? "";

      if (status == 1) {
        String token = data['token'] ?? "";
        print("Token from loginscreen is $token");
        String userId = data['userid'] ?? "";

        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setInt('status', status);
        // await prefs.setString('token', token);
        // await prefs.setString('userid', userId);
        await NativeStorage.saveLogin(
          status: status,
          token: token,
          userId: userId,
        );
        // 👉 Now read it
        final data1 = await NativeStorage.getLogin();

        String? savedToken = data1?['token'];

        print("Saved Token = $savedToken");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.isEmpty ? "Login Success" : message)),
        );

        /// ✅ Navigate to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SaveApp()),
        );
      } else {
        /// ❌ Login failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      print("Parse Error: $e");
    }
  }

  /// ==========================
  /// UI
  /// ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A2D3D), Color(0xFF11877C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Image.asset("assets/login.png", height: 150),
                    const SizedBox(height: 10),

                    const Text(
                      'My Personal App',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),

                    const SizedBox(height: 40),

                    /// MOBILE
                    TextFormField(
                      controller: _mobilenumber,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Mobile Number"),
                      validator: (value) =>
                      value!.isEmpty ? "Enter Mobile Number" : null,
                    ),

                    const SizedBox(height: 20),

                    /// PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Password").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Enter Password" : null,
                    ),

                    const SizedBox(height: 30),

                    /// LOGIN BUTTON
                    SizedBox(
                      width: 180,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            loginUser(); // ✅ Only real login
                          }
                        },
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// REGISTER
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const RegistrationScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have account? Create one",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// COMMON INPUT DECORATION
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(5),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}




// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
//
// import 'package:new_project_2025/services/API_services/API_services.dart';
// import 'package:new_project_2025/view/home/widget/home_screen.dart';
// import 'package:new_project_2025/view/home/widget/Resgistration_page/Resgistration_page.dart';
//
// import '../../../view_model/Resgistration_page/Resgistration_page.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'SAVE App',
//       theme: ThemeData(primarySwatch: Colors.teal),
//       home: const LoginScreen(),
//     );
//   }
// }
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _mobilenumber = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   bool _obscureText = true;
//   bool isLoading = false;
//
//   /// ==========================
//   /// LOGIN FUNCTION
//   /// ==========================
//   Future<void> loginUser() async {
//     setState(() => isLoading = true);
//
//     var uuid = const Uuid().v4();
//     String timestamp =
//     DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
//
//     Map<String, String> logdata = {
//       "mobile": _mobilenumber.text.trim(),
//       "password": _passwordController.text.trim(),
//       "uuid": uuid,
//       "timestamp": timestamp,
//     };
//
//     try {
//       ApiHelper api = ApiHelper();
//
//       String response =
//       await api.postApiResponse("userLoginPremium.php", logdata);
//
//       print("RAW RESPONSE: $response");
//
//       await handleLoginResponse(response);
//     } catch (e) {
//       print("Login Error: $e");
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Something went wrong")),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   /// ==========================
//   /// HANDLE RESPONSE
//   /// ==========================
//   Future<void> handleLoginResponse(String response) async {
//     try {
//       final data = jsonDecode(response);
//
//       print("DECODED: $data");
//
//       int status = int.parse(data['status'].toString());
//       String message = data['message'] ?? "";
//
//       if (status == 1) {
//         String token = data['token'] ?? "";
//         print("Token from loginscreen is $token");
//         String userId = data['userid'] ?? "";
//
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setInt('status', status);
//         await prefs.setString('token', token);
//         await prefs.setString('userid', userId);
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(message.isEmpty ? "Login Success" : message)),
//         );
//
//         /// ✅ Navigate to Home
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const SaveApp()),
//         );
//       } else {
//         /// ❌ Login failed
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(message)),
//         );
//       }
//     } catch (e) {
//       print("Parse Error: $e");
//     }
//   }
//
//   /// ==========================
//   /// UI
//   /// ==========================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF1A2D3D), Color(0xFF11877C)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Form(
//           key: _formKey,
//           child: SafeArea(
//             child: Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 30),
//                 child: Column(
//                   children: [
//                     Image.asset("assets/login.png", height: 150),
//                     const SizedBox(height: 10),
//
//                     const Text(
//                       'My Personal App',
//                       style: TextStyle(color: Colors.white, fontSize: 20),
//                     ),
//
//                     const SizedBox(height: 40),
//
//                     /// MOBILE
//                     TextFormField(
//                       controller: _mobilenumber,
//                       keyboardType: TextInputType.phone,
//                       style: const TextStyle(color: Colors.white),
//                       decoration: _inputDecoration("Mobile Number"),
//                       validator: (value) =>
//                       value!.isEmpty ? "Enter Mobile Number" : null,
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     /// PASSWORD
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: _obscureText,
//                       style: const TextStyle(color: Colors.white),
//                       decoration: _inputDecoration("Password").copyWith(
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureText
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                             color: Colors.white,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscureText = !_obscureText;
//                             });
//                           },
//                         ),
//                       ),
//                       validator: (value) =>
//                       value!.isEmpty ? "Enter Password" : null,
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     /// LOGIN BUTTON
//                     SizedBox(
//                       width: 180,
//                       height: 55,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: Colors.teal,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                         onPressed: isLoading
//                             ? null
//                             : () {
//                           if (_formKey.currentState!.validate()) {
//                             loginUser(); // ✅ Only real login
//                           }
//                         },
//                         child: isLoading
//                             ? const CircularProgressIndicator()
//                             : const Text(
//                           'Login',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     /// REGISTER
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                             const RegistrationScreen(),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         "Don't have account? Create one",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// COMMON INPUT DECORATION
//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Colors.white70),
//       enabledBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: Colors.white),
//         borderRadius: BorderRadius.circular(5),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: Colors.white),
//         borderRadius: BorderRadius.circular(5),
//       ),
//     );
//   }
// }
//
// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:intl/intl.dart';
// // import 'package:new_project_2025/services/API_services/API_services.dart';
// // import 'package:new_project_2025/view/home/widget/Resgistration_page/Resgistration_page.dart';
// // import 'package:new_project_2025/view/home/widget/home_screen.dart';
// // import 'package:new_project_2025/view_model/Resgistration_page/Resgistration_page.dart';
// //
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:uuid/uuid.dart';
// //
// // import '../../../view/home/widget/profile_page/profile_page.dart';
// //
// // void main() {
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({Key? key}) : super(key: key);
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       title: 'SAVE App',
// //       theme: ThemeData(primarySwatch: Colors.teal),
// //       home: const LoginScreen(),
// //     );
// //   }
// // }
// //
// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<LoginScreen> createState() => _LoginScreenState();
// // }
// //
// // class _LoginScreenState extends State<LoginScreen> {
// //
// //   @override
// //   initState() {
// //   //  apidata;
// //
// //     super.initState();
// //   }
// //  // bool _isLoading = false;
// //   void _handleLogin() async {
// //     setState(() {
// //       //_isLoading = true;
// //     });
// //
// //     await Future.delayed(const Duration(seconds: 2));
// //
// //     setState(() {
// //    //   _isLoading = false;
// //     });
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('Login Successful!')),
// //     );
// //   }
// //
// //
// //   final _formKey = GlobalKey<FormState>();
// //   bool _obscureText = true;
// //   final TextEditingController _passwordController = TextEditingController();
// //   final TextEditingController _mobilenumber = TextEditingController();
// //
// //   var apidata = ApiHelper();
// //
// //   void loginUser() async {
// //     var uuid = Uuid().v4(); // generates a random UUID
// //     String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
// //
// //     Map<String, String> logdata = {
// //       "mobile": _mobilenumber.text.trim(),
// //       "password": _passwordController.text.trim(),
// //       "uuid": uuid,
// //       "timestamp": timestamp,
// //     };
// //
// //     ApiHelper api = ApiHelper();
// //
// //     try {
// //     //  String logresponse = await api.postApiResponse("UserLogin.php", logdata);
// //       String logresponse = await api.postApiResponse("userLoginPremium.php", logdata);
// //       print("Response: $logresponse");
// //    var res = json.decode(logresponse);
// //      print("res is...$res");
// //
// //       handleLoginResponse(context, logresponse);
// //
// //       //if (parseLoginResponse.statusCode == 200) {
// //       //   // Parse JSON
// //       //   var data = json.decode(response.body);
// //       //
// //       //   bool status = data['status'];
// //       //   String message = data['message'];
// //       //   String? token = data['token'];
// //       //
// //       //   print("Status: $status");
// //       //   print("Message: $message");
// //       //   print("Token: $token");
// //       // } else {
// //       //   print("Error: ${response.statusCode}");
// //       // }
// //     } catch (e) {
// //       print("Error: $e");
// //     }
// //   }
// //
// //   Future<void> handleLoginResponse(
// //     BuildContext context,
// //     String response,
// //   ) async {
// //     try {
// //       final data = jsonDecode(
// //         response,
// //       ); // Decode once — result is Map<String, dynamic>
// //
// //       int status = data['status'];
// //       String message = data['message'];
// //
// //       if (status == 0) {
// //         print("no login data");
// //
// //       } else if (status == 1) {
// //         int status = data['status'];
// //         String token = data['token'];
// //         String userId = data['userid'];
// //         String message = data['message'];
// //
// //         print('Status: $status');
// //         print('Token: $token');
// //         print('User ID: $userId');
// //         print('Message: $message');
// //         //saved to shared preference
// //
// //         final prefs = await SharedPreferences.getInstance();
// //         await prefs.setInt('status', status);
// //         await prefs.setString('token', token);
// //         await prefs.setString('userid', userId);
// //         await prefs.setString('message', message);
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(builder: (context) => const SaveApp()),
// //         );
// //       }
// //     } catch (e) {
// //       print("Error parsing response: $e");
// //     }
// //   }
// //
// //   Future<void> saveCredentials() async {
// //     final prefs = await SharedPreferences.getInstance();
// //
// //     await prefs.setString('password', _passwordController.text);
// //
// //     // String? token = prefs.getString('token');
// //     // String? userId = prefs.getString('userid');
// //     // int? status = prefs.getInt('status');
// //     //
// //     // print("Saved token: $token");
// //     ScaffoldMessenger.of(
// //       context,
// //     ).showSnackBar(SnackBar(content: Text(' password saved!')));
// //   }
// //
// //   //bool isLoading = false;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [Color(0xFF1A2D3D), Color(0xFF11877C)],
// //           ),
// //         ),
// //         child: Form(
// //           key: _formKey,
// //           child: SafeArea(
// //             child: Center(
// //
// //               child:
// //               SingleChildScrollView(
// //                 padding: const EdgeInsets.symmetric(horizontal: 30),
// //                 child:
// //                 //_isLoading?const CircularProgressIndicator():
// //                 Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: <Widget>[
// //                     Image.asset("assets/login.png", height: 150),
// //                     const SizedBox(height: 10),
// //
// //                     const Text(
// //                       'My Personal App',
// //                       style: TextStyle(color: Colors.white, fontSize: 20),
// //                     ),
// //
// //                     const SizedBox(height: 40),
// //
// //                     TextFormField(
// //                       keyboardType: TextInputType.phone,
// //                       style: const TextStyle(color: Colors.white),
// //                       controller: _mobilenumber,
// //                       decoration: InputDecoration(
// //                         hintText: 'Mobile Number',
// //                         hintStyle: const TextStyle(color: Colors.white),
// //                         enabledBorder: OutlineInputBorder(
// //                           borderSide: const BorderSide(color: Colors.white),
// //                           borderRadius: BorderRadius.circular(5),
// //                         ),
// //
// //                         focusedBorder: OutlineInputBorder(
// //                           borderSide: const BorderSide(color: Colors.white),
// //                           borderRadius: BorderRadius.circular(5),
// //                         ),
// //                       ),
// //                       validator: (value) {
// //                         if (value == null || value.trim().isEmpty) {
// //                           return 'Please Enter Mobile';
// //                         }
// //                         return null;
// //                       },
// //                     ),
// //
// //                     const SizedBox(height: 20),
// //
// //                     TextFormField(
// //                       obscureText: _obscureText,
// //                       style: TextStyle(color: Colors.white),
// //                       controller: _passwordController,
// //                       decoration: InputDecoration(
// //                         labelText: 'Password',
// //                         hintText: 'Password',
// //                         hintStyle: const TextStyle(color: Colors.white),
// //                         enabledBorder: OutlineInputBorder(
// //                           borderSide: const BorderSide(color: Colors.white),
// //                           borderRadius: BorderRadius.circular(5),
// //                         ),
// //                         focusedBorder: OutlineInputBorder(
// //                           borderSide: const BorderSide(color: Colors.white),
// //                           borderRadius: BorderRadius.circular(5),
// //                         ),
// //                         suffixIcon: IconButton(
// //                           icon: Icon(
// //                             _obscureText
// //                                 ? Icons.visibility
// //                                 : Icons.visibility_off,
// //                             color: Colors.black,
// //                           ),
// //                           onPressed: () {
// //                             setState(() {
// //                               _obscureText = !_obscureText;
// //                             });
// //                           },
// //                         ),
// //                       ),
// //                       validator: (value) {
// //                         if (value == null || value.trim().isEmpty) {
// //                           return 'Please Enter Password';
// //                         }
// //                         return null;
// //                       },
// //                     ),
// //
// //                     const SizedBox(height: 10),
// //
// //                     Align(
// //                       alignment: Alignment.centerRight,
// //                       child: TextButton(
// //                         onPressed: () {},
// //                         child: const Text(
// //                           'Forgot password ?',
// //                           style: TextStyle(color: Colors.white, fontSize: 16),
// //                         ),
// //                       ),
// //                     ),
// //
// //                     const SizedBox(height: 30),
// //
// //                     SizedBox(
// //                       width: 180,
// //                       height: 60,
// //                       child: ElevatedButton(
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.white,
// //                           foregroundColor: Colors.teal,
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(20),
// //                           ),
// //                         ),
// //                         onPressed: () async {
// //                         _handleLogin();
// //                           //loginUser();
// //                           // Navigator.push(
// //                           //     context,
// //                           //     MaterialPageRoute(builder: (context) =>  ProfileScreen()));
// //                           //call Jsondata
// //                           // if(_mobilenumber.text == "" )
// //                           //   {
// //                           //     _mobilenumber.text = "Please Enter Mobile Number";
// //                           //
// //                           //   }
// //                           // else if(_passwordController.text == ""){
// //                           //
// //                           //   _passwordController.text = "Please Enter Password";
// //                           //
// //                           // }
// //                           if (_mobilenumber.text == "" &&
// //                               _passwordController.text == "") {
// //                             _mobilenumber.text = "Please Enter Mobile Number";
// //                             _passwordController.text = "Please Enter Password";
// //                           } else {
// //                              loginUser();
// //                         //    Navigator.push( context, MaterialPageRoute(builder: (context) =>  ProfileScreen()));
// //
// //
// //                           }
// //
// //                           final prefs = await SharedPreferences.getInstance();
// //
// //                           int? status = prefs.getInt('status');
// //                           print("Error status code is $status");
// //
// //                           // else {
// //                           //   // Push to HomePage
// //                           //   Navigator.push(
// //                           //     context,
// //                           //     MaterialPageRoute(builder: (context) => SaveApp()),
// //                           //   );
// //                           // }
// //                         },
// //                         child: const Text(
// //                           'Login',
// //                           style: TextStyle(
// //                             color: Colors.black,
// //                             fontSize: 20,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //
// //                     const SizedBox(height: 40),
// //
// //                     TextButton(
// //                       onPressed: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (context) => const RegistrationScreen(),
// //                           ),
// //                         );
// //                       },
// //                       child: const Text(
// //                         'Don\'t you have account ? Create new one',
// //                         style: TextStyle(color: Colors.white, fontSize: 20),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
