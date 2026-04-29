// import 'dart:math';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
// import 'package:new_project_2025/view_model/Journal/addJournal.dart';
// // import 'package:new_project_2025/view_model/Journal/Journel_class_model_class.dart';
//
// class JournalPage extends StatefulWidget {
//   const JournalPage({super.key});
//
//   @override
//   State<JournalPage> createState() => _JournalPageState();
// }
//
// class _JournalPageState extends State<JournalPage>
//     with TickerProviderStateMixin {
//   String selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
//   List<Map<String, dynamic>> journalEntries = [];
//   double total = 0;
//   bool isLoading = false;
//
//   // Animation Controllers
//   late AnimationController _fadeController;
//   late AnimationController _pulseController;
//   late AnimationController _slideController;
//   late AnimationController _pageController;
//   late AnimationController _glowController;
//   late AnimationController _colorController;
//
//   // Animations
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _pulseAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _pageAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<Color?> _colorAnimation;
//
//   // Beautiful Color Palette
//   final Color _primaryPurple = const Color(0xFF9D4EDD); // Vibrant Purple
//   final Color _secondaryPurple = const Color(0xFFC77DFF); // Light Purple
//   final Color _deepPurple = const Color(0xFF7B2CBF); // Deep Purple
//   final Color _electricBlue = const Color(0xFF4361EE); // Electric Blue
//   final Color _cyan = const Color(0xFF4CC9F0); // Bright Cyan
//   final Color _magenta = const Color(0xFFF72585); // Hot Pink/Magenta
//   final Color _green = const Color.fromARGB(255, 19, 108, 52); // Bright Green
//   final Color _orange = const Color(0xFFFB923C); // Warm Orange
//   final Color _yellow = const Color(0xFFFBBF24); // Sunny Yellow
//   final Color _coral = const Color(0xFFFF6B6B); // Coral Red
//
//   // Gradient Sets
//   final List<Gradient> _headerGradients = [
//     const LinearGradient(
//       colors: [Color(0xFF9D4EDD), Color(0xFF4361EE)],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     ),
//     const LinearGradient(
//       colors: [Color(0xFFF72585), Color(0xFF9D4EDD)],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     ),
//     const LinearGradient(
//       colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 900),
//       vsync: this,
//     );
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1800),
//       vsync: this,
//     )..repeat(reverse: true);
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 700),
//       vsync: this,
//     );
//     _pageController = AnimationController(
//       duration: const Duration(milliseconds: 1400),
//       vsync: this,
//     );
//     _glowController = AnimationController(
//       duration: const Duration(milliseconds: 2200),
//       vsync: this,
//     )..repeat(reverse: true);
//     _colorController = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOutCubic,
//     );
//     _pulseAnimation = TweenSequence<double>([
//       TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.08), weight: 1),
//       TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.92), weight: 1),
//     ]).animate(_pulseController);
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, -0.2),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
//     );
//     _pageAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _pageController, curve: Curves.fastOutSlowIn),
//     );
//     _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
//       CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
//     );
//     _colorAnimation = ColorTween(
//       begin: _primaryPurple.withOpacity(0.7),
//       end: _electricBlue.withOpacity(0.7),
//     ).animate(_colorController);
//
//     _fadeController.forward();
//     _slideController.forward();
//     _pageController.forward();
//     _loadJournalEntries();
//   }
//
//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _pulseController.dispose();
//     _slideController.dispose();
//     _pageController.dispose();
//     _glowController.dispose();
//     _colorController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadJournalEntries() async {
//     setState(() => isLoading = true);
//     try {
//       final db = await DatabaseHelper().database;
//       final monthYear = selectedYearMonth.split('-');
//       String year = monthYear[0];
//       String month =
//       DateFormat(
//         'MMM',
//       ).format(DateTime(2020, int.parse(monthYear[1]))).toLowerCase();
//
//       final List<Map<String, dynamic>> debitEntries = await db.query(
//         'TABLE_ACCOUNTS',
//         where:
//         "ACCOUNTS_VoucherType = ? AND ACCOUNTS_month = ? AND ACCOUNTS_year = ? AND ACCOUNTS_type = ?",
//         whereArgs: [4, month, year, 'debit'],
//       );
//
//       List<Map<String, dynamic>> entries = [];
//       for (var debitEntry in debitEntries) {
//         final entryId = debitEntry['ACCOUNTS_entryid'];
//         final creditEntry = await db.query(
//           'TABLE_ACCOUNTS',
//           where:
//           "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
//           whereArgs: [4, entryId, 'credit'],
//         );
//
//         if (creditEntry.isNotEmpty) {
//           final debitAccount = await _getAccountName(
//             debitEntry['ACCOUNTS_setupid'],
//           );
//           final creditAccount = await _getAccountName(
//             creditEntry.first['ACCOUNTS_setupid'],
//           );
//           entries.add({
//             'entryId': entryId.toString(),
//             'date': debitEntry['ACCOUNTS_date'].toString(),
//             'debitAccount': debitAccount,
//             'creditAccount': creditAccount,
//             'amount': debitEntry['ACCOUNTS_amount'].toString(),
//             'remarks': debitEntry['ACCOUNTS_remarks']?.toString() ?? "",
//           });
//         }
//       }
//       await Future.delayed(const Duration(milliseconds: 400));
//       setState(() {
//         journalEntries = entries;
//         total = _calculateTotal(entries);
//         isLoading = false;
//       });
//       _fadeController.forward();
//       _slideController.forward();
//     } catch (e) {
//       setState(() => isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 AnimatedBuilder(
//                   animation: _pulseAnimation,
//                   builder: (context, child) {
//                     return Transform.scale(
//                       scale: 0.8 + (0.2 * _pulseAnimation.value),
//                       child: Icon(Icons.error_outline, color: Colors.white),
//                     );
//                   },
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Error loading journal entries',
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: _coral,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             elevation: 8,
//           ),
//         );
//       }
//     }
//   }
//
//   Future<String> _getAccountName(dynamic setupId) async {
//     try {
//       final db = await DatabaseHelper().database;
//       final rows = await db.query(
//         'TABLE_ACCOUNTSETTINGS',
//         where: "keyid = ?",
//         whereArgs: [setupId],
//       );
//       if (rows.isNotEmpty) {
//         final data = rows.first['data'];
//         Map<String, dynamic> accountData;
//         if (data is String) {
//           accountData = jsonDecode(data);
//         } else if (data is Map<String, dynamic>) {
//           accountData = data;
//         } else {
//           return 'Unknown';
//         }
//         return accountData['Accountname']?.toString() ?? 'Unknown';
//       }
//       return 'Unknown';
//     } catch (e) {
//       return 'Unknown';
//     }
//   }
//
//   double _calculateTotal(List<Map<String, dynamic>> entries) {
//     double total = 0;
//     for (var entry in entries) {
//       total += double.tryParse(entry['amount'].toString()) ?? 0;
//     }
//     return total;
//   }
//
//   String _getDisplayMonth() {
//     final parts = selectedYearMonth.split('-');
//     final year = parts[0];
//     final month = int.parse(parts[1]);
//     final monthName = DateFormat('MMMM').format(DateTime(2022, month));
//     return '$monthName $year';
//   }
//
//   void _showMonthYearPicker() async {
//     final now = DateTime.now();
//     final years = List.generate(
//       10,
//           (index) => (now.year + index - 5).toString(),
//     );
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//
//     final currentParts = selectedYearMonth.split('-');
//     String selectedYear = currentParts[0];
//     int currentMonthIndex =
//         int.tryParse(currentParts[1]) ?? DateTime.now().month;
//     String selectedMonth = months[currentMonthIndex - 1];
//
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateDialog) {
//             return Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(28),
//               ),
//               backgroundColor: Colors.transparent,
//               insetPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 24,
//               ),
//               child: AnimatedBuilder(
//                 animation: _colorController,
//                 builder: (context, child) {
//                   final maxWidth = MediaQuery.of(context).size.width * 0.9;
//                   return Center(
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(
//                         maxWidth: maxWidth > 560 ? 560 : maxWidth,
//                       ),
//                       child: SingleChildScrollView(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(28),
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 _primaryPurple.withOpacity(0.05),
//                                 Colors.white,
//                                 _magenta.withOpacity(0.02),
//                               ],
//                             ),
//                             border: Border.all(
//                               color: _primaryPurple.withOpacity(0.2),
//                               width: 1.5,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: _primaryPurple.withOpacity(0.12),
//                                 blurRadius: 30,
//                                 spreadRadius: 1,
//                                 offset: const Offset(0, 10),
//                               ),
//                             ],
//                           ),
//                           padding: const EdgeInsets.all(20),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               AnimatedBuilder(
//                                 animation: _pulseAnimation,
//                                 builder: (context, child) {
//                                   return Transform.scale(
//                                     scale:
//                                     0.95 + (0.05 * _pulseAnimation.value),
//                                     child: Container(
//                                       padding: const EdgeInsets.all(14),
//                                       decoration: BoxDecoration(
//                                         gradient: _headerGradients[1],
//                                         borderRadius: BorderRadius.circular(16),
//                                       ),
//                                       child: Text(
//                                         '🎯 Select Period',
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.w900,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                               const SizedBox(height: 18),
//                               _buildDropdownContainer(
//                                 label: 'Month',
//                                 value: selectedMonth,
//                                 items: months,
//                                 icon: Icons.calendar_today_rounded,
//                                 color: _primaryPurple,
//                                 onChanged:
//                                     (value) => setStateDialog(
//                                       () => selectedMonth = value!,
//                                 ),
//                               ),
//                               const SizedBox(height: 14),
//                               _buildDropdownContainer(
//                                 label: 'Year',
//                                 value: selectedYear,
//                                 items: years,
//                                 icon: Icons.date_range_rounded,
//                                 color: _electricBlue,
//                                 onChanged:
//                                     (value) => setStateDialog(
//                                       () => selectedYear = value!,
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: _buildGradientButton(
//                                       text: 'Cancel',
//                                       gradient: LinearGradient(
//                                         colors: [
//                                           Colors.grey[400]!,
//                                           Colors.grey[600]!,
//                                         ],
//                                       ),
//                                       onPressed: () => Navigator.pop(context),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: _buildGradientButton(
//                                       text: 'Apply',
//                                       gradient: LinearGradient(
//                                         colors: [_primaryPurple, _magenta],
//                                       ),
//                                       onPressed: () {
//                                         final monthIndex =
//                                             months.indexOf(selectedMonth) + 1;
//                                         setState(() {
//                                           selectedYearMonth =
//                                           '$selectedYear-${monthIndex.toString().padLeft(2, "0")}';
//                                         });
//                                         _loadJournalEntries();
//                                         Navigator.pop(context);
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildDropdownContainer({
//     required String label,
//     required String value,
//     required List<String> items,
//     required IconData icon,
//     required Color color,
//     required Function(String?) onChanged,
//   }) {
//     // Use LayoutBuilder inside to be adaptive
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final width = constraints.maxWidth;
//         final compact = width < 320;
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 6, bottom: 6),
//               child: Row(
//                 children: [
//                   Icon(icon, color: color, size: compact ? 16 : 18),
//                   SizedBox(width: compact ? 6 : 8),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       color: color,
//                       fontWeight: FontWeight.w700,
//                       fontSize: compact ? 13 : 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             AnimatedBuilder(
//               animation: _pulseAnimation,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: 0.98 + (0.02 * _pulseAnimation.value),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: color.withOpacity(0.35),
//                         width: 1.6,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: color.withOpacity(0.12),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: DropdownButton<String>(
//                       value: value,
//                       isExpanded: true,
//                       dropdownColor: Colors.white,
//                       icon: AnimatedBuilder(
//                         animation: _pulseAnimation,
//                         builder: (context, child) {
//                           return Transform.rotate(
//                             angle: _pulseAnimation.value * 0.08,
//                             child: Icon(
//                               Icons.arrow_drop_down_rounded,
//                               color: color,
//                               size: compact ? 26 : 30,
//                             ),
//                           );
//                         },
//                       ),
//                       underline: const SizedBox(),
//                       borderRadius: BorderRadius.circular(12),
//                       style: TextStyle(
//                         fontSize: compact ? 13 : 15,
//                         color: Colors.grey[800],
//                         fontWeight: FontWeight.w600,
//                       ),
//                       items:
//                       items.map((item) {
//                         return DropdownMenuItem(
//                           value: item,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 8,
//                             ),
//                             child: Text(
//                               item,
//                               style: TextStyle(
//                                 fontSize: compact ? 13 : 15,
//                                 color: Colors.grey[800],
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: onChanged,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildGradientButton({
//     required String text,
//     required Gradient gradient,
//     required VoidCallback onPressed,
//   }) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       child: GestureDetector(
//         onTapDown: (_) {
//           try {
//             _pulseController.reverse();
//           } catch (_) {}
//         },
//         onTapUp: (_) {
//           try {
//             _pulseController.forward();
//           } catch (_) {}
//         },
//         onTapCancel: () {
//           try {
//             _pulseController.forward();
//           } catch (_) {}
//         },
//         onTap: onPressed,
//         child: AnimatedBuilder(
//           animation: _pulseAnimation,
//           builder: (context, child) {
//             return Transform.scale(
//               scale: _pulseAnimation.value,
//               child: Container(
//                 height: 48,
//                 decoration: BoxDecoration(
//                   gradient: gradient,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: _primaryPurple.withOpacity(0.2),
//                       blurRadius: 12,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Text(
//                     text,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w800,
//                       fontSize: 15,
//                       letterSpacing: 0.6,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Future<void> _handleAddJournal() async {
//     try {
//       await _pulseController.forward();
//     } catch (_) {}
//     final result = await Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder:
//             (context, animation, secondaryAnimation) => const AddJournal(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           const begin = Offset(1.0, 0.0);
//           const end = Offset.zero;
//           const curve = Curves.easeInOutCubic;
//           var tween = Tween(
//             begin: begin,
//             end: end,
//           ).chain(CurveTween(curve: curve));
//
//           return SlideTransition(
//             position: animation.drive(tween),
//             child: FadeTransition(opacity: animation, child: child),
//           );
//         },
//         transitionDuration: const Duration(milliseconds: 600),
//       ),
//     );
//     if (result == true) _loadJournalEntries();
//   }
//
//   Future<void> _editItem(int index) async {
//     final entry = journalEntries[index];
//     final journalEntry = JournalEntry(
//       entryId: int.parse(entry['entryId']),
//       date: entry['date'],
//       debitAccount: entry['debitAccount'],
//       creditAccount: entry['creditAccount'],
//       amount: double.parse(entry['amount']),
//       remarks: entry['remarks'],
//     );
//
//     try {
//       await _pulseController.forward();
//     } catch (_) {}
//     final result = await Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder:
//             (context, animation, secondaryAnimation) =>
//             AddJournal(journalEntry: journalEntry),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           const begin = Offset(0.0, 1.0);
//           const end = Offset.zero;
//           const curve = Curves.easeInOutCubic;
//           var tween = Tween(
//             begin: begin,
//             end: end,
//           ).chain(CurveTween(curve: curve));
//
//           return SlideTransition(
//             position: animation.drive(tween),
//             child: FadeTransition(opacity: animation, child: child),
//           );
//         },
//         transitionDuration: const Duration(milliseconds: 600),
//       ),
//     );
//     if (result == true) _loadJournalEntries();
//   }
//
//   Future<void> _deleteItem(int index) async {
//     final entryId = journalEntries[index]['entryId'];
//     await showDialog(
//       context: context,
//       builder:
//           (context) => AnimatedBuilder(
//         animation: _colorController,
//         builder: (context, child) {
//           final maxWidth = MediaQuery.of(context).size.width * 0.92;
//           return Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 maxWidth: maxWidth > 560 ? 560 : maxWidth,
//               ),
//               child: Dialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 elevation: 0,
//                 backgroundColor: Colors.transparent,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         _coral.withOpacity(0.06),
//                         Colors.white,
//                         _coral.withOpacity(0.04),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: _coral.withOpacity(0.2),
//                       width: 1.5,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: _coral.withOpacity(0.18),
//                         blurRadius: 30,
//                         spreadRadius: 1,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(18),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [_coral, _orange],
//                           ),
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(20),
//                             topRight: Radius.circular(20),
//                           ),
//                         ),
//                         child: AnimatedBuilder(
//                           animation: _pulseAnimation,
//                           builder: (context, child) {
//                             return Transform.scale(
//                               scale: 0.9 + (0.1 * _pulseAnimation.value),
//                               child: Icon(
//                                 Icons.warning_amber_rounded,
//                                 color: Colors.white,
//                                 size: 56,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(18),
//                         child: Column(
//                           children: [
//                             Text(
//                               'Delete Entry?',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w900,
//                                 color: _coral,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'This action cannot be undone. All related data will be permanently removed.',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey[700],
//                                 height: 1.45,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _buildGradientButton(
//                                     text: 'Cancel',
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Colors.grey[500]!,
//                                         Colors.grey[700]!,
//                                       ],
//                                     ),
//                                     onPressed: () => Navigator.pop(context),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: _buildGradientButton(
//                                     text: 'Delete',
//                                     gradient: LinearGradient(
//                                       colors: [_coral, _magenta],
//                                     ),
//                                     onPressed: () async {
//                                       try {
//                                         final db =
//                                         await DatabaseHelper().database;
//                                         await db.delete(
//                                           'TABLE_ACCOUNTS',
//                                           where:
//                                           "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ?",
//                                           whereArgs: [4, entryId],
//                                         );
//                                         setState(() {
//                                           journalEntries.removeAt(index);
//                                           total = _calculateTotal(
//                                             journalEntries,
//                                           );
//                                         });
//                                         if (mounted) {
//                                           Navigator.pop(context);
//                                           ScaffoldMessenger.of(
//                                             context,
//                                           ).showSnackBar(
//                                             SnackBar(
//                                               content: Row(
//                                                 children: [
//                                                   AnimatedBuilder(
//                                                     animation:
//                                                     _pulseAnimation,
//                                                     builder: (
//                                                         context,
//                                                         child,
//                                                         ) {
//                                                       return Transform.scale(
//                                                         scale:
//                                                         0.8 +
//                                                             (0.2 *
//                                                                 _pulseAnimation
//                                                                     .value),
//                                                         child: Icon(
//                                                           Icons
//                                                               .check_circle,
//                                                           color:
//                                                           Colors.white,
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                   const SizedBox(width: 12),
//                                                   Expanded(
//                                                     child: Text(
//                                                       'Entry deleted successfully',
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               backgroundColor: _green,
//                                               behavior:
//                                               SnackBarBehavior.floating,
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                 BorderRadius.circular(
//                                                   12,
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                         }
//                                       } catch (e) {
//                                         if (mounted) {
//                                           Navigator.pop(context);
//                                           ScaffoldMessenger.of(
//                                             context,
//                                           ).showSnackBar(
//                                             SnackBar(
//                                               content: Row(
//                                                 children: [
//                                                   Icon(
//                                                     Icons.error,
//                                                     color: Colors.white,
//                                                   ),
//                                                   const SizedBox(width: 12),
//                                                   Expanded(
//                                                     child: Text(
//                                                       'Error: $e',
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               backgroundColor: _coral,
//                                               behavior:
//                                               SnackBarBehavior.floating,
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                 BorderRadius.circular(
//                                                   12,
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                         }
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final double scale = (size.width / 420).clamp(0.78, 1.0);
//     final isSmallScreen = size.width < 360;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: AnimatedBuilder(
//                 animation: _colorController,
//                 builder: (context, child) {
//                   return Container(
//                     decoration: BoxDecoration(
//                       gradient: RadialGradient(
//                         center: Alignment.topRight,
//                         radius: 1.8,
//                         colors: [
//                           _primaryPurple.withOpacity(
//                             0.05 + 0.05 * _glowAnimation.value,
//                           ),
//                           _electricBlue.withOpacity(
//                             0.03 + 0.03 * _glowAnimation.value,
//                           ),
//                           Colors.transparent,
//                         ],
//                         stops: [0.1, 0.5, 1.0],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Column(
//               children: [
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: Container(
//                     margin: EdgeInsets.all(16 * scale),
//                     padding: EdgeInsets.all(16 * scale),
//                     decoration: BoxDecoration(
//                       gradient: _headerGradients[0],
//                       borderRadius: BorderRadius.circular(20 * scale),
//                       boxShadow: [
//                         BoxShadow(
//                           color: _primaryPurple.withOpacity(0.4),
//                           blurRadius: 20 * scale,
//                           offset: Offset(0, 8 * scale),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         _buildIconButton(
//                           icon: Icons.arrow_back_ios_new_rounded,
//                           onTap: () => Navigator.pop(context),
//                           color: Colors.white,
//                           backgroundColor: Colors.white.withOpacity(0.2),
//                         ),
//                         SizedBox(width: 12 * scale),
//                         Flexible(
//                           child: FittedBox(
//                             fit: BoxFit.scaleDown,
//                             alignment: Alignment.centerLeft,
//                             child: AnimatedBuilder(
//                               animation: _pageAnimation,
//                               builder: (context, child) {
//                                 return Opacity(
//                                   opacity: _pageAnimation.value,
//                                   child: Transform.translate(
//                                     offset: Offset(
//                                       30 * (1 - _pageAnimation.value),
//                                       0,
//                                     ),
//                                     child: Text(
//                                       '📒 Financial Journal',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w900,
//                                         fontSize: 26 * scale,
//                                         color: Colors.white,
//                                         letterSpacing: 0.2,
//                                         shadows: [
//                                           Shadow(
//                                             color: Colors.black.withOpacity(
//                                               0.25,
//                                             ),
//                                             blurRadius: 8 * scale,
//                                             offset: Offset(0, 1 * scale),
//                                           ),
//                                         ],
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 8 * scale),
//                         _buildIconButton(
//                           icon: Icons.refresh_rounded,
//                           onTap: () {
//                             _fadeController.reset();
//                             _slideController.reset();
//                             _loadJournalEntries().then((_) {
//                               _fadeController.forward();
//                               _slideController.forward();
//                             });
//                           },
//                           color: Colors.white,
//                           backgroundColor: Colors.white.withOpacity(0.2),
//                           pulse: true,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16 * scale,
//                       vertical: 8 * scale,
//                     ),
//                     child: AnimatedBuilder(
//                       animation: _pulseAnimation,
//                       builder: (context, child) {
//                         return Transform.scale(
//                           scale: 0.98 + (0.02 * _pulseAnimation.value),
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(16 * scale),
//                             onTap: _showMonthYearPicker,
//                             child: Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 16 * scale,
//                                 vertical: 14 * scale,
//                               ),
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                   colors: [
//                                     Colors.white,
//                                     _cyan.withOpacity(0.06),
//                                     _primaryPurple.withOpacity(0.03),
//                                   ],
//                                 ),
//                                 border: Border.all(
//                                   color: _primaryPurple.withOpacity(0.22),
//                                   width: 1.5 * scale,
//                                 ),
//                                 borderRadius: BorderRadius.circular(14 * scale),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: _primaryPurple.withOpacity(0.12),
//                                     blurRadius: 12 * scale,
//                                     offset: Offset(0, 6 * scale),
//                                   ),
//                                 ],
//                               ),
//                               child: Row(
//                                 children: [
//                                   AnimatedBuilder(
//                                     animation: _pulseAnimation,
//                                     builder: (context, child) {
//                                       return Transform.scale(
//                                         scale:
//                                         0.92 +
//                                             (0.08 * _pulseAnimation.value),
//                                         child: Container(
//                                           padding: EdgeInsets.all(10 * scale),
//                                           decoration: BoxDecoration(
//                                             gradient: LinearGradient(
//                                               colors: [
//                                                 _primaryPurple,
//                                                 _secondaryPurple,
//                                               ],
//                                             ),
//                                             borderRadius: BorderRadius.circular(
//                                               12 * scale,
//                                             ),
//                                           ),
//                                           child: Icon(
//                                             Icons.calendar_month_rounded,
//                                             color: Colors.white,
//                                             size: 20 * scale,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   SizedBox(width: 14 * scale),
//                                   Expanded(
//                                     child: Text(
//                                       _getDisplayMonth(),
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w800,
//                                         fontSize: 16 * scale,
//                                         color: _deepPurple,
//                                         letterSpacing: 0.2,
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                   Icon(
//                                     Icons.keyboard_arrow_down_rounded,
//                                     color: _primaryPurple,
//                                     size: 28 * scale,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(
//                     16 * scale,
//                     18 * scale,
//                     16 * scale,
//                     10 * scale,
//                   ),
//                   child: _buildTableHeader(scale: scale),
//                 ),
//                 Expanded(
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child:
//                     isLoading
//                         ? _buildLoadingAnimation(scale: scale)
//                         : journalEntries.isEmpty
//                         ? _buildEmptyState(scale: scale)
//                         : _buildJournalList(scale: scale),
//                   ),
//                 ),
//                 SlideTransition(
//                   position: Tween<Offset>(
//                     begin: const Offset(0, 1),
//                     end: Offset.zero,
//                   ).animate(
//                     CurvedAnimation(
//                       parent: _slideController,
//                       curve: Curves.easeOutBack,
//                     ),
//                   ),
//                   child: Container(
//                     margin: EdgeInsets.all(16 * scale),
//                     padding: EdgeInsets.all(16 * scale),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           _primaryPurple.withOpacity(0.14),
//                           _magenta.withOpacity(0.12),
//                           _electricBlue.withOpacity(0.06),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(16 * scale),
//                       boxShadow: [
//                         BoxShadow(
//                           color: _primaryPurple.withOpacity(0.16),
//                           blurRadius: 20 * scale,
//                           offset: Offset(0, 8 * scale),
//                         ),
//                       ],
//                       border: Border.all(
//                         color: _primaryPurple.withOpacity(0.2),
//                         width: 1.6 * scale,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.account_balance_wallet_rounded,
//                           color: _primaryPurple,
//                           size: 22 * scale,
//                         ),
//                         SizedBox(width: 12 * scale),
//                         Text(
//                           'Total Amount: ',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w800,
//                             fontSize: 15 * scale,
//                             color: _deepPurple,
//                             letterSpacing: 0.2,
//                           ),
//                         ),
//                         AnimatedBuilder(
//                           animation: _pulseAnimation,
//                           builder: (context, child) {
//                             return Transform.scale(
//                               scale: 1 + (0.06 * _pulseAnimation.value),
//                               child: Text(
//                                 _formatAmount(total.toString()),
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w900,
//                                   fontSize: 20 * scale,
//                                   color: _primaryPurple,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: AnimatedBuilder(
//         animation: _pulseAnimation,
//         builder: (context, child) {
//           final fabSize = (size.width < 360) ? 56.0 : 72.0;
//           return Transform.scale(
//             scale: _pulseAnimation.value,
//             child: FloatingActionButton(
//               onPressed: _handleAddJournal,
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               child: Container(
//                 width: fabSize,
//                 height: fabSize,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [_magenta, _primaryPurple, _electricBlue],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: _magenta.withOpacity(0.5),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                     BoxShadow(
//                       color: _primaryPurple.withOpacity(0.3),
//                       blurRadius: 16,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: AnimatedBuilder(
//                   animation: _pulseAnimation,
//                   builder: (context, child) {
//                     return Transform.rotate(
//                       angle: _pulseAnimation.value * 0.2,
//                       child: Icon(
//                         Icons.add_rounded,
//                         color: Colors.white,
//                         size: fabSize * 0.48,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildIconButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     required Color color,
//     required Color backgroundColor,
//     bool pulse = false,
//   }) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedBuilder(
//           animation: pulse ? _pulseAnimation : _glowAnimation,
//           builder: (context, child) {
//             final size = pulse ? 52.0 : 48.0;
//             return Container(
//               width: size,
//               height: size,
//               decoration: BoxDecoration(
//                 color: backgroundColor,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.28),
//                   width: 1.2,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(pulse ? 0.14 : 0.08),
//                     blurRadius: pulse ? 14 : 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Center(child: Icon(icon, color: color, size: 20)),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTableHeader({double scale = 1.0}) {
//     return AnimatedBuilder(
//       animation: _colorAnimation,
//       builder: (context, child) {
//         return Container(
//           padding: EdgeInsets.symmetric(
//             vertical: 12 * scale,
//             horizontal: 12 * scale,
//           ),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 _primaryPurple.withOpacity(0.12),
//                 _electricBlue.withOpacity(0.06),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(12 * scale),
//             border: Border.all(
//               color: _primaryPurple.withOpacity(0.16),
//               width: 1.5 * scale,
//             ),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 flex: 2,
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.date_range_rounded,
//                       size: 16 * scale,
//                       color: _primaryPurple,
//                     ),
//                     SizedBox(width: 8 * scale),
//                     Text(
//                       'Date',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w800,
//                         color: _primaryPurple,
//                         fontSize: 13 * scale,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 flex: 3,
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.account_balance_rounded,
//                       size: 16 * scale,
//                       color: _primaryPurple,
//                     ),
//                     SizedBox(width: 8 * scale),
//                     Text(
//                       'Account',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w800,
//                         color: _primaryPurple,
//                         fontSize: 13 * scale,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 flex: 2,
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.attach_money_rounded,
//                       size: 16 * scale,
//                       color: _primaryPurple,
//                     ),
//                     SizedBox(width: 8 * scale),
//                     Text(
//                       'Amount',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w800,
//                         color: _primaryPurple,
//                         fontSize: 13 * scale,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 flex: 2,
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.settings_rounded,
//                       size: 16 * scale,
//                       color: _primaryPurple,
//                     ),
//                     SizedBox(width: 8 * scale),
//                     Text(
//                       'Actions',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w800,
//                         color: _primaryPurple,
//                         fontSize: 13 * scale,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildLoadingAnimation({double scale = 1.0}) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _pulseAnimation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: 1 + (0.3 * _pulseAnimation.value),
//                 child: Container(
//                   width: 84 * scale,
//                   height: 84 * scale,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(
//                       colors: [
//                         _primaryPurple.withOpacity(0.28),
//                         _cyan.withOpacity(0.28),
//                       ],
//                     ),
//                   ),
//                   child: Center(
//                     child: AnimatedBuilder(
//                       animation: _pulseAnimation,
//                       builder: (context, child) {
//                         return Transform.rotate(
//                           angle: _pulseAnimation.value * 2 * pi,
//                           child: Icon(
//                             Icons.account_balance_wallet_rounded,
//                             color: _primaryPurple,
//                             size: 40 * scale,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//           SizedBox(height: 18 * scale),
//           Text(
//             'Loading Journal Entries...',
//             style: TextStyle(
//               fontSize: 16 * scale,
//               color: _primaryPurple.withOpacity(0.8),
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           SizedBox(height: 12 * scale),
//           SizedBox(
//             width: 120 * scale,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8 * scale),
//               child: LinearProgressIndicator(
//                 minHeight: 10 * scale,
//                 backgroundColor: _primaryPurple.withOpacity(0.1),
//                 valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState({double scale = 1.0}) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(24 * scale),
//         child: AnimatedBuilder(
//           animation: _pulseAnimation,
//           builder: (context, child) {
//             return Transform.scale(
//               scale: 0.92 + (0.08 * _pulseAnimation.value),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 120 * scale,
//                     height: 120 * scale,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: LinearGradient(
//                         colors: [
//                           _primaryPurple.withOpacity(0.15),
//                           _cyan.withOpacity(0.15),
//                           _magenta.withOpacity(0.1),
//                         ],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: _primaryPurple.withOpacity(0.18),
//                           blurRadius: 20 * scale,
//                           spreadRadius: 1,
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Icon(
//                         Icons.receipt_long_rounded,
//                         color: _primaryPurple.withOpacity(0.6),
//                         size: 56 * scale,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 18 * scale),
//                   Text(
//                     'No Journal Entries Yet',
//                     style: TextStyle(
//                       fontSize: 20 * scale,
//                       fontWeight: FontWeight.w900,
//                       color: _deepPurple,
//                     ),
//                   ),
//                   SizedBox(height: 10 * scale),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20 * scale),
//                     child: Text(
//                       'Start by adding your first journal entry to track your financial transactions',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 13 * scale,
//                         color: Colors.grey[700],
//                         height: 1.45,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 18 * scale),
//                   SizedBox(
//                     width: 200 * scale,
//                     child: _buildGradientButton(
//                       text: '➕ Create First Entry',
//                       gradient: LinearGradient(
//                         colors: [_primaryPurple, _magenta],
//                       ),
//                       onPressed: _handleAddJournal,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildJournalList({double scale = 1.0}) {
//     return ListView.builder(
//       itemCount: journalEntries.length,
//       padding: EdgeInsets.symmetric(
//         horizontal: 16 * scale,
//         vertical: 12 * scale,
//       ),
//       itemBuilder: (context, index) {
//         final item = journalEntries[index];
//         return _buildJournalEntry(item, index, scale: scale);
//       },
//     );
//   }
//
//   Widget _buildJournalEntry(
//       Map<String, dynamic> item,
//       int index, {
//         double scale = 1.0,
//       }) {
//     return AnimatedBuilder(
//       animation: _fadeController,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, 24 * (1 - _fadeAnimation.value)),
//           child: Opacity(
//             opacity: _fadeAnimation.value,
//             child: Container(
//               margin: EdgeInsets.only(bottom: 12 * scale),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(14 * scale),
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.white,
//                     _primaryPurple.withOpacity(0.06),
//                     Colors.white,
//                   ],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _primaryPurple.withOpacity(0.10),
//                     blurRadius: 12 * scale,
//                     offset: Offset(0, 6 * scale),
//                   ),
//                 ],
//                 border: Border.all(
//                   color: _primaryPurple.withOpacity(0.14),
//                   width: 1.2 * scale,
//                 ),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(14 * scale),
//                 child: Column(
//                   children: [
//                     // Debit row
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border(
//                           bottom: BorderSide(
//                             color: _primaryPurple.withOpacity(0.06),
//                             width: 1,
//                           ),
//                         ),
//                         gradient: LinearGradient(
//                           colors: [Colors.white, _coral.withOpacity(0.06)],
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             flex: 2,
//                             child: _buildDataCell(
//                               _formatDisplayDate(item['date']),
//                               isFirst: true,
//                               color: _deepPurple,
//                               icon: Icons.calendar_today_rounded,
//                               scale: scale,
//                             ),
//                           ),
//                           Expanded(
//                             flex: 3,
//                             child: _buildDataCell(
//                               item['debitAccount'],
//                               isBold: true,
//                               color: Colors.grey[900]!,
//                               icon: Icons.arrow_circle_down_rounded,
//                               scale: scale,
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: _buildDataCell(
//                               '${_formatAmount(item['amount'])} Dr',
//                               isAmount: true,
//                               color: _coral,
//                               icon: Icons.arrow_outward_rounded,
//                               scale: scale,
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 _buildActionButton(
//                                   icon: Icons.edit_rounded,
//                                   color: _cyan,
//                                   onTap: () => _editItem(index),
//                                 ),
//                                 SizedBox(width: 10 * scale),
//                                 _buildActionButton(
//                                   icon: Icons.delete_rounded,
//                                   color: _coral,
//                                   onTap: () => _deleteItem(index),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Credit row
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.white, _green.withOpacity(0.06)],
//                         ),
//                       ).copyWith(
//                         border:
//                         item['remarks']?.toString().trim().isNotEmpty ==
//                             true
//                             ? Border(
//                           bottom: BorderSide(
//                             color: _primaryPurple.withOpacity(0.06),
//                             width: 1,
//                           ),
//                         )
//                             : null,
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             flex: 2,
//                             child: _buildDataCell('', scale: scale),
//                           ),
//                           Expanded(
//                             flex: 3,
//                             child: _buildDataCell(
//                               "To ${item['creditAccount']}",
//                               color: _green,
//                               icon: Icons.arrow_circle_up_rounded,
//                               scale: scale,
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: _buildDataCell(
//                               '${_formatAmount(item['amount'])} Cr',
//                               isAmount: true,
//                               color: _green,
//                               icon: Icons.arrow_upward_rounded,
//                               scale: scale,
//                             ),
//                           ),
//                           Expanded(flex: 2, child: Container()),
//                         ],
//                       ),
//                     ),
//                     if (item['remarks'] != null &&
//                         item['remarks'].toString().trim().isNotEmpty)
//                       Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               _cyan.withOpacity(0.06),
//                               _primaryPurple.withOpacity(0.04),
//                             ],
//                           ),
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 14 * scale,
//                           vertical: 12 * scale,
//                         ),
//                         child: Row(
//                           children: [
//                             AnimatedBuilder(
//                               animation: _pulseAnimation,
//                               builder: (context, child) {
//                                 return Transform.scale(
//                                   scale: 0.9 + (0.1 * _pulseAnimation.value),
//                                   child: Container(
//                                     padding: EdgeInsets.all(8 * scale),
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         colors: [_cyan, _electricBlue],
//                                         begin: Alignment.topLeft,
//                                         end: Alignment.bottomRight,
//                                       ),
//                                       borderRadius: BorderRadius.circular(
//                                         10 * scale,
//                                       ),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: _cyan.withOpacity(0.26),
//                                           blurRadius: 8 * scale,
//                                           offset: Offset(0, 3 * scale),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Icon(
//                                       Icons.notes_rounded,
//                                       size: 18 * scale,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                             SizedBox(width: 12 * scale),
//                             Expanded(
//                               child: Text(
//                                 'Remarks: ${item['remarks']}',
//                                 style: TextStyle(
//                                   fontSize: 13 * scale,
//                                   color: Colors.blueGrey[800],
//                                   fontStyle: FontStyle.italic,
//                                   fontWeight: FontWeight.w600,
//                                   height: 1.3,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   String _formatAmount(String amount) {
//     try {
//       double value = double.parse(amount);
//       if (value >= 10000000) {
//         return '₹${(value / 10000000).toStringAsFixed(2)}Cr';
//       } else if (value >= 100000) {
//         return '₹${(value / 100000).toStringAsFixed(2)}L';
//       } else if (value >= 1000) {
//         return '₹${(value / 1000).toStringAsFixed(2)}K';
//       } else {
//         return '₹${value.toStringAsFixed(2)}';
//       }
//     } catch (_) {
//       return amount;
//     }
//   }
//
//   String _formatAmountWithCommas(String amount) {
//     try {
//       double value = double.parse(amount);
//       final formatter = NumberFormat('#,##,###.##', 'en_IN');
//       return '₹${formatter.format(value)}';
//     } catch (_) {
//       return amount;
//     }
//   }
//
//   Widget _buildDataCell(
//       String text, {
//         bool isFirst = false,
//         bool isBold = false,
//         bool isAmount = false,
//         Color? color,
//         IconData? icon,
//         double scale = 1.0,
//       }) {
//     return Container(
//       height: 56 * scale,
//       padding: EdgeInsets.symmetric(
//         horizontal: 12 * scale,
//         vertical: 8 * scale,
//       ),
//       child: Row(
//         children: [
//           if (icon != null && text.isNotEmpty)
//             Icon(icon, color: color, size: 16 * scale),
//           if (icon != null && text.isNotEmpty) SizedBox(width: 8 * scale),
//           Expanded(
//             child: Align(
//               alignment:
//               isAmount
//                   ? Alignment.centerRight
//                   : isFirst
//                   ? Alignment.center
//                   : Alignment.centerLeft,
//               child: Text(
//                 text,
//                 textAlign:
//                 isAmount
//                     ? TextAlign.right
//                     : isFirst
//                     ? TextAlign.center
//                     : TextAlign.left,
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 1,
//                 softWrap: false,
//                 style: TextStyle(
//                   fontSize: isAmount ? 12 * scale : 13 * scale,
//                   fontWeight:
//                   isBold || isAmount ? FontWeight.w700 : FontWeight.w600,
//                   color: color ?? Colors.grey[800],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedBuilder(
//           animation: _pulseAnimation,
//           builder: (context, child) {
//             return Transform.scale(
//               scale: 0.92 + (0.08 * _pulseAnimation.value),
//               child: Container(
//                 width: 38,
//                 height: 38,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [color, Color.lerp(color, Colors.white, 0.3)!],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: color.withOpacity(0.38),
//                       blurRadius: 10,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Icon(icon, color: Colors.white, size: 18),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   String _formatDisplayDate(String dateString) {
//     try {
//       DateTime date = DateTime.parse(dateString);
//       return DateFormat('dd MMM yyyy').format(date);
//     } catch (e) {
//       return dateString;
//     }
//   }
// }
