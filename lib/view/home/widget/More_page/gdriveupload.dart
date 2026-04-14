
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;


class DriveUploader extends StatefulWidget {
  @override
  _DriveUploaderState createState() => _DriveUploaderState();
}

class _DriveUploaderState extends State<DriveUploader> {
  GoogleSignInAccount? _currentUser;
  late GoogleSignIn _googleSignIn;
  drive.DriveApi? _driveApi;

  @override
  void initState() {
    super.initState();

    _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveFileScope],
    );

    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() => _currentUser = account);
    });

    _googleSignIn.signInSilently();
  }
  Future<void> _handleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return; // user cancelled
      _currentUser = account;
      final authHeaders = await _currentUser!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      _driveApi = drive.DriveApi(authenticateClient);
    } catch (error) {
      print('Sign in failed: $error');
    }
  }


  Future<void> _uploadFile() async {
    if (_currentUser == null) {
      await _handleSignIn();
    }

    // ⛔ Add a check to ensure _driveApi is initialized
    if (_driveApi == null) {
      final authHeaders = await _currentUser!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      _driveApi = drive.DriveApi(authenticateClient);
    }

    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final fileToUpload = File(filePath);
      final fileName = result.files.single.name;

      final media = drive.Media(fileToUpload.openRead(), fileToUpload.lengthSync());
      final driveFile = drive.File()..name = fileName;

      final uploadedFile = await _driveApi?.files.create(driveFile, uploadMedia: media);
print("uploaded file is ${uploadedFile?.name}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded: ${uploadedFile?.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload to Google Drive")),
      body: Center(
        child: ElevatedButton(
          child: Text("Upload File to Google Drive"),
          onPressed: _uploadFile,
        ),
      ),
    );
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
  }
}




// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// final GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes: [
//     'https://www.googleapis.com/auth/drive.file',
//   ],
// );
//
// Future<GoogleSignInAccount?> handleSignIn() async {
//   final account = await _googleSignIn.signIn();
//   return account;
// }
//
// Future<String?> getAccessToken() async {
//   final account = await handleSignIn();
//   final auth = await account?.authentication;
//   return auth?.accessToken;
// }
//
//
// final _globalKey = GlobalKey<ScaffoldMessengerState>();
//
// class Mytoken extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('Google Sign-In')),
//         body: Center(
//           child: ElevatedButton(
//             child: Text('Get Access Token'),
//             onPressed: () async {
//               final token = await getAccessToken();
//               if (token != null) {
//                 var snackBar = SnackBar(content: Text(' token isss$token'));
//                 _globalKey.currentState?.showSnackBar(snackBar);
//                // print('Access Token: $token');
//               } else {
//                 print('Failed to get token.');
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:http/http.dart' as http;
//
//
//
// class GoogleAuthClient extends http.BaseClient {
//   final Map<String, String> _headers;
//   final http.Client _client = http.Client();
//
//   GoogleAuthClient(this._headers);
//
//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//     return _client.send(request..headers.addAll(_headers));
//   }
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(title: 'Google Drive Upload', home: UploadPage());
//   }
// }
//
// class UploadPage extends StatefulWidget {
//   @override
//   _UploadPageState createState() => _UploadPageState();
// }
//
// class _UploadPageState extends State<UploadPage> {
//   final _googleSignIn = GoogleSignIn(
//     scopes: <String>['https://www.googleapis.com/auth/drive.file'],
//   );
//
//   String _status = 'Not signed in';
//
//   Future<void> _pickAndUploadFile() async {
//     final account = await _googleSignIn.signIn();
//     if (account == null) {
//       setState(() => _status = 'User cancelled sign-in');
//       return;
//     }
//
//     final result = await FilePicker.platform.pickFiles();
//     if (result == null) return;
//
//     final file = File(result.files.single.path!);
//     final headers = await account.authHeaders;
//     final client = GoogleAuthClient(headers);
//     final driveApi = drive.DriveApi(client);
//
//     final media = drive.Media(file.openRead(), file.lengthSync());
//     final driveFile = drive.File()..name = file.path.split('/').last;
//
//     await driveApi.files.create(driveFile, uploadMedia: media);
//     setState(() => _status = '✅ File uploaded: ${driveFile.name}');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Upload to Google Drive')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(_status),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _pickAndUploadFile,
//               child: Text('Pick and Upload File'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:google_sign_in/google_sign_in.dart';
// // import 'package:googleapis/drive/v3.dart' as drive;
// // import 'package:http/http.dart' as http;
// //
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:google_sign_in/google_sign_in.dart';
// // import 'package:googleapis/drive/v3.dart' as drive;
// // import 'package:http/http.dart' as http;
// //
// //
// //
// // class GoogleAuthClient extends http.BaseClient {
// //   final Map<String, String> _headers;
// //   final http.Client _client = http.Client();
// //
// //   GoogleAuthClient(this._headers);
// //
// //   @override
// //   Future<http.StreamedResponse> send(http.BaseRequest request) {
// //     return _client.send(request..headers.addAll(_headers));
// //   }
// // }
// //
// //
// //
// // class UploadPage extends StatefulWidget {
// //   @override
// //   _UploadPageState createState() => _UploadPageState();
// // }
// //
// // class _UploadPageState extends State<UploadPage> {
// //   final GoogleSignIn _googleSignIn = GoogleSignIn(
// //     scopes: <String>[
// //       'https://www.googleapis.com/auth/drive.file',
// //     ],
// //   );
// //
// //
// //   GoogleSignInAccount? _currentUser;
// //   String? _status;
// //
// //   Future<void> _signIn() async {
// //     try {
// //       final user = await _googleSignIn.signIn();
// //       setState(() {
// //         _currentUser = user;
// //         _status = "Signed in as ${user?.displayName}";
// //       });
// //     } catch (error) {
// //       setState(() => _status = "Sign in failed: $error");
// //     }
// //   }
// //
// //   Future<void> _uploadFile() async {
// //     if (_currentUser == null) {
// //       await _signIn();
// //     }
// //
// //     final result = await FilePicker.platform.pickFiles();
// //     if (result == null || result.files.single.path == null) return;
// //
// //     final file = File(result.files.single.path!);
// //     final headers = await _currentUser!.authHeaders;
// //     final client = GoogleAuthClient(headers);
// //     final driveApi = drive.DriveApi(client);
// //
// //     final media = drive.Media(file.openRead(), file.lengthSync());
// //     final driveFile = drive.File()..name = file.path.split('/').last;
// //
// //     await driveApi.files.create(driveFile, uploadMedia: media);
// //
// //     setState(() => _status = "✅ File uploaded: ${driveFile.name}");
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Upload to Google Drive')),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Text(_status ?? 'Not signed in'),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: _uploadFile,
// //               child: Text('Pick & Upload File'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
