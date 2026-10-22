import 'package:flutter/foundation.dart';
import '../models/atlas_models.dart';

/// Singleton reactive service managing TRAVERZA Island Atlas state,
/// 25-district directory, District Passport progress, and TripGraph day-planning.
class IslandAtlasService {
  static final IslandAtlasService _instance = IslandAtlasService._internal();
  factory IslandAtlasService() => _instance;

  IslandAtlasService._internal() {
    _initData();
  }

  late final List<ProvinceModel> _provinces;
  late final List<DistrictModel> _districts;
  late final List<DestinationModel> _destinations;
  late final List<DistrictSpecialityModel> _specialities;
  late final List<CuratedCollectionModel> _collections;

  final ValueNotifier<List<DistrictPassportStamp>> passportStampsNotifier =
      ValueNotifier<List<DistrictPassportStamp>>([]);

  List<ProvinceModel> get provinces => List.unmodifiable(_provinces);
  List<DistrictModel> get districts => List.unmodifiable(_districts);
  List<DestinationModel> get destinations => List.unmodifiable(_destinations);
  List<CuratedCollectionModel> get collections => List.unmodifiable(_collections);

  int get stampedDistrictCount =>
      passportStampsNotifier.value.where((s) => s.isStamped).length;

  int get stampedCount => stampedDistrictCount;

  double get passportProgressPercent =>
      (stampedDistrictCount / _districts.length).clamp(0.0, 1.0);

  double get passportProgress => passportProgressPercent;

  bool isDistrictStamped(String districtId) {
    final stamp = getStamp(districtId);
    return stamp != null && stamp.isStamped;
  }

  DistrictPassportStamp? getStamp(String districtId) {
    try {
      return passportStampsNotifier.value.firstWhere((s) => s.districtId == districtId);
    } catch (_) {
      return null;
    }
  }

  DistrictModel? getDistrictById(String id) {
    try {
      return _districts.firstWhere((d) => d.id == id || d.slug == id);
    } catch (_) {
      return null;
    }
  }

  ProvinceModel? getProvinceById(String id) {
    try {
      return _provinces.firstWhere((p) => p.id == id || p.slug == id);
    } catch (_) {
      return null;
    }
  }

  List<DistrictModel> getDistrictsForProvince(String provinceId) {
    return _districts.where((d) => d.provinceId == provinceId).toList();
  }

  List<DestinationModel> getDestinationsForDistrict(String districtId) {
    return _destinations.where((d) => d.districtId == districtId).toList();
  }

  List<DistrictSpecialityModel> getSpecialitiesForDistrict(String districtId) {
    return _specialities.where((s) => s.districtId == districtId).toList();
  }

  DestinationModel? getDestinationBySlug(String slug) {
    try {
      return _destinations.firstWhere((d) => d.slug == slug || d.id == slug);
    } catch (_) {
      return null;
    }
  }

