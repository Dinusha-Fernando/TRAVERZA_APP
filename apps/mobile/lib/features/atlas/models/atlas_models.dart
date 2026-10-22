library;

/// Data contracts for the TRAVERZA Island Atlas
/// Governed by the TRAVERZA Island Atlas Strategy (Oct 22, 2026, V1.0)

class ProvinceModel {
  final String id;
  final String slug;
  final String name;
  final String nameSi;
  final String nameTa;
  final String capital;
  final String description;
  final String signatureLandscapes;
  final int displayOrder;
  final int districtCount;
  final int publishedPlacesCount;
  final String coverImage;

  const ProvinceModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.nameSi,
    required this.nameTa,
    required this.capital,
    required this.description,
    required this.signatureLandscapes,
    required this.displayOrder,
    required this.districtCount,
    required this.publishedPlacesCount,
    required this.coverImage,
  });
}

class DistrictModel {
  final String id;
  final String provinceId;
  final String slug;
  final String name;
  final String nameSi;
  final String nameTa;
  final String capital;
  final double latitude;
  final double longitude;
  final String story;
  final String knownFor;
  final bool isVerified;
  final int placeCount;

  // ignore: non_constant_identifier_names
  String get known_for => knownFor;

  const DistrictModel({
    required this.id,
    required this.provinceId,
    required this.slug,
    required this.name,
    required this.nameSi,
    required this.nameTa,
    required this.capital,
    required this.latitude,
    required this.longitude,
    required this.story,
    String? knownFor,
    // ignore: non_constant_identifier_names
    String? known_for,
    required this.isVerified,
    required this.placeCount,
  }) : knownFor = knownFor ?? known_for ?? '';
}

class DistrictSpecialityModel {
  final String id;
  final String districtId;
  final String themeGroup;
  final String title;
  final String description;
  final String evidenceSource;

  const DistrictSpecialityModel({
    required this.id,
    required this.districtId,
    required this.themeGroup,
    required this.title,
    required this.description,
    required this.evidenceSource,
  });
}

class DestinationModel {
  final String id;
  final String slug;
  final String provinceId;
  final String districtId;
  final String name;
  final String nameSi;
  final String nameTa;
  final String placeType; // 'iconic', 'locally_loved', 'emerging', 'seasonal'
  final String category; // 'HERITAGE', 'NATURE', 'BEACH', 'WILDLIFE', 'CRAFT_FOOD', 'SACRED', 'OUTDOOR'
  final double latitude;
  final double longitude;
  final String coordinatePrecision;
  final String summary;
  final String story;
  final int dwellDurationMins;
  final String openingHoursText;
  final String feeInfoText;
  final String accessState; // 'OPEN', 'SEASONAL', 'RESTRICTED', 'UNKNOWN'
  final String terrainNotes;
  final String safetyNotes;
  final bool isFamilyFriendly;
  final String accessibilityNotes;
  final String evidenceSource;
  final DateTime lastVerifiedAt;
  final String reviewStatus; // 'APPROVED', 'NEEDS_VERIFICATION', 'STALE'
  final String photoUrl;
  final String photoAttribution;

  const DestinationModel({
    required this.id,
    required this.slug,
    required this.provinceId,
    required this.districtId,
    required this.name,
    required this.nameSi,
    required this.nameTa,
    required this.placeType,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.coordinatePrecision,
    required this.summary,
    required this.story,
    required this.dwellDurationMins,
    required this.openingHoursText,
    required this.feeInfoText,
    required this.accessState,
    required this.terrainNotes,
    required this.safetyNotes,
    required this.isFamilyFriendly,
    required this.accessibilityNotes,
    required this.evidenceSource,
    required this.lastVerifiedAt,
    required this.reviewStatus,
    required this.photoUrl,
    required this.photoAttribution,
  });
}

class CuratedCollectionModel {
  final String slug;
  final String title;
  final String subtitle;
  final String theme;
  final String coverImage;
  final String editorialNote;
  final List<String> placeSlugs;

  // ignore: non_constant_identifier_names
  String get editorial_note => editorialNote;

  const CuratedCollectionModel({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.coverImage,
    String? editorialNote,
    // ignore: non_constant_identifier_names
    String? editorial_note,
    required this.placeSlugs,
  }) : editorialNote = editorialNote ?? editorial_note ?? '';
}

class DistrictPassportStamp {
  final String districtId;
  final String districtName;
  final String provinceName;
  final bool isStamped;
  final DateTime? stampedAt;
  final String culturalFact;
  final String userNote;

  String get notes => userNote;

  const DistrictPassportStamp({
    required this.districtId,
    required this.districtName,
    required this.provinceName,
    required this.isStamped,
    this.stampedAt,
    required this.culturalFact,
    this.userNote = '',
  });

  DistrictPassportStamp copyWith({
    bool? isStamped,
    DateTime? stampedAt,
    String? userNote,
  }) {
    return DistrictPassportStamp(
      districtId: districtId,
      districtName: districtName,
      provinceName: provinceName,
      isStamped: isStamped ?? this.isStamped,
      stampedAt: stampedAt ?? this.stampedAt,
      culturalFact: culturalFact,
      userNote: userNote ?? this.userNote,
    );
  }
}
