import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talevra/app/bootstrap/app_initializer.dart';
import 'package:talevra/app/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: .86,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait<void>([AppInitializer.init(), _controller.forward()]);
    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(gradient: AppPalette.gradient),
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 28,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 48,
                    color: AppPalette.yellow,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Talevra',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stories worth staying for',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .72),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 34),
                Container(
                  width: 34,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppPalette.yellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