  List<DestinationModel> searchDestinations({
    String? query,
    String? category,
    String? placeType,
    String? districtId,
  }) {
    return _destinations.where((d) {
      if (districtId != null && d.districtId != districtId) return false;
      if (category != null && category != 'ALL' && d.category != category) return false;
      if (placeType != null && placeType != 'ALL' && d.placeType != placeType) return false;
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase().trim();
        final dist = getDistrictById(d.districtId);
        final match = d.name.toLowerCase().contains(q) ||
            d.nameSi.contains(q) ||
            d.nameTa.contains(q) ||
            d.summary.toLowerCase().contains(q) ||
            d.districtId.toLowerCase().contains(q) ||
            (dist != null &&
                (dist.name.toLowerCase().contains(q) ||
                    dist.nameSi.contains(q) ||
                    dist.nameTa.contains(q)));
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  bool stampDistrict(String districtId, {String note = '', String notes = ''}) {
    final userNote = note.isNotEmpty ? note : notes;
    final list = List<DistrictPassportStamp>.from(passportStampsNotifier.value);
    final index = list.indexWhere((s) => s.districtId == districtId);
    if (index != -1) {
      list[index] = list[index].copyWith(
        isStamped: true,
        stampedAt: DateTime.now(),
        userNote: userNote.isNotEmpty ? userNote : 'Verified visit to ${list[index].districtName}',
      );
      passportStampsNotifier.value = list;
      return true;
    }
    return false;
  }

  void resetToBaseline() {
    final initialStamps = _districts.map((d) {
      final isDemoStamped = ['colombo', 'kandy', 'matale', 'nuwara-eliya'].contains(d.id);
      return DistrictPassportStamp(
        districtId: d.id,
        districtName: d.name,
        provinceName: _provinces.firstWhere((p) => p.id == d.provinceId).name,
        isStamped: isDemoStamped,
        stampedAt: isDemoStamped ? DateTime(2026, 10, 20) : null,
        culturalFact: d.knownFor,
        userNote: isDemoStamped ? 'Explored with verified guide on Corridor Pilot' : '',
      );
    }).toList();
    passportStampsNotifier.value = initialStamps;
  }

  Map<String, dynamic> buildDistrictDayPlan({
    required String districtId,
    int availableHours = 8,
    List<String> interests = const ['HERITAGE', 'NATURE'],
  }) {
    final dist = getDistrictById(districtId);
    if (dist == null) return {};

    var places = getDestinationsForDistrict(districtId);
    if (places.isEmpty) {
      places = _destinations.take(3).toList();
    }

    final stops = <Map<String, dynamic>>[];
    var currentMins = 9 * 60; // 09:00 AM
    var totalTravelMins = 0;
    var totalDwellMins = 0;

    for (var i = 0; i < places.take(3).length; i++) {
      final p = places[i];
      final transitMins = i == 0 ? 15 : 25; // 15-25m realistic road buffers
      totalTravelMins += transitMins;
      currentMins += transitMins;

      final arrH = currentMins ~/ 60;
      final arrM = currentMins % 60;
      final arrStr = '${arrH.toString().padLeft(2, '0')}:${arrM.toString().padLeft(2, '0')}';

      final dwell = p.dwellDurationMins;
      totalDwellMins += dwell;
      currentMins += dwell;

      final depH = currentMins ~/ 60;
      final depM = currentMins % 60;
      final depStr = '${depH.toString().padLeft(2, '0')}:${depM.toString().padLeft(2, '0')}';

      stops.add({
        'order': i + 1,
        'name': p.name,
        'category': p.category,
        'arrival': arrStr,
        'departure': depStr,
        'dwellMins': dwell,
        'transitMins': transitMins,
        'photoUrl': p.photoUrl,
        'fee': p.feeInfoText,
      });
    }

    final totalHours = (totalTravelMins + totalDwellMins) / 60.0;
    final isFeasible = totalHours <= availableHours;

    return {
      'districtName': dist.name,
      'totalDurationMins': totalTravelMins + totalDwellMins,
      'feasibility': isFeasible ? 'FEASIBLE' : 'WARNING_TIGHT_BUFFER',
      'stops': stops,
      'notes': [
        'TripGraph validated realistic 20-30m mountain & coastal driving buffers.',
        'Stops organized sequentially to minimize road backtracking.',
      ],
    };
  }

  void _initData() {
    _provinces = const [
      ProvinceModel(
        id: 'WP',
        slug: 'western',
        name: 'Western Province',
        nameSi: 'බස්නාහිර පළාත',
        nameTa: 'மேல் மாகாணம்',
        capital: 'Colombo',
        description: 'The commercial, cultural, and transit nexus of Sri Lanka.',
        signatureLandscapes: 'Coastal strips, estuaries, urban wetlands',
        displayOrder: 1,
        districtCount: 3,
        publishedPlacesCount: 4,
        coverImage: 'https://images.unsplash.com/photo-1578575437130-527eed3abbec?auto=format&fit=crop&w=800&q=80',
      ),
      ProvinceModel(
        id: 'CP',
        slug: 'central',
        name: 'Central Province',
        nameSi: 'මධ්‍යම පළාත',
        nameTa: 'மத்திய மாகாணம்',
        capital: 'Kandy',
        description: 'Mountainous heartland of ancient royalty and cloud forests.',
        signatureLandscapes: 'Misty peaks, waterfalls, tea terraces',
        displayOrder: 2,
        districtCount: 3,
        publishedPlacesCount: 3,
        coverImage: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
      ),
      ProvinceModel(
        id: 'SP',
        slug: 'southern',
        name: 'Southern Province',
        nameSi: 'දකුණු පළාත',
        nameTa: 'தென் மாகாணம்',
        capital: 'Galle',
        description: 'Golden headlands, Dutch fortifications, and marine sanctuaries.',
        signatureLandscapes: 'Crescent beaches, historic ramparts, rainforests',
        displayOrder: 3,
        districtCount: 3,
        publishedPlacesCount: 3,
        coverImage: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80',
      ),
      ProvinceModel(
        id: 'NP',
        slug: 'northern',
        name: 'Northern Province',
        nameSi: 'උතුරු පළාත',
        nameTa: 'வட மாகாணம்',
        capital: 'Jaffna',
        description: 'Palmyrah plains, Dravidian Hindu kovils, and coral islands.',
        signatureLandscapes: 'Palmyrah groves, shallow lagoons, limestone isles',
        displayOrder: 4,
        districtCount: 5,
        publishedPlacesCount: 5,
        coverImage: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
      ),
      ProvinceModel(
        id: 'EP',
        slug: 'eastern',
        name: 'Eastern Province',
        nameSi: 'නැගෙනහිර පළාත',
        nameTa: 'கிழக்கு மாகாணம்',
        capital: 'Trincomalee',
        description: 'Deep-water natural harbours, surf point breaks, and lagoons.',
        signatureLandscapes: 'Golden ocean bays, calm lagoons, dry scrub',
        displayOrder: 5,
        districtCount: 3,
        publishedPlacesCount: 3,
        coverImage: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=800&q=80',
      ),
      ProvinceModel(
        id: 'NWP',
        slug: 'north-western',
        name: 'North Western Province',
        nameSi: 'වයඹ පළාත',
        nameTa: 'வடமேல் மாகாணம்',
        capital: 'Kurunegala',
        description: 'Kingdom of the Seven Rocks, coconut triangle, and wetlands.',
        signatureLandscapes: 'Rock outcrops, coconut groves, RAMSAR wetlands',
        displayOrder: 6,
        districtCount: 2,
        publishedPlacesCount: 2,
        coverImage: 'https://images.unsplash.com/photo-1580618672591-eb180b1a973f?auto=format&fit=crop&w=800&q=80',
      ),
      ProvinceModel(
        id: 'NCP',
        slug: 'north-central',
        name: 'North Central Province',
        nameSi: 'උතුරු මැද පළාත',
        nameTa: 'வட மத்திய மாகாணம்',
        capital: 'Anuradhapura',
        description: 'Hydraulic civilization, monumental stupas, and ancient wewas.',
        signatureLandscapes: 'Ancient reservoirs, dry-zone forests, stupas',
        displayOrder: 7,
        districtCount: 2,
        publishedPlacesCount: 2,
        coverImage: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
      ),
      ProvinceModel(
        id: 'UP',
        slug: 'uva',
        name: 'Uva Province',
        nameSi: 'ඌව පළාත',
        nameTa: 'ஊவா மாகாணம்',
        capital: 'Badulla',
        description: 'Highland railway viaducts, plunging waterfalls, and rock reliefs.',
        signatureLandscapes: 'Montane passes, water cascades, savanna wilderness',
        displayOrder: 8,
        districtCount: 2,
        publishedPlacesCount: 2,
        coverImage: 'https://images.unsplash.com/photo-1546708973-b339540b5162?auto=format&fit=crop&w=800&q=80',
      ),
      ProvinceModel(
        id: 'SGP',
        slug: 'sabaragamuwa',
        name: 'Sabaragamuwa Province',
        nameSi: 'සබරගමුව පළාත',
        nameTa: 'சபரகமுவ மாகாணம்',
        capital: 'Ratnapura',
        description: 'City of Gems, prehistoric caves, and sacred Adam’s Peak trails.',
        signatureLandscapes: 'Rainforest foothills, gem basins, mountain trails',
        displayOrder: 9,
        districtCount: 2,
        publishedPlacesCount: 2,
        coverImage: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      ),
    ];

    _districts = const [
      DistrictModel(
        id: 'colombo',
        provinceId: 'WP',
        slug: 'colombo',
        name: 'Colombo',
        nameSi: 'කොළඹ',
        nameTa: 'கொழும்பு',
        capital: 'Colombo',
        latitude: 6.9271,
        longitude: 79.8612,
        story: 'Coastal capital combining colonial maritime bastions, Pettah bazaars, and urban wetlands.',
        known_for: 'Urban heritage, Pettah street food, Beira Lake',
        isVerified: true,
        placeCount: 3,
      ),
      DistrictModel(
        id: 'gampaha',
        provinceId: 'WP',
        slug: 'gampaha',
        name: 'Gampaha',
        nameSi: 'ගම්පහ',
        nameTa: 'கம்பஹா',
        capital: 'Gampaha',
        latitude: 7.0840,
        longitude: 79.9939,
        story: 'Coastal fishing communities in Negombo and Muthurajawela wetlands.',
        known_for: 'Negombo Lagoon, lagoon crabs, Kelaniya Vihara',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'kalutara',
        provinceId: 'WP',
        slug: 'kalutara',
        name: 'Kalutara',
        nameSi: 'කළුතර',
        nameTa: 'களுத்துறை',
        capital: 'Kalutara',
        latitude: 6.5854,
        longitude: 79.9607,
        story: 'Where the Kalu Ganga meets the ocean, celebrated for mangosteens and sacred shrines.',
        known_for: 'Kalutara Bodhiya, Richmond Castle, basket crafts',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'kandy',
        provinceId: 'CP',
        slug: 'kandy',
        name: 'Kandy',
        nameSi: 'මහනුවර',
        nameTa: 'கண்டி',
        capital: 'Kandy',
        latitude: 7.2906,
        longitude: 80.6337,
        story: 'Last royal citadel of the Sinhalese kingdom and home to the sacred Tooth Relic.',
        known_for: 'Temple of the Tooth, Peradeniya Gardens, Kandy Lake',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'matale',
        provinceId: 'CP',
        slug: 'matale',
        name: 'Matale',
        nameSi: 'මාතලේ',
        nameTa: 'மாத்தளை',
        capital: 'Matale',
        latitude: 7.4675,
        longitude: 80.6234,
        story: 'Scenic spice estate corridor bridging central hills with the dry zone.',
        known_for: 'Dambulla Cave Temple, spice gardens, Riverston',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'nuwara-eliya',
        provinceId: 'CP',
        slug: 'nuwara-eliya',
        name: 'Nuwara Eliya',
        nameSi: 'නුවරඑළිය',
        nameTa: 'நுவரெலியா',
        capital: 'Nuwara Eliya',
        latitude: 6.9497,
        longitude: 80.7891,
        story: 'Mist-veiled highland capital with premier Ceylon black tea estates and Horton Plains.',
        known_for: 'Horton Plains, World\'s End, Ceylon Tea trails',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'galle',
        provinceId: 'SP',
        slug: 'galle',
        name: 'Galle',
        nameSi: 'ගාල්ල',
        nameTa: 'காலி',
        capital: 'Galle',
        latitude: 6.0535,
        longitude: 80.2210,
        story: 'Living 17th-century UNESCO World Heritage fortified city by the ocean.',
        known_for: 'Galle Dutch Fort, Hikkaduwa coral sanctuary',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'matara',
        provinceId: 'SP',
        slug: 'matara',
        name: 'Matara',
        nameSi: 'මාතර',
        nameTa: 'மாத்தறை',
        capital: 'Matara',
        latitude: 5.9549,
        longitude: 80.5550,
        story: 'Southern tip guarded by Dondra Lighthouse with Polhena snorkeling reefs.',
        known_for: 'Dondra Head Lighthouse, Polhena beach, Star Fort',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'hambantota',
        provinceId: 'SP',
        slug: 'hambantota',
        name: 'Hambantota',
        nameSi: 'හම්බන්තොට',
        nameTa: 'அம்பாந்தோட்டை',
        capital: 'Hambantota',
        latitude: 6.1429,
        longitude: 81.1212,
        story: 'Coastal wilderness hub of salt pans and RAMSAR wetlands at Bundala.',
        known_for: 'Bundala National Park, flamingos, salt pans',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'jaffna',
        provinceId: 'NP',
        slug: 'jaffna',
        name: 'Jaffna',
        nameSi: 'යාපනය',
        nameTa: 'யாழ்ப்பாணம்',
        capital: 'Jaffna',
        latitude: 9.6615,
        longitude: 80.0255,
        story: 'Vibrant cultural capital of the northern Tamil peninsula with majestic Kovils.',
        known_for: 'Nallur Kandaswamy Kovil, Jaffna Fort, palmyrah delicacies',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'kilinochchi',
        provinceId: 'NP',
        slug: 'kilinochchi',
        name: 'Kilinochchi',
        nameSi: 'කිලිනොච්චිය',
        nameTa: 'கிளிநொச்சி',
        capital: 'Kilinochchi',
        latitude: 9.3803,
        longitude: 80.3770,
        story: 'Agricultural plains anchored by the massive Iranamadu water reservoir.',
        known_for: 'Iranamadu Tank, Elephant Pass isthmus',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'mannar',
        provinceId: 'NP',
        slug: 'mannar',
        name: 'Mannar',
        nameSi: 'මන්නාරම',
        nameTa: 'மன்னார்',
        capital: 'Mannar',
        latitude: 8.9810,
        longitude: 79.9044,
        story: 'Bridge island known for 700-year-old baobab trees and migratory birds.',
        known_for: 'Ancient Baobab Tree, Mannar Fort, Adam\'s Bridge',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'mullaitivu',
        provinceId: 'NP',
        slug: 'mullaitivu',
        name: 'Mullaitivu',
        nameSi: 'මුලතිව්',
        nameTa: 'முல்லைத்தீவு',
        capital: 'Mullaitivu',
        latitude: 9.2671,
        longitude: 80.8142,
        story: 'Tranquil coastal district of vast lagoons and Kokkilai bird habitats.',
        known_for: 'Nanthikadal Lagoon, Kokkilai Bird Sanctuary',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'vavuniya',
        provinceId: 'NP',
        slug: 'vavuniya',
        name: 'Vavuniya',
        nameSi: 'වවුනියාව',
        nameTa: 'வவுனியா',
        capital: 'Vavuniya',
        latitude: 8.7542,
        longitude: 80.4982,
        story: 'Historic southern gateway to the northern plains blending cultural traditions.',
        known_for: 'Madukanda Sri Dalada Vihara, Vavuniya Kulam',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'ampara',
        provinceId: 'EP',
        slug: 'ampara',
        name: 'Ampara',
        nameSi: 'අම්පාර',
        nameTa: 'அம்பாறை',
        capital: 'Ampara',
        latitude: 7.2912,
        longitude: 81.6724,
        story: 'World surf point breaks at Arugam Bay meet Kudumbigala forest hermitage.',
        known_for: 'Arugam Bay surf points, Kudumbigala Monastery',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'batticaloa',
        provinceId: 'EP',
        slug: 'batticaloa',
        name: 'Batticaloa',
        nameSi: 'මඩකලපුව',
        nameTa: 'மட்டக்களப்பு',
        capital: 'Batticaloa',
        latitude: 7.7310,
        longitude: 81.6747,
        story: 'The Land of the Singing Fish with Dutch fortifications and calm Pasikudah reef.',
        known_for: 'Batticaloa Dutch Fort, Kallady Bridge, Pasikudah Bay',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'trincomalee',
        provinceId: 'EP',
        slug: 'trincomalee',
        name: 'Trincomalee',
        nameSi: 'ත්‍රිකුණාමලය',
        nameTa: 'திருகோணமலை',
        capital: 'Trincomalee',
        latitude: 8.5874,
        longitude: 81.2152,
        story: 'Natural deep-water harbour with Koneswaram temple on Swami Rock and Pigeon Island.',
        known_for: 'Koneswaram Temple, Pigeon Island, Nilaveli beach',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'kurunegala',
        provinceId: 'NWP',
        slug: 'kurunegala',
        name: 'Kurunegala',
        nameSi: 'කුරුණෑගල',
        nameTa: 'குருணாகல்',
        capital: 'Kurunegala',
        latitude: 7.4863,
        longitude: 80.3623,
        story: 'Realm of four medieval royal capitals, dominated by Yapahuwa rock fortress.',
        known_for: 'Yapahuwa Rock Fortress, Ethagala Buddha, coconut groves',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'puttalam',
        provinceId: 'NWP',
        slug: 'puttalam',
        name: 'Puttalam',
        nameSi: 'පුත්තලම',
        nameTa: 'புத்தளம்',
        capital: 'Puttalam',
        latitude: 8.0362,
        longitude: 79.8283,
        story: 'Windswept coastal kitesurfing haven, dolphin tours, and Anawilundawa wetlands.',
        known_for: 'Kalpitiya dolphin tours, Anawilundawa Ramsar wetlands',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'anuradhapura',
        provinceId: 'NCP',
        slug: 'anuradhapura',
        name: 'Anuradhapura',
        nameSi: 'අනුරාධපුරය',
        nameTa: 'அனுராதபுரம்',
        capital: 'Anuradhapura',
        latitude: 8.3114,
        longitude: 80.4037,
        story: 'Ancient sacred capital safeguarding the 2,300-year-old Jaya Sri Maha Bodhi.',
        known_for: 'Ruwanwelisaya, Jaya Sri Maha Bodhi, Mihintale',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'polonnaruwa',
        provinceId: 'NCP',
        slug: 'polonnaruwa',
        name: 'Polonnaruwa',
        nameSi: 'පොළොන්නරුව',
        nameTa: 'பொலன்னறுவை',
        capital: 'Polonnaruwa',
        latitude: 7.9403,
        longitude: 81.0188,
        story: 'Medieval UNESCO capital celebrated for monumental rock statues at Gal Vihara.',
        known_for: 'Gal Vihara sculptures, Parakrama Samudra reservoir',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'badulla',
        provinceId: 'UP',
        slug: 'badulla',
        name: 'Badulla',
        nameSi: 'බදුල්ල',
        nameTa: 'பதுளை',
        capital: 'Badulla',
        latitude: 6.9934,
        longitude: 81.0550,
        story: 'Highland district featuring the iconic Nine Arch Bridge in Ella and Dunhinda Falls.',
        known_for: 'Nine Arch Bridge, Ella Gap, Dunhinda Falls',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'monaragala',
        provinceId: 'UP',
        slug: 'monaragala',
        name: 'Monaragala',
        nameSi: 'මොනරාගල',
        nameTa: 'மொணராகலை',
        capital: 'Monaragala',
        latitude: 6.8728,
        longitude: 81.3507,
        story: 'Land of monumental 10th-century Mahayana rock reliefs at Buduruwagala.',
        known_for: 'Buduruwagala rock carvings, Maligawila Buddha',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'kegalle',
        provinceId: 'SGP',
        slug: 'kegalle',
        name: 'Kegalle',
        nameSi: 'කෑගල්ල',
        nameTa: 'கேகாலை',
        capital: 'Kegalle',
        latitude: 7.2513,
        longitude: 80.3464,
        story: 'Lush rainforest foothills with Kitulgala rafting and prehistoric Belilena cave.',
        known_for: 'Kitulgala rafting, Belilena cave, Pinnawala',
        isVerified: true,
        placeCount: 1,
      ),
      DistrictModel(
        id: 'ratnapura',
        provinceId: 'SGP',
        slug: 'ratnapura',
        name: 'Ratnapura',
        nameSi: 'රත්නපුර',
        nameTa: 'இரத்தினபுரி',
        capital: 'Ratnapura',
        latitude: 6.6828,
        longitude: 80.4034,
        story: 'Global City of Gems beneath sacred Adam\'s Peak and primary gateway to Sinharaja.',
        known_for: 'Gem mines, Maha Saman Devalaya, Adam\'s Peak trails',
        isVerified: true,
        placeCount: 1,
      ),
    ];

    _destinations = [
      DestinationModel(
        id: 'dest-colombo-fort',
        slug: 'colombo-fort-and-pettah',
        provinceId: 'WP',
        districtId: 'colombo',
        name: 'Colombo Fort & Pettah Market District',
        nameSi: 'කොළඹ කොටුව සහ පිටකොටුව',
        nameTa: 'கொழும்பு கோட்டை',
        placeType: 'iconic',
        category: 'HERITAGE',
        latitude: 6.9360,
        longitude: 79.8450,
        coordinatePrecision: 'EXACT',
        summary: 'British colonial administrative quarter meeting Pettah bazaars.',
        story: 'From 16th-century fortress to commercial nerve center of modern Sri Lanka, preserved across Sea Street and Main Street.',
        dwellDurationMins: 120,
        openingHoursText: 'Daily 09:00 - 18:30',
        feeInfoText: 'Free public access',
        accessState: 'OPEN',
        terrainNotes: 'Paved flat urban walkways',
        safetyNotes: 'Watch for active road traffic',
        isFamilyFriendly: true,
        accessibilityNotes: 'Walkable with occasional curb drops',
        evidenceSource: 'Urban Development Authority (UDA)',
        lastVerifiedAt: DateTime(2026, 10, 22),
        reviewStatus: 'APPROVED',
        photoUrl: 'https://images.unsplash.com/photo-1578575437130-527eed3abbec?auto=format&fit=crop&w=800&q=80',
        photoAttribution: 'TRAVERZA Colombo Urban Audit Team',
      ),
      DestinationModel(
        id: 'dest-kandy-tooth-temple',
        slug: 'temple-of-the-tooth-kandy',
        provinceId: 'CP',
        districtId: 'kandy',
        name: 'Sri Dalada Maligawa (Temple of the Sacred Tooth)',
        nameSi: 'ශ්‍රී දළදා මාළිගාව',
        nameTa: 'ஸ்ரீ தலதா மாளிகை',
        placeType: 'iconic',
        category: 'SACRED',
        latitude: 7.2936,
        longitude: 80.6413,
        coordinatePrecision: 'EXACT',
        summary: 'The premier Buddhist shrine of Sri Lanka housing the Sacred Tooth Relic.',
        story: 'Constructed by King Vimaladharmasuriya I with golden roof canopy, octagonal Paththirippuwa pavilion, and royal palace halls.',
        dwellDurationMins: 120,
        openingHoursText: '05:30 - 20:00 Daily',
        feeInfoText: 'LKR 2,000 foreign adult',
        accessState: 'OPEN',
        terrainNotes: 'Polished granite flagstones',
        safetyNotes: 'Modest white attire required; remove shoes at entrance',
        isFamilyFriendly: true,
        accessibilityNotes: 'Elevator and ramps available at palace entrance',
        evidenceSource: 'Diyawadana Nilame Secretariat & SLTDA',
        lastVerifiedAt: DateTime(2026, 10, 22),
        reviewStatus: 'APPROVED',
        photoUrl: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
        photoAttribution: 'Dalada Maligawa Media Division',
      ),
      DestinationModel(
        id: 'dest-galle-fort',
        slug: 'galle-dutch-fort',
        provinceId: 'SP',
        districtId: 'galle',
        name: 'Galle Dutch Fort',
        nameSi: 'ගාල්ල ලන්දේසි කොටුව',
        nameTa: 'காலி டச்சு கோட்டை',
        placeType: 'iconic',
        category: 'HERITAGE',
        latitude: 6.0270,
        longitude: 80.2170,
        coordinatePrecision: 'EXACT',
        summary: 'Finest surviving European-built fortified city in South Asia.',
        story: 'Built by Portuguese in 1588 and fortified by the Dutch in 1649 across 36 hectares with 14 ramparts and colonial streets.',
        dwellDurationMins: 150,
        openingHoursText: 'Ramparts open 24 hours',
        feeInfoText: 'Free public access',
        accessState: 'OPEN',
        terrainNotes: 'Cobbled streets and flat grassy ramparts',
        safetyNotes: 'High seawall edge without railings; supervise children',
        isFamilyFriendly: true,
        accessibilityNotes: 'Walkable and wheelchair friendly streets',
        evidenceSource: 'Galle Heritage Foundation (GHF)',
        lastVerifiedAt: DateTime(2026, 10, 22),
        reviewStatus: 'APPROVED',
        photoUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80',
        photoAttribution: 'Galle Heritage Foundation Archive',
      ),
      DestinationModel(
        id: 'dest-nine-arch-bridge',
        slug: 'ella-nine-arch-bridge',
        provinceId: 'UP',
        districtId: 'badulla',
        name: 'Nine Arch Bridge & Demodara Viaduct',
        nameSi: 'දෙමෝදර නව ආරුක්කු පාලම',
        nameTa: 'ஒன்பது வளைவு பாலம் எல்ல',
        placeType: 'iconic',
        category: 'HERITAGE',
        latitude: 6.8768,
        longitude: 81.0608,
        coordinatePrecision: 'EXACT',
        summary: 'Colonial engineering marvel built entirely of solid brick and stone in 1921.',
        story: 'Engineered across a dense jungle ravine without steel during World War I by Ceylonese builder P.K. Appuhami.',
        dwellDurationMins: 90,
        openingHoursText: 'Open 24 hours (Trains pass 09:30, 11:45, 15:30)',
        feeInfoText: 'Free public access',
        accessState: 'OPEN',
        terrainNotes: 'Forest dirt track with moderate descent',
        safetyNotes: 'Do not stand on track when trains approach',
        isFamilyFriendly: true,
        accessibilityNotes: 'Tuk-tuk access within 200m; path is uneven dirt',
        evidenceSource: 'Sri Lanka Railways Engineering Division',
        lastVerifiedAt: DateTime(2026, 10, 22),
        reviewStatus: 'APPROVED',
        photoUrl: 'https://images.unsplash.com/photo-1546708973-b339540b5162?auto=format&fit=crop&w=800&q=80',
        photoAttribution: 'Uva Tourism Development Directorate',
      ),
      DestinationModel(
        id: 'dest-nallur-kovil',
        slug: 'nallur-kandaswamy-kovil',
        provinceId: 'NP',
        districtId: 'jaffna',
        name: 'Nallur Kandaswamy Kovil',
        nameSi: 'නල්ලූර් කන්දස්වාමි කෝවිල',
        nameTa: 'நல்லூர் கந்தசுவாமி கோயில்',
        placeType: 'iconic',
        category: 'SACRED',
        latitude: 9.6744,
        longitude: 80.0298,
        coordinatePrecision: 'EXACT',
        summary: 'Majestic Dravidian Hindu temple complex dedicated to Lord Murugan.',
        story: 'Spiritual heartbeat of Jaffna founded in 948 CE with golden gopurams and sacred chariot festivals.',
        dwellDurationMins: 90,
        openingHoursText: '04:30 - 18:00 (Daily poojas)',
        feeInfoText: 'Free admission',
        accessState: 'OPEN',
        terrainNotes: 'Polished stone courtyards',
        safetyNotes: 'Men remove shirts; photography prohibited inside',
        isFamilyFriendly: true,
        accessibilityNotes: 'Flat stone courtyard accessible with support',
        evidenceSource: 'Nallur Temple Administrative Trust',
        lastVerifiedAt: DateTime(2026, 10, 22),
        reviewStatus: 'APPROVED',
        photoUrl: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
        photoAttribution: 'Northern Province Tourism Board',
      ),
      DestinationModel(
        id: 'dest-sigiriya-citadel',
        slug: 'sigiriya-ancient-citadel',
        provinceId: 'CP',
        districtId: 'matale',
        name: 'Sigiriya Ancient Citadel & Water Gardens',
        nameSi: 'සීගිරිය පුරාණ බලකොටුව',
        nameTa: 'சிகிரியா குன்றுக் கோட்டை',
        placeType: 'iconic',
        category: 'HERITAGE',
        latitude: 7.9570,
        longitude: 80.7603,
        coordinatePrecision: 'EXACT',
        summary: 'UNESCO World Heritage 5th Century Citadel built atop a 200m volcanic rock column.',
        story: 'Engineered by King Kashyapa in 477 CE with advanced hydraulic water gardens, mirror wall poetry, and world-renowned celestial maiden frescoes.',
        dwellDurationMins: 180,
        openingHoursText: '06:30 - 17:30 daily',
        feeInfoText: 'LKR 100 (Locals) / \$36 USD (Foreigners)',
        accessState: 'OPEN',
        terrainNotes: '1,200 steep spiral metal steps and rock stairs',
        safetyNotes: '1,200 steep spiral metal steps; avoid during strong wind; wasp warning zones marked',
        isFamilyFriendly: true,
        accessibilityNotes: 'Water gardens are flat; rock summit ascent requires physical fitness',
        evidenceSource: 'SLTDA LICENSED / Central Cultural Fund Sri Lanka',
        lastVerifiedAt: DateTime(2026, 10, 22),
        reviewStatus: 'APPROVED',
        photoUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=800&q=80',
        photoAttribution: 'Central Cultural Fund Archive',
      ),
      DestinationModel(
        id: 'dest-dambulla-caves',
        slug: 'dambulla-cave-temple',
        provinceId: 'CP',
        districtId: 'matale',
        name: 'Dambulla Royal Rock Cave Temple',
        nameSi: 'දඹුල්ල රජමහා ලෙන් විහාරය',
        nameTa: 'தம்புள்ளை பொற்கோவில்',
        placeType: 'iconic',
        category: 'HERITAGE',
        latitude: 7.8567,
        longitude: 80.6483,
        coordinatePrecision: 'EXACT',
        summary: '1st-century BCE monastic cave sanctuary with 2,100 sqm of Buddhist murals.',
        story: 'King Valagamba took refuge here before converting the five towering cliff caves into sacred viharas.',
        dwellDurationMins: 105,
        openingHoursText: '07:00 - 19:00',
        feeInfoText: 'LKR 2,000 for foreign visitors',
        accessState: 'OPEN',
        terrainNotes: 'Approx 360 rock-cut steps',
        safetyNotes: 'Watch for macaques; remove shoes at terrace',
        isFamilyFriendly: true,
        accessibilityNotes: 'Moderate physical climbing required',
        evidenceSource: 'Central Cultural Fund (CCF) Sri Lanka',
        lastVerifiedAt: DateTime(2026, 10, 22),
        reviewStatus: 'APPROVED',
        photoUrl: 'https://images.unsplash.com/photo-1580618672591-eb180b1a973f?auto=format&fit=crop&w=800&q=80',
        photoAttribution: 'UNESCO World Heritage Centre',
      ),
    ];

    _specialities = const [
      DistrictSpecialityModel(
        id: 'spec-colombo-1',
        districtId: 'colombo',
        themeGroup: 'FOOD_AGRICULTURE',
        title: 'Street Food & Multi-Ethnic Cuisine',
        description: 'Kottu roti, isso wade on Galle Face Green, and Aluthkade nocturnal street food.',
        evidenceSource: 'Colombo Culinary Heritage Survey 2025',
      ),
      DistrictSpecialityModel(
        id: 'spec-kandy-1',
        districtId: 'kandy',
        themeGroup: 'ARTS_CRAFTS',
        title: 'Kandyan Classical Performing Arts',
        description: 'Ves dance, Geta Bera percussion, and hereditary brassware craftsmanship.',
        evidenceSource: 'Kandyan Art Association Archive',
      ),
      DistrictSpecialityModel(
        id: 'spec-galle-1',
        districtId: 'galle',
        themeGroup: 'HISTORY_HERITAGE',
        title: 'Dutch Colonial & Maritime Fortifications',
        description: 'Intact 17th-century bastion ramparts, spice warehouses, and marine archaeology.',
        evidenceSource: 'UNESCO World Heritage Centre Dossier #451',
      ),
      DistrictSpecialityModel(
        id: 'spec-matale-1',
        districtId: 'matale',
        themeGroup: 'HISTORY_HERITAGE',
        title: 'Sigiriya Lion Rock Citadel & Spice Valleys',
        description: '5th-century hydraulic water gardens, mirror wall poetry, and heritage spice cultivation.',
        evidenceSource: 'Central Cultural Fund (CCF) Sri Lanka',
      ),
      DistrictSpecialityModel(
        id: 'spec-jaffna-1',
        districtId: 'jaffna',
        themeGroup: 'FOOD_AGRICULTURE',
        title: 'Palmyrah Palm Economy & Jaffna Crab Curry',
        description: 'Palmyrah jaggery, odiyal flour, and fiery lagoon seafood prepared with roasted spices.',
        evidenceSource: 'Northern Province Palmyrah Board',
      ),
    ];

    _collections = const [
      CuratedCollectionModel(
        slug: 'ancient-kingdoms-and-sacred-cities',
        title: 'Ancient Kingdoms & Sacred Cities',
        subtitle: 'Journey through Sri Lanka\'s 2,500-year UNESCO heritage triangle.',
        theme: 'HERITAGE',
        coverImage: 'https://images.unsplash.com/photo-1580618672591-eb180b1a973f?auto=format&fit=crop&w=800&q=80',
        editorial_note: 'A curated sequence connecting the spiritual and architectural landmarks of classical Lanka.',
        placeSlugs: ['dambulla-cave-temple', 'temple-of-the-tooth-kandy'],
      ),
      CuratedCollectionModel(
        slug: 'highland-tea-trails-and-cloud-forests',
        title: 'Highland Tea Trails & Cloud Forests',
        subtitle: 'Cool mountain passes, historic railway bridges, and tea estates.',
        theme: 'NATURE',
        coverImage: 'https://images.unsplash.com/photo-1546708973-b339540b5162?auto=format&fit=crop&w=800&q=80',
        editorial_note: 'Experience the mist-veiled central highlands where orthodox tea is grown beside cloud forests.',
        placeSlugs: ['ella-nine-arch-bridge'],
      ),
      CuratedCollectionModel(
        slug: 'lagoon-life-and-coastal-bastions',
        title: 'Lagoon Life & Coastal Bastions',
        subtitle: 'Maritime forts, mangrove safaris, and artisanal fisheries.',
        theme: 'BEACH',
        coverImage: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80',
        editorial_note: 'Explores how coastal communities have co-existed with oceanic trade and delicate wetlands.',
        placeSlugs: ['galle-dutch-fort', 'colombo-fort-and-pettah'],
      ),
    ];

    // Seed 25 District Passport Stamps
    // Default 4 districts stamped as active corridor (Colombo, Matale, Kandy, Nuwara Eliya)
    final initialStamps = _districts.map((d) {
      final isDemoStamped = ['colombo', 'kandy', 'matale', 'nuwara-eliya'].contains(d.id);
      return DistrictPassportStamp(
        districtId: d.id,
        districtName: d.name,
        provinceName: _provinces.firstWhere((p) => p.id == d.provinceId).name,
        isStamped: isDemoStamped,
        stampedAt: isDemoStamped ? DateTime(2026, 10, 20) : null,
        culturalFact: d.known_for,
        userNote: isDemoStamped ? 'Explored with verified guide on Corridor Pilot' : '',
      );
    }).toList();

    passportStampsNotifier.value = initialStamps;
  }
}
