
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectWhatsAppLauncher extends StatefulWidget {
  const DirectWhatsAppLauncher({super.key});

  @override
  State<DirectWhatsAppLauncher> createState() => _DirectWhatsAppLauncherState();
}

class _DirectWhatsAppLauncherState extends State<DirectWhatsAppLauncher> {
  @override
  void initState() {
    super.initState();

   // WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchWhatsApp();
   // });
  }

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/919846290789");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog("WhatsApp is not installed on this device");
      }
    } catch (e) {
      _showErrorDialog("Failed to launch WhatsApp: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              "Opening WhatsApp...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// void main() {
//   runApp(const MaterialApp(
//     home: WhatsAppLauncherPage(),
//     debugShowCheckedModeBanner: false,
//   ));
// }
//
// class WhatsAppLauncherPage extends StatelessWidget {
//   const WhatsAppLauncherPage({super.key});
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("WhatsApp Launcher"),
//         backgroundColor: Colors.teal,
//       ),
//       body: Center(
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.teal,
//             shadowColor: Colors.transparent,
//             padding: const EdgeInsets.symmetric(vertical: 25),
//           ),
//           onPressed: () async{
//             final Uri url = Uri.parse("https://wa.me/919846290789");
//             if (!await launchUrl(url, mode: LaunchMode.externalApplication));
//
//           }, child: Text("HelpOnWhatsapp",style: TextStyle(color: Colors.white,fontWeight:FontWeight.w100 ),),
//
//
//
//
//         ),
//       ),
//     );
//   }
// }
