import 'package:flutter/material.dart';
 import '../models/catogory_model.dart';
import 'bbpsapiservice.dart';
import 'catogorycard.dart';

/// Bill Payments Page
/// Main page showing all bill payment categories with search functionality
class BillPaymentsPage extends StatefulWidget {
  const BillPaymentsPage({Key? key}) : super(key: key);

  @override
  State<BillPaymentsPage> createState() => _BillPaymentsPageState();
}

class _BillPaymentsPageState extends State<BillPaymentsPage> {
  late Future<List<CategoryModel>> categoriesFuture;
  List<CategoryModel> allCategories = [];
  List<CategoryModel> filteredCategories = [];
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    categoriesFuture = BBPSApiService.getCategories();
    _loadCategories();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// Load categories from API
  Future<void> _loadCategories() async {
    try {
      final categories = await BBPSApiService.getCategories();
      setState(() {
        allCategories = categories;
        filteredCategories = categories;
      });
    } catch (e) {
      // Handle error
    }
  }

  /// Filter categories based on search query
  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCategories = allCategories;
        isSearching = false;
      } else {
        isSearching = true;
        filteredCategories =
            allCategories.where((category) {
              return category.categoryName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
                  category.categoryDomain.toLowerCase().contains(
                    query.toLowerCase(),
                  );
            }).toList();
      }
    });
  }

  /// Group categories by domain
  Map<String, List<CategoryModel>> _groupCategoriesByDomain(
      List<CategoryModel> categories,
      ) {
    Map<String, List<CategoryModel>> grouped = {};
    for (var category in categories) {
      if (!grouped.containsKey(category.categoryDomain)) {
        grouped[category.categoryDomain] = [];
      }
      grouped[category.categoryDomain]!.add(category);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Bill Payments',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Open drawer or menu
          },
        ),
        actions: [
          // Logo or brand image
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Image.asset(
              'assets/Bill_pay.png',
              height: 34,
              width: 34,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.payment, size: 32);
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<CategoryModel>>(
        future: categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red[300], size: 64),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Oops! Something went wrong',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Unable to load categories. Please check your connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        categoriesFuture = BBPSApiService.getCategories();
                        _loadCategories();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No categories available',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Store all categories if not already done
          if (allCategories.isEmpty) {
            allCategories = snapshot.data!;
            filteredCategories = allCategories;
          }

          // Group categories by domain
          Map<String, List<CategoryModel>> groupedCategories =
          _groupCategoriesByDomain(filteredCategories);

          return Column(
            children: [
              // Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterCategories,
                  decoration: InputDecoration(
                    hintText: 'Search for bill payments...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon:
                    isSearching
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        _filterCategories('');
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue[300]!,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              // Categories List
              Expanded(
                child:
                filteredCategories.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try searching with different keywords',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: groupedCategories.length,
                  itemBuilder: (context, index) {
                    String domain = groupedCategories.keys.elementAt(
                      index,
                    );
                    List<CategoryModel> domainCategories =
                    groupedCategories[domain]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Domain Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            16,
                            20,
                            12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(
                                    2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                domain,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Category Grid
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: domainCategories.length,
                            itemBuilder: (context, catIndex) {
                              return CategoryCard(
                                category: domainCategories[catIndex],
                                onTap: () {
                                  // Navigate to biller selection page
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${domainCategories[catIndex].categoryName} selected',
                                      ),
                                      duration: const Duration(
                                        seconds: 2,
                                      ),
                                      backgroundColor: Colors.blue[700],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}