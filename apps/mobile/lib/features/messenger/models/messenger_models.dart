enum ConversationTypeEnum {
  direct,
  providerInquiry,
  tripGroup,
  districtLounge,
}

enum MessageTypeEnum {
  text,
  photo,
  video,
  file,
  placeSnippet,
  itinerarySnippet,
  providerQuoteRequest,
}

class PlaceSnippetModel {
  final String destinationName;
  final String districtName;
  final String? photoUrl;
  final String? summary;

  const PlaceSnippetModel({
    required this.destinationName,
    required this.districtName,
    this.photoUrl,
    this.summary,
  });

  factory PlaceSnippetModel.fromJson(Map<String, dynamic> json) {
    return PlaceSnippetModel(
      destinationName: json['destination_name'] as String? ?? 'Destination',
      districtName: json['district_name'] as String? ?? 'District',
      photoUrl: json['photo_url'] as String?,
      summary: json['summary'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'destination_name': destinationName,
    'district_name': districtName,
    'photo_url': photoUrl,
    'summary': summary,
  };
}

class MediaAttachmentModel {
  final String mediaUrl;
  final String mediaType; // 'image', 'video', or 'file'
  final String? caption;
  final int? durationSeconds;
  final String? thumbnailUrl;
  final String? fileName;
  final String? fileSize;
  final String? fileExtension;

  const MediaAttachmentModel({
    required this.mediaUrl,
    this.mediaType = 'image',
    this.caption,
    this.durationSeconds,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.fileExtension,
  });

  factory MediaAttachmentModel.fromJson(Map<String, dynamic> json) {
    return MediaAttachmentModel(
      mediaUrl: json['media_url'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? 'image',
      caption: json['caption'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as String?,
      fileExtension: json['file_extension'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'media_url': mediaUrl,
    'media_type': mediaType,
    'caption': caption,
    'duration_seconds': durationSeconds,
    'thumbnail_url': thumbnailUrl,
    'file_name': fileName,
    'file_size': fileSize,
    'file_extension': fileExtension,
  };
}

class ProviderQuoteModel {
  final String serviceName;
  final String proposedDate;
  final int guestsCount;
  final int? estimatedLKR;
  final String bookingStatus;

  const ProviderQuoteModel({
    required this.serviceName,
    required this.proposedDate,
    this.guestsCount = 2,
    this.estimatedLKR,
    this.bookingStatus = 'INQUIRY_OPEN',
  });

  factory ProviderQuoteModel.fromJson(Map<String, dynamic> json) {
    return ProviderQuoteModel(
      serviceName: json['service_name'] as String? ?? 'Service',
      proposedDate: json['proposed_date'] as String? ?? '',
      guestsCount: json['guests_count'] as int? ?? 2,
      estimatedLKR: json['estimated_lkr'] as int?,
      bookingStatus: json['booking_status'] as String? ?? 'INQUIRY_OPEN',
    );
  }

  Map<String, dynamic> toJson() => {
    'service_name': serviceName,
    'proposed_date': proposedDate,
    'guests_count': guestsCount,
    'estimated_lkr': estimatedLKR,
    'booking_status': bookingStatus,
  };
}

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String clientMessageId;
  final MessageTypeEnum messageType;
  final String textContent;
  final PlaceSnippetModel? placeSnippet;
  final ProviderQuoteModel? quoteRequest;
  final MediaAttachmentModel? mediaAttachment;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.clientMessageId,
    required this.messageType,
    required this.textContent,
    this.placeSnippet,
    this.quoteRequest,
    this.mediaAttachment,
    required this.createdAt,
  });
}

class ChatConversationModel {
  final String id;
  final ConversationTypeEnum conversationType;
  final String title;
  final String? relatedProviderId;
  final String? relatedTripId;
  final String? districtName;
  final int memberCount;
  final String lastMessageText;
  final DateTime lastMessageAt;
  final int unreadCount;
  final String participantSubtitle;

  const ChatConversationModel({
    required this.id,
    required this.conversationType,
    required this.title,
    this.relatedProviderId,
    this.relatedTripId,
    this.districtName,
    this.memberCount = 2,
    required this.lastMessageText,
    required this.lastMessageAt,
    this.unreadCount = 0,
    required this.participantSubtitle,
  });

  ChatConversationModel copyWith({
    String? lastMessageText,
    DateTime? lastMessageAt,
    int? unreadCount,
    int? memberCount,
  }) {
    return ChatConversationModel(
      id: id,
      conversationType: conversationType,
      title: title,
      relatedProviderId: relatedProviderId,
      relatedTripId: relatedTripId,
      districtName: districtName,
      memberCount: memberCount ?? this.memberCount,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      participantSubtitle: participantSubtitle,
    );
  }
}
