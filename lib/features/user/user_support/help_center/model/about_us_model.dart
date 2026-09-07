class AboutUsModel {
  final int id;
  final String title;
  final String content;
  final String faqFor;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  AboutUsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.faqFor,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AboutUsModel.fromJson(Map<String, dynamic> json) {
    return AboutUsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      faqFor: json['faq_for'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class AboutUsResponse {
  final bool success;
  final String message;
  final List<AboutUsModel> data;

  AboutUsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AboutUsResponse.fromJson(Map<String, dynamic> json) {
    return AboutUsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<AboutUsModel>.from(
              (json['data'] as List).map((x) => AboutUsModel.fromJson(x)),
            )
          : [],
    );
  }
}
