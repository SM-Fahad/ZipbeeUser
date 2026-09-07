class HelpArticleModel {
  final int id;
  final String title;
  final String faqFor;
  final String content;
  final bool published;
  final String createdAt;
  final String updatedAt;

  HelpArticleModel({
    required this.id,
    required this.title,
    required this.faqFor,
    required this.content,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HelpArticleModel.fromJson(Map<String, dynamic> json) {
    return HelpArticleModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      faqFor: json['faq_for'] ?? '',
      content: json['content'] ?? '',
      published: json['published'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class HelpArticleResponse {
  final bool success;
  final String message;
  final List<HelpArticleModel> data;

  HelpArticleResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory HelpArticleResponse.fromJson(Map<String, dynamic> json) {
    return HelpArticleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<HelpArticleModel>.from(
              (json['data'] as List).map((x) => HelpArticleModel.fromJson(x)),
            )
          : [],
    );
  }
}
