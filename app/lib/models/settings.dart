class StreamSettings {
  final String tvTitle;
  final String? tvStreamUrl;
  final String radioTitle;
  final String? radioFrequency;
  final String? radioStreamUrl;

  StreamSettings({
    required this.tvTitle,
    this.tvStreamUrl,
    required this.radioTitle,
    this.radioFrequency,
    this.radioStreamUrl,
  });

  factory StreamSettings.fromJson(Map<String, dynamic> j) => StreamSettings(
        tvTitle: (j['tvTitle'] as String?) ?? 'Gotabgaa TV',
        tvStreamUrl: j['tvStreamUrl'] as String?,
        radioTitle: (j['radioTitle'] as String?) ?? 'Gotabgaa Radio',
        radioFrequency: j['radioFrequency'] as String?,
        radioStreamUrl: j['radioStreamUrl'] as String?,
      );
}

class SocialLinks {
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? youtube;
  final String? whatsapp;
  final String? tiktok;

  SocialLinks({
    this.facebook,
    this.twitter,
    this.instagram,
    this.youtube,
    this.whatsapp,
    this.tiktok,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> j) => SocialLinks(
        facebook: j['facebook'] as String?,
        twitter: j['twitter'] as String?,
        instagram: j['instagram'] as String?,
        youtube: j['youtube'] as String?,
        whatsapp: j['whatsapp'] as String?,
        tiktok: j['tiktok'] as String?,
      );
}

class SiteSettings {
  final StreamSettings stream;
  final SocialLinks social;

  SiteSettings({required this.stream, required this.social});

  factory SiteSettings.fromJson(Map<String, dynamic> j) => SiteSettings(
        stream: StreamSettings.fromJson(
            (j['stream'] as Map<String, dynamic>?) ?? {}),
        social:
            SocialLinks.fromJson((j['social'] as Map<String, dynamic>?) ?? {}),
      );
}
