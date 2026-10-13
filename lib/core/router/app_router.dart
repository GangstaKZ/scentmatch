import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';
import '../localization/app_strings.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/quiz_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/catalog/presentation/search_screen.dart';
import '../../features/catalog/presentation/perfume_screen.dart';
import '../../features/collection/presentation/collection_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/subscription/presentation/pro_screen.dart';
import '../../shared/widgets/async_panel.dart';

class RouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefresh();
  ref.listen(identityProvider, (_, __) => refresh.refresh());
  ref.listen(profileProvider, (_, __) => refresh.refresh());
  ref.listen(settingsProvider, (_, __) => refresh.refresh());
  final router = GoRouter(
      initialLocation: '/home',
      refreshListenable: refresh,
      redirect: (context, state) {
        final location = state.matchedLocation;
        if (!ref.read(settingsProvider).welcomeSeen) {
          return location == '/welcome' ? null : '/welcome';
        }
        final identity = ref.read(identityProvider);
        if (identity.isLoading || identity.hasError) {
          return location == '/loading' ? null : '/loading';
        }
        if (identity.valueOrNull == null) {
          return location == '/auth' ? null : '/auth';
        }
        final profile = ref.read(profileProvider);
        if (profile.isLoading || profile.hasError) {
          return location == '/loading' ? null : '/loading';
        }
        if (profile.valueOrNull?.quizComplete != true) {
          return location == '/quiz' ? null : '/quiz';
        }
        if (['/welcome', '/auth', '/loading', '/'].contains(location)) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
        GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
        GoRoute(path: '/loading', builder: (_, __) => const LoadingScreen()),
        GoRoute(path: '/quiz', builder: (_, __) => const QuizScreen()),
        GoRoute(
            path: '/perfume/:id',
            builder: (_, state) => PerfumeScreen(
                id: state.pathParameters['id']!,
                heroTag: state.extra as String?)),
        GoRoute(path: '/pro', builder: (_, __) => const ProScreen()),
        StatefulShellRoute.indexedStack(
            builder: (_, __, shell) => AppShell(shell: shell),
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(path: '/home', builder: (_, __) => const HomeScreen())
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                    path: '/search', builder: (_, __) => const SearchScreen())
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                    path: '/collection',
                    builder: (_, __) => const CollectionScreen())
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                    path: '/profile', builder: (_, __) => const ProfileScreen())
              ]),
            ]),
      ],
      errorBuilder: (context, state) => Scaffold(
          appBar: AppBar(),
          body: EmptyPanel(
              icon: Icons.explore_off_outlined,
              title: context.tr('Страница не найдена', 'Page not found'),
              subtitle: context.tr(
                  'Вернитесь к ароматам.', 'Return to your fragrances.'),
              action: FilledButton(
                  onPressed: () => context.go('/home'),
                  child: Text(context.tr('На главную', 'Home'))))));
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;
  @override
  Widget build(BuildContext context) => Scaffold(
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000), child: shell)),
      bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: context.tr('Главная', 'Home')),
            NavigationDestination(
                icon: const Icon(Icons.search),
                label: context.tr('Поиск', 'Search')),
            NavigationDestination(
                icon: const Icon(Icons.inventory_2_outlined),
                selectedIcon: const Icon(Icons.inventory_2),
                label: context.tr('Коллекция', 'Collection')),
            NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: context.tr('Профиль', 'Profile'))
          ]));
}

class LoadingScreen extends ConsumerWidget {
  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failed = ref.watch(identityProvider).hasError ||
        ref.watch(profileProvider).hasError;
    return Scaffold(
        body: Center(
            child: failed
                ? EmptyPanel(
                    icon: Icons.cloud_off_outlined,
                    title: context.tr('Не удалось открыть профиль',
                        'Unable to open your profile'),
                    subtitle: context.tr(
                        'Проверьте подключение и попробуйте снова.',
                        'Check your connection and try again.'),
                    action: FilledButton(
                        onPressed: () {
                          ref.invalidate(identityProvider);
                          ref.invalidate(profileProvider);
                        },
                        child: Text(context.tr('Повторить', 'Retry'))))
                : const CircularProgressIndicator()));
  }
}
