
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:new_project_2025/view_model/AccountSet_up/accountsetup.dart';
import 'package:path_provider/path_provider.dart';

import '../../model/receipt.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:intl/intl.dart';
import 'addDiary.dart';
import 'editDiary.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;


class DiaryModel {
  final int? keyid;
  final String language;
  final String startdate;
  final String remarks;
  final String subject;

  DiaryModel({
    required this.keyid,
    required this.language,
    required this.startdate,
    required this.remarks,
    required this.subject
  });

  // From JSON (API or DB with nested data)
  factory DiaryModel.fromJson(Map<String, dynamic> json) {
    return DiaryModel(
      keyid: json['keyid'],
      language: json['data'] != null ? json['data']['language'] ?? '' : '',
      startdate: json['data'] != null ? json['data']['startdate'] ?? '' : '',
      remarks: json['data'] != null ? json['data']['remarks'] ?? '' : '',
      subject: json['data'] != null ? json['data']['subject'] ?? '' : '',
    );
  }



  // To Map (for DB insert/update)
  Map<String, dynamic> toMap() {
    return {
      'keyid': keyid,
      'language': language,
      'startdate': startdate,
      'remarks': remarks,
      'subject': subject,
    };
  }

  // To JSON (nested like your original structure)
  Map<String, dynamic> toJson() {
    return {
      'keyid': keyid,
      'data': {
        'language': language,
        'startdate': startdate,
        'remarks': remarks,
        'subject': subject,
      },
    };
  }

  DiaryModel fromMap(Map<String, dynamic> map) {
    return DiaryModel(
      keyid: map['keyid'],
      language: map['language'] ?? '',
      startdate: map['startdate'] ?? '',
      remarks: map['remarks'] ?? '',
      subject: map['subject'] ?? '',
    );
  }
}
//Get All Subjects to dropdown
class SubjectModel {
  final int? keyid;
  final String subject;

  SubjectModel({
    required this.keyid,
    required this.subject,
  });

  // From JSON (API or DB with nested data)
  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      keyid: json['keyid'],
      subject: json['data'] != null ? json['data']['subject'] ?? '' : '',
    );
  }

  // From Map (e.g., SQLite row with flat fields)
  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      keyid: map['keyid'],
      subject: map['subject'] ?? '',
    );
  }

  // To Map (for DB insert/update)
  Map<String, dynamic> toMap() {
    return {
      'keyid': keyid,
      'subject': subject,
    };
  }

  // To JSON (nested like your original structure)
  Map<String, dynamic> toJson() {
    return {
      'keyid': keyid,
      'data': {
        'subject': subject,
      },
    };
  }
}
class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<Diary> {


