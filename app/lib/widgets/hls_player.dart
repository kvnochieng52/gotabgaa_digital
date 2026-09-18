import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';

/// Wraps [video_player] + [chewie] for a decent HLS live-stream experience.
/// Falls back to a friendly branded error card if the URL can't play.
class HlsPlayer extends StatefulWidget {
  final String? url;
  final bool autoplay;
  final double aspectRatio;
  const HlsPlayer({
    super.key,
    required this.url,
    this.autoplay = true,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<HlsPlayer> createState() => _HlsPlayerState();
}

class _HlsPlayerState extends State<HlsPlayer> {
  VideoPlayerController? _video;
  ChewieController? _chewie;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant HlsPlayer old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _dispose();
      _initialize();
    }
  }

  Future<void> _initialize() async {
    if (widget.url == null || widget.url!.isEmpty) {
      setState(() => _error = 'No stream URL configured yet.');
      return;
    }
    final url = widget.url!;
    if (url.startsWith('rtmp://')) {
      setState(() =>
          _error = 'RTMP URLs cannot play in a browser or mobile app. Use an HLS URL.');
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        formatHint: VideoFormat.hls,
      );
      await controller.initialize();
      if (!mounted) return;
      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: widget.autoplay,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        isLive: true,
        showControlsOnInitialize: false,
        placeholder: Container(color: Colors.black),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.brandRed,
          handleColor: AppColors.brandOrange,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
      );
      setState(() {
        _video = controller;
        _chewie = chewie;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Stream failed to load. Please try again.');
    }
  }

  void _dispose() {
    _chewie?.dispose();
    _video?.dispose();
    _video = null;
    _chewie = null;
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _FallbackPanel(message: _error!);
    }
    if (_chewie != null) {
      return Chewie(controller: _chewie!);
    }
    return const _FallbackPanel(message: 'Loading stream…', busy: true);
  }
}

class _FallbackPanel extends StatelessWidget {
  final String message;
  final bool busy;
  const _FallbackPanel({required this.message, this.busy = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0F13), Color(0xFF0A0A0F)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.brandOrange),
              )
            else
              const Icon(Icons.live_tv_outlined,
                  color: Colors.white70, size: 40),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
