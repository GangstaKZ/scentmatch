import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scentmatch/app.dart';
import 'package:scentmatch/core/providers.dart';
import 'package:scentmatch/core/router/app_router.dart';
import 'package:scentmatch/features/catalog/data/catalog_repository.dart';
import 'package:scentmatch/features/catalog/domain/perfume.dart';
import 'package:scentmatch/features/catalog/presentation/perfume_screen.dart';
import 'package:scentmatch/features/onboarding/presentation/quiz_screen.dart';

const quiz = {
  'gender': 'unisex',
  'age': '25-34',
  'family': 'woody',
  'budget': 'luxury',
  'season': 'autumn',
  'longevity': 'medium',
  'mood': 'calm'
};

class FixtureCatalogRepository implements CatalogRepository {
  @override
  Future<List<Perfume>> load() async =>
      (jsonDecode(File('assets/data/perfumes.json').readAsStringSync()) as List)
          .map((e) => Perfume.fromJson(
              e['id'] as String, Map<String, dynamic>.from(e as Map)))
          .toList();
}

Future<ProviderContainer> launch(WidgetTester tester,
    {bool completed = false}) async {
  if (Platform.environment['EXPORT_PREVIEWS'] == '1') {
    await tester.runAsync(() async {
      for (final entry in {
        'Manrope': 'assets/fonts/Manrope.ttf',
        'CormorantGaramond': 'assets/fonts/CormorantGaramond.ttf',
        'MaterialIcons': 'fonts/MaterialIcons-Regular.otf'
      }.entries) {
        final loader = FontLoader(entry.key)
          ..addFont(rootBundle.load(entry.value));
        await loader.load();
      }
    });
  }
  SharedPreferences.setMockInitialValues(completed
      ? {
          'welcomeSeen': true,
          'profile_demo': jsonEncode({
            'name': 'Исследователь',
            'email': '',
            'createdAt': '2026-10-13T00:00:00Z',
            'quizAnswers': quiz,
            'isPro': false
          })
        }
      : {});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    preferencesProvider.overrideWithValue(prefs),
    catalogRepositoryProvider.overrideWithValue(FixtureCatalogRepository())
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: container, child: const ScentMatchApp()));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('first launch completes all 7 questions and restores the profile',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = await launch(tester);
    await tester.ensureVisible(find.text('Найти свой аромат'));
    await tester.tap(find.text('Найти свой аромат'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsOneWidget);
    for (var i = 0; i < quizQuestions.length; i++) {
      final q = quizQuestions[i];
      final tile = find.byWidgetPredicate(
          (w) => w is RadioListTile<String> && w.value == quiz[q.key]);
      await tester.ensureVisible(tile);
      await tester.tap(tile);
      await tester.pumpAndSettle();
      final button =
          find.text(i == 6 ? 'Показать мои рекомендации' : 'Продолжить');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }
    expect(container.read(profileProvider).valueOrNull!.quizAnswers, quiz);
    expect(find.text('Искусство быть собой'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final json = container.read(preferencesProvider).getString('profile_demo')!;
    expect((jsonDecode(json) as Map)['quizAnswers'], quiz);
  });
  testWidgets('search, wishlist, notes, reviews and locale work together',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = await launch(tester, completed: true);
    container.read(routerProvider).go('/search');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Sauvage');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sauvage').last);
    await tester.tap(find.text('Sauvage').last);
    await tester.pumpAndSettle();
    expect(find.byType(PerfumeScreen), findsOneWidget);
    final wishlist = find.text('Хочу попробовать · Wishlist');
    await tester.ensureVisible(wishlist);
    await tester.tap(wishlist);
    await tester.pumpAndSettle();
    expect(container.read(collectionProvider).valueOrNull!.single.perfumeId,
        'dior-sauvage');
    final edit = find.text('В Wishlist · изменить');
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    // The opening button remains busy until its modal is dismissed.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField), 'Для прохладного вечера');
    await tester.tap(find.byTooltip('4/5'));
    await tester.pump();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(container.read(collectionProvider).valueOrNull!.single.rating, 4);
    final write = find.text('Написать');
    await tester.scrollUntilVisible(write, 400,
        scrollable: find
            .descendant(
                of: find.byType(PerfumeScreen),
                matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    await tester.tap(write);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextField), 'Свежий старт, тёплая база.');
    await tester.pump();
    await tester.tap(find.text('Опубликовать'));
    await tester.pumpAndSettle();
    expect(find.text('Свежий старт, тёплая база.'), findsOneWidget);
    container.read(routerProvider).go('/collection');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wishlist'));
    await tester.pumpAndSettle();
    expect(find.text('Для прохладного вечера'), findsOneWidget);
    container.read(routerProvider).go('/profile');
    await tester.pumpAndSettle();
    await container
        .read(settingsProvider.notifier)
        .update(locale: 'en', dark: false);
    await tester.pumpAndSettle();
    expect(find.text('My profile'), findsOneWidget);
    expect(Theme.of(tester.element(find.text('My profile'))).brightness,
        Brightness.light);
    expect(tester.takeException(), isNull);
  });
  testWidgets('screens render at phone width and export optional previews',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = await launch(tester, completed: true);
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child:
            RepaintBoundary(key: boundaryKey, child: const ScentMatchApp())));
    for (final route in [
      '/home',
      '/search',
      '/perfume/byredo-gypsy',
      '/collection',
      '/profile',
      '/pro'
    ]) {
      container.read(routerProvider).go(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
      if (Platform.environment['EXPORT_PREVIEWS'] == '1') {
        final boundary = boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final directory = Directory('preview')..createSync();
          await File('${directory.path}/${route.split('/').last}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
  });
}
