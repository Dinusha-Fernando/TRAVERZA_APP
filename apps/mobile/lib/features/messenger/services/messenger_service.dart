import 'package:flutter/foundation.dart';
import '../models/messenger_models.dart';

class MessengerService extends ChangeNotifier {
  static final MessengerService instance = MessengerService._internal();

  MessengerService._internal() {
    _loadSeedConversations();
  }

  final List<ChatConversationModel> _conversations = [];
  final Map<String, List<ChatMessageModel>> _messages = {};
  final Set<String> _idempotencyKeys = {};
  int _msgSeq = 0;

  List<ChatConversationModel> get conversations => List.unmodifiable(_conversations);

  int get totalUnreadCount => _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  void _loadSeedConversations() {
    final now = DateTime.now();

    final c1 = ChatConversationModel(
      id: 'cv-101',
      conversationType: ConversationTypeEnum.providerInquiry,
      title: 'Sigiriya Eco Villa · Booking #BK-9041',
      relatedProviderId: 'p-101',
      relatedTripId: 'trip-1',
      districtName: 'Matale',
      memberCount: 2,
      lastMessageText: 'We have prepared the garden cottage for your 18:30 check-in.',
      lastMessageAt: now.subtract(const Duration(minutes: 25)),
      unreadCount: 1,
      participantSubtitle: 'Provider Inquiry · Eco Villa Stays',
    );

    final c2 = ChatConversationModel(
      id: 'cv-102',
      conversationType: ConversationTypeEnum.direct,
      title: 'Duminda Bandara (SLTDA Licensed Guide)',
      districtName: 'Matale',
      memberCount: 2,
      lastMessageText: 'Meeting at Sigiriya south entrance at 06:15 AM sharp.',
      lastMessageAt: now.subtract(const Duration(hours: 1)),
      unreadCount: 0,
      participantSubtitle: 'Direct · Cultural Heritage Guide',
    );

    final c3 = ChatConversationModel(
      id: 'cv-103',
      conversationType: ConversationTypeEnum.tripGroup,
      title: 'Ceylon Cultural Triangle 2026',
      relatedTripId: 'trip-1',
      districtName: 'Central Province',
      memberCount: 4,
      lastMessageText: 'Added Dambulla Cave Temples to Day 2 afternoon itinerary.',
      lastMessageAt: now.subtract(const Duration(hours: 4)),
      unreadCount: 0,
      participantSubtitle: 'Trip Group · 4 Members',
    );

    final c4 = ChatConversationModel(
      id: 'cv-104',
      conversationType: ConversationTypeEnum.districtLounge,
      title: 'Ella & Uva Travellers Lounge',
      districtName: 'Badulla / Ella',
      memberCount: 342,
      lastMessageText: 'Watch the blue train crossing through the tea valley!',
      lastMessageAt: now.subtract(const Duration(minutes: 15)),
      unreadCount: 2,
      participantSubtitle: 'Public District Lounge · 342 Travellers',
    );

    final c5 = ChatConversationModel(
      id: 'cv-105',
      conversationType: ConversationTypeEnum.districtLounge,
      title: 'Sigiriya & Cultural Triangle Hub',
      districtName: 'Matale / Sigiriya',
      memberCount: 516,
      lastMessageText: 'Pidurangala sunrise climb: recommend starting at 05:15 AM.',
      lastMessageAt: now.subtract(const Duration(minutes: 40)),
      unreadCount: 1,
      participantSubtitle: 'Public District Lounge · 516 Travellers',
    );

    final c6 = ChatConversationModel(
      id: 'cv-106',
      conversationType: ConversationTypeEnum.direct,
      title: 'Ayesha De Silva (Travel Creator)',
      districtName: 'Galle / Coast',
      memberCount: 2,
      lastMessageText: 'Here is the sunset view from Galle Fort Pedlar Street!',
      lastMessageAt: now.subtract(const Duration(hours: 2)),
      unreadCount: 0,
      participantSubtitle: 'Direct · Southern Coast Creator',
    );

    _conversations.addAll([c4, c5, c1, c2, c6, c3]);

    // Messages for cv-101 (Provider)
    _messages['cv-101'] = [
      ChatMessageModel(
        id: 'msg-1',
        conversationId: 'cv-101',
        senderId: 'u-traveller',
        senderName: 'Dinusha',
        clientMessageId: 'cli-001',
        messageType: MessageTypeEnum.providerQuoteRequest,
        textContent: 'Booking inquiry for 2 nights starting tomorrow.',
        quoteRequest: const ProviderQuoteModel(
          serviceName: 'Sigiriya Water Garden Eco Villa',
          proposedDate: 'Tomorrow · 18:30 Check-in',
          guestsCount: 2,
          estimatedLKR: 38000,
          bookingStatus: 'PROVIDER_CONFIRMED',
        ),
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      ChatMessageModel(
        id: 'msg-2',
        conversationId: 'cv-101',
        senderId: 'u-provider',
        senderName: 'Sigiriya Eco Villa Reservations',
        clientMessageId: 'cli-002',
        messageType: MessageTypeEnum.text,
        textContent: 'Ayubowan! We have prepared the garden cottage for your 18:30 check-in. Dinner can be served on your private terrace overlooking the lily pond.',
        createdAt: now.subtract(const Duration(minutes: 25)),
      ),
    ];

    // Messages for cv-102 (Guide)
    _messages['cv-102'] = [
      ChatMessageModel(
        id: 'msg-3',
        conversationId: 'cv-102',
        senderId: 'u-guide',
        senderName: 'Duminda Bandara',
        clientMessageId: 'cli-003',
        messageType: MessageTypeEnum.placeSnippet,
        textContent: 'Here is the meeting landmark for tomorrow\'s dawn ascent.',
        placeSnippet: const PlaceSnippetModel(
          destinationName: 'Sigiriya Ancient Citadel & Lion Rock',
          districtName: 'Matale District',
          photoUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=400&q=80',
          summary: 'UNESCO 5th-century sky fortress built by King Kasyapa.',
        ),
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      ChatMessageModel(
        id: 'msg-4',
        conversationId: 'cv-102',
        senderId: 'u-guide',
        senderName: 'Duminda Bandara',
        clientMessageId: 'cli-004',
        messageType: MessageTypeEnum.text,
        textContent: 'Meeting at Sigiriya south entrance at 06:15 AM sharp. I will carry the official archaeological badges.',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ];

    // Messages for cv-104 (Ella Travellers Lounge - includes Photo & Video)
    _messages['cv-104'] = [
      ChatMessageModel(
        id: 'msg-10',
        conversationId: 'cv-104',
        senderId: 'u-markus',
        senderName: 'Markus Weber',
        clientMessageId: 'cli-010',
        messageType: MessageTypeEnum.photo,
        textContent: 'Golden sunrise over the Nine Arch viaduct this morning! Completely quiet before 07:00 AM.',
        mediaAttachment: const MediaAttachmentModel(
          mediaUrl: 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80',
          mediaType: 'image',
          caption: 'Nine Arch Bridge at sunrise',
        ),
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      ChatMessageModel(
        id: 'msg-11',
        conversationId: 'cv-104',
        senderId: 'u-kavinda',
        senderName: 'Kavinda Perera',
        clientMessageId: 'cli-011',
        messageType: MessageTypeEnum.placeSnippet,
        textContent: 'If anyone is heading towards Wellawaya afterwards, check out Ravana Falls pool:',
        placeSnippet: const PlaceSnippetModel(
          destinationName: 'Ravana Falls & Secret Caves',
          districtName: 'Badulla District',
          photoUrl: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=600&q=80',
          summary: 'Cascading highland waterfall with natural pools. Caution: rocky sections slippery after rain.',
        ),
        createdAt: now.subtract(const Duration(minutes: 35)),
      ),
      ChatMessageModel(
        id: 'msg-12',
        conversationId: 'cv-104',
        senderId: 'u-elena',
        senderName: 'Elena Rostova',
        clientMessageId: 'cli-012',
        messageType: MessageTypeEnum.video,
        textContent: 'Watch the blue train crossing through the tea valley!',
        mediaAttachment: const MediaAttachmentModel(
          mediaUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          mediaType: 'video',
          durationSeconds: 18,
          thumbnailUrl: 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80',
          caption: 'Blue express train clearing Nine Arch viaduct',
        ),
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
    ];

    // Messages for cv-105 (Sigiriya Hub)
    _messages['cv-105'] = [
      ChatMessageModel(
        id: 'msg-20',
        conversationId: 'cv-105',
        senderId: 'u-guide',
        senderName: 'Duminda Bandara',
        clientMessageId: 'cli-020',
        messageType: MessageTypeEnum.placeSnippet,
        textContent: 'Pidurangala sunrise climb: recommend starting at 05:15 AM from north temple.',
        placeSnippet: const PlaceSnippetModel(
          destinationName: 'Pidurangala Rock Sanctuary',
          districtName: 'Matale District',
          photoUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=600&q=80',
          summary: 'Panoramic granite peak directly facing Sigiriya Lion Rock fortress.',
        ),
        createdAt: now.subtract(const Duration(minutes: 40)),
      ),
    ];

    // Messages for cv-106 (Ayesha De Silva Direct)
    _messages['cv-106'] = [
      ChatMessageModel(
        id: 'msg-30',
        conversationId: 'cv-106',
        senderId: 'u-ayesha',
        senderName: 'Ayesha De Silva',
        clientMessageId: 'cli-030',
        messageType: MessageTypeEnum.photo,
        textContent: 'Here is the sunset view from Galle Fort Pedlar Street!',
        mediaAttachment: const MediaAttachmentModel(
          mediaUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80',
          mediaType: 'image',
          caption: 'Galle Fort Lighthouse & Ramparts',
        ),
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];

    // Messages for cv-103 (Trip Group)
    _messages['cv-103'] = [
      ChatMessageModel(
        id: 'msg-5',
        conversationId: 'cv-103',
        senderId: 'u-traveller',
        senderName: 'Dinusha',
        clientMessageId: 'cli-005',
        messageType: MessageTypeEnum.text,
        textContent: 'Added Dambulla Cave Temples to Day 2 afternoon itinerary. TripGraph confirmed 25m transit buffer from Sigiriya.',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  List<ChatMessageModel> getMessages(String conversationId) {
    return _messages[conversationId] ?? const [];
  }

  void markAsRead(String conversationId) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1 && _conversations[idx].unreadCount > 0) {
      _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  void sendMessage({
    required String conversationId,
    required String textContent,
    MessageTypeEnum messageType = MessageTypeEnum.text,
    PlaceSnippetModel? placeSnippet,
    ProviderQuoteModel? quoteRequest,
    MediaAttachmentModel? mediaAttachment,
    String? clientMessageId,
  }) {
    final nonce = clientMessageId ?? 'cli-${DateTime.now().microsecondsSinceEpoch}-${_msgSeq++}';

    // Idempotency protection: never duplicate on retry
    if (_idempotencyKeys.contains(nonce)) return;
    _idempotencyKeys.add(nonce);

    final now = DateTime.now();
    final newMsg = ChatMessageModel(
      id: 'msg-${now.millisecondsSinceEpoch}-${_msgSeq++}',
      conversationId: conversationId,
      senderId: 'u-traveller',
      senderName: 'Dinusha',
      clientMessageId: nonce,
      messageType: messageType,
      textContent: textContent,
      placeSnippet: placeSnippet,
      quoteRequest: quoteRequest,
      mediaAttachment: mediaAttachment,
      createdAt: now,
    );

    _messages.putIfAbsent(conversationId, () => []).add(newMsg);

    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(
        lastMessageText: textContent,
        lastMessageAt: now,
      );
    }
    notifyListeners();
  }

  void sendPhotoMessage({
    required String conversationId,
    required String photoUrl,
    String? caption,
  }) {
    sendMessage(
      conversationId: conversationId,
      textContent: caption?.trim().isNotEmpty == true ? caption! : 'Shared a travel photo',
      messageType: MessageTypeEnum.photo,
      mediaAttachment: MediaAttachmentModel(
        mediaUrl: photoUrl,
        mediaType: 'image',
        caption: caption,
      ),
    );
  }

  void sendVideoMessage({
    required String conversationId,
    required String videoUrl,
    String? caption,
    int durationSeconds = 15,
    String? thumbnailUrl,
  }) {
    sendMessage(
      conversationId: conversationId,
      textContent: caption?.trim().isNotEmpty == true ? caption! : 'Shared a travel video clip',
      messageType: MessageTypeEnum.video,
      mediaAttachment: MediaAttachmentModel(
        mediaUrl: videoUrl,
        mediaType: 'video',
        durationSeconds: durationSeconds,
        thumbnailUrl: thumbnailUrl ?? 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80',
        caption: caption,
      ),
    );
  }

  void sendPlaceSnippet({
    required String conversationId,
    required String destinationName,
    required String districtName,
    String? photoUrl,
    String? summary,
    String? messageNote,
  }) {
    sendMessage(
      conversationId: conversationId,
      textContent: messageNote ?? 'Check out $destinationName in $districtName!',
      messageType: MessageTypeEnum.placeSnippet,
      placeSnippet: PlaceSnippetModel(
        destinationName: destinationName,
        districtName: districtName,
        photoUrl: photoUrl,
        summary: summary,
      ),
    );
  }

  String startDirectChat({
    required String userName,
    required String userRole,
    String? initialMessage,
    String? districtName,
  }) {
    final now = DateTime.now();

    // Check if a direct chat with this user already exists
    final matches = _conversations.where(
      (c) => c.conversationType == ConversationTypeEnum.direct && c.title.contains(userName),
    );
    if (matches.isNotEmpty) {
      final existing = matches.first;
      if (initialMessage != null && initialMessage.trim().isNotEmpty) {
        sendMessage(conversationId: existing.id, textContent: initialMessage);
      }
      return existing.id;
    }

    final convId = 'cv-${now.millisecondsSinceEpoch}';
    final newConv = ChatConversationModel(
      id: convId,
      conversationType: ConversationTypeEnum.direct,
      title: '$userName ($userRole)',
      districtName: districtName ?? 'Sri Lanka',
      memberCount: 2,
      lastMessageText: initialMessage ?? 'Started conversation',
      lastMessageAt: now,
      unreadCount: 0,
      participantSubtitle: 'Direct Chat · $userRole',
    );

    _conversations.insert(0, newConv);

    if (initialMessage != null && initialMessage.trim().isNotEmpty) {
      sendMessage(conversationId: convId, textContent: initialMessage);
    }

    notifyListeners();
    return convId;
  }

  String joinDistrictLounge({
    required String districtId,
    required String loungeTitle,
    required String subtitle,
    String? districtName,
  }) {
    // Check if already in this lounge
    final matches = _conversations.where(
      (c) => c.conversationType == ConversationTypeEnum.districtLounge && c.title == loungeTitle,
    );
    if (matches.isNotEmpty) {
      return matches.first.id;
    }

    final now = DateTime.now();
    final convId = 'cv-${now.millisecondsSinceEpoch}';
    final newConv = ChatConversationModel(
      id: convId,
      conversationType: ConversationTypeEnum.districtLounge,
      title: loungeTitle,
      districtName: districtName ?? districtId,
      memberCount: 150 + (now.millisecond % 200),
      lastMessageText: 'You joined the lounge. Say Ayubowan!',
      lastMessageAt: now,
      unreadCount: 0,
      participantSubtitle: subtitle,
    );

    _conversations.insert(0, newConv);
    notifyListeners();
    return convId;
  }

  String startProviderInquiry({
    required String providerName,
    required String serviceTitle,
    required String destinationName,
    required String proposedDate,
    int guestsCount = 2,
    int? estimatedLKR,
    String initialMessage = 'Hi, I would like to inquire about availability and pricing.',
  }) {
    final now = DateTime.now();
    final convId = 'cv-${now.millisecondsSinceEpoch}';

    final newConv = ChatConversationModel(
      id: convId,
      conversationType: ConversationTypeEnum.providerInquiry,
      title: '$providerName · Inquiry',
      lastMessageText: initialMessage,
      lastMessageAt: now,
      unreadCount: 0,
      participantSubtitle: 'Provider Inquiry · $destinationName',
    );

    _conversations.insert(0, newConv);

    final quote = ProviderQuoteModel(
      serviceName: serviceTitle,
      proposedDate: proposedDate,
      guestsCount: guestsCount,
      estimatedLKR: estimatedLKR,
      bookingStatus: 'INQUIRY_OPEN',
    );

    final msg = ChatMessageModel(
      id: 'msg-${now.millisecondsSinceEpoch}',
      conversationId: convId,
      senderId: 'u-traveller',
      senderName: 'Dinusha',
      clientMessageId: 'cli-${now.microsecondsSinceEpoch}',
      messageType: MessageTypeEnum.providerQuoteRequest,
      textContent: initialMessage,
      quoteRequest: quote,
      createdAt: now,
    );

    _messages[convId] = [msg];
    notifyListeners();
    return convId;
  }
}
