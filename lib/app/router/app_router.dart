import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talevra/features/home/home_page.dart';
import 'package:talevra/features/player/player_page.dart';
import 'package:talevra/features/earning/earning_page.dart';
import 'package:talevra/features/home/home_tab.dart';
import 'package:talevra/l10n/app_localizations.dart';

/// 全局路由。短剧 App 典型结构：
///   /              → HomePage（带底部导航：首页/书库/设置）
///   /player/:id    → 播放页
/// 后续新增详情、登录等页面在此挂载。
class AppRouter {
  AppRouter._();

  static final GoRouter config = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomePage(
          initialTab: state.uri.queryParameters['tab'] == 'library' ? 2 : 0,
        ),
      ),
      GoRoute(
        path: '/player/:dramaId',
        builder: (context, state) =>
            PlayerPage(dramaId: state.pathParameters['dramaId']!),
      ),
      GoRoute(
        path: '/earning',
        builder: (context, state) => const EarningPage(),
      ),
      GoRoute(
        path: '/rankings',
        builder: (context, state) => const RankingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.routeNotFound(state.uri.toString()),
        ),
      ),
    ),
  );
}
