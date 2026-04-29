
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'Add_Acount.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'editaccountdetails.dart';

class Accountsetup extends StatefulWidget {
  const Accountsetup({super.key});

  @override
  State<Accountsetup> createState() => _AccountsetupState();
}

class _AccountsetupState extends State<Accountsetup> {
  late Future<List<Map<String, dynamic>>> _accountsFuture;

  TextEditingController _searchController = TextEditingController();
  String names = "";

  // 🎤 Speech
  late stt.SpeechToText _speech;
  bool _isListening = false;
  double _soundLevel = 0.0;

  // 🔊 TTS
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTTS();
    _loadData();
  }

  void _initTTS() async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1.0);
  }

  void _loadData() {
    _accountsFuture =
        DatabaseHelper().getAllData1('TABLE_ACCOUNTSETTINGS');
  }

  Future<void> _speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  // 🎤 START
  void _startListening() async {
    bool available = await _speech.initialize();

    if (available) {
      setState(() {
        names = "";
        _searchController.clear();
        _isListening = true;
      });

      _speech.listen(
        listenFor: Duration(seconds: 15),
        pauseFor: Duration(seconds: 3),

        onResult: (result) {
          final voiceText = result.recognizedWords;

          // 🔥 IMPORTANT FIX (single source of truth)
          setState(() {
            names = voiceText.toLowerCase().trim();
            _searchController.text = voiceText;
          });

          // Debug (remove later)
          print("VOICE INPUT: $voiceText");

          if (result.finalResult && voiceText.isNotEmpty) {
            _speak("Searching for $voiceText");
          }
        },

        onSoundLevelChange: (level) {
          setState(() => _soundLevel = level);
        },
      );
    }
  }

  // 🛑 STOP
  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // 🔍 FILTER (IMPROVED)
  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> data) {
    if (names.trim().isEmpty) return data.reversed.toList();

    final query = names.toLowerCase().trim();

    return data.reversed.where((e) {
      final dat = jsonDecode(e["data"]);
      final acc =
      (dat['Accountname'] ?? "").toString().toLowerCase().trim();

      // 🔥 flexible match
      return acc.contains(query) ||
          query.split(" ").any((word) => acc.contains(word));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          // 🔵 HEADER
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 50, left: 16, bottom: 20),
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

          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              onChanged: (v) {
                setState(() {
                  names = v.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),

                // 🎤 MIC
                suffixIcon: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    if (_isListening) {
                      _stopListening();

                      setState(() {
                        names = "";
                        _searchController.clear();
                      });

                      Future.delayed(Duration(milliseconds: 300), () {
                        _startListening();
                      });
                    } else {
                      _startListening();
                    }
                  },
                ),

                hintText:
                _isListening ? "Listening..." : "Search by Account Name",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 🎤 WAVE
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            height: 10 + (_soundLevel * 2),
            width: _isListening ? 60 + (_soundLevel * 5) : 20,
            decoration: BoxDecoration(
              color: _isListening ? Colors.red : Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          SizedBox(height: 5),

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

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        title: Text(
                          dat['Accountname'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Category: ${dat['Accounttype']}"),
                            Text("Balance: ₹${dat['OpeningBalance']}"),
                            Text("Type: ${dat['Type']}"),
                          ],
                        ),

                        onTap: () {
                          _speak(
                            "${dat['Accountname']} balance ${dat['OpeningBalance']}",
                          );
                        },

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.green),
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
                                  setState(() => _loadData());
                                }
                              },
                            ),

                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await DatabaseHelper().deleteData(
                                  "TABLE_ACCOUNTSETTINGS",
                                  keyid.toString(),
                                );

                                _speak("${dat['Accountname']} deleted");

                                setState(() => _loadData());
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Addaccountsdet()),
          );

          if (result == true) {
            setState(() => _loadData());
          }
        },
        icon: Icon(Icons.add),
        label: Text("Add"),
      ),
    );
  }
}
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'Add_Acount.dart';
// import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
// import 'editaccountdetails.dart';
//
// class Accountsetup extends StatefulWidget {
//   const Accountsetup({super.key});
//
//   @override
//   State<Accountsetup> createState() => _AccountsetupState();
// }
//
// class _AccountsetupState extends State<Accountsetup> {
//   int currentYear = DateTime.now().year;
//
//   late Future<List<Map<String, dynamic>>> _accountsFuture;
//
//   TextEditingController _searchController = TextEditingController();
//
//   String names = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   void _loadData() {
//     _accountsFuture =
//         DatabaseHelper().getAllData1('TABLE_ACCOUNTSETTINGS');
//   }
//
//   // 🔍 SEARCH FILTER
//   List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> data) {
//     if (names.isEmpty) return data.reversed.toList();
//
//     return data.reversed.where((e) {
//       final dat = jsonDecode(e["data"]);
//       final acc = dat['Accountname'].toString().toLowerCase();
//       return acc.contains(names.toLowerCase());
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       body: Column(
//         children: [
//
//           // 🔵 HEADER (SAME DESIGN)
//
//
//           Padding(
//             padding: const EdgeInsets.all(0.0),
//             child: Container(
//               width: double.infinity,
//               padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.teal, Colors.blue],
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(25),
//                   bottomRight: Radius.circular(25),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   SizedBox(width: 5),
//                   Text(
//                     "Account Setup",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // 🔍 SEARCH BOX
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: TextField(
//               controller: _searchController,
//               onChanged: (v) {
//                 setState(() {
//                   names = v;
//                 });
//               },
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.search),
//                 hintText: "Search by Account Name",
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//
//           // 📋 LIST
//           Expanded(
//             child: FutureBuilder<List<Map<String, dynamic>>>(
//               future: _accountsFuture,
//               builder: (context, snapshot) {
//
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(child: Text("No Data Found"));
//                 }
//
//                 final items = _filter(snapshot.data!);
//                 return ListView.builder(
//                   itemCount: items.length,
//                   itemBuilder: (context, index) {
//                     final item = items[index];
//                     final dat = jsonDecode(item["data"]);
//                     final keyid = item['keyid'];
//
//                     return Dismissible(
//                       key: Key(keyid.toString()),
//
//                       direction: DismissDirection.endToStart,
//
//                       background: Container(
//                         alignment: Alignment.centerRight,
//                         padding: EdgeInsets.only(right: 20),
//                         color: Colors.red,
//                         child: Icon(Icons.delete, color: Colors.white),
//                       ),
//
//                       confirmDismiss: (direction) async {
//                         return await showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: Text("Delete Account?"),
//                             content: Text("This action cannot be undone."),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context, false),
//                                 child: Text("Cancel"),
//                               ),
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context, true),
//                                 child: Text(
//                                   "Delete",
//                                   style: TextStyle(color: Colors.red),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//
//                       onDismissed: (direction) async {
//                         await DatabaseHelper().deleteData(
//                           "TABLE_ACCOUNTSETTINGS",
//                           keyid.toString(),
//                         );
//
//                         setState(() {
//                           _loadData();
//                         });
//
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text("${dat['Accountname']} deleted"),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       },
//
//                       child:
//                       Card(
//                         elevation: 4,
//                         margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//
//                               Text("Account Name: ${dat['Accountname']}"),
//                               Text("Category: ${dat['Accounttype']}"),
//                               Text("Opening Balance: ${dat['OpeningBalance']}"),
//                               Text("Type: ${dat['Type']}"),
//                               Text("Year: $currentYear"),
//
//                               Align(
//                                 alignment: Alignment.centerRight,
//                                 child: TextButton(
//                                   onPressed: () async {
//                                     final res = await Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => Editaccount1(
//                                           keyid: keyid.toString(),
//                                           year: dat['year'] ?? "",
//                                           accname: dat['Accountname'],
//                                           cat: dat['Accounttype'],
//                                           obalance: dat['OpeningBalance'],
//                                           actype: dat['Type'],
//                                         ),
//                                       ),
//                                     );
//
//                                     if (res == true) {
//                                       setState(() {
//                                         _loadData();
//                                       });
//                                     }
//                                   },
//                                   child: Text(
//                                     "Edit",
//                                     style: TextStyle(color: Colors.green),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//                 // return ListView.builder(
//                 //   itemCount: items.length,
//                 //   itemBuilder: (context, index) {
//                 //
//                 //     final item = items[index];
//                 //     final dat = jsonDecode(item["data"]);
//                 //
//                 //     return Card(
//                 //       elevation: 4,
//                 //       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 //       child: Padding(
//                 //         padding: const EdgeInsets.all(12),
//                 //         child: Column(
//                 //           crossAxisAlignment: CrossAxisAlignment.start,
//                 //           children: [
//                 //
//                 //             Text("Account Name: ${dat['Accountname']}"),
//                 //             Text("Category: ${dat['Accounttype']}"),
//                 //             Text("Opening Balance: ${dat['OpeningBalance']}"),
//                 //             Text("Type: ${dat['Type']}"),
//                 //             Text("Year: $currentYear"),
//                 //
//                 //             Align(
//                 //               alignment: Alignment.centerRight,
//                 //               child: TextButton(
//                 //                 onPressed: () async {
//                 //
//                 //                   final res = await Navigator.push(
//                 //                     context,
//                 //                     MaterialPageRoute(
//                 //                       builder: (context) => Editaccount1(
//                 //                         keyid: item['keyid'].toString(),
//                 //                         year: dat['year'] ?? "",
//                 //                         accname: dat['Accountname'],
//                 //                         cat: dat['Accounttype'],
//                 //                         obalance: dat['OpeningBalance'],
//                 //                         actype: dat['Type'],
//                 //                       ),
//                 //                     ),
//                 //                   );
//                 //
//                 //                   if (res == true) {
//                 //                     setState(() {
//                 //                       _loadData();
//                 //                     });
//                 //                   }
//                 //                 },
//                 //                 child: Text(
//                 //                   "Edit",
//                 //                   style: TextStyle(color: Colors.green),
//                 //                 ),
//                 //               ),
//                 //             )
//                 //           ],
//                 //         ),
//                 //       ),
//                 //     );
//                 //   },
//                 // );
//               },
//             ),
//           ),
//         ],
//       ),
//
//       // ➕ FLOAT BUTTON
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.red,
//         onPressed: () async {
//
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => Addaccountsdet()),
//           );
//
//           if (result == true) {
//             setState(() {
//               _loadData();
//             });
//           }
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
//