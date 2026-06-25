class UserModel {
  final int id;
  final String username;
  final String email;
  final String role;
  final String displayName;
  final bool isActive;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.displayName,
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        username: json['username'],
        email: json['email'] ?? '',
        role: json['role'],
        displayName: json['display_name'] ?? json['username'],
        isActive: json['is_active'] ?? true,
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'role': role,
        'display_name': displayName,
      };
}

class TextRecordModel {
  final int id;
  final int userId;
  final String status;
  final String? originalText;
  final String? userPrompt;
  final String? aiOptimizedText;
  final String? createdAt;
  final double? promptScore;
  final int? aiTotal;
  final double? finalScore;
  final int? humanTotal;
  ContentEvalModel? contentEvaluation;
  String? authorName;

  TextRecordModel({
    required this.id,
    required this.userId,
    required this.status,
    this.originalText,
    this.userPrompt,
    this.aiOptimizedText,
    this.createdAt,
    this.promptScore,
    this.aiTotal,
    this.finalScore,
    this.humanTotal,
    this.contentEvaluation,
    this.authorName,
  });

  factory TextRecordModel.fromJson(Map<String, dynamic> json) {
    final r = TextRecordModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? '',
      originalText: json['original_text'],
      userPrompt: json['user_prompt'],
      aiOptimizedText: json['ai_optimized_text'],
      createdAt: json['created_at'],
      promptScore: (json['prompt_score'] as num?)?.toDouble(),
      aiTotal: json['ai_total'],
      finalScore: (json['final_score'] as num?)?.toDouble(),
      humanTotal: json['human_total'],
      authorName: json['author_name'],
    );
    if (json['content_evaluation'] != null) {
      r.contentEvaluation =
          ContentEvalModel.fromJson(json['content_evaluation']);
    }
    return r;
  }
}

class ContentEvalModel {
  final int id;
  final String? evalTargetType;
  final int? aiLiteratureRelevance;
  final int? aiCitationAccuracy;
  final int? aiOutlineStructure;
  final int? aiBasicTotal;
  final int? aiInterdisciplinary;
  final int? aiReflection;
  final int? aiBonusTotal;
  final int? aiTotal;
  final String? aiReport;
  final int? humanLiteratureRelevance;
  final int? humanCitationAccuracy;
  final int? humanOutlineStructure;
  final int? humanBasicTotal;
  final int? humanInterdisciplinary;
  final int? humanReflection;
  final int? humanBonusTotal;
  final int? humanTotal;
  final String? humanComment;
  final double? finalScore;
  final double? aiWeight;
  final double? humanWeight;
  final String? createdAt;

  ContentEvalModel({
    required this.id,
    this.evalTargetType,
    this.aiLiteratureRelevance,
    this.aiCitationAccuracy,
    this.aiOutlineStructure,
    this.aiBasicTotal,
    this.aiInterdisciplinary,
    this.aiReflection,
    this.aiBonusTotal,
    this.aiTotal,
    this.aiReport,
    this.humanLiteratureRelevance,
    this.humanCitationAccuracy,
    this.humanOutlineStructure,
    this.humanBasicTotal,
    this.humanInterdisciplinary,
    this.humanReflection,
    this.humanBonusTotal,
    this.humanTotal,
    this.humanComment,
    this.finalScore,
    this.aiWeight,
    this.humanWeight,
    this.createdAt,
  });

  factory ContentEvalModel.fromJson(Map<String, dynamic> json) =>
      ContentEvalModel(
        id: json['id'],
        evalTargetType: json['eval_target_type'],
        aiLiteratureRelevance: json['ai_literature_relevance'],
        aiCitationAccuracy: json['ai_citation_accuracy'],
        aiOutlineStructure: json['ai_outline_structure'],
        aiBasicTotal: json['ai_basic_total'],
        aiInterdisciplinary: json['ai_interdisciplinary'],
        aiReflection: json['ai_reflection'],
        aiBonusTotal: json['ai_bonus_total'],
        aiTotal: json['ai_total'],
        aiReport: json['ai_report'],
        humanLiteratureRelevance: json['human_literature_relevance'],
        humanCitationAccuracy: json['human_citation_accuracy'],
        humanOutlineStructure: json['human_outline_structure'],
        humanBasicTotal: json['human_basic_total'],
        humanInterdisciplinary: json['human_interdisciplinary'],
        humanReflection: json['human_reflection'],
        humanBonusTotal: json['human_bonus_total'],
        humanTotal: json['human_total'],
        humanComment: json['human_comment'],
        finalScore: (json['final_score'] as num?)?.toDouble(),
        aiWeight: (json['ai_weight'] as num?)?.toDouble(),
        humanWeight: (json['human_weight'] as num?)?.toDouble(),
        createdAt: json['created_at'],
      );
}

class ScoreCardModel {
  final List<Map<String, dynamic>> basicItems;
  final List<Map<String, dynamic>> bonusItems;
  final int? aiBasicTotal;
  final int? aiBonusTotal;
  final int? aiTotal;
  final dynamic humanBasicTotal;
  final dynamic humanBonusTotal;
  final dynamic humanTotal;
  final double? finalScore;
  final double aiWeight;
  final double humanWeight;
  final bool hasHuman;
  final String? humanComment;
  final String? aiReport;
  final List<String> radarLabels;
  final List<int> radarAi;
  final List<int>? radarHuman;
  final Map<String, bool> bonusAi;
  final Map<String, bool>? bonusHuman;

  ScoreCardModel({
    required this.basicItems,
    required this.bonusItems,
    this.aiBasicTotal,
    this.aiBonusTotal,
    this.aiTotal,
    this.humanBasicTotal,
    this.humanBonusTotal,
    this.humanTotal,
    this.finalScore,
    required this.aiWeight,
    required this.humanWeight,
    required this.hasHuman,
    this.humanComment,
    this.aiReport,
    required this.radarLabels,
    required this.radarAi,
    this.radarHuman,
    required this.bonusAi,
    this.bonusHuman,
  });

  factory ScoreCardModel.fromJson(Map<String, dynamic> json) {
    return ScoreCardModel(
      basicItems: List<Map<String, dynamic>>.from(json['basic_items'] ?? []),
      bonusItems: List<Map<String, dynamic>>.from(json['bonus_items'] ?? []),
      aiBasicTotal: json['ai_basic_total'],
      aiBonusTotal: json['ai_bonus_total'],
      aiTotal: json['ai_total'],
      humanBasicTotal: json['human_basic_total'],
      humanBonusTotal: json['human_bonus_total'],
      humanTotal: json['human_total'],
      finalScore: (json['final_score'] as num?)?.toDouble(),
      aiWeight: (json['ai_weight'] as num?)?.toDouble() ?? 0.5,
      humanWeight: (json['human_weight'] as num?)?.toDouble() ?? 0.5,
      hasHuman: json['has_human'] ?? false,
      humanComment: json['human_comment'],
      aiReport: json['ai_report'],
      radarLabels: List<String>.from(json['radar_labels'] ?? []),
      radarAi: List<int>.from(json['radar_ai'] ?? []),
      radarHuman: json['radar_human'] != null
          ? List<int>.from(json['radar_human'])
          : null,
      bonusAi: Map<String, bool>.from(json['bonus_ai'] ?? {}),
      bonusHuman: json['bonus_human'] != null
          ? Map<String, bool>.from(json['bonus_human'])
          : null,
    );
  }
}

class CourseModel {
  final int id;
  final String title;
  final String? description;
  final String? videoUrl;
  final String category;
  final int? durationMinutes;
  final int? sortOrder;
  final bool isActive;
  final bool isWatched;
  final bool isCompleted;

  CourseModel({
    required this.id,
    required this.title,
    this.description,
    this.videoUrl,
    required this.category,
    this.durationMinutes,
    this.sortOrder,
    this.isActive = true,
    this.isWatched = false,
    this.isCompleted = false,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        videoUrl: json['video_url'],
        category: json['category'],
        durationMinutes: json['duration_minutes'],
        sortOrder: json['sort_order'],
        isActive: json['is_active'] ?? true,
        isWatched: json['is_watched'] ?? false,
        isCompleted: json['is_completed'] ?? false,
      );
}

class RewriteModel {
  final int id;
  final String rewriteType;
  final double? oldPromptScore;
  final double? newPromptScore;
  final String? promptComparisonReport;
  final String? newAiText;
  final String? humanRewrittenText;
  final String? createdAt;
  ContentEvalModel? evaluation;

  RewriteModel({
    required this.id,
    required this.rewriteType,
    this.oldPromptScore,
    this.newPromptScore,
    this.promptComparisonReport,
    this.newAiText,
    this.humanRewrittenText,
    this.createdAt,
    this.evaluation,
  });

  factory RewriteModel.fromJson(Map<String, dynamic> json) {
    final r = RewriteModel(
      id: json['id'],
      rewriteType: json['rewrite_type'] ?? '',
      oldPromptScore: (json['old_prompt_score'] as num?)?.toDouble(),
      newPromptScore: (json['new_prompt_score'] as num?)?.toDouble(),
      promptComparisonReport: json['prompt_comparison_report'],
      newAiText: json['new_ai_text'],
      humanRewrittenText: json['human_rewritten_text'],
      createdAt: json['created_at'],
    );
    if (json['evaluation'] != null) {
      r.evaluation = ContentEvalModel.fromJson(json['evaluation']);
    }
    return r;
  }
}
