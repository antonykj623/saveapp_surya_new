import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project_2025/view/home/widget/More_page/snackbarextension.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:new_project_2025/app/Modules/login/login_page.dart';
import 'package:flutter/foundation.dart' show listEquals;

class CheckPattern extends StatefulWidget {
  @override
  _CheckPatternState createState() => _CheckPatternState();
}

class _CheckPatternState extends State<CheckPattern> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<int>? savedPattern;
  bool? locpin;

  @override
  void initState() {
    super.initState();
    loadSavedPattern();
  }

  Future<void> loadSavedPattern() async {
    final prefs = await SharedPreferences.getInstance();
    final patternString = prefs.getString('lock_pattern');
    locpin = prefs.getBool('app_lock_enabled');
    if (patternString != null && locpin == true) {
      setState(() {
        locpin = true;
        savedPattern = patternString.split(',').map((e) => int.parse(e)).toList();
      });
    } else {
      // If no pattern exists or app lock is disabled, go to home screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SaveApp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Check Pattern"),
      ),
      body: savedPattern == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(
            child: Text(
              "Draw your pattern",
              style: TextStyle(fontSize: 26),
            ),
          ),
          Flexible(
            child: PatternLock(
              selectedColor: Colors.red,
              pointRadius: 8,
              showInput: true,
              dimension: 3,
              relativePadding: 0.7,
              selectThreshold: 25,
              fillPoints: true,
              onInputComplete: (List<int> input) {
                if (listEquals<int>(input, savedPattern)) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SaveApp()));
                } else {
                  context.replaceSnackbar(
                    content: Text(
                      "Wrong pattern",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    color: Colors.red,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:new_project_2025/view/home/widget/home_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pattern_lock/pattern_lock.dart';
// import 'package:new_project_2025/view/home/widget/More_page/snackbarextension.dart';
//
// import '../../../../app/Modules/login/login_page.dart';
//
// class CheckPattern extends StatefulWidget {
//   @override
//   _CheckPatternState createState() => _CheckPatternState();
// }
//
// class _CheckPatternState extends State<CheckPattern> {
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//   List<int>? savedPattern;
// bool? locpin;
//   @override
//   void initState() {
//     super.initState();
//     loadSavedPattern();
//     print('Saved password is $savedPattern');
//   }
//
//   Future<void> loadSavedPattern() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final patternString = prefs.getString('lock_pattern');
//   locpin = prefs.getBool('app_lock_enabled');
//     if (patternString != null || locpin == true) {
//       setState(() {
//         locpin = true;
//         savedPattern = patternString?.split(',').map((e) => int.parse(e)).toList();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         title: Text("Check Pattern"),
//       ),
//       body: savedPattern == null
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           Flexible(
//             child: Text(
//               "Draw your pattern",
//               style: TextStyle(fontSize: 26),
//             ),
//           ),
//           Flexible(
//             child: PatternLock(
//               selectedColor: Colors.red,
//               pointRadius: 8,
//               showInput: true,
//               dimension: 3,
//               relativePadding: 0.7,
//               selectThreshold: 25,
//               fillPoints: true,
//               onInputComplete: (List<int> input) {
//                 if (listEquals<int>(input, savedPattern)) {
//                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SaveApp()));
//                  // Navigator.of(context).pop(true);
//                 } else {
//                   context.replaceSnackbar(
//                     content: Text("Wrong pattern", textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.white, fontSize: 12),
//                     ),
//                     color: Colors.red,
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:new_project_2025/view/home/widget/More_page/snackbarextension.dart';
// //
// // import 'package:pattern_lock/pattern_lock.dart';
// //
// //
// // class CheckPattern extends StatelessWidget {
// //   final scaffoldKey = GlobalKey<ScaffoldState>();
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final List<int>? pattern = ModalRoute.of(context)!.settings.arguments as List<int>?;
// //     return Scaffold(
// //       key: scaffoldKey,
// //       appBar: AppBar(
// //         title: Text("Check Pattern"),
// //       ),
// //       body: Column(
// //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //         children: <Widget>[
// //           Flexible(
// //             child: Text(
// //               "Draw Your pattern",
// //               style: TextStyle(fontSize: 26),
// //             ),
// //           ),
// //           Flexible(
// //             child: PatternLock(
// //               selectedColor: Colors.red,
// //               pointRadius: 8,
// //               showInput: true,
// //               dimension: 3,
// //               relativePadding: 0.7,
// //               selectThreshold: 25,
// //               fillPoints: true,
// //               onInputComplete: (List<int> input) {
// //                 if (listEquals<int>(input, pattern)) {
// //                   Navigator.of(context).pop(true);
// //                 } else {
// //                   context.replaceSnackbar(
// //                     content: Text("wrong", textAlign: TextAlign.center,
// //                       style: TextStyle(color: Colors.white,fontSize: 12),
// //                     ), color: Colors.red,
// //                   );
// //                 }
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }