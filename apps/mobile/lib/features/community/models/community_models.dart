enum PostType {
  photo,
  video,
  carousel,
  question,
  fieldReport,
  localNote,
}

enum AuthorBadge {
  verifiedVisitor,
  licensedGuide,
  verifiedProvider,
  communityExpert,
  traveller,
}

class PostMediaModel {
  final String id;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String? thumbnailUrl;
  final String? altText;
  final int? durationSeconds;
  final String? fileName;
  final String? fileSize;

  const PostMediaModel({
    required this.id,
    required this.mediaUrl,
    this.mediaType = 'image',
    this.thumbnailUrl,
    this.altText,
    this.durationSeconds,
    this.fileName,
    this.fileSize,
  });

  factory PostMediaModel.fromJson(Map<String, dynamic> json) {
    return PostMediaModel(
      id: json['id'] as String? ?? '',
      mediaUrl: json['media_url'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? 'image',
      thumbnailUrl: json['thumbnail_url'] as String?,
      altText: json['alt_text'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as String?,
    );
  }
}

class PostCommentModel {
  final String id;
  final String authorName;
  final AuthorBadge authorBadge;
  final String commentText;
  final bool isAcceptedAnswer;
  final int helpfulVotes;
  final DateTime createdAt;

  const PostCommentModel({
    required this.id,
    required this.authorName,
    required this.authorBadge,
    required this.commentText,
    this.isAcceptedAnswer = false,
    this.helpfulVotes = 0,
    required this.createdAt,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'] as String? ?? '',
      authorName: json['author_name'] as String? ?? 'Traveller',
      authorBadge: _parseBadge(json['author_badge'] as String?),
      commentText: json['comment_text'] as String? ?? '',
      isAcceptedAnswer: json['is_accepted_answer'] as bool? ?? false,
      helpfulVotes: json['helpful_votes'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CommunityPostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final AuthorBadge authorBadge;
  final String? authorBadgeDetail;

  final PostType postType;
  final String caption;

  final String districtId;
  final String districtName;
  final String provinceId;
  final String? destinationSlug;
  final String? destinationName;

  final String trustLabel;
  final DateTime? observedAt;
  final DateTime? expiresAt;
  final bool isStale;
  final String freshnessLabel;

  final int helpfulCount;
  final int likeCount;
  final int commentCount;
  final int saveCount;
  final bool isQuestionResolved;

  final DateTime createdAt;
  final List<PostMediaModel> media;
  final List<PostCommentModel> comments;

  const CommunityPostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.authorBadge,
    this.authorBadgeDetail,
    required this.postType,
    required this.caption,
    required this.districtId,
    required this.districtName,
    required this.provinceId,
    this.destinationSlug,
    this.destinationName,
    required this.trustLabel,
    this.observedAt,
    this.expiresAt,
    this.isStale = false,
    required this.freshnessLabel,
    this.helpfulCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.saveCount = 0,
    this.isQuestionResolved = false,
    required this.createdAt,
    this.media = const [],
    this.comments = const [],
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      authorName: json['author_name'] as String? ?? 'Community Contributor',
      authorAvatarUrl: json['author_avatar_url'] as String?,
      authorBadge: _parseBadge(json['author_badge'] as String?),
      authorBadgeDetail: json['author_badge_detail'] as String?,
      postType: _parsePostType(json['post_type'] as String?),
      caption: json['caption'] as String? ?? '',
      districtId: json['district_id'] as String? ?? '',
      districtName: json['district_name'] as String? ?? '',
      provinceId: json['province_id'] as String? ?? '',
      destinationSlug: json['destination_slug'] as String?,
      destinationName: json['destination_name'] as String?,
      trustLabel: json['trust_label'] as String? ?? 'Community Observation',
      observedAt: json['observed_at'] != null ? DateTime.tryParse(json['observed_at'].toString()) : null,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'].toString()) : null,
      isStale: json['is_stale'] as bool? ?? false,
      freshnessLabel: json['freshness_label'] as String? ?? 'Active',
      helpfulCount: json['helpful_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      saveCount: json['save_count'] as int? ?? 0,
      isQuestionResolved: json['is_question_resolved'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      media: (json['media'] as List<dynamic>? ?? [])
          .map((m) => PostMediaModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((c) => PostCommentModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  CommunityPostModel copyWith({
    int? helpfulCount,
    int? likeCount,
    int? commentCount,
    int? saveCount,
    bool? isQuestionResolved,
    List<PostCommentModel>? comments,
  }) {
    return CommunityPostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      authorBadge: authorBadge,
      authorBadgeDetail: authorBadgeDetail,
      postType: postType,
      caption: caption,
      districtId: districtId,
      districtName: districtName,
      provinceId: provinceId,
      destinationSlug: destinationSlug,
      destinationName: destinationName,
      trustLabel: trustLabel,
      observedAt: observedAt,
      expiresAt: expiresAt,
      isStale: isStale,
      freshnessLabel: freshnessLabel,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      saveCount: saveCount ?? this.saveCount,
      isQuestionResolved: isQuestionResolved ?? this.isQuestionResolved,
      createdAt: createdAt,
      media: media,
      comments: comments ?? this.comments,
    );
  }
}

class PlaceSignalModel {
  final String destinationName;
  final String districtName;
  final int recentNotesCount;
  final int unansweredQuestionsCount;
  final int activeFieldReportsCount;
  final String? latestObservation;
  final DateTime? latestObservedAt;
  final String trailOrRoadStatus;
  final String crowdLevel;
  final String freshnessStatus;

  const PlaceSignalModel({
    required this.destinationName,
    required this.districtName,
    required this.recentNotesCount,
    required this.unansweredQuestionsCount,
    required this.activeFieldReportsCount,
    this.latestObservation,
    this.latestObservedAt,
    required this.trailOrRoadStatus,
    required this.crowdLevel,
    required this.freshnessStatus,
  });
}

class ItineraryAdditionValidationResult {
  final bool isFeasible;
  final String destinationName;
  final int proposedDayNumber;
  final String proposedStartTime;
  final String proposedEndTime;
  final int roadBufferMins;
  final int transitDurationMins;
  final List<String> conflicts;
  final String recommendation;

  const ItineraryAdditionValidationResult({
    required this.isFeasible,
    required this.destinationName,
    required this.proposedDayNumber,
    required this.proposedStartTime,
    required this.proposedEndTime,
    required this.roadBufferMins,
    required this.transitDurationMins,
    required this.conflicts,
    required this.recommendation,
  });
}

AuthorBadge _parseBadge(String? badge) {
  switch (badge) {
    case 'LICENSED_GUIDE':
      return AuthorBadge.licensedGuide;
    case 'VERIFIED_PROVIDER':
      return AuthorBadge.verifiedProvider;
    case 'VERIFIED_VISITOR':
      return AuthorBadge.verifiedVisitor;
    case 'COMMUNITY_EXPERT':
      return AuthorBadge.communityExpert;
    default:
      return AuthorBadge.traveller;
  }
}

PostType _parsePostType(String? type) {
  switch (type) {
    case 'VIDEO':
      return PostType.video;
    case 'FIELD_REPORT':
      return PostType.fieldReport;
    case 'QUESTION':
      return PostType.question;
    case 'LOCAL_NOTE':
      return PostType.localNote;
    case 'CAROUSEL':
      return PostType.carousel;
    default:
      return PostType.photo;
  }
}
