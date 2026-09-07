class ContentManagementModel {
  final int id;
  final String contentType;
  final String faqFor;
  final String description;
  final bool isPublished;
  final String? version;

  ContentManagementModel({
    required this.id,
    required this.contentType,
    required this.faqFor,
    required this.description,
    required this.isPublished,
    this.version,
  });

  factory ContentManagementModel.fromJson(Map<String, dynamic> json) {
    return ContentManagementModel(
      id: json['id'] ?? 0,
      contentType: json['contenttype'] ?? '',
      faqFor: json['faq_for'] ?? '',
      description: json['description'] ?? '',
      isPublished: json['isPublished'] ?? false,
      version: json['version'],
    );
  }
}

class ContentManagementResponse {
  final bool success;
  final String message;
  final List<ContentManagementModel> data;

  ContentManagementResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ContentManagementResponse.fromJson(Map<String, dynamic> json) {
    return ContentManagementResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<ContentManagementModel>.from(
              (json['data'] as List).map(
                (x) => ContentManagementModel.fromJson(x),
              ),
            )
          : [],
    );
  }
}
