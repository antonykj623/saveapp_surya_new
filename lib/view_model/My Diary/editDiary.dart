import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/My Diary/diary.dart';

import 'addSubject.dart';

class Editdiary extends StatefulWidget {
  final keyid, date, subject, remark;

  Editdiary({super.key, this.keyid, this.date, this.subject, this.remark});

  @override
  State<Editdiary> createState() => _EditDiaryPageState();
}

class _EditDiaryPageState extends State<Editdiary> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  final Color _primaryPurple = const Color(0xFF9D4EDD);
  final List<Gradient> _headerGradients = [
    const LinearGradient(
      colors: [Color(0xFF9D4EDD), Color(0xFF4361EE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  late DateTime selectedDate;
  String? selectedSubject;

  final TextEditingController _remarksController = TextEditingController();

  String dropdownvalu1 = 'English';

  List<String> subjectList = [];

  @override
  void initState() {
    super.initState();
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
    _remarksController.text = widget.remark ?? "";

    try {
      selectedDate = DateTime.parse(widget.date.toString());
    } catch (_) {
      selectedDate = DateTime.now();
    }

    selected_startDate = selectedDate;

    _loadSubjects();
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
  Future<void> _loadSubjects() async {
    final dbHelper = DatabaseHelper();
    final rows = await dbHelper.getAllData("DIARYSUBJECT_table");

    setState(() {
      subjectList = rows.map((row) {
        dynamic data = row['data'];

        if (data is String) {
          data = jsonDecode(data);
        }

        if (data is Map && data.containsKey('subject')) {
          return data['subject'].toString();
        }
        return "";
      }).where((e) => e.isNotEmpty).toList();

      selectedSubject = widget.subject;
    });
  }

  DateTime selected_startDate = DateTime.now();

  String _getDisplayStartDate() {
    return DateFormat('dd/MM/yyyy').format(selected_startDate);
  }

  void selectDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: selected_startDate,
    );

    if (picked != null) {
      setState(() {
        selected_startDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scale = (size.width / 420).clamp(0.78, 1.0);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF112eea),
              Color(0xFF121ba2),
              Color(0xFFF111fb),
            ],
          ),
        ),

        child: Column(
          children: [

            /// HEADER
            Container(
              child: Column(
                children: [
                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.all(16 * scale),
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
                                    builder: (_) => const Diary()),
                              );},
                            color: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),

                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ' Edit Diary',
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


            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //   decoration: BoxDecoration(
            //     color: Colors.black.withOpacity(0.2),
            //   ),
            //   child: SafeArea(
            //     child: Row(
            //       children: [
            //         GestureDetector(
            //           onTap: () => Navigator.pop(context),
            //           child: const Icon(Icons.arrow_back, color: Colors.white),
            //         ),
            //         const SizedBox(width: 10),
            //         const Text(
            //           "Edit Diary",
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 18,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         )
            //       ],
            //     ),
            //   ),
            // ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      /// LANGUAGE
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton(
                          isExpanded: true,
                          value: dropdownvalu1,
                          items: ["English", "Malayalam", "Hindi"]
                              .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              dropdownvalu1 = val!;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// DATE PICKER
                      InkWell(
                        onTap: selectDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_getDisplayStartDate()),
                              const Icon(Icons.calendar_month),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// SUBJECT
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonFormField<String>(
                          value: selectedSubject,
                          items: subjectList
                              .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedSubject = val;
                            });
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: "Subject",
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// REMARKS
                      Container(
                        color: Colors.white,
                        child: TextFormField(
                          controller: _remarksController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                            labelText: "Remarks",
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// UPDATE BUTTON
                      SizedBox(
                        //width: double.infinity,
                        child: Container(
                          width: 200,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[600],
                              padding: const EdgeInsets.all(14),
                            ),
                            onPressed: () async {
                              final language = dropdownvalu1;
                              final subject = selectedSubject ?? "";
                              final remarks = _remarksController.text;
                              final date = selected_startDate.toString();

                              await DatabaseHelper().updateDiary(
                                date,
                                subject,
                                remarks,
                                language,
                                widget.keyid,
                              );

                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Update",
                              style: TextStyle(color: Colors.white,fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
//
// import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
// import 'package:new_project_2025/view_model/My%20Diary/diary.dart';
//
// import 'addSubject.dart';
//
// class Editdiary extends StatefulWidget {
//
//  final keyid,date,subject,remark;
//     Editdiary({super.key, this.keyid, this.date, this.subject, this.remark});
//
//   @override
//   State<Editdiary> createState() => _EditDiaryPageState();
// }
//
// class _EditDiaryPageState extends State<Editdiary> {
//
//
//   @override
//   void initState() {
//     super.initState();
// setState(() {
//   _loadSubjects();
//   _remarksController.text = widget.remark;
//   if (widget.date != null) {
//     try {
//       selectedDate = DateTime.parse(widget.date.toString());
//     } catch (_) {
//       selectedDate = DateTime.now();
//     }
//   } else {
//     selectedDate = DateTime.now();
//   }
//
//   // This makes the date picker text match saved date immediately
//   selected_startDate = selectedDate;
//   // selected_startDate = widget.date;
// });
//
//   }
//   List<String> subjectList = [];
//
//   Future<void> _loadSubjects() async {
//     final dbHelper = DatabaseHelper();
//
//     final rows = await dbHelper.getAllData("DIARYSUBJECT_table");
//     print("Rows are $rows");
//
//     setState(() {
//       subjectList = rows.map((row) {
//         // Step 1: Make sure we have a map, not a string
//         dynamic data = row['data'];
//         if (data is String) {
//           try {
//             data = jsonDecode(data);
//             print("Jsonatas are $data");// convert JSON string to Map
//           } catch (e) {
//             print("JSON decode error: $e");
//             return ""; // skip this row if invalid
//           }
//         }
//
//         // Step 2: Safely extract 'subject'
//         if (data is Map && data.containsKey('subject')) {
//           return data['subject'].toString();
//         } else {
//           return ""; // skip if no subject key
//         }
//       }).where((s) => s.isNotEmpty).toList();
//
//       if (subjectList.isNotEmpty) {
//         selectedSubject = widget.subject;
//       }
//     });
//   }
//
//   final _formKey = GlobalKey<FormState>();
//   late DateTime selectedDate;
//   String? selectedAccount;
//   final TextEditingController _amountController = TextEditingController();
//   String paymentMode = 'Cash';
//   String? selectedCashOption;
//   final TextEditingController _remarksController = TextEditingController();
//   var dropdownvalu1 = 'English';
//   String? selectedSubject;
//   var items1 = [
//     'English',
//     'Malayalam',
//     'Hindi',
//
//   ];
//   var items2= [
//     'Add Subjecct',
//
//
//   ];
//
//
//
//   String selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
//   DateTime selected_startDate = DateTime.now();
//   DateTime selected_endDate = DateTime.now();
//
//   String _getDisplayStartDate() {
//     return DateFormat('dd/MM/yyyy').format(selected_startDate);
//   }
//
//   selectDate(bool isStart) {
//     showDatePicker(
//       context: context,
//
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     ).then((pickedDate) {
//       if (pickedDate != null) {
//         setState(() {
//           selectedDate = pickedDate;
//           selectedYearMonth = DateFormat('yyyy-MM').format(pickedDate);
//           if (isStart) {
//             selected_startDate = pickedDate;
//           } else {
//             selected_endDate = pickedDate;
//           }
//
//         });
//       }
//     });
//   }
//
//   late AnimationController _buttonHoverController;
//   late AnimationController _backgroundController;
//   late Animation<double> _buttonScaleAnimation;
//   late Animation<double> _backgroundAnimation;
//   bool _obscurePassword = true;
//
//   // Map original border types to new border types
//   String _mapBorderType(String originalType) {
//     switch (originalType) {
//       case 'cyber':
//         return 'electric';
//       case 'aurora':
//         return 'rainbow';
//       case 'matrix':
//         return 'neon'; // Matrix maps to neon for green digital effect
//       case 'galaxy':
//         return 'ocean'; // Galaxy maps to ocean for a cosmic feel
//       case 'plasma':
//         return 'fire';
//       case 'neon':
//         return 'neon';
//       default:
//         return 'electric';
//     }
//   }
//
//   // Define custom colors to match original ModernAnimatedBorderWidget
//   List<Color> _getCustomColors(String borderType) {
//     switch (borderType) {
//       case 'cyber':
//         return [
//           Colors.transparent,
//           Color(0xFF00D4FF).withOpacity(0.3),
//           Color(0xFF0099FF),
//           Color(0xFF00FFFF),
//           Color(0xFF39FF14),
//           Color(0xFF00FFFF),
//           Color(0xFF0099FF),
//           Colors.transparent,
//         ];
//       case 'aurora':
//         return [
//           Colors.transparent,
//           Color(0xFF00FF87).withOpacity(0.4),
//           Color(0xFF60EFFF),
//           Color(0xFF00FF87),
//           Color(0xFFFFE66D),
//           Color(0xFF00FF87),
//           Color(0xFF60EFFF),
//           Colors.transparent,
//         ];
//       case 'matrix':
//         return [
//           Colors.transparent,
//           Color(0xFF39FF14).withOpacity(0.3),
//           Color(0xFF39FF14),
//           Color(0xFF00FF00),
//           Color(0xFF32CD32),
//           Color(0xFF00FF00),
//           Color(0xFF39FF14),
//           Colors.transparent,
//         ];
//       case 'galaxy':
//         return [
//           Colors.transparent,
//           Color(0xFF9B59B6).withOpacity(0.4),
//           Color(0xFF8E44AD),
//           Color(0xFFE74C3C),
//           Color(0xFFF39C12),
//           Color(0xFFE74C3C),
//           Color(0xFF8E44AD),
//           Colors.transparent,
//         ];
//       case 'plasma':
//         return [
//           Colors.transparent,
//           Color(0xFFFF6B6B).withOpacity(0.4),
//           Color(0xFFFF8E8E),
//           Color(0xFFFFB347),
//           Color(0xFFFFD93D),
//           Color(0xFFFFB347),
//           Color(0xFFFF8E8E),
//           Colors.transparent,
//         ];
//       case 'neon':
//         return [
//           Colors.transparent,
//           Color(0xFF667eea).withOpacity(0.4),
//           Color(0xFF764ba2),
//           Color(0xFF89f7fe),
//           Color(0xFF66a6ff),
//           Color(0xFF89f7fe),
//           Color(0xFF764ba2),
//           Colors.transparent,
//         ];
//       default:
//         return [Colors.grey.shade300];
//     }
//   }
//
//   Widget _buildModernButton({
//     required String text,
//     required VoidCallback onPressed,
//     required List<Color> gradientColors,
//     required String borderType,
//     bool isDestructive = false,
//   }) {
//     return AnimatedBuilder(
//       animation: _buttonScaleAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _buttonScaleAnimation.value,
//           child: AnimatedBorderWidget(
//             borderType: _mapBorderType(borderType),
//             customColors: _getCustomColors(borderType),
//             borderWidth: 2.0,
//             glowSize: 6.0,
//             borderRadius: BorderRadius.circular(25),
//             isActive: true,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: gradientColors,
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(25),
//                 boxShadow: [
//                   BoxShadow(
//                     color: gradientColors[0].withOpacity(0.3),
//                     blurRadius: 15,
//                     offset: Offset(0, 8),
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(25),
//                   onTap: onPressed,
//                   onTapDown: (_) => _buttonHoverController.forward(),
//                   onTapUp: (_) => _buttonHoverController.reverse(),
//                   onTapCancel: () => _buttonHoverController.reverse(),
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                     child: Center(
//                       child: Text(
//                         text,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           letterSpacing: 1.2,
//                           shadows: [
//                             Shadow(
//                               color: Colors.black.withOpacity(0.3),
//                               blurRadius: 4,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       body: Column(
//
//         children: [
//           Container(
//
//             width: double.infinity,
//             padding:  EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 12,),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFF093fb)],
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.15),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(Icons.arrow_back, color: Colors.white),
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         'Edit Diary',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           Container(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child:DropdownButton(
//                         isExpanded: true,
//                         // Initial Value
//                         value: dropdownvalu1,
//
//                         // Down Arrow Icon
//                         icon: const Icon(Icons.keyboard_arrow_down),
//
//                         // Array list of items
//                         items: items1.map((String items) {
//                           return DropdownMenuItem(
//                             value: items,
//                             child: Text(items),
//                           );
//                         }).toList(),
//                         // After selecting the desired option,it will
//                         // change button value to selected value
//                         onChanged: (String? newValue2) {
//                           setState(() {
//                             dropdownvalu1 = newValue2!;
//                             print("Value is..:$dropdownvalu1");
//                           });
//                         },
//                       ),
//
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       width: 380,
//                       height: 40,
//                       child: InkWell(
//                         onTap: () {
//                           selectDate(true);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.black),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 _getDisplayStartDate(),
//                                 style: const TextStyle(fontSize: 18),
//                               ),
//                               const Icon(Icons.calendar_today),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//
//
//
//
//
//
//                     const SizedBox(height: 16),
//
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 10),
//
//
//                               child:
//
//                               DropdownButtonFormField<String>(
//                                 value: selectedSubject,
//                                 items: subjectList.map((subject) {
//                                   return DropdownMenuItem(
//                                     value: subject,
//                                     child: Text(subject),
//                                   );
//                                 }).toList(),
//                                 onChanged: (value) {
//                                   setState(() {
//                                     selectedSubject = widget.subject!;
//                                   });
//                                 },
//                                 decoration: InputDecoration(
//                                   labelText: "Select Subject",
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               )
//
//
//
//
//                           ),
//                         ),
//
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Container(
//                             child: FloatingActionButton(
//                               backgroundColor: Colors.red,
//                               tooltip: 'Increment',
//                               shape:   const CircleBorder(),
//                               onPressed: (){
//                                 Navigator.push(context,MaterialPageRoute(builder:(context)=>Adddsubject( )));
//
//
//                               },
//                               child: const Icon(Icons.add, color: Colors.white, size: 25),
//                             ),
//                           ),
//                         ),
//                       ],),
//
//
//
//                     const SizedBox(height: 5),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//
//                       child: AnimatedTextField(
//                         controller: _remarksController,
//                         maxLines: 3,
//                         labelText: 'Remarks',
//
//
//                         borderType: _mapBorderType("matrix"),
//                         customColors: _getCustomColors("matrix"),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Center(
//
//                       child: Column(
//                         children: [
//                           Container(
//                             width: 100,
//                             child: ElevatedButton(
//
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.teal,// background (button) color
//                                 foregroundColor: Colors.white,
//                                 // foreground (text) color
//                               ),
//
//                               onPressed: () async{
//                                 if (_formKey.currentState!.validate()) {
//                                   try {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(content: Text('Processing Data')),
//                                     );
//
//                                     final language = dropdownvalu1;
//                                     final subject =  selectedSubject;
//                                     final startdate = selectedDate.toString();
//                                     final remarks = _remarksController.text;
//                                     final keyid = widget.keyid;
//                                     print('Language name is ...$language');
//                                     print('Subject name is ...$subject');
//                                     print('Startdate name is ...$startdate');
//                                     print('remarks name is ...$remarks');
//
//                                     Map<String, dynamic> diaryData = {
//                                       "language": language,
//                                       "startdate": startdate,
//                                       "remarks": remarks,
//                                       "subject": subject,
//                                       "keyid": keyid,
//                                     };
//
//                                     // Save to database
//                                     await DatabaseHelper().updateDiary(startdate, subject!, remarks, language, keyid);
//
//
//                                     // Show success message
//                                     if (mounted) {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             'selected language is "$language" added successfully!',
//                                           ),
//                                           backgroundColor: Colors.green,
//                                         ),
//                                       );
//
//
//                                       Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                           builder:
//                                           (context) => Diary()));
//                                       // Return true to indicate success and pop the page
//                                     //  Navigator.pop(context, true);
//                                     }
//                                   } catch (e) {
//                                     print('Error  in Diary Data: $e');
//                                     if (mounted) {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                           content: Text('Error  in Diary Data: $e'),
//                                           backgroundColor: Colors.red,
//                                         ),
//                                       );
//                                     }
//                                   }
//                                 }
//                               },
//                               child: Text(
//                                 "Update",
//                                 style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
//                               ),
//                               //   color: const Color(0xFF1BC0C5),
//                             ),
//                           ),
//
//
// //                       Padding(
// //                         padding: const EdgeInsets.all(8.0),
// //                         child: ElevatedButton(onPressed: () async {
// //
// //
// //                           var data =  await dbhelper.queryallacc();
// //
// //                           print("Datas are...$data");
// //
// //
// //
// //                           //  dbhelper1.accountqueryall1();
// //                           // dbhelper1;
// // //                               QuickAlert.show(
// // //  context: context,
// // //  type: QuickAlertType.success,
// // //   title: 'registration Completed Please login',
// //
// // // );
// //
// //
// //                         }, child: Text('showdata'),),
// //                       ),
// //
// //
//
//
//                           // ElevatedButton(
//                           //   onPressed: () async{
//                           //     var alterTable = await dbhelper.alterTable('accountstable','catogory');
//                           //     // alterTable();
//                           //     //   alterTable();
//                           //
//                           //     print("Value Altered : $alterTable()");
//                           //     //  clearText();
//                           //   },
//                           //
//                           //   child: Text(
//                           //     'Alter',
//                           //     style: TextStyle(color: Colors.blue, fontSize: 25),
//                           //   ),
//                           //
//                           // ),
//
//                         ],),
//
//
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ), ],  ),
//     );
//   }
// }
//
// class AnimatedBorderWidget extends StatefulWidget {
//   final Widget child;
//   final String
//   borderType; // 'electric', 'rainbow', 'fire', 'ocean', 'neon', 'custom'
//   final List<Color>? customColors;
//   final double borderWidth;
//   final double glowSize;
//   final int animationDuration; // in milliseconds
//   final BorderRadius? borderRadius;
//   final bool isActive; // Controls when animation starts/stops
//
//   const AnimatedBorderWidget({
//     Key? key,
//     required this.child,
//     this.borderType = 'electric',
//     this.customColors,
//     this.borderWidth = 3.0,
//     this.glowSize = 20.0,
//     this.animationDuration = 2500,
//     this.borderRadius,
//     this.isActive = true,
//   }) : super(key: key);
//
//   @override
//   _AnimatedBorderWidgetState createState() => _AnimatedBorderWidgetState();
// }
//
// class _AnimatedBorderWidgetState extends State<AnimatedBorderWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: widget.animationDuration),
//       vsync: this,
//     );
//
//     if (widget.isActive) {
//       _animationController.repeat();
//     }
//   }
//
//   @override
//   void didUpdateWidget(AnimatedBorderWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isActive != oldWidget.isActive) {
//       if (widget.isActive) {
//         _animationController.repeat();
//       } else {
//         _animationController.stop();
//         _animationController.reset();
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   List<Color> _getGradientColors() {
//     if (widget.customColors != null) {
//       return widget.customColors!;
//     }
//
//     switch (widget.borderType) {
//       case 'electric':
//         return [
//           Colors.transparent,
//           Color(0xFF00D4FF).withOpacity(0.3),
//           Color(0xFF0099FF).withOpacity(0.6),
//           Color(0xFF0066FF),
//           Color(0xFF3366FF),
//           Color(0xFF6633FF),
//           Color(0xFF9933FF),
//           Color(0xFFCC33FF),
//           Color(0xFF9933FF),
//           Color(0xFF6633FF),
//           Color(0xFF3366FF),
//           Color(0xFF0066FF),
//           Colors.transparent,
//         ];
//       case 'rainbow':
//         return [
//           Colors.transparent,
//           Colors.red.withOpacity(0.3),
//           Colors.orange.withOpacity(0.6),
//           Colors.yellow,
//           Colors.green,
//           Colors.blue,
//           Colors.indigo,
//           Colors.purple,
//           Colors.pink,
//           Colors.purple,
//           Colors.indigo,
//           Colors.blue,
//           Colors.green,
//           Colors.yellow,
//           Colors.orange.withOpacity(0.6),
//           Colors.red.withOpacity(0.3),
//           Colors.transparent,
//         ];
//       case 'fire':
//         return [
//           Colors.transparent,
//           Color(0xFFFF6B35).withOpacity(0.3),
//           Color(0xFFFF8C42).withOpacity(0.6),
//           Color(0xFFFFA500),
//           Color(0xFFFFD700),
//           Color(0xFFFF6347),
//           Color(0xFFFF4500),
//           Color(0xFFDC143C),
//           Color(0xFFB22222),
//           Color(0xFFDC143C),
//           Color(0xFFFF4500),
//           Color(0xFFFF6347),
//           Color(0xFFFFD700),
//           Color(0xFFFFA500),
//           Colors.transparent,
//         ];
//       case 'ocean':
//         return [
//           Colors.transparent,
//           Color(0xFF00CED1).withOpacity(0.3),
//           Color(0xFF20B2AA).withOpacity(0.6),
//           Color(0xFF008B8B),
//           Color(0xFF00FFFF),
//           Color(0xFF40E0D0),
//           Color(0xFF48D1CC),
//           Color(0xFF00CED1),
//           Color(0xFF5F9EA0),
//           Color(0xFF00CED1),
//           Color(0xFF48D1CC),
//           Color(0xFF40E0D0),
//           Color(0xFF00FFFF),
//           Color(0xFF008B8B),
//           Colors.transparent,
//         ];
//       case 'neon':
//         return [
//           Colors.transparent,
//           Color(0xFFFF073A).withOpacity(0.3),
//           Color(0xFFFF073A).withOpacity(0.6),
//           Color(0xFFFF073A),
//           Color(0xFF39FF14),
//           Color(0xFF00FFFF),
//           Color(0xFFFF1493),
//           Color(0xFFFFFF00),
//           Color(0xFF9400D3),
//           Color(0xFFFFFF00),
//           Color(0xFFFF1493),
//           Color(0xFF00FFFF),
//           Color(0xFF39FF14),
//           Color(0xFFFF073A),
//           Colors.transparent,
//         ];
//       default:
//         return [Colors.grey.shade300];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return CustomAnimatedBorder(
//           borderSize: widget.isActive ? widget.borderWidth : 1.0,
//           glowSize: widget.isActive ? widget.glowSize : 0.0,
//           gradientColors:
//           widget.isActive ? _getGradientColors() : [Colors.grey.shade300],
//           animationProgress: _animationController.value,
//           borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
//           child: widget.child,
//         );
//       },
//     );
//   }
// }
//
// class CustomAnimatedBorder extends StatelessWidget {
//   final Widget child;
//   final double borderSize;
//   final double glowSize;
//   final List<Color> gradientColors;
//   final double animationProgress;
//   final BorderRadius borderRadius;
//
//   const CustomAnimatedBorder({
//     Key? key,
//     required this.child,
//     required this.borderSize,
//     required this.glowSize,
//     required this.gradientColors,
//     required this.animationProgress,
//     required this.borderRadius,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: borderRadius,
//         boxShadow:
//         glowSize > 0
//             ? [
//           BoxShadow(
//             color:
//             gradientColors.isNotEmpty
//                 ? gradientColors[gradientColors.length ~/ 2]
//                 .withOpacity(0.8)
//                 : Colors.blue.withOpacity(0.8),
//             blurRadius: glowSize,
//             spreadRadius: glowSize / 4,
//           ),
//           BoxShadow(
//             color:
//             gradientColors.isNotEmpty
//                 ? gradientColors[gradientColors.length ~/ 3]
//                 .withOpacity(0.5)
//                 : Colors.blue.withOpacity(0.5),
//             blurRadius: glowSize * 1.5,
//             spreadRadius: glowSize / 3,
//           ),
//           BoxShadow(
//             color:
//             gradientColors.isNotEmpty
//                 ? gradientColors[gradientColors.length ~/ 4]
//                 .withOpacity(0.3)
//                 : Colors.blue.withOpacity(0.3),
//             blurRadius: glowSize * 2,
//             spreadRadius: glowSize / 2,
//           ),
//         ]
//             : null,
//       ),
//       child: CustomPaint(
//         painter: AnimatedBorderPainter(
//           borderSize: borderSize,
//           gradientColors: gradientColors,
//           animationProgress: animationProgress,
//           borderRadius: borderRadius,
//         ),
//         child: child,
//       ),
//     );
//   }
// }
//
// class AnimatedBorderPainter extends CustomPainter {
//   final double borderSize;
//   final List<Color> gradientColors;
//   final double animationProgress;
//   final BorderRadius borderRadius;
//
//   AnimatedBorderPainter({
//     required this.borderSize,
//     required this.gradientColors,
//     required this.animationProgress,
//     required this.borderRadius,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (gradientColors.length <= 1) {
//       // Static border for inactive state
//       final paint =
//       Paint()
//         ..color =
//         gradientColors.isNotEmpty ? gradientColors.first : Colors.grey
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = borderSize;
//
//       final rect = Rect.fromLTWH(
//         borderSize / 2,
//         borderSize / 2,
//         size.width - borderSize,
//         size.height - borderSize,
//       );
//       final rrect = RRect.fromRectAndRadius(rect, borderRadius.topLeft);
//       canvas.drawRRect(rrect, paint);
//       return;
//     }
//
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     final rrect = RRect.fromRectAndRadius(rect, borderRadius.topLeft);
//     final path = Path()..addRRect(rrect);
//     final pathMetrics =
//     path.computeMetrics().toList(); // Fixed typo: toockedList -> toList
//
//     if (pathMetrics.isNotEmpty) {
//       final pathMetric = pathMetrics.first;
//       final totalLength = pathMetric.length;
//
//       if (totalLength > 0) {
//         final trainLength = totalLength * 0.4;
//         final trainPosition = (animationProgress * totalLength) % totalLength;
//
//         // Draw main gradient train
//         _drawGradientTrain(
//           canvas,
//           pathMetric,
//           totalLength,
//           trainLength,
//           trainPosition,
//         );
//
//         // Draw sparkle effects
//         _drawSparkleEffects(
//           canvas,
//           pathMetric,
//           totalLength,
//           trainPosition,
//           trainLength,
//         );
//
//         // Draw trailing glow
//         _drawTrailingGlow(
//           canvas,
//           pathMetric,
//           totalLength,
//           trainPosition,
//           trainLength,
//         );
//       }
//     }
//   }
//
//   void _drawGradientTrain(
//       Canvas canvas,
//       PathMetric pathMetric,
//       double totalLength,
//       double trainLength,
//       double trainPosition,
//       ) {
//     for (int i = 0; i < gradientColors.length; i++) {
//       final segmentLength = trainLength / gradientColors.length;
//       final segmentStart =
//           (trainPosition - trainLength / 2 + i * segmentLength) % totalLength;
//       final segmentEnd = (segmentStart + segmentLength) % totalLength;
//
//       final paint =
//       Paint()
//         ..color = gradientColors[i]
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = borderSize
//         ..strokeCap = StrokeCap.round;
//
//       try {
//         if (segmentStart < segmentEnd && segmentEnd <= totalLength) {
//           final segmentPath = pathMetric.extractPath(segmentStart, segmentEnd);
//           canvas.drawPath(segmentPath, paint);
//         } else if (segmentStart >= 0 && segmentStart < totalLength) {
//           if (segmentStart < totalLength) {
//             final segmentPath1 = pathMetric.extractPath(
//               segmentStart,
//               totalLength,
//             );
//             canvas.drawPath(segmentPath1, paint);
//           }
//           if (segmentEnd > 0) {
//             final segmentPath2 = pathMetric.extractPath(
//               0,
//               math.min(segmentEnd, totalLength),
//             );
//             canvas.drawPath(segmentPath2, paint);
//           }
//         }
//       } catch (e) {
//         continue;
//       }
//     }
//   }
//
//   void _drawSparkleEffects(
//       Canvas canvas,
//       PathMetric pathMetric,
//       double totalLength,
//       double trainPosition,
//       double trainLength,
//       ) {
//     final sparklePositions = [
//       (trainPosition + trainLength * 0.2) % totalLength,
//       (trainPosition + trainLength * 0.5) % totalLength,
//       (trainPosition + trainLength * 0.8) % totalLength,
//     ];
//
//     final sparklePaint =
//     Paint()
//       ..color = Colors.white.withOpacity(0.9)
//       ..style = PaintingStyle.fill;
//
//     final sparkleGlowPaint =
//     Paint()
//       ..color = Colors.white.withOpacity(0.3)
//       ..style = PaintingStyle.fill;
//
//     for (int i = 0; i < sparklePositions.length; i++) {
//       final pos = sparklePositions[i];
//       try {
//         if (pos >= 0 && pos <= totalLength) {
//           final tangent = pathMetric.getTangentForOffset(pos);
//           if (tangent != null) {
//             canvas.drawCircle(tangent.position, 5, sparkleGlowPaint);
//             canvas.drawCircle(tangent.position, 2, sparklePaint);
//           }
//         }
//       } catch (e) {
//         continue;
//       }
//     }
//   }
//
//   void _drawTrailingGlow(
//       Canvas canvas,
//       PathMetric pathMetric,
//       double totalLength,
//       double trainPosition,
//       double trainLength,
//       ) {
//     final trailStart = (trainPosition - trainLength * 0.6) % totalLength;
//     final trailEnd = (trainPosition - trainLength * 0.3) % totalLength;
//
//     final trailPaint =
//     Paint()
//       ..color =
//       gradientColors.isNotEmpty
//           ? gradientColors[gradientColors.length ~/ 2].withOpacity(0.3)
//           : Colors.white.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = borderSize * 1.5
//       ..strokeCap = StrokeCap.round;
//
//     try {
//       if (trailStart < trailEnd && trailEnd <= totalLength) {
//         final trailPath = pathMetric.extractPath(trailStart, trailEnd);
//         canvas.drawPath(trailPath, trailPaint);
//       }
//     } catch (e) {
//       // Continue if there's an error
//     }
//   }
//
//   @override
//   bool shouldRepaint(AnimatedBorderPainter oldDelegate) {
//     return oldDelegate.animationProgress != animationProgress ||
//         oldDelegate.borderSize != borderSize ||
//         oldDelegate.gradientColors != gradientColors;
//   }
// }
//
// class AnimatedTextField extends StatefulWidget {
//   final TextEditingController controller;
//   final String labelText;
//   final String borderType;
//   final bool obscureText;
//   final int maxLines;
//   final String? Function(String?)? validator;
//   final TextInputType? keyboardType;
//   final Icon? prefixIcon;
//   final int borderRadius;
//   final Color backgroundColor;
//   final List<Color>? customColors;
//
//   const AnimatedTextField({
//     Key? key,
//     required this.controller,
//     required this.labelText,
//     this.borderType = 'electric',
//     this.obscureText = false,
//     this.maxLines = 1,
//     this.validator,
//     this.keyboardType,
//     this.prefixIcon,
//     this.borderRadius = 12,
//     this.backgroundColor = Colors.white,
//     this.customColors,
//   }) : super(key: key);
//
//   @override
//   _AnimatedTextFieldState createState() => _AnimatedTextFieldState();
// }
//
// class _AnimatedTextFieldState extends State<AnimatedTextField> {
//   final FocusNode _focusNode = FocusNode();
//   bool _isFocused = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(() {
//       setState(() {
//         _isFocused = _focusNode.hasFocus;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return AnimatedBorderWidget(
//
//       borderType: widget.borderType,
//       customColors: widget.customColors,
//       isActive: _isFocused,
//       borderWidth: _isFocused ? 3.0 : 1.5,
//       glowSize: _isFocused ? 12.0 : 0.0,
//       borderRadius: BorderRadius.circular(widget.borderRadius.toDouble()),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(widget.borderRadius.toDouble()),
//           color:
//           _isFocused
//               ? widget.backgroundColor.withOpacity(0.95)
//               : widget.backgroundColor.withOpacity(0.92),
//           boxShadow:
//           _isFocused
//               ? [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: Offset(0, 4),
//             ),
//           ]
//               : null,
//         ),
//         child: TextFormField(
//           controller: widget.controller,
//           focusNode: _focusNode,
//           obscureText: widget.obscureText,
//           maxLines: widget.maxLines,
//           keyboardType: widget.keyboardType,
//           decoration: InputDecoration(
//             labelText: widget.labelText,
//             labelStyle: TextStyle(
//               color: _isFocused ? Colors.blue[700] : Colors.grey[600],
//               fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
//               fontSize: 16,
//             ),
//             prefixIcon:
//             widget.prefixIcon != null
//                 ? Padding(
//               padding: EdgeInsets.only(left: 8, right: 12),
//               child: widget.prefixIcon,
//             )
//                 : null,
//             border: InputBorder.none,
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: widget.prefixIcon != null ? 8 : 24,
//               vertical: widget.maxLines > 1 ? 20 : 18,
//             ),
//             floatingLabelBehavior: FloatingLabelBehavior.auto,
//           ),
//           style: TextStyle(
//             color: Colors.grey[800],
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//           validator: widget.validator,
//         ),
//       ),
//     );
//   }
// }