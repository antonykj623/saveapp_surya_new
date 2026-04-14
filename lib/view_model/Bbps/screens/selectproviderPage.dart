
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'bbps1.dart';

/// -------------------------
/// Biller Model
/// -------------------------
class BillerModel {
  final String billerId;
  final String billerName;
  final String billerCategory;
  final String billerCoverage;
  final String paymentAmountExactness;
  final String billerIcon;

  BillerModel({
    required this.billerId,
    required this.billerName,
    required this.billerCategory,
    required this.billerCoverage,
    required this.paymentAmountExactness,
    required this.billerIcon,
  });

  factory BillerModel.fromJson(Map<String, dynamic> json) {
    return BillerModel(
      billerId: json['billerId']?.toString() ?? '',
      billerName: json['billerName'] ?? '',
      billerCategory: json['billerCategory'] ?? '',
      billerCoverage: json['billerCoverage'] ?? '',
      paymentAmountExactness: json['paymentAmountExactness'] ?? '',
      billerIcon: json['biller_icon']?['icon_data'] ?? '',
    );
  }

  Uint8List? getImageBytes() {
    if (billerIcon.isEmpty) return null;
    try {
      final base64String =
      billerIcon.contains(',') ? billerIcon.split(',').last : billerIcon;
      return base64Decode(base64String);
    } catch (_) {
      return null;
    }
  }
}

/// -------------------------
/// Biller Response Model
/// -------------------------
class BillerResponse {
  final List<BillerModel> billers;
  final int currentPage;
  final int pageSize;
  final int totalElements;
  final int totalPages;

  BillerResponse({
    required this.billers,
    required this.currentPage,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
  });

  factory BillerResponse.fromJson(Map<String, dynamic> json) {
    List<BillerModel> billerList = [];

    if (json['billerResp'] != null && json['billerResp'] is List) {
      final rawList = json['billerResp'] as List;
      for (var i = 0; i < rawList.length; i++) {
        try {
          final billerData = rawList[i] as Map<String, dynamic>;
          final biller = BillerModel.fromJson(billerData);
          billerList.add(biller);
        } catch (e) {
          print('⚠️ Error parsing biller at index $i: $e');
        }
      }
    } else {
      print('⚠️ billerResp is not a list: ${json['billerResp']}');
    }

    final pageNo = json['pageNo'] as int? ?? json['page'] as int? ?? 1;
    final size = json['pageSize'] as int? ?? json['size'] as int? ?? 10;
    final totalCount = json['totalElements'] as int? ??
        json['totalCount'] as int? ??
        json['totalRecords'] as int? ??
        json['total'] as int? ??
        0;

    final calculatedPages = totalCount > 0 ? (totalCount / size).ceil() : 1;
    final apiTotalPages =
        json['totalPages'] as int? ?? json['totalPage'] as int? ?? calculatedPages;

    return BillerResponse(
      billers: billerList,
      currentPage: pageNo,
      pageSize: size,
      totalElements: totalCount,
      totalPages: apiTotalPages,
    );
  }
}

class BillerPaginationScreen extends StatefulWidget {
  final String? cat;
  const BillerPaginationScreen({super.key, this.cat});

  @override
  State<BillerPaginationScreen> createState() => _BillerPaginationScreenState();
}

class _BillerPaginationScreenState extends State<BillerPaginationScreen> {
  List<BillerModel> billerResps = [];
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  String searchQuery = '';

