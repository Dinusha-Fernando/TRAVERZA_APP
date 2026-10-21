/// Curated Sri Lanka Explorer Avatar Presets
class AvatarPreset {
  final String id;
  final String title;
  final String subtitle;
  final String url;
  final String emoji;

  const AvatarPreset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.emoji,
  });

  static const List<AvatarPreset> presets = [
    AvatarPreset(
      id: 'pilot',
      title: 'Pilot Explorer',
      subtitle: 'Official Corridor Pilot',
      url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      emoji: '✈️',
    ),
    AvatarPreset(
      id: 'backpacker',
      title: 'Cultural Backpacker',
      subtitle: 'Ancient Cities Explorer',
      url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      emoji: '🎒',
    ),
    AvatarPreset(
      id: 'luxury',
      title: 'Luxury Heritage',
      subtitle: 'Boutique Villa Traveller',
      url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
      emoji: '🧭',
    ),
    AvatarPreset(
      id: 'coastal',
      title: 'Coastal Surfer',
      subtitle: 'Mirissa & Arugam Wave Rider',
      url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
      emoji: '🏄‍♀️',
    ),
    AvatarPreset(
      id: 'highland',
      title: 'Highlands Trekker',
      subtitle: 'Ella Rock & Horton Plains',
      url: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=300&q=80',
      emoji: '🧗‍♂️',
    ),
    AvatarPreset(
      id: 'wildlife',
      title: 'Wildlife Naturalist',
      subtitle: 'Yala & Wilpattu Safari',
      url: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
      emoji: '🐆',
    ),
  ];
}
