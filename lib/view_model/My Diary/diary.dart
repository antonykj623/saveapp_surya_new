import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../view/home/widget/home_screen.dart';
import 'addDiary.dart';
import 'editDiary.dart';
import 'calandar.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

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
    required this.subject,
  });
}

class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  DateTime selectedDate = DateTime.now();
  String? selectedSubject;

  List<DiaryModel> datalist = [];
  List<String> subjectList = [];

  bool _showList = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  // ================= LOAD DATA =================
  Future<void> _loadData({String? subject, DateTime? date}) async {
    final rawData = await DatabaseHelper().fetchAllDiaryData();

    List<DiaryModel> loaded = [];

    for (var entry in rawData) {
      try {
        final decoded = jsonDecode(entry['data']);
        final rawDate = decoded['startdate'];

        if (rawDate == null) continue;

        final entryDate = DateTime.parse(rawDate);

        if (subject != null && subject.isNotEmpty) {
          if (decoded['subject'] != subject) continue;
        }

        if (date != null) {
          if (entryDate.year != date.year ||
              entryDate.month != date.month ||
              entryDate.day != date.day) continue;
        }

        loaded.add(
          DiaryModel(
            keyid: entry['keyid'],
            language: decoded['language'] ?? "",
            startdate: DateFormat('dd/MM/yyyy').format(entryDate),
            remarks: decoded['remarks'] ?? "",
            subject: decoded['subject'] ?? "",
          ),
        );
      } catch (_) {}
    }

    setState(() {
      datalist = loaded;
    });
  }

  // ================= SUBJECTS =================
  Future<void> _loadSubjects() async {
    final rows = await DatabaseHelper().getAllData("DIARYSUBJECT_table");

    setState(() {
      subjectList = rows.map((row) {
        final data = jsonDecode(row['data']);
        return data['subject'].toString();
      }).toList();

      if (subjectList.isNotEmpty) {
        selectedSubject = subjectList.first;
      }
    });
  }

  // ================= PDF =================
  Future<void> exportPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Table.fromTextArray(
          headers: ['Date', 'Subject', 'Remarks'],
          data: datalist
              .map((e) => [e.startdate, e.subject, e.remarks])
              .toList(),
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/diary.pdf");

    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)]);
  }

  // ================= VIEW DIALOG =================
  void _showContentDialog(int keyid) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Diary Entry"),
        content: FutureBuilder<Map<String, dynamic>?>(
          future: DatabaseHelper().getDataByKeyId('DIARY_table', keyid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final item = snapshot.data!;
            final dat = jsonDecode(item["data"]);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Subject: ${dat['subject']}"),
                Text("Remarks: ${dat['remarks']}"),
                const SizedBox(height: 10),

                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Editdiary(
                              keyid: item['keyid'].toString(),
                              date: dat['startdate'],
                              subject: dat['subject'],
                              remark: dat['remarks'],
                            ),
                          ),
                        );

                        _loadData(
                          subject: selectedSubject,
                          date: selectedDate,
                        );
                      },
                      child: const Text("Edit"),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        await DatabaseHelper()
                            .deleteByKeyId('DIARY_table', keyid);

                        Navigator.pop(context);

                        _loadData(
                          subject: selectedSubject,
                          date: selectedDate,
                        );
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void toggleList() {
    setState(() => _showList = !_showList);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ✅ FLOATING BUTTON FIXED BOTTOM
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddDiary()),
          );

          _loadData(
            subject: selectedSubject,
            date: selectedDate,
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF112eea),
              Color(0xFF121ba2),
              Color(0xFFF111fb)
            ],
          ),
        ),
        child: Column(
          children: [

            /// HEADER
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black.withOpacity(0.2),
              child: SafeArea(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SaveApp()),
                        );
                      },
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Text("Diary",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ================= CALENDAR =================
            Padding(
              padding: const EdgeInsets.all(0),
              child: GemCalendar(
                entries: datalist,
                onDateSelected: (date) {
                  setState(() => selectedDate = date);
                },
              ),
            ),

            // ================= DROPDOWN =================
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subjectList.length,
                itemBuilder: (context, index) {
                  final subject = subjectList[index];
                  final isSelected = selectedSubject == subject;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSubject = subject;
                      });
                    },

                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Colors.grey),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        subject,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(10),
            //   child: DropdownButtonFormField<String>(
            //     value: selectedSubject,
            //     items: subjectList
            //         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            //         .toList(),
            //     onChanged: (val) => setState(() => selectedSubject = val),
            //   ),
            // ),
            const SizedBox(height: 20),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 12),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(12),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black12,
            //         blurRadius: 6,
            //         offset: Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   child: DropdownButtonFormField<String>(
            //     value: selectedSubject,
            //     isExpanded: true,
            //     dropdownColor: Colors.white,
            //     icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            //
            //     items: subjectList
            //         .map((e) => DropdownMenuItem(
            //       value: e,
            //       child: Text(e),
            //     ))
            //         .toList(),
            //
            //     onChanged: (val) => setState(() => selectedSubject = val),
            //
            //     decoration: const InputDecoration(
            //       border: InputBorder.none,
            //
            //     ),
            //   ),
            // ),
            // ================= SEARCH =================
            ElevatedButton(
              onPressed: () {
                _loadData(
                  subject: selectedSubject,
                  date: selectedDate,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink, // ✅ pink background
                foregroundColor: Colors.white, // ✅ text color
              ),
              child: const Text("Search"),
            ),

            // ================= LIST =================
            // Expanded(
            //   child: Container(
            //     margin: const EdgeInsets.all(10),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //
            //     child: Column(
            //       children: [
            //
            //         // HEADER
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //
            //             const Padding(
            //               padding: EdgeInsets.all(8),
            //               child: Text("Diary Entries"),
            //             ),
            //
            //             Row(
            //               children: [
            //
            //                 // DOWNLOAD BUTTON (TOP RIGHT SMALL ICON)
            //                 IconButton(
            //                   icon: const Icon(Icons.download, size: 20),
            //                   onPressed: exportPDF,
            //                 ),
            //
            //                 // TOGGLE BUTTON
            //                 IconButton(
            //                   icon: Icon(_showList
            //                       ? Icons.keyboard_arrow_up
            //                       : Icons.keyboard_arrow_down),
            //                   onPressed: toggleList,
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //
            //         // LIST
            //         if (_showList)
            //           Expanded(
            //             child: datalist.isEmpty
            //                 ? const Center(child: Text("No Data"))
            //                 : ListView.builder(
            //               itemCount: datalist.length,
            //               itemBuilder: (_, i) {
            //                 final item = datalist[i];
            //
            //                 return ListTile(
            //                   leading: const Icon(Icons.book),
            //                   title: Text(item.subject),
            //                   subtitle: Text(
            //                       "${item.startdate}\n${item.remarks}"),
            //                   onTap: () =>
            //                       _showContentDialog(item.keyid!),
            //                 );
            //               },
            //             ),
            //           ),
            //       ],
            //     ),
            //   ),
            // ),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [

                  // HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        const Text(
                          "Diary Entries",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        Row(
                          children: [

                            // 📥 DOWNLOAD BUTTON
                            IconButton(
                              icon: const Icon(Icons.download, size: 20),
                              onPressed: exportPDF,
                            ),

                            // 🔼 TOGGLE BUTTON
                            IconButton(
                              icon: Icon(
                                _showList
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showList = !_showList;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // BODY
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),

                    crossFadeState: _showList
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,

                    // 📜 LIST VIEW
                    firstChild: SizedBox(
                      height: 320,
                      child: datalist.isEmpty
                          ? const Center(child: Text("No Data"))
                          : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: datalist.length,
                        itemBuilder: (_, i) {
                          final item = datalist[i];

                          return ListTile(
                            leading: const Icon(Icons.book),
                            title: Text(item.subject),
                            subtitle: Text(
                              "${item.startdate}\n${item.remarks}",
                            ),
                            onTap: () => _showContentDialog(item.keyid!),
                          );
                        },
                      ),
                    ),

                    // 🔽 COLLAPSED VIEW
                    secondChild: const SizedBox(
                      height: 50,
                      child: Center(child: Text("Hidden")),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
