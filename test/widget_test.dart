// 6 国投放冒烟测试：验证每个品牌入口的默认语种与品牌码注入正确。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:talevra/main.dart';

void main() {
  group('TalevraApp 六国默认语种', () {
    const cases = <(String, List<Locale>, Locale, String)>[
      ('brand_us', [Locale('en')], Locale('en'), 'Home'),
      ('brand_br', [Locale('pt'), Locale('en')], Locale('pt'), 'Início'),
      ('brand_mx', [Locale('es'), Locale('en')], Locale('es'), 'Inicio'),
      ('brand_id', [Locale('id'), Locale('en')], Locale('id'), 'Beranda'),
      ('brand_jp', [Locale('ja'), Locale('en')], Locale('ja'), 'ホーム'),
      ('brand_kr', [Locale('ko'), Locale('en')], Locale('ko'), '홈'),
    ];

    for (final (code, locales, def, homeTab) in cases) {
      testWidgets('$code 默认 ${def.toLanguageTag()}', (tester) async {
        await tester.pumpWidget(TalevraApp(
          brandCode: code,
          supportedLocales: locales,
          defaultLocale: def,
        ));
        await tester.pumpAndSettle();
        expect(find.text(homeTab), findsOneWidget, reason: '$code 首页文案');
        expect(find.textContaining(code), findsOneWidget, reason: '$code 品牌码');
      });
    }
  });
}
