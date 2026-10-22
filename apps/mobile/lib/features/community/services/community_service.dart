import 'package:flutter/foundation.dart';
import '../models/community_models.dart';

class CommunityService extends ChangeNotifier {
  static final CommunityService instance = CommunityService._internal();

  CommunityService._internal() {
    _loadSeedPosts();
  }

  final List<CommunityPostModel> _allPosts = [];
  final Set<String> _savedPostIds = {};
  final Set<String> _helpfulPostIds = {};
  final Set<String> _likedPostIds = {};

  List<CommunityPostModel> get allPosts => List.unmodifiable(_allPosts);

  void _loadSeedPosts() {
    final now = DateTime.now();
    _allPosts.addAll([
      CommunityPostModel(
        id: 'c1000000-0000-0000-0000-000000000001',
        authorId: 'u1000000-0000-0000-0000-000000000001',
        authorName: 'Duminda Bandara',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
        authorBadge: AuthorBadge.licensedGuide,
        authorBadgeDetail: 'SLTDA National Guide #GD-2026/044',
        postType: PostType.localNote,
        caption: 'Early morning ascent at Sigiriya: gate opens at 06:30. Climbing before 08:30 avoids midday heat on spiral stairs and tour bus crowds. Bring at least 1.5L of water and non-slip sandals.',
        districtId: 'matale',
        districtName: 'Matale District',
        provinceId: 'CP',
        destinationSlug: 'sigiriya-rock-fortress',
        destinationName: 'Sigiriya Ancient Citadel & Lion Rock',
        trustLabel: 'SLTDA Licensed Guide Field Insight',
        observedAt: now.subtract(const Duration(hours: 3)),
        expiresAt: null,
        isStale: false,
        freshnessLabel: 'Active Note',
        helpfulCount: 42,
        likeCount: 18,
        saveCount: 35,
        commentCount: 2,
        createdAt: now.subtract(const Duration(hours: 3)),
        media: const [
          PostMediaModel(
            id: 'm101',
            mediaUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=800&q=80',
            altText: 'Sigiriya rock fortress citadel at sunrise',
          ),
        ],
        comments: [
          PostCommentModel(
            id: 'cm101',
            authorName: 'Elena Rostova',
            authorBadge: AuthorBadge.traveller,
            commentText: 'Is the ticket counter accepting international credit cards now or still cash only?',
            isAcceptedAnswer: false,
            helpfulVotes: 3,
            createdAt: now.subtract(const Duration(hours: 2)),
          ),
          PostCommentModel(
            id: 'cm102',
            authorName: 'Duminda Bandara',
            authorBadge: AuthorBadge.licensedGuide,
            commentText: 'Visa and Mastercard are accepted at the main CCF counter, but keep LKR 12,000 cash handy in case of morning network dips.',
            isAcceptedAnswer: true,
            helpfulVotes: 12,
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      CommunityPostModel(
        id: 'c1000000-0000-0000-0000-000000000002',
        authorId: 'u1000000-0000-0000-0000-000000000003',
        authorName: 'Rohan & Tara Senanayake',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        authorBadge: AuthorBadge.verifiedVisitor,
        authorBadgeDetail: 'Verified Booking #BK-9041',
        postType: PostType.fieldReport,
        caption: 'Nine Arch Bridge live observation: Morning valley mist cleared at 09:15. Blue Passenger Express from Badulla crossed at 09:35. Trail down from Ella through tea slopes is clear.',
        districtId: 'badulla',
        districtName: 'Badulla District',
        provinceId: 'UP',
        destinationSlug: 'nine-arch-bridge-demodara',
        destinationName: 'Demodara Nine Arch Bridge',
        trustLabel: 'Verified Visitor Fresh Observation',
        observedAt: now.subtract(const Duration(hours: 1)),
        expiresAt: now.add(const Duration(hours: 3)),
        isStale: false,
        freshnessLabel: 'Fresh · Valid for 3h',
        helpfulCount: 29,
        likeCount: 34,
        saveCount: 19,
        commentCount: 1,
        createdAt: now.subtract(const Duration(hours: 1)),
        media: const [
          PostMediaModel(
            id: 'm102',
            mediaUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=800&q=80',
            altText: 'Blue train crossing Demodara Nine Arch Bridge',
          ),
        ],
        comments: [
          PostCommentModel(
            id: 'cm103',
            authorName: 'Marc Dubost',
            authorBadge: AuthorBadge.traveller,
            commentText: 'Catching the 11:40 train from the viewpoint cafe right now, great report!',
            isAcceptedAnswer: false,
            helpfulVotes: 2,
            createdAt: now.subtract(const Duration(minutes: 40)),
          ),
        ],
      ),
      CommunityPostModel(
        id: 'c1000000-0000-0000-0000-000000000003',
        authorId: 'u1000000-0000-0000-0000-000000000005',
        authorName: 'Sarah Jenkins',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
        authorBadge: AuthorBadge.traveller,
        authorBadgeDetail: 'Traveller from UK',
        postType: PostType.question,
        caption: 'Is Pidurangala Rock suitable for a sunrise climb with an 8-year-old child? We want to know how challenging the upper boulder scramble is.',
        districtId: 'matale',
        districtName: 'Matale District',
        provinceId: 'CP',
        destinationSlug: 'pidurangala-rock',
        destinationName: 'Pidurangala Rock Sanctuary',
        trustLabel: 'Community Question',
        observedAt: now.subtract(const Duration(hours: 5)),
        expiresAt: null,
        isStale: false,
        freshnessLabel: 'Active Question',
        helpfulCount: 15,
        likeCount: 9,
        saveCount: 8,
        commentCount: 1,
        isQuestionResolved: true,
        createdAt: now.subtract(const Duration(hours: 5)),
        media: const [
          PostMediaModel(
            id: 'm103',
            mediaUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
            altText: 'Pidurangala summit looking out toward Sigiriya',
          ),
        ],
        comments: [
          PostCommentModel(
            id: 'cm104',
            authorName: 'Duminda Bandara',
            authorBadge: AuthorBadge.licensedGuide,
            commentText: 'First 70% is stone temple steps and easy. Final 15 mins requires navigating between large boulders where an 8yo will need a boost. Bring two headlamps and allow 50 mins. Very safe if not rushing.',
            isAcceptedAnswer: true,
            helpfulVotes: 24,
            createdAt: now.subtract(const Duration(hours: 4)),
          ),
        ],
      ),
      CommunityPostModel(
        id: 'c1000000-0000-0000-0000-000000000004',
        authorId: 'u1000000-0000-0000-0000-000000000006',
        authorName: 'Thulasi Vimalanathan',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
        authorBadge: AuthorBadge.communityExpert,
        authorBadgeDetail: 'Jaffna Heritage Fellow',
        postType: PostType.localNote,
        caption: 'Visiting Nallur Kandaswamy Kovil: evening puja at 17:00 is magnificent with traditional Nadaswaram bells. Men must be bare-chested to enter sanctum. Free footwear depository at south gate.',
        districtId: 'jaffna',
        districtName: 'Jaffna District',
        provinceId: 'NP',
        destinationSlug: 'nallur-kandaswamy-kovil',
        destinationName: 'Nallur Kandaswamy Golden Kovil',
        trustLabel: 'Local Cultural Expert Verified',
        observedAt: now.subtract(const Duration(hours: 8)),
        expiresAt: null,
        isStale: false,
        freshnessLabel: 'Active Note',
        helpfulCount: 38,
        likeCount: 22,
        saveCount: 41,
        commentCount: 0,
        createdAt: now.subtract(const Duration(hours: 8)),
        media: const [
          PostMediaModel(
            id: 'm104',
            mediaUrl: 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?auto=format&fit=crop&w=800&q=80',
            altText: 'Nallur Kandaswamy Kovil golden tower at dusk',
          ),
        ],
        comments: const [],
      ),
      CommunityPostModel(
        id: 'c1000000-0000-0000-0000-000000000005',
        authorId: 'u1000000-0000-0000-0000-000000000007',
        authorName: 'Ceylon Chauffeurs Guild',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=200&q=80',
        authorBadge: AuthorBadge.verifiedProvider,
        authorBadgeDetail: 'SLTDA Transport #CG-2026/102',
        postType: PostType.fieldReport,
        caption: 'Road Advisory - Ramboda Pass (A5 Gampola to Nuwara Eliya): Road clear after morning drizzle. Mountain pass speed 35 km/h. CMB to Nuwara Eliya travel time currently +25 mins.',
        districtId: 'nuwara-eliya',
        districtName: 'Nuwara Eliya District',
        provinceId: 'CP',
        destinationSlug: 'ramboda-falls-pass',
        destinationName: 'Ramboda Falls & Mountain Pass',
        trustLabel: 'Chauffeur Guild Fleet Telemetry',
        observedAt: now.subtract(const Duration(minutes: 45)),
        expiresAt: now.add(const Duration(hours: 2)),
        isStale: false,
        freshnessLabel: 'Fresh · Valid for 2h',
        helpfulCount: 31,
        likeCount: 14,
        saveCount: 12,
        commentCount: 0,
        createdAt: now.subtract(const Duration(minutes: 45)),
        media: const [
          PostMediaModel(
            id: 'm105',
            mediaUrl: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
            altText: 'Misty mountain road in Nuwara Eliya tea country',
          ),
        ],
        comments: const [],
      ),
      CommunityPostModel(
        id: 'c1000000-0000-0000-0000-000000000006',
        authorId: 'u1000000-0000-0000-0000-000000000008',
        authorName: 'Elena Rostova',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        authorBadge: AuthorBadge.verifiedVisitor,
        authorBadgeDetail: 'Highland Trekker',
        postType: PostType.video,
        caption: 'Blue express train clearing Nine Arch Viaduct in the misty highland morning! Watch with sound on for the echoing steam whistle.',
        districtId: 'badulla',
        districtName: 'Badulla District',
        provinceId: 'UP',
        destinationSlug: 'nine-arch-bridge',
        destinationName: 'Nine Arch Demodara Viaduct',
        trustLabel: 'Verified High-Altitude Video Capture',
        observedAt: now.subtract(const Duration(hours: 1)),
        expiresAt: null,
        isStale: false,
        freshnessLabel: 'Active Video',
        helpfulCount: 64,
        likeCount: 42,
        saveCount: 55,
        commentCount: 8,
        createdAt: now.subtract(const Duration(hours: 1)),
        media: const [
          PostMediaModel(
            id: 'm106',
            mediaUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            mediaType: 'video',
            durationSeconds: 18,
            thumbnailUrl: 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80',
            altText: 'Blue train crossing Nine Arch Bridge',
            fileName: 'Nine_Arch_Blue_Train.mp4',
            fileSize: '24.2 MB',
          ),
        ],
        comments: const [],
      ),
    ]);
  }

  List<CommunityPostModel> filterPosts({
    PostType? postType,
    String? districtId,
    String? searchQuery,
  }) {
    return _allPosts.where((p) {
      if (postType != null && p.postType != postType) return false;
      if (districtId != null && districtId.isNotEmpty && p.districtId != districtId.toLowerCase()) return false;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchCaption = p.caption.toLowerCase().contains(q);
        final matchDest = p.destinationName?.toLowerCase().contains(q) ?? false;
        final matchDist = p.districtName.toLowerCase().contains(q);
        final matchAuthor = p.authorName.toLowerCase().contains(q);
        if (!matchCaption && !matchDest && !matchDist && !matchAuthor) return false;
      }
      return true;
    }).toList();
  }

  bool isSaved(String postId) => _savedPostIds.contains(postId);
  bool isHelpful(String postId) => _helpfulPostIds.contains(postId);
  bool isLiked(String postId) => _likedPostIds.contains(postId);

  void toggleSave(String postId) {
    final idx = _allPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final p = _allPosts[idx];
      final willSave = !_savedPostIds.contains(postId);
      if (willSave) {
        _savedPostIds.add(postId);
        _allPosts[idx] = p.copyWith(saveCount: p.saveCount + 1);
      } else {
        _savedPostIds.remove(postId);
        _allPosts[idx] = p.copyWith(saveCount: (p.saveCount - 1).clamp(0, 9999));
      }
      notifyListeners();
    }
  }

  void toggleHelpful(String postId) {
    final idx = _allPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final p = _allPosts[idx];
      final willAdd = !_helpfulPostIds.contains(postId);
      if (willAdd) {
        _helpfulPostIds.add(postId);
        _allPosts[idx] = p.copyWith(helpfulCount: p.helpfulCount + 1);
      } else {
        _helpfulPostIds.remove(postId);
        _allPosts[idx] = p.copyWith(helpfulCount: (p.helpfulCount - 1).clamp(0, 9999));
      }
      notifyListeners();
    }
  }