  Future<void> _exportAndSharePDF() async {
    if (datalist.isEmpty) {
      print("No data to export");
      return;
    }

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(level: 0, child: pw.Text('Diary Data')),
            pw.Table.fromTextArray(
              headers: ['KeyID', 'Language', 'Start Date', 'Remarks', 'Subject'],
              data: datalist.map((item) {
                return [
                  item.keyid.toString(),
                  item.language,
                  item.startdate,
                  item.remarks,
                  item.subject,
                ];
              }).toList(),
            ),
          ],
        ),
      );

      final output = await getTemporaryDirectory();
      final filePath = "${output.path}/diary_data.pdf";
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(filePath)], text: "My Diary PDF Export");

      print("PDF saved at: $filePath");
    } catch (e) {
      print("Error creating PDF: $e");
    }
  }
  bool _showContainer = false;

  var dropdownvalu = 'OneTime';

  String selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  DateTime selected_startDate = DateTime.now();
  DateTime selected_endDate = DateTime.now();
  String getFormattedDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final parsedDate = DateTime.parse(dateString);
      final date = DateFormat('dd/MM/yyyy').format(parsedDate);
      print("Date is $date");
    return  date; // Only date
    } catch (e) {
      print("Date parsing error: $e");
      return dateString; // fallback to original if parsing fails
    }
  }
  List<Receipt> receipts = [];
  double total = 0;
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
_loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {

    _loadSubjects();

    });
  }
  void _showContentDialog(int keyid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Diary Entry'),
          content: SizedBox(
            height: 200,
            width: double.maxFinite,
            child: FutureBuilder<Map<String, dynamic>?>(
              future: DatabaseHelper().getDataByKeyId('DIARY_table', keyid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final item = snapshot.data;
                if (item == null) {
                  return const Center(child: Text('No diary entry found.'));
                }

                final dat = jsonDecode(item["data"]);
                String formattedDate = DateFormat('dd-MM-yyyy')
                    .format(DateTime.parse(dat['startdate']));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow("Language", dat['language']),
                    buildRow("Start Date", formattedDate),
                    buildRow("Subject", dat['subject']),
                    buildRow("Remarks", dat['remarks']),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Editdiary(
                                  keyid: item['keyid'].toString(),
                                  date: dat['startdate'].toString(),
                                  subject: dat['subject'].toString(),
                                  remark: dat['remarks'].toString(),
                                ),
                              ),
                            );
                          },
                          child: const Text("Edit",
                              style: TextStyle(color: Colors.green)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            await DatabaseHelper()
                                .deleteByKeyId('DIARY_table', keyid);

                            Navigator.pop(context); // close dialog
                            setState(() {
                              _loadData(); // reload list after delete
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Diary entry deleted"),
                              ),
                            );
                          },
                          child: const Text("Delete",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

   toggleView() {
    setState(() {
      if(_showContainer)
        {
          _showContainer = false;
        }
      else{
        _showContainer = true;

      }



    });
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }
  String? selectedSubject;


  List<SubjectModel> subjectdata = [];
  List<DiaryModel> datalist = [];

  List<DiaryModel> loadedData = [];

  String? extLanguage;
  String? extStartDate;
  String? extRemarks;
  String? extSubject;
  final keyId = 0;
  void _loadData({String? subject, DateTime? startDate, DateTime? endDate}) async {
    final rawData = await DatabaseHelper().fetchAllDiaryData();
    loadedData = [];

    for (var entry in rawData) {
      final keyId = entry['keyid'];
      final jsonString = entry['data'];

      try {
        final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
        decodedMap['keyid'] = keyId;

        final entryDate = DateTime.tryParse(decodedMap['startdate'] ?? "");
        if (entryDate == null) continue;

        // ✅ Apply filters
        if (subject != null && decodedMap['subject'] != subject) {
          continue;
        }
        if (startDate != null && entryDate.isBefore(startDate)) {
          continue;
        }
        if (endDate != null && entryDate.isAfter(endDate)) {
          continue;
        }


        loadedData.add(
          DiaryModel(
            keyid: keyId,
            language: decodedMap['language'] ?? "",
            startdate: getFormattedDate(decodedMap['startdate'])!,
            remarks: decodedMap['remarks'] ?? "",
            subject: decodedMap['subject'] ?? "",
          ),
        );
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    }

    setState(() {
      datalist = loadedData;
    });
  }

  List<String> subjectList = [];

  Future<void> _loadSubjects() async {
    final dbHelper = DatabaseHelper();

    final rows = await dbHelper.getAllData("DIARYSUBJECT_table");
    print("Rows are $rows");

    setState(() {
      subjectList = rows.map((row) {
        // Step 1: Make sure we have a map, not a string
        dynamic subjdata = row['data'];
        if (subjdata is String) {
          try {
            subjdata = jsonDecode(subjdata);
            print("Jsonatas are $subjdata");// convert JSON string to Map
          } catch (e) {
            print("JSON decode error: $e");
            return ""; // skip this row if invalid
          }
        }

        // Step 2: Safely extract 'subject'
        if (subjdata is Map && subjdata.containsKey('subject')) {
          return subjdata['subject'].toString();
        } else {
          return ""; // skip if no subject key
        }
      }).where((s) => s.isNotEmpty).toList();

      if (subjectList.isNotEmpty) {
        selectedSubject = subjectList.first;
      }
    });
  }

  void showMonthYearPicker(bool isStart) {
    showDatePicker(
      context: context,

      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          if (isStart) {
            selected_startDate = pickedDate;
          }
          else {
            selected_endDate = pickedDate;
          }

          // _loadReceipts();
        });
      }
    });
  }

  selectDate(bool isStart) {
    showDatePicker(
      context: context,

      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          // selectedDate = pickedDate;
          selectedYearMonth = DateFormat('yyyy-MM').format(pickedDate);
          if (isStart) {
            selected_startDate = pickedDate;
          } else {
            selected_endDate = pickedDate;
          }



        });
      }
    });
  }

  String _getDisplayMonth() {
    final parts = selectedYearMonth.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    final monthName = DateFormat(
      'MMMM',
    ).format(DateTime(int.parse(year), month));
    return '$monthName $year';
  }

  String _getDisplayStartDate() {
    return DateFormat('dd/MM/yyyy').format(selected_startDate);
  }

  String _getDisplayEndDate() {
    return DateFormat('dd/MM/yyyy').format(selected_endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500],


      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[800], // ✅ GREY BACKGROUND
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 28.0),
                        child: Container(
                          height: 35,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white, // ✅ keep white
                            ),
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => SaveApp()),
                                    (Route<dynamic> route) => false,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Text(
                          'Diary',
                          style: TextStyle(
                            color: Colors.white, // ✅ white text on grey
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //
          //   width: double.infinity,
          //   padding:  EdgeInsets.symmetric(
          //     horizontal: 6,
          //     vertical:10,),
          //   decoration:  BoxDecoration(
          //     gradient: LinearGradient(
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //       colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFF093fb)],
          //     ),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       GestureDetector(
          //         //   onTap: () => Navigator.pop(context),
          //         child: Row(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             Padding(
          //               padding: const EdgeInsets.only(top:28.0),
          //               child: Container(
          //                 //  padding: EdgeInsets.only(top: 5),
          //                 height: 35, width: 40,
          //                 decoration: BoxDecoration(
          //                   color: Colors.white.withOpacity(0.15),
          //                   shape: BoxShape.circle,
          //                 ),
          //                 child: IconButton(
          //                   icon: Icon(Icons.arrow_back, color: Colors.white),
          //                   onPressed: () {
          //                     Navigator.pushAndRemoveUntil(
          //                       context,
          //                       MaterialPageRoute(builder: (context) => SaveApp()), // Your new home screen
          //                           (Route<dynamic> route) => false, // Predicate to remove all previous routes
          //                     );
          //
          //                     // Navigator.of(context).pop();
          //                   },
          //                 ),
          //               ),
          //             ),
          //             SizedBox(width: 8),
          //             Padding(
          //               padding: const EdgeInsets.only(top: 30.0),
          //               child: Text(
          //                 'Diary',
          //                 style: TextStyle(
          //                   color: Colors.white,
          //                   fontSize: 16,
          //                   fontWeight: FontWeight.w500,
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //    //   SizedBox(width: 5),
          //
          //     ],
          //   ),
          // ),
Padding(
  padding: const EdgeInsets.all(8.0),
  child: Container(
         child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Container(
                  //   width: 150,
                  //   height: 60,
                  //   child: InkWell(
                  //     onTap: () {
                  //       selectDate(true);
                  //     },
                  //     child: Container(
                  //       padding: const EdgeInsets.all(10),
                  //       decoration: BoxDecoration(
                  //         border: Border.all(color: Colors.black),
                  //         borderRadius: BorderRadius.circular(6),
                  //       ),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Text(
                  //             _getDisplayStartDate(),
                  //             style: const TextStyle(fontSize: 18),
                  //           ),
                  //           const Icon(Icons.calendar_month),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Container(
                    width: 180,
                    height: 60,
                    child: InkWell(
                      onTap: () {
                        selectDate(true);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white, // ✅ WHITE BACKGROUND
                          border: Border.all(color: Colors.grey), // softer border
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getDisplayStartDate(),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black, // ✅ text visible on white
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.black, // ✅ icon visible
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Container(
                  //   width: 150,
                  //   height: 60,
                  //   child: InkWell(
                  //     onTap:() {
                  //       selectDate(false);
                  //     },
                  //     child: Container(
                  //       padding: const EdgeInsets.all(15),
                  //       decoration: BoxDecoration(
                  //         border: Border.all(color: Colors.black),
                  //         borderRadius: BorderRadius.circular(6),
                  //       ),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Text(
                  //             _getDisplayEndDate(),
                  //             style: const TextStyle(fontSize: 18),
                  //           ),
                  //            Icon(Icons.calendar_today),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Container(
                    width: 180,
                    height: 60,
                    child: InkWell(
                      onTap: () {
                        selectDate(false);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white, // ✅ WHITE BACKGROUND
                          border: Border.all(color: Colors.grey), // softer border
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getDisplayEndDate(),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black, // ✅ readable text
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.black, // ✅ visible icon
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
           // SizedBox(height: 20,),
  ),
),

          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white, // ✅ WHITE BACKGROUND
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey), // soft border
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedSubject,
                      dropdownColor: Colors.white, // ✅ dropdown list bg
                      style: const TextStyle(color: Colors.black), // ✅ text color
                      iconEnabledColor: Colors.black, // ✅ arrow color
                      items: subjectList.map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(
                            subject,
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubject = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Select Subject",
                        labelStyle: const TextStyle(color: Colors.black),
                        border: InputBorder.none, // ✅ remove extra border
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

  SizedBox(height: 20,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _loadData(
                subject: selectedSubject,
                startDate: selected_startDate,
                //endDate: selected_endDate,
              );
            },
            child: const Text("Search"),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left:20.0,right: 20.0),
            child: Column(
                children: [

                  Container(
                    width: double.infinity,
                    height: (!_showContainer) ? 70 : 350,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white, // ✅ MAIN BACKGROUND WHITE
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        children: [

                          /// 🔹 HEADER ROW
                          Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: Text(
                                  "This view was toggled!",
                                  style: TextStyle(color: Colors.black), // ✅ text black
                                ),
                              ),

                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.download,
                                        color: Colors.black, // ✅ icon black
                                        size: 20,
                                      ),
                                      onPressed: _exportAndSharePDF,
                                    ),

                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        (!_showContainer)
                                            ? Icons.arrow_drop_down
                                            : Icons.arrow_drop_up,
                                        color: Colors.black, // ✅ icon black
                                        size: 20,
                                      ),
                                      onPressed: toggleView,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          /// 🔹 LIST SECTION
                          if (_showContainer)
                            Expanded(
                              child: Card(
                                color: Colors.grey[100], // ✅ light grey inside
                                child: Container(
                                  height: 250,
                                  width: double.maxFinite,
                                  child: datalist.isEmpty
                                      ? const Center(
                                    child: Text(
                                      "No diary entries found.",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                      : ListView.builder(
                                    itemCount: datalist.length,
                                    itemBuilder: (context, index) {
                                      final item = datalist[index];

                                      return Card(
                                        color: Colors.white, // ✅ inner card white
                                        elevation: 3,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: GestureDetector(
                                            onTap: () =>
                                                _showContentDialog(item.keyid!),
                                            child: Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  Icons.book,
                                                  color: Colors.black, // ✅ icon black
                                                  size: 50,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    "${item.startdate}\n${item.subject}\n${item.remarks}",
                                                    style: const TextStyle(
                                                        color: Colors.black), // ✅ text black
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ],),
          ),
          Spacer(),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 40.0,bottom: 50),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                Spacer(),
                Spacer(),
                Spacer(),
                Spacer(),
                Spacer(),
                Spacer(),
                Spacer(),
                Container(
                  height: 65,

                  child: FloatingActionButton(
                    backgroundColor: Colors.red,
                    tooltip: 'Increment',
                    shape: const CircleBorder(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddDiary()),
                      );
                    },
                    child: const Icon(Icons.add, color: Colors.white, size: 25),
                  ),
                ),
                //  Text('Home'),
                Spacer(),
              ],
            ),
          )



        ],
      ),

    );
  }

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.black,style: BorderStyle.solid)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold,),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }


}
Widget buildRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Text(
          "$label : ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

