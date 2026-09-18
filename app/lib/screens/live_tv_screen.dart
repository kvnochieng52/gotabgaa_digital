import 'package:flutter/material.dart';

import '../models/settings.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hls_player.dart';

class LiveTVScreen extends StatefulWidget {
  final SiteSettings? settings;
  const LiveTVScreen({super.key, this.settings});

  @override
  State<LiveTVScreen> createState() => _LiveTVScreenState();
}

class _LiveTVScreenState extends State<LiveTVScreen> {
  SiteSettings? _settings;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    if (_settings == null) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await ApiService.instance.fetchSettings();
      if (mounted) setState(() => _settings = s);
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _settings?.stream;
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        foregroundColor: Colors.white,
        title: Text(s?.tvTitle ?? 'Gotabgaa TV'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: HlsPlayer(url: s?.tvStreamUrl, autoplay: true),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.brandRed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle,
                                  color: Colors.white, size: 8),
                              SizedBox(width: 6),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${s?.tvTitle ?? 'Gotabgaa TV'} · 24/7 broadcast',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Rotate your device for full-screen playback.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
