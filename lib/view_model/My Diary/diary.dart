
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../view/home/widget/home_screen.dart';
import 'addDiary.dart';
import 'diaryheader.dart';
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

class _DiaryState extends State<Diary> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  bool _isRefreshing = false; // ✅ NEW
  Future<void> _refreshData() async {
    if (_isRefreshing) return; // ✅ prevent double tap

    setState(() => _isRefreshing = true);

    await _loadData(
      subject: selectedSubject,
      date: selectedDate,
    );

    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  final Color _primaryPurple = const Color(0xFF9D4EDD);
  final List<Gradient> _headerGradients = [
    const LinearGradient(
      colors: [Color(0xFF9D4EDD), Color(0xFF4361EE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];
  DateTime selectedDate = DateTime.now();
  String? selectedSubject;

  List<DiaryModel> datalist = [];
  List<String> subjectList = [];

  bool _showList = true;

  @override
  void initState() {
    super.initState();
   // datalist = [];
    _loadSubjects();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _refreshData(); // ✅ ensures subject is loaded first
    // });
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color backgroundColor,
    bool pulse = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulse ? _pulseAnimation : _slideController,
        builder: (context, child) {
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          );
        },
      ),
    );
  }

  // ================= LOAD DATA =================
  Future<void> _loadData({String? subject, DateTime? date}) async {
    setState(() {
      datalist = [];
    });

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
              entryDate.day != date.day) {
            continue;
          }
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

    if (!mounted) return;

    setState(() {
      datalist = loaded;
    });
  }

  Future<void> _loadSubjects() async {
    final rows = await DatabaseHelper().getAllData("DIARYSUBJECT_table");
print("Rows are....$rows");
    setState(() {
      subjectList = rows.map((row) {
        final data = jsonDecode(row['data']);
        return data['subject'].toString();
      }).toList();

      selectedSubject = null; // ✅ NO AUTO SELECTION
   selectedSubject = subjectList.first;
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
    final size = MediaQuery.of(context).size;
    final double scale = (size.width / 420).clamp(0.78, 1.0);

    return Scaffold(

      // ✅ FLOATING BUTTON FIXED BOTTOM
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () async {
          await Navigator.push(
            context,
           MaterialPageRoute(builder: (_) => AddDiary()),
            //MaterialPageRoute(builder: (_) => JournalHeaderOnlyPage())
          );
          await _refreshData();
        //   _loadData(
        //     subject: selectedSubject,
        //     date: selectedDate,
        //   );
        // _refreshData();
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
Container(
  child: Padding(
    padding: const EdgeInsets.all(0),
    child: Column(
      children: [
        SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: EdgeInsets.all(0 * scale),
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              gradient: _headerGradients[0],
              borderRadius: BorderRadius.circular(20 * scale),
              boxShadow: [
                BoxShadow(
                  color: _primaryPurple.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // _buildIconButton(
                //   icon: _isRefreshing
                //       ? Icons.hourglass_empty
                //       : Icons.refresh_rounded,
                //   onTap: _isRefreshing ? () {} : _refreshData,
                //   color: Colors.white,
                //   backgroundColor: Colors.white24,
                //   pulse: !_isRefreshing,
                // ),
                _buildIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SaveApp()),
                      );},
                  color: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),

                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Diary',
                      textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 24 * scale,
                          color: Colors.white,
                        ),
                      ),
                  //    SizedBox(height: 4 * scale),

                    ],
                  ),
                ),
                _buildIconButton(
                  icon: _isRefreshing
                      ? Icons.hourglass_empty
                      : Icons.refresh_rounded,
                  onTap: _isRefreshing ? () {} : _refreshData,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                  pulse: !_isRefreshing,
                ),
                // _buildIconButton(
                //   icon: Icons.refresh_rounded,
                //   onTap: () {},
                //   color: Colors.white,
                //   backgroundColor: Colors.white.withOpacity(0.2),
                //   pulse: true,
                // ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),
            /// HEADER

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
              child: subjectList.isEmpty
                  ? const Center(
                child: Text(
                  "No Subjects Found",
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemExtent: 120,
                itemCount: subjectList.length,
                itemBuilder: (context, index) {
                  final subject = subjectList[index];
                  final isSelected = selectedSubject == subject;

                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        selectedSubject = subject;
                      });

                      await _loadData(
                        subject: selectedSubject,
                        date: selectedDate,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        subject,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.all(0),
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
                    firstChild:
    SizedBox(
    height: 320,
    child: selectedSubject == null
    ? const Center(
    child: Text(
    "Select a subject to view entries",
    style: TextStyle(fontSize: 16),
    ),
    )
        : datalist.isEmpty
    ? const Center(
    child: Text(
    "No Data Found",
    style: TextStyle(fontSize: 16),
    ),
    )
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


