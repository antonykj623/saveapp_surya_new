import 'package:flutter/material.dart';
  import 'dart:typed_data';

import '../models/catogory_model.dart';
import 'bbps1.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const CategoryCard({Key? key, required this.category, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes = category.getImageBytes();

    return GestureDetector(
      onTap: () {
        // Navigate to ElectricityScreen with category data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ElectricityScreen(
              categoryName: category.categoryName,
              categoryId: category.categoryId ?? '', biller: '', billid: '',
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon/Image section
              Container(
                width: 70,
                height: 70,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[100]!, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                  imageBytes != null
                      ? Image.memory(imageBytes, fit: BoxFit.contain)
                      : Center(
                    child: Icon(
                      Icons.category_outlined,
                      size: 36,
                      color: Colors.blue[300],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  category.categoryName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Domain text (like "Recharges", "Finance & Insurance")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  category.categoryDomain,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}