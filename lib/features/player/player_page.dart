import 'package:flutter/material.dart';

/// 短剧播放页：占位。dramaId 由路由参数注入，
/// 后续接视频播放器、剧集列表、充值等。
class PlayerPage extends StatelessWidget {
  final String dramaId;
  const PlayerPage({super.key, required this.dramaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player')),
      body: Center(child: Text('播放占位 · dramaId = $dramaId')),
    );
  }
}