  String get categoryName => widget.cat ?? 'Electricity';

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    fetchBillers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = searchController.text.trim();
      });
      fetchBillers(search: searchQuery);
    });
  }

  Future<void> fetchBillers({String search = ''}) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final uri = Uri.parse(
        "https://bbps-staging.digiledge.in/agent/cou-master/masters/billers",
      ).replace(queryParameters: {
        "category": categoryName,
        "pagesize": "1000", // large size to avoid pagination
        if (search.isNotEmpty) "billerName": search,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final billerResponse = BillerResponse.fromJson(jsonData);
print("Biller response datas are ${jsonData}");
        setState(() {
          billerResps = billerResponse.billers;
        });
      } else {
        print("⚠️ API error: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error fetching billers: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$categoryName Billers')),
      body: isLoading && billerResps.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search biller',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Biller List
          Expanded(
            child: billerResps.isEmpty
                ? Center(
              child: Text(
                searchQuery.isEmpty
                    ? 'No billers available for "$categoryName"'
                    : 'No billers found for "$searchQuery"',
              ),
            )
                : ListView.builder(
              itemCount: billerResps.length,
              itemBuilder: (context, index) {
                final biller = billerResps[index];
                return ListTile(
                  leading: biller.getImageBytes() != null
                      ? Image.memory(
                    biller.getImageBytes()!,
                    width: 40,
                    height: 40,
                  )
                      : const Icon(Icons.electric_meter),
                  title: Text(biller.billerName),
                  subtitle: Text(
                      '${biller.billerCategory} • ${biller.billerCoverage}'),
                  trailing:
                  Text(biller.paymentAmountExactness),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ElectricityScreen(

                              biller: biller.billerName,
                              categoryName:
                              biller.billerCategory, billid: biller.billerId,
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
    );
  }
}


/// -------------------------
/// Biller Pagination Screen with API Search
/// -------------------------
// class BillerPaginationScreen extends StatefulWidget {
//   final String? cat;
//   const BillerPaginationScreen({super.key, this.cat});
//
//   @override
//   State<BillerPaginationScreen> createState() => _BillerPaginationScreenState();
// }
//
// class _BillerPaginationScreenState extends State<BillerPaginationScreen> {
//   List<BillerModel> billerResps = [];
//   int page = 0;
//   int totalPages = 1;
//   final int pageSize = 10;
//   bool isLoading = false;
//   final TextEditingController searchController = TextEditingController();
//   Timer? _debounce;
//   String searchQuery = '';
//
//   String get categoryName => widget.cat ?? 'Electricity';
//
//   @override
//   void initState() {
//     super.initState();
//     searchController.addListener(_onSearchChanged);
//     fetchBillers(pageNumber: page);
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     searchController.dispose();
//     super.dispose();
//   }
//
//   void _onSearchChanged() {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       setState(() {
//         searchQuery = searchController.text.trim();
//         page = 1; // reset page when search changes
//       });
//       fetchBillers(pageNumber: 0, search: searchQuery);
//     });
//   }
//
//   Future<void> fetchBillers({int pageNumber = 0, String search = ''}) async {
//     if (isLoading) return;
//
//     setState(() => isLoading = true);
//
//     try {
//       final uri = Uri.parse(
//         "https://bbps-staging.digiledge.in/agent/cou-master/masters/billers",
//       ).replace(queryParameters: {
//         "category": categoryName,
//         "page": pageNumber.toString(),
//         "pagesize": pageSize.toString(),
//         if (search.isNotEmpty) "billerName": search, // send search to API
//       });
//
//       final response = await http.get(uri);
//
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         final billerResponse = BillerResponse.fromJson(jsonData);
//
//         setState(() {
//           billerResps = billerResponse.billers;
//           page = billerResponse.currentPage;
//           totalPages = billerResponse.totalPages;
//         });
//       } else {
//         print("⚠️ API error: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("⚠️ Error fetching billers: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('$categoryName Billers')),
//       body: isLoading && billerResps.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           // Search bar
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search biller',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//
//           // Biller list
//           Expanded(
//             child: billerResps.isEmpty
//                 ? Center(
//               child: Text(searchQuery.isEmpty
//                   ? 'No billers available for "$categoryName"'
//                   : 'No billers found for "$searchQuery"'),
//             )
//                 : ListView.builder(
//               itemCount: billerResps.length,
//               itemBuilder: (context, index) {
//                 final biller = billerResps[index];
//                 return ListTile(
//                   leading: biller.getImageBytes() != null
//                       ? Image.memory(
//                     biller.getImageBytes()!,
//                     width: 40,
//                     height: 40,
//                   )
//                       : const Icon(Icons.electric_meter),
//                   title: Text(biller.billerName),
//                   subtitle: Text(
//                       '${biller.billerCategory} • ${biller.billerCoverage}'),
//                   trailing: Text(biller.paymentAmountExactness),
//                   onTap:() {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             ElectricityScreen(biller: biller.billerName, categoryName: biller.billerCategory),
//                       ),
//                     );
//                   }
//                 );
//               },
//             ),
//           ),
//
//           // Pagination
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton(
//                   onPressed: page >= 1
//                       ? () =>
//                       fetchBillers(pageNumber: page - 1, search: searchQuery)
//                       : null,
//                   child: const Text('Previous'),
//                 ),
//                 Text(
//                   'Page $page / $totalPages',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 ElevatedButton(
//                   onPressed: page < totalPages
//                       ? () =>
//                       fetchBillers(pageNumber: page + 1, search: searchQuery)
//                       : null,
//                   child: const Text('Next'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
