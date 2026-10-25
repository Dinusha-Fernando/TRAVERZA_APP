import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/widgets/creative_experience_tab_switcher.dart';
import 'package:mobile/features/messenger/presentation/widgets/creative_experience_share_sheet.dart';
import 'package:mobile/features/messenger/services/messenger_service.dart';
import 'package:mobile/features/messenger/presentation/conversation_screen.dart';
import 'package:mobile/features/community/presentation/widgets/media_gallery_picker_modal.dart';

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
  0x89, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
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

  Widget buildTestable(Widget child) {
    return MaterialApp(
      theme: AppTheme.theme,
      home: Scaffold(body: child),
    );
  }

  group('Creative Travel Experience Tab Tests', () {
    testWidgets('CreativeExperienceTabSwitcher renders tabs with badges and triggers callback', (tester) async {
      int selected = 0;

      await tester.pumpWidget(
        buildTestable(
          StatefulBuilder(
            builder: (ctx, setState) {
              return CreativeExperienceTabSwitcher(
                selectedIndex: selected,
                onTabChanged: (idx) {
                  setState(() => selected = idx);
                },
                items: const [
                  CreativeExperienceTabItem(
                    label: 'Gallery',
                    icon: Icons.photo_camera_back_rounded,
                    badge: 'PHOTOS',
                  ),
                  CreativeExperienceTabItem(
                    label: 'Videos',
                    icon: Icons.videocam_rounded,
                    badge: '4K',
                  ),
                  CreativeExperienceTabItem(
                    label: 'Files',
                    icon: Icons.folder_open_rounded,
                    badge: 'DOCS',
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Videos'), findsOneWidget);
      expect(find.text('Files'), findsOneWidget);
      expect(find.text('PHOTOS'), findsOneWidget);
      expect(find.text('4K'), findsOneWidget);
      expect(find.text('DOCS'), findsOneWidget);

      // Tap on Videos tab
      await tester.tap(find.text('Videos'));
      await tester.pumpAndSettle();
      expect(selected, 1);

      // Tap on Files tab
      await tester.tap(find.text('Files'));
      await tester.pumpAndSettle();
      expect(selected, 2);
    });

    testWidgets('CreativeExperienceShareSheet shares user gallery photos, user videos, travel files, and custom notes', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool sent = false;

      await tester.pumpWidget(
        buildTestable(
          CreativeExperienceShareSheet(
            conversationId: 'cv-101',
            onMessageSent: () {
              sent = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and user vault badge
      expect(find.text('Share Travel Experience'), findsOneWidget);
      expect(find.text('USER VAULT'), findsOneWidget);

      // Check the 4 tabs
      expect(find.descendant(of: find.byType(CreativeExperienceTabSwitcher), matching: find.text('Gallery')), findsOneWidget);
      expect(find.descendant(of: find.byType(CreativeExperienceTabSwitcher), matching: find.text('Videos')), findsOneWidget);
      expect(find.descendant(of: find.byType(CreativeExperienceTabSwitcher), matching: find.text('Files')), findsOneWidget);
      expect(find.descendant(of: find.byType(CreativeExperienceTabSwitcher), matching: find.text('Notes')), findsOneWidget);

      // In initial Gallery tab, verify no default mock photos and real action controls
      expect(find.text('IMG_20261025_NineArch_Dawn.jpg'), findsNothing);
      expect(find.text('IMG_20261024_Pidurangala_Sunrise.jpg'), findsNothing);
      expect(find.text('Capture'), findsOneWidget);
      expect(find.text('Open Gallery'), findsOneWidget);
      expect(find.text('No photos selected yet'), findsOneWidget);

      // Tap to switch to Videos tab
      await tester.tap(find.descendant(of: find.byType(CreativeExperienceTabSwitcher), matching: find.text('Videos')));
      await tester.pumpAndSettle();

      expect(find.text('VID_20261024_BlueTrain_Viaduct.mp4'), findsNothing);
      expect(find.text('VID_20261023_Minneriya_ElephantHerd.mp4'), findsNothing);
      expect(find.text('Record'), findsOneWidget);
      expect(find.text('Open Videos'), findsOneWidget);
      expect(find.text('No video clips selected yet'), findsOneWidget);

      // Tap to switch to Files tab
      await tester.tap(find.descendant(of: find.byType(CreativeExperienceTabSwitcher), matching: find.text('Files')));
      await tester.pumpAndSettle();

      expect(find.text('e-Visa_SriLanka_2026.pdf'), findsNothing);
      expect(find.text('Browse Device Files (PDF, GPX, Tickets)'), findsOneWidget);
      expect(find.text('Attach'), findsOneWidget);
      expect(find.text('No files attached yet'), findsOneWidget);

      // Tap to switch to Notes tab (Live Composer)
      await tester.tap(find.descendant(of: find.byType(CreativeExperienceTabSwitcher), matching: find.text('Notes')));
      await tester.pumpAndSettle();

      expect(find.text('EXPERIENCE TOPIC'), findsOneWidget);
      expect(find.text('Trail Condition'), findsOneWidget);
      expect(find.text('Transport Tip'), findsOneWidget);
      expect(find.text('LIVE DISPATCH'), findsOneWidget);
      expect(find.text('Dispatch Experience Note'), findsOneWidget);

      // Tap dispatch experience note to send
      await tester.tap(find.text('Dispatch Experience Note'));
      await tester.pumpAndSettle();

      expect(sent, isTrue);
    });

    testWidgets('ConversationScreen renders document file attachment card and opens file details dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      MessengerService.instance.sendFileMessage(
        conversationId: 'cv-101',
        fileUrl: '/storage/emulated/0/Documents/Travel/e-Visa_SriLanka_2026.pdf',
        fileName: 'e-Visa_SriLanka_2026.pdf',
        fileSize: '1.4 MB',
        fileExtension: 'PDF',
        caption: 'Official Sri Lanka ETA Authorization',
      );

      await tester.pumpWidget(
        buildTestable(
          const ConversationScreen(conversationId: 'cv-101'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('e-Visa_SriLanka_2026.pdf'), findsWidgets);
      expect(find.text('PDF'), findsWidgets);
      expect(find.text('1.4 MB'), findsWidgets);

      // Tapping the file triggers real file opening / details dialog
      await tester.tap(find.text('e-Visa_SriLanka_2026.pdf').first);
      await tester.pumpAndSettle();

      expect(find.text('FILE STORAGE PATH'), findsOneWidget);
      expect(find.text('Open System App'), findsOneWidget);
      expect(find.text('Copy Path'), findsOneWidget);
    });

    testWidgets('MediaGalleryPickerModal renders upgraded creative experience tab switcher', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestable(
          const MediaGalleryPickerModal(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CreativeExperienceTabSwitcher), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Videos'), findsOneWidget);
      expect(find.text('Open Files'), findsOneWidget);
      expect(find.descendant(of: find.byType(CreativeExperienceTabSwitcher), matching: find.text('HDR')), findsOneWidget);
      expect(find.descendant(of: find.byType(CreativeExperienceTabSwitcher), matching: find.text('4K')), findsOneWidget);
      expect(find.descendant(of: find.byType(CreativeExperienceTabSwitcher), matching: find.text('STORAGE')), findsOneWidget);

      // Switch to Videos tab
      await tester.tap(find.text('Videos'));
      await tester.pumpAndSettle();

      expect(find.text('Ella Valley'), findsOneWidget);

      // Switch to Open Files tab
      await tester.tap(find.text('Open Files'));
      await tester.pumpAndSettle();

      expect(find.textContaining('VID_20261023'), findsWidgets);
    });
  });
}
