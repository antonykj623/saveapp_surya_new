import 'dart:typed_data';
import 'dart:convert';

/// Category Model
/// Represents a bill payment category (e.g., Mobile, DTH, Electricity)
class CategoryModel {
  final String categoryId;
  final String categoryName;
  final String categoryIcon; // Base64 encoded image
  final String categoryDomain;
  final String buttonName;
  final String textArea;
  final List<dynamic> faqDetailsList;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryDomain,
    required this.buttonName,
    required this.textArea,
    required this.faqDetailsList,
  });

  /// Create CategoryModel from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryIcon: json['categoryIcon'] ?? '',
      categoryDomain: json['categoryDomain'] ?? '',
      buttonName: json['buttonName'] ?? '',
      textArea: json['textArea'] ?? '',
      faqDetailsList: json['faqDetailsList'] ?? [],
    );
  }

  /// Convert base64 icon to image bytes
  Uint8List? getImageBytes() {
    if (categoryIcon.isEmpty) return null;
    try {
      // Remove data:image/png;base64, prefix if present
      String base64String = categoryIcon;
      if (categoryIcon.contains(',')) {
        base64String = categoryIcon.split(',').last;
      }
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }
}