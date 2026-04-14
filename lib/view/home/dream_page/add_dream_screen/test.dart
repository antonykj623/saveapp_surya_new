// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:new_project_2025/view/home/widget/home_screen.dart';
// //import 'package:new_project_2025/view/home/widget/password_manger/password_manger/password_list_screen/password_details/password_details.dart';
// import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
// //import '../Edit_password/EditPasswordManager.dart';
//
// class listpasswordData1 extends StatefulWidget {
//   const listpasswordData1({super.key});
//
//   @override
//   State<listpasswordData1> createState() => _Home_ScreenState();
// }
//
// class _Home_ScreenState extends State<listpasswordData1>
//     with TickerProviderStateMixin {
//   bool isLoading = false;
//   List<passwordModel> docLinks = [];
//   String _searchQuery = '';
//   bool _showSearch = false;
//   final TextEditingController _searchController = TextEditingController();
//
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late AnimationController _fabController;
//   late Animation<double> _headerAnimation;
//   late Animation<double> _fabAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _headerAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 900),
//       vsync: this,
//     );
//     _listAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fabController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _headerAnimation = CurvedAnimation(
//       parent: _headerAnimationController,
//       curve: Curves.easeOutCubic,
//     );
//     _fabAnimation = CurvedAnimation(
//       parent: _fabController,
//       curve: Curves.elasticOut,
//     );
//
//     _headerAnimationController.forward();
//     Future.delayed(const Duration(milliseconds: 400), () {
//       _fabController.forward();
//     });
//     _loadData();
//   }
//
//   void _loadData() async {
//     final rawData = await DatabaseHelper().fetchAllpassData();
//     List<passwordModel> loadedLinks = [];
//     for (var entry in rawData) {
//       final keyId = entry['keyid'];
//       final jsonString = entry['data'];
//       try {
//         final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
//         decodedMap['keyid'] = keyId;
//         loadedLinks.add(passwordModel.fromMap(decodedMap));
//       } catch (e) {
//         print("Error decoding JSON: $e");
//       }
//     }
//     setState(() {
//       docLinks = loadedLinks;
//     });
//     _listAnimationController.forward();
//   }
//
//   Future<void> _handleDelete(int keyid) async {
//     setState(() => isLoading = true);
//     await DatabaseHelper().deleteByFieldId('TABLE_PASSWORD', keyid);
//     _loadData();
//     await Future.delayed(const Duration(milliseconds: 300));
//     setState(() => isLoading = false);
//   }
//
//   @override
//   void dispose() {
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();
//     _fabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   // ─── Icon per title ───────────────────────────────────────────────────────
//   IconData _iconForTitle(String title) {
//     final t = title.toLowerCase();
//     if (t.contains('bank') || t.contains('finance'))
//       return Icons.account_balance_rounded;
//     if (t.contains('email') || t.contains('mail') || t.contains('gmail'))
//       return Icons.mail_rounded;
//     if (t.contains('social') ||
//         t.contains('facebook') ||
//         t.contains('instagram'))
//       return Icons.people_rounded;
//     if (t.contains('shop') || t.contains('amazon') || t.contains('store'))
//       return Icons.shopping_bag_rounded;
//     if (t.contains('game') || t.contains('play'))
//       return Icons.sports_esports_rounded;
//     if (t.contains('work') || t.contains('office')) return Icons.work_rounded;
//     if (t.contains('phone') || t.contains('mobile'))
//       return Icons.phone_android_rounded;
//     return Icons.lock_rounded;
//   }
//
//   // ─── Gradient per index ───────────────────────────────────────────────────
//   List<Color> _gradientForIndex(int index) {
//     final palettes = [
//       [const Color(0xFF6C63FF), const Color(0xFF3B2FBF)],
//       [const Color(0xFFFF6B6B), const Color(0xFFBF2F2F)],
//       [const Color(0xFF00C9A7), const Color(0xFF007A65)],
//       [const Color(0xFFFFB347), const Color(0xFFBF7820)],
//       [const Color(0xFF4DA6FF), const Color(0xFF1A5FA8)],
//       [const Color(0xFFFF79C6), const Color(0xFFAA3F7E)],
//     ];
//     return palettes[index % palettes.length];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E1A),
//       body: Stack(
//         children: [
//           // ── Orb background ────────────────────────────────────────────────
//           const _OrbBackground(),
//
//           Column(
//             children: [
//               // ── Header ────────────────────────────────────────────────────
//               AnimatedBuilder(
//                 animation: _headerAnimation,
//                 builder:
//                     (context, child) => Transform.translate(
//                   offset: Offset(0, -60 * (1 - _headerAnimation.value)),
//                   child: Opacity(
//                     opacity: _headerAnimation.value.clamp(0.0, 1.0),
//                     child: _buildHeader(),
//                   ),
//                 ),
//               ),
//
//               // ── Search bar ────────────────────────────────────────────────
//               AnimatedSize(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//                 child:
//                 _showSearch ? _buildSearchBar() : const SizedBox.shrink(),
//               ),
//
//               // ── List ──────────────────────────────────────────────────────
//               Expanded(
//                 child: FutureBuilder<List<Map<String, dynamic>>>(
//                   future: DatabaseHelper().getAllData('TABLE_PASSWORD'),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: _ShimmerCards());
//                     }
//                     if (snapshot.hasError) {
//                       return Center(
//                         child: Text(
//                           'Error: ${snapshot.error}',
//                           style: const TextStyle(color: Colors.white54),
//                         ),
//                       );
//                     }
//
//                     final allItems = snapshot.data ?? [];
//                     final items =
//                     _searchQuery.isEmpty
//                         ? allItems
//                         : allItems.where((item) {
//                       final d = jsonDecode(item['data'] ?? '{}');
//                       return (d['title'] ?? '')
//                           .toString()
//                           .toLowerCase()
//                           .contains(_searchQuery.toLowerCase());
//                     }).toList();
//
//                     if (allItems.isEmpty) return _buildEmptyState();
//                     if (items.isEmpty) return _buildNoResultsState();
//
//                     return ListView.builder(
//                       padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
//                       itemCount: items.length,
//                       itemBuilder: (context, index) {
//                         final item = items[index];
//                         final keyId = item['keyid'];
//                         final dataJson = jsonDecode(item['data'] ?? '{}');
//                         return _buildPasswordCard(
//                           context,
//                           keyId,
//                           dataJson,
//                           index,
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//
//           // ── Loading overlay ───────────────────────────────────────────────
//           if (isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.7),
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(32),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1A2235),
//                     borderRadius: BorderRadius.circular(24),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.08),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const SizedBox(
//                         width: 48,
//                         height: 48,
//                         child: CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Color(0xFF6C63FF),
//                           ),
//                           strokeWidth: 3,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Deleting...',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.8),
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: ScaleTransition(
//         scale: _fabAnimation,
//         child: _buildFab(),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
//
//   // ─── Header ───────────────────────────────────────────────────────────────
//
//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.only(
//         left: 20,
//         right: 20,
//         top: MediaQuery.of(context).padding.top + 16,
//         bottom: 24,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             const Color(0xFF6C63FF).withOpacity(0.25),
//             const Color(0xFF0A0E1A).withOpacity(0.1),
//           ],
//         ),
//         border: Border(
//           bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
//         ),
//       ),
//       child: Row(
//         children: [
//           // Back button
//           GestureDetector(
//             onTap:
//                 () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => SaveApp()),
//             ),
//             child: Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.12),
//                   width: 1,
//                 ),
//               ),
//               child: const Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 color: Colors.white,
//                 size: 18,
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//
//           // Title
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Password Vault',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//                 Text(
//                   '${docLinks.length} saved credential${docLinks.length != 1 ? 's' : ''}',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.4),
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Shield icon
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF6C63FF), Color(0xFF3B2FBF)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(14),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF6C63FF).withOpacity(0.4),
//                   blurRadius: 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.shield_rounded,
//               color: Colors.white,
//               size: 22,
//             ),
//           ),
//
//           const SizedBox(width: 10),
//
//           // Search toggle
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 _showSearch = !_showSearch;
//                 if (!_showSearch) {
//                   _searchQuery = '';
//                   _searchController.clear();
//                 }
//               });
//             },
//             child: Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color:
//                 _showSearch
//                     ? const Color(0xFF6C63FF).withOpacity(0.2)
//                     : Colors.white.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(
//                   color:
//                   _showSearch
//                       ? const Color(0xFF6C63FF).withOpacity(0.4)
//                       : Colors.white.withOpacity(0.12),
//                   width: 1,
//                 ),
//               ),
//               child: Icon(
//                 _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
//                 color: _showSearch ? const Color(0xFF6C63FF) : Colors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Search Bar ───────────────────────────────────────────────────────────
//
//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF1A2235),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: const Color(0xFF6C63FF).withOpacity(0.3),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xFF6C63FF).withOpacity(0.1),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: TextField(
//           controller: _searchController,
//           autofocus: true,
//           style: const TextStyle(color: Colors.white, fontSize: 15),
//           onChanged: (v) => setState(() => _searchQuery = v),
//           decoration: InputDecoration(
//             hintText: 'Search passwords...',
//             hintStyle: TextStyle(
//               color: Colors.white.withOpacity(0.3),
//               fontSize: 14,
//             ),
//             prefixIcon: Icon(
//               Icons.search_rounded,
//               color: Colors.white.withOpacity(0.3),
//               size: 20,
//             ),
//             border: InputBorder.none,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 14,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ─── Password Card ────────────────────────────────────────────────────────
//
//   Widget _buildPasswordCard(
//       BuildContext context,
//       int keyId,
//       Map<String, dynamic> dataJson,
//       int index,
//       ) {
//     final gradient = _gradientForIndex(index);
//     final icon = _iconForTitle(dataJson['title'] ?? '');
//     final title = dataJson['title'] ?? 'Unknown';
//     final uname = dataJson['uname'] ?? '';
//     final initials = title.isNotEmpty ? title[0].toUpperCase() : '?';
//
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0, end: 1),
//       duration: Duration(milliseconds: 350 + index * 60),
//       curve: Curves.easeOutCubic,
//       builder:
//           (context, value, child) => Transform.translate(
//         offset: Offset(0, 30 * (1 - value)),
//         child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
//       ),
//       child: GestureDetector(
//         onTap: () async {
//           final passwordItem = passwordModel.fromMap({
//             'keyid': keyId,
//             'title': dataJson['title'] ?? '',
//             'uname': dataJson['uname'] ?? '',
//             'passwd': dataJson['passwd'] ?? '',
//             'website': dataJson['website'] ?? '',
//             'remarks': dataJson['remarks'] ?? '',
//           });
//           // final result = await Navigator.push(
//           //   context,
//           //   MaterialPageRoute(
//           //     builder: (_) => EditPasswordPage(entry: passwordItem),
//           //   ),
//           // );
//           // if (result == true) _loadData();
//         },
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 16),
//           decoration: BoxDecoration(
//             color: const Color(0xFF131929),
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(color: gradient[0].withOpacity(0.2), width: 1),
//             boxShadow: [
//               BoxShadow(
//                 color: gradient[0].withOpacity(0.12),
//                 blurRadius: 20,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // ── Card top ────────────────────────────────────────────────
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//                 child: Row(
//                   children: [
//                     // Avatar with gradient
//                     Container(
//                       width: 52,
//                       height: 52,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: gradient,
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: gradient[0].withOpacity(0.4),
//                             blurRadius: 12,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Text(
//                           initials,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 14),
//
//                     // Title + username
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             title,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 17,
//                               fontWeight: FontWeight.w700,
//                               letterSpacing: 0.2,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.person_outline_rounded,
//                                 color: Colors.white.withOpacity(0.4),
//                                 size: 13,
//                               ),
//                               const SizedBox(width: 4),
//                               Expanded(
//                                 child: Text(
//                                   uname.isNotEmpty ? uname : 'No username',
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.5),
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Service icon badge
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: gradient[0].withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: gradient[0].withOpacity(0.2),
//                           width: 1,
//                         ),
//                       ),
//                       child: Icon(icon, color: gradient[0], size: 18),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // ── Password dots row ────────────────────────────────────────
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.05),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.password_rounded,
//                             color: Colors.white.withOpacity(0.3),
//                             size: 13,
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             '● ● ● ● ● ● ● ●',
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.3),
//                               fontSize: 10,
//                               letterSpacing: 2,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // ── Divider + actions ────────────────────────────────────────
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//                 child: Divider(
//                   color: Colors.white.withOpacity(0.06),
//                   height: 1,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 child: Row(
//                   children: [
//                     // Website chip
//                     if ((dataJson['website'] ?? '').toString().isNotEmpty)
//                       Expanded(
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.link_rounded,
//                               color: Colors.white.withOpacity(0.3),
//                               size: 13,
//                             ),
//                             const SizedBox(width: 4),
//                             Flexible(
//                               child: Text(
//                                 dataJson['website'] ?? '',
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.35),
//                                   fontSize: 11,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     else
//                       const Spacer(),
//
//                     // Edit button
//                     _cardButton(
//                       label: 'Edit',
//                       icon: Icons.edit_outlined,
//                       color: const Color(0xFF4DA6FF),
//                       onTap: () async {
//                         final passwordItem = passwordModel.fromMap({
//                           'keyid': keyId,
//                           'title': dataJson['title'] ?? '',
//                           'uname': dataJson['uname'] ?? '',
//                           'passwd': dataJson['passwd'] ?? '',
//                           'website': dataJson['website'] ?? '',
//                           'remarks': dataJson['remarks'] ?? '',
//                         });
//                         // final result = await Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(
//                         //     builder:
//                         //         (_) => EditPasswordPage(entry: passwordItem),
//                         //   ),
//                         // );
//                         // if (result == true) _loadData();
//                       },
//                     ),
//                     const SizedBox(width: 8),
//
//                     // Delete button
//                     _cardButton(
//                       label: 'Delete',
//                       icon: Icons.delete_outline_rounded,
//                       color: Colors.redAccent,
//                       onTap: () async {
//                         final confirm = await _showDeleteDialog();
//                         if (confirm == true) await _handleDelete(keyId);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _cardButton({
//     required String label,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: color.withOpacity(0.25), width: 1),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: color, size: 14),
//             const SizedBox(width: 5),
//             Text(
//               label,
//               style: TextStyle(
//                 color: color,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ─── Delete Dialog ────────────────────────────────────────────────────────
//
//   Future<bool?> _showDeleteDialog() {
//     return showDialog<bool>(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         backgroundColor: const Color(0xFF1A2235),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.delete_forever_rounded,
//                 color: Colors.redAccent,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Text(
//               'Delete Password',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'This will permanently remove the password. Are you sure?',
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.65),
//             height: 1.5,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: Colors.white.withOpacity(0.5)),
//             ),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.redAccent,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── FAB ──────────────────────────────────────────────────────────────────
//
//   Widget _buildFab() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF6C63FF), Color(0xFF3B2FBF)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF6C63FF).withOpacity(0.5),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: FloatingActionButton.extended(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         onPressed: () {
//           // Navigator.push(
//           //   context,
//           //   MaterialPageRoute(builder: (_) => AddPasswordPage()),
//           // ).then((_) => _loadData());
//         },
//         icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
//         label: const Text(
//           'Add Password',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//             fontSize: 15,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ─── Empty States ─────────────────────────────────────────────────────────
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF6C63FF), Color(0xFF3B2FBF)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(28),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF6C63FF).withOpacity(0.35),
//                   blurRadius: 24,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.lock_open_rounded,
//               color: Colors.white,
//               size: 48,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Your vault is empty',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Tap "Add Password" to store your\nfirst credential securely.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.4),
//               fontSize: 14,
//               height: 1.6,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNoResultsState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.search_off_rounded,
//             color: Colors.white.withOpacity(0.2),
//             size: 60,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No results for "$_searchQuery"',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.5),
//               fontSize: 15,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Orb Background ───────────────────────────────────────────────────────────
//
// class _OrbBackground extends StatefulWidget {
//   const _OrbBackground();
//
//   @override
//   State<_OrbBackground> createState() => _OrbBackgroundState();
// }
//
// class _OrbBackgroundState extends State<_OrbBackground>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 8),
//     )..repeat(reverse: true);
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _ctrl,
//       builder: (_, __) {
//         return CustomPaint(
//           size: Size.infinite,
//           painter: _OrbPainter(_ctrl.value),
//         );
//       },
//     );
//   }
// }
//
// class _OrbPainter extends CustomPainter {
//   final double t;
//   _OrbPainter(this.t);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Top-left purple orb
//     final p1 =
//     Paint()
//       ..shader = RadialGradient(
//         colors: [
//           const Color(
//             0xFF6C63FF,
//           ).withOpacity(0.22 + 0.08 * math.sin(t * math.pi)),
//           Colors.transparent,
//         ],
//       ).createShader(
//         Rect.fromCircle(
//           center: Offset(size.width * 0.15, size.height * 0.12),
//           radius: 220,
//         ),
//       );
//     canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.12), 220, p1);
//
//     // Bottom-right teal orb
//     final p2 =
//     Paint()
//       ..shader = RadialGradient(
//         colors: [
//           const Color(
//             0xFF00C9A7,
//           ).withOpacity(0.14 + 0.06 * math.cos(t * math.pi)),
//           Colors.transparent,
//         ],
//       ).createShader(
//         Rect.fromCircle(
//           center: Offset(size.width * 0.85, size.height * 0.78),
//           radius: 200,
//         ),
//       );
//     canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.78), 200, p2);
//   }
//
//   @override
//   bool shouldRepaint(_OrbPainter old) => old.t != t;
// }
//
// // ─── Shimmer Cards ────────────────────────────────────────────────────────────
//
// class _ShimmerCards extends StatefulWidget {
//   const _ShimmerCards();
//
//   @override
//   State<_ShimmerCards> createState() => _ShimmerCardsState();
// }
//
// class _ShimmerCardsState extends State<_ShimmerCards>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1400),
//     )..repeat();
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _ctrl,
//       builder:
//           (_, __) => Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: List.generate(
//             4,
//                 (i) => Container(
//               margin: const EdgeInsets.only(bottom: 16),
//               height: 130,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(24),
//                 gradient: LinearGradient(
//                   begin: Alignment(-1.5 + _ctrl.value * 3, 0),
//                   end: Alignment(1.5 + _ctrl.value * 3, 0),
//                   colors: [
//                     const Color(0xFF1A2235),
//                     const Color(0xFF232F45),
//                     const Color(0xFF1A2235),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Models (unchanged) ───────────────────────────────────────────────────────
//
// class passwordModel {
//   final int? keyid;
//   final String title;
//   final String uname;
//   final String passwd;
//   final String website;
//   final String remarks;
//
//   passwordModel({
//     required this.keyid,
//     required this.title,
//     required this.uname,
//     required this.passwd,
//     required this.website,
//     required this.remarks,
//   });
//
//   factory passwordModel.fromMap(Map<String, dynamic> map) {
//     return passwordModel(
//       keyid: map['keyid'],
//       title: map['title'] ?? '',
//       uname: map['uname'] ?? '',
//       passwd: map['passwd'] ?? '',
//       website: map['website'] ?? '',
//       remarks: map['remarks'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'keyid': keyid,
//       'title': title,
//       'uname': uname,
//       'passwd': passwd,
//       'website': website,
//       'remarks': remarks,
//     };
//   }
// }