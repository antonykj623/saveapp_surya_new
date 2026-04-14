class SliderResponse {
  final int status;
  final String message;
  final List<SliderItem> data;

  SliderResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SliderResponse.fromJson(Map<String, dynamic> json) {
    return SliderResponse(
      status: json['status'],
      message: json['message'],
      data: List<SliderItem>.from(
        json['data'].map((item) => SliderItem.fromJson(item)),
      ),
    );
  }
}

class SliderItem {
  final String id;
  final String image;
  final String description;

  SliderItem({
    required this.id,
    required this.image,
    required this.description,
  });

  factory SliderItem.fromJson(Map<String, dynamic> json) {
    return SliderItem(
      id: json['id'],
      image: json['image'],
      description: json['description'].trim(),
    );
  }
}