  void toggleLike(String postId) {
    final idx = _allPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final p = _allPosts[idx];
      final willLike = !_likedPostIds.contains(postId);
      if (willLike) {
        _likedPostIds.add(postId);
        _allPosts[idx] = p.copyWith(likeCount: p.likeCount + 1);
      } else {
        _likedPostIds.remove(postId);
        _allPosts[idx] = p.copyWith(likeCount: (p.likeCount - 1).clamp(0, 9999));
      }
      notifyListeners();
    }
  }

  void addComment(String postId, String commentText, {String authorName = 'Dinusha'}) {
    final idx = _allPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final p = _allPosts[idx];
      final newComment = PostCommentModel(
        id: 'cm-${DateTime.now().millisecondsSinceEpoch}',
        authorName: authorName,
        authorBadge: AuthorBadge.traveller,
        commentText: commentText,
        createdAt: DateTime.now(),
      );
      final updatedComments = List<PostCommentModel>.from(p.comments)..add(newComment);
      _allPosts[idx] = p.copyWith(
        comments: updatedComments,
        commentCount: updatedComments.length,
      );
      notifyListeners();
    }
  }

  void markAcceptedAnswer(String postId, String commentId) {
    final idx = _allPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final p = _allPosts[idx];
      final updatedComments = p.comments.map((c) {
        if (c.id == commentId) {
          return PostCommentModel(
            id: c.id,
            authorName: c.authorName,
            authorBadge: c.authorBadge,
            commentText: c.commentText,
            isAcceptedAnswer: true,
            helpfulVotes: c.helpfulVotes + 1,
            createdAt: c.createdAt,
          );
        }
        return c;
      }).toList();

      _allPosts[idx] = p.copyWith(
        comments: updatedComments,
        isQuestionResolved: true,
      );
      notifyListeners();
    }
  }

  void createPost({
    required PostType postType,
    required String caption,
    required String districtId,
    String? destinationName,
    List<String> mediaUrls = const [],
    String mediaType = 'image',
    int? durationSeconds,
    String? thumbnailUrl,
    String? fileName,
    String? fileSize,
    int? expiryHours,
  }) {
    final now = DateTime.now();
    DateTime? expiresAt;
    if (postType == PostType.fieldReport) {
      expiresAt = now.add(Duration(hours: expiryHours ?? 4));
    }

    final newPost = CommunityPostModel(
      id: 'c-${now.millisecondsSinceEpoch}',
      authorId: 'u-current-user',
      authorName: 'Dinusha',
      authorBadge: AuthorBadge.traveller,
      postType: postType,
      caption: caption,
      districtId: districtId.toLowerCase(),
      districtName: '${districtId[0].toUpperCase()}${districtId.substring(1)} District',
      provinceId: 'CP',
      destinationName: destinationName ?? '${districtId[0].toUpperCase()}${districtId.substring(1)} Landmark',
      trustLabel: 'Community Observation',
      observedAt: now,
      expiresAt: expiresAt,
      isStale: false,
      freshnessLabel: postType == PostType.fieldReport ? 'Fresh · Valid for ${expiryHours ?? 4}h' : 'Active Note',
      createdAt: now,
      media: mediaUrls
          .map((url) => PostMediaModel(
                id: 'm-${now.millisecondsSinceEpoch}',
                mediaUrl: url,
                mediaType: mediaType,
                durationSeconds: durationSeconds,
                thumbnailUrl: thumbnailUrl,
                fileName: fileName,
                fileSize: fileSize,
              ))
          .toList(),
    );

    _allPosts.insert(0, newPost);
    notifyListeners();
  }

  PlaceSignalModel getPlaceSignal(String destinationName) {
    final matching = _allPosts.where(
      (p) => (p.destinationName ?? '').toLowerCase().contains(destinationName.toLowerCase()),
    ).toList();

    final activeReports = matching.where((p) => p.postType == PostType.fieldReport && !p.isStale).length;
    final notes = matching.where((p) => p.postType == PostType.localNote).length;
    final unanswered = matching.where((p) => p.postType == PostType.question && !p.isQuestionResolved).length;

    return PlaceSignalModel(
      destinationName: destinationName,
      districtName: matching.isNotEmpty ? matching.first.districtName : 'Cultural Triangle',
      recentNotesCount: notes,
      unansweredQuestionsCount: unanswered,
      activeFieldReportsCount: activeReports,
      latestObservation: matching.isNotEmpty ? matching.first.caption : 'Trail open and clear.',
      latestObservedAt: matching.isNotEmpty ? matching.first.observedAt : DateTime.now(),
      trailOrRoadStatus: activeReports > 0 ? 'CLEAR_AND_DRY' : 'NORMAL',
      crowdLevel: 'LOW_AT_DAWN',
      freshnessStatus: activeReports > 0 ? 'FRESH' : 'MODERATE',
    );
  }

  ItineraryAdditionValidationResult validateItineraryAddition({
    required String destinationName,
    int dayNumber = 1,
    int requestedStartHour = 10,
    int dwellDurationMins = 90,
  }) {
    final endDecimal = requestedStartHour + (dwellDurationMins / 60.0);
    final isFeasible = endDecimal <= 17.5;

    final conflicts = <String>[];
    String recommendation;

    if (!isFeasible) {
      conflicts.add(
        'Stop ends at ${endDecimal.toInt()}:${((endDecimal % 1) * 60).toInt().toString().padLeft(2, '0')}, exceeding gate closure (17:30).',
      );
      recommendation = 'Shift arrival to 14:00 or schedule for Day 2 morning.';
    } else {
      recommendation = 'Feasible: 45m transit + 25m road buffer fits Day $dayNumber schedule.';
    }

    return ItineraryAdditionValidationResult(
      isFeasible: isFeasible,
      destinationName: destinationName,
      proposedDayNumber: dayNumber,
      proposedStartTime: '${requestedStartHour.toString().padLeft(2, '0')}:00',
      proposedEndTime: '${endDecimal.toInt().toString().padLeft(2, '0')}:${((endDecimal % 1) * 60).toInt().toString().padLeft(2, '0')}',
      roadBufferMins: 25,
      transitDurationMins: 45,
      conflicts: conflicts,
      recommendation: recommendation,
    );
  }
}
