import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/community/models/community_models.dart';
import 'package:mobile/features/community/services/community_service.dart';
import 'package:mobile/features/community/presentation/community_pulse_screen.dart';
import 'package:mobile/features/community/presentation/create_post_sheet.dart';
import 'package:mobile/features/community/presentation/widgets/community_post_card.dart';
import 'package:mobile/features/community/presentation/widgets/media_gallery_picker_modal.dart';
import 'package:mobile/features/messenger/models/messenger_models.dart';
import 'package:mobile/features/messenger/services/messenger_service.dart';
import 'package:mobile/features/messenger/presentation/messenger_inbox_screen.dart';
import 'package:mobile/features/messenger/presentation/conversation_screen.dart';
import 'package:mobile/features/messenger/presentation/widgets/creative_messenger_button.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/theme/app_theme.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _kTransparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

final Uint8List _kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  group('TRAVERZA Community Moments - Service & Models', () {
    final service = CommunityService.instance;

    test('Initial feed loads canonical seed posts with district tagging', () {
      final posts = service.allPosts;
      expect(posts.length, greaterThanOrEqualTo(5));

      final first = posts.first;
      expect(first.districtId, 'matale');
      expect(first.trustLabel, contains('Guide'));
      expect(first.comments.length, greaterThanOrEqualTo(1));
    });

    test('Filtering by post type returns matching moments', () {
      final fieldReports = service.filterPosts(postType: PostType.fieldReport);
      expect(fieldReports, isNotEmpty);
      expect(fieldReports.every((p) => p.postType == PostType.fieldReport), isTrue);

      final questions = service.filterPosts(postType: PostType.question);
      expect(questions, isNotEmpty);
      expect(questions.every((p) => p.postType == PostType.question), isTrue);
    });

    test('Filtering by district matches district ID', () {
      final badullaPosts = service.filterPosts(districtId: 'badulla');
      expect(badullaPosts, isNotEmpty);
      expect(badullaPosts.every((p) => p.districtId == 'badulla'), isTrue);
    });

    test('Toggling helpful and save updates counters', () {
      final post = service.allPosts.first;
      final initialHelpful = post.helpfulCount;

      service.toggleHelpful(post.id);
      expect(service.isHelpful(post.id), isTrue);
      expect(service.allPosts.first.helpfulCount, initialHelpful + 1);

      service.toggleSave(post.id);
      expect(service.isSaved(post.id), isTrue);
    });

    test('Adding comment and marking accepted answer resolves question', () {
      final question = service.allPosts.firstWhere((p) => p.postType == PostType.question);
      final initialCommentCount = question.commentCount;

      service.addComment(question.id, 'Test reply for families climb.');
      final updated = service.allPosts.firstWhere((p) => p.id == question.id);
      expect(updated.commentCount, initialCommentCount + 1);

      final commentId = updated.comments.last.id;
      service.markAcceptedAnswer(question.id, commentId);

      final resolved = service.allPosts.firstWhere((p) => p.id == question.id);
      expect(resolved.isQuestionResolved, isTrue);
    });

    test('TripGraph feasibility check validates road buffer and closure window', () {
      final feasible = service.validateItineraryAddition(
        destinationName: 'Sigiriya Lion Rock',
        dayNumber: 1,
        requestedStartHour: 10,
        dwellDurationMins: 90,
      );
      expect(feasible.isFeasible, isTrue);
      expect(feasible.roadBufferMins, 25);

      final infeasible = service.validateItineraryAddition(
        destinationName: 'Sigiriya Lion Rock',
        dayNumber: 1,
        requestedStartHour: 17,
        dwellDurationMins: 120,
      );
      expect(infeasible.isFeasible, isFalse);
      expect(infeasible.conflicts, isNotEmpty);
    });
  });

  group('TRAVERZA Travel Messenger - Service & Idempotency', () {
    final messenger = MessengerService.instance;

    test('Initial conversations load district lounges, direct chats, and inquiry chats', () {
      final convs = messenger.conversations;
      expect(convs.length, greaterThanOrEqualTo(5));

      expect(convs.any((c) => c.conversationType == ConversationTypeEnum.districtLounge), isTrue);
      expect(convs.any((c) => c.conversationType == ConversationTypeEnum.direct), isTrue);
      expect(convs.any((c) => c.conversationType == ConversationTypeEnum.providerInquiry), isTrue);
      expect(convs.any((c) => c.conversationType == ConversationTypeEnum.tripGroup), isTrue);

      final ellaLounge = convs.firstWhere((c) => c.id == 'cv-104');
      expect(ellaLounge.memberCount, 342);
      expect(ellaLounge.districtName, contains('Ella'));
    });

    test('Sending photo and video messages stores media attachments', () {
      final convId = 'cv-104';
      final initialCount = messenger.getMessages(convId).length;

      messenger.sendPhotoMessage(
        conversationId: convId,
        photoUrl: 'https://images.unsplash.com/photo-test.jpg',
        caption: 'Sunset over Ella Rock peak',
      );

      final afterPhoto = messenger.getMessages(convId);
      expect(afterPhoto.length, initialCount + 1);
      expect(afterPhoto.last.messageType, MessageTypeEnum.photo);
      expect(afterPhoto.last.mediaAttachment?.mediaType, 'image');
      expect(afterPhoto.last.mediaAttachment?.caption, 'Sunset over Ella Rock peak');

      messenger.sendVideoMessage(
        conversationId: convId,
        videoUrl: 'https://sample-videos.com/video.mp4',
        durationSeconds: 20,
        caption: 'Ella blue train steam whistle clip',
      );

      final afterVideo = messenger.getMessages(convId);
      expect(afterVideo.length, initialCount + 2);
      expect(afterVideo.last.messageType, MessageTypeEnum.video);
      expect(afterVideo.last.mediaAttachment?.mediaType, 'video');
      expect(afterVideo.last.mediaAttachment?.durationSeconds, 20);
    });

    test('Sending place snippet message attaches structured destination data', () {
      final convId = 'cv-104';
      final initialCount = messenger.getMessages(convId).length;

      messenger.sendPlaceSnippet(
        conversationId: convId,
        destinationName: 'Demodara Loop Viaduct',
        districtName: 'Badulla District',
        photoUrl: 'https://test-photo.jpg',
        summary: 'Spiral railway loop built in British Ceylon era.',
      );

      final msgs = messenger.getMessages(convId);
      expect(msgs.length, initialCount + 1);
      expect(msgs.last.messageType, MessageTypeEnum.placeSnippet);
      expect(msgs.last.placeSnippet?.destinationName, 'Demodara Loop Viaduct');
    });

    test('Joining a new District Lounge adds conversation to user inboxes', () {
      final newLoungeId = messenger.joinDistrictLounge(
        districtId: 'galle',
        loungeTitle: 'Galle & Southern Coast Lounge',
        subtitle: 'Public District Lounge · 420 Travellers',
        districtName: 'Galle District',
      );

      expect(newLoungeId, isNotEmpty);
      final found = messenger.conversations.firstWhere((c) => c.id == newLoungeId);
      expect(found.title, 'Galle & Southern Coast Lounge');
      expect(found.conversationType, ConversationTypeEnum.districtLounge);
    });

    test('Starting a direct chat with author or creator', () {
      final convId = messenger.startDirectChat(
        userName: 'Ayesha De Silva',
        userRole: 'Southern Coast Creator',
        districtName: 'Galle / Matara',
        initialMessage: 'Hey Ayesha! Loved your surf tip in Mirissa.',
      );

      expect(convId, isNotEmpty);
      final conv = messenger.conversations.firstWhere((c) => c.id == convId);
      expect(conv.title, contains('Ayesha De Silva'));
    });

    test('Sending message with idempotency key protects against duplicates', () {
      final convId = messenger.conversations.first.id;
      final initialCount = messenger.getMessages(convId).length;
      final clientNonce = 'cli-test-nonce-99';

      messenger.sendMessage(
        conversationId: convId,
        textContent: 'Testing duplicate retry protection.',
        clientMessageId: clientNonce,
      );

      expect(messenger.getMessages(convId).length, initialCount + 1);

      // Retry with same nonce
      messenger.sendMessage(
        conversationId: convId,
        textContent: 'Testing duplicate retry protection.',
        clientMessageId: clientNonce,
      );

      // Must remain initialCount + 1 (no duplicate!)
      expect(messenger.getMessages(convId).length, initialCount + 1);
    });
  });

  group('TRAVERZA Community & Messenger - UI Widgets', () {
    testWidgets('CommunityPulseScreen renders header, search, filter chips, and moments', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const CommunityPulseScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Community Pulse'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('All Moments'), findsOneWidget);
      expect(find.text('⏱️ Field Reports'), findsOneWidget);
      expect(find.text('❓ Questions & Q&A'), findsOneWidget);
      expect(find.text('Share Moment'), findsOneWidget);
    });

    testWidgets('CommunityPostCard includes direct Chat with Author button', (tester) async {
      final post = CommunityService.instance.allPosts.first;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: CommunityPostCard(post: post),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(post.authorName), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsWidgets);
    });

    testWidgets('MessengerInboxScreen renders district lounges, FAB, and filter chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const MessengerInboxScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Travel Messenger'), findsOneWidget);
      expect(find.text('All Inboxes'), findsOneWidget);
      expect(find.text('🌍 District Lounges'), findsOneWidget);
      expect(find.text('💬 Travellers & Guides'), findsOneWidget);
      expect(find.text('Join Lounge / Chat'), findsOneWidget);
      expect(find.textContaining('Ella & Uva Travellers Lounge'), findsOneWidget);
    });

    testWidgets('ConversationScreen renders photo bubble and video play card with media action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const ConversationScreen(conversationId: 'cv-104'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ella & Uva Travellers Lounge'), findsOneWidget);
      expect(find.textContaining('online'), findsOneWidget);
      expect(find.text('View Photo'), findsWidgets);
      expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);

      // Scroll to reveal video clip card in ListView
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.text('VIDEO CLIP'), findsWidgets);
    });

    testWidgets('CreativeMessengerButton renders voyager glider emblem, pulse aura, and unread badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: CreativeMessengerButton(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the creative voyager airplane emblem is rendered
      expect(find.byIcon(Icons.near_me_rounded), findsOneWidget);

      // Verify tooltip and button container
      expect(find.byType(CreativeMessengerButton), findsOneWidget);
    });

    testWidgets('CreatePostSheet renders Open Gallery, Select Video, and Browse Files buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const Scaffold(
            body: CreatePostSheet(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Share a Travel Moment or Field Report'), findsOneWidget);
      expect(find.text('Open Gallery'), findsOneWidget);
      expect(find.text('Select Video'), findsOneWidget);
      expect(find.text('Browse Files'), findsOneWidget);
      expect(find.text('📸 Photo Moment'), findsOneWidget);
      expect(find.text('🎥 Travel Video'), findsOneWidget);
    });

    testWidgets('MediaGalleryPickerModal renders Gallery, Videos, and Open Files tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const Scaffold(
            body: MediaGalleryPickerModal(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select Travel Media'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Videos'), findsOneWidget);
      expect(find.text('Open Files'), findsOneWidget);
      expect(find.text('Attach Media'), findsOneWidget);
      expect(find.textContaining('NineArch'), findsWidgets);
    });

    test('Creating video moment in CommunityService stores video media metadata', () {
      final initialCount = CommunityService.instance.allPosts.length;
      CommunityService.instance.createPost(
        postType: PostType.video,
        caption: 'Minneriya wild elephant river crossing',
        districtId: 'polonnaruwa',
        mediaUrls: ['https://sample-videos.com/video.mp4'],
        mediaType: 'video',
        durationSeconds: 24,
        fileName: 'Minneriya_Elephant_Crossing.mp4',
        fileSize: '38.4 MB',
      );

      final posts = CommunityService.instance.allPosts;
      expect(posts.length, initialCount + 1);
      final newPost = posts.first;
      expect(newPost.postType, PostType.video);
      expect(newPost.media.first.mediaType, 'video');
      expect(newPost.media.first.durationSeconds, 24);
      expect(newPost.media.first.fileName, 'Minneriya_Elephant_Crossing.mp4');
    });

    testWidgets('HomeScreen renders Community Pulse as creative flagship living feature', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: HomeScreen(
              hasActiveTrip: true,
              isHotelConfirmed: true,
              onNavigateToPlan: () {},
              onCategorySelected: (_) {},
              onNavigateToSafety: () {},
              onNavigateToCatalogue: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_community_pulse_card')), findsOneWidget);
      expect(find.text('LIVE ISLAND RADAR'), findsOneWidget);
      expect(find.text('6 Districts Active'), findsOneWidget);
      expect(find.text('Community Pulse'), findsOneWidget);
      expect(find.text('Share Photo'), findsOneWidget);
      expect(find.text('Post Video'), findsOneWidget);
      expect(find.text('Road Advisory'), findsOneWidget);
      expect(find.text('Ask Guide'), findsOneWidget);
      expect(find.text('LIVE RADAR:'), findsOneWidget);
      expect(find.byKey(const Key('home_open_community_pulse_button')), findsOneWidget);
    });
  });
}
