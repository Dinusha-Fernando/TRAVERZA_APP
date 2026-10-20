enum PackageType {
  operatorPackage, // Type 1: Bundled operator product with defined terms & single booking contract
  itineraryTemplate, // Type 2: Editorial / suggested sequence; services booked independently
}

class TraverzaPackage {
  final String id;
  final String slug;
  final String title;
  final String summary;
  final String description;
  final PackageType packageType;
  final int durationDays;
  final int durationNights;
  final String priceBasis; // "PER_PERSON", "TOTAL_PACKAGE", "PER_VEHICLE"
  final double basePriceLkr;
  final String corridorName;
  final List<String> destinations;
  final String coverImageUrl;
  final List<String> inclusions;
  final List<String> exclusions;
  final String cancellationPolicy;
  final String providerName;
  final String sltdaLicenseNo;
  final bool isVerified;
  final double rating;
  final int reviewCount;
  final String fitScoreReason;
  final List<DayItineraryItem> itinerary;

  const TraverzaPackage({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.description,
    required this.packageType,
    required this.durationDays,
    required this.durationNights,
    required this.priceBasis,
    required this.basePriceLkr,
    required this.corridorName,
    required this.destinations,
    required this.coverImageUrl,
    required this.inclusions,
    required this.exclusions,
    required this.cancellationPolicy,
    required this.providerName,
    required this.sltdaLicenseNo,
    required this.isVerified,
    required this.rating,
    required this.reviewCount,
    required this.fitScoreReason,
    required this.itinerary,
  });

  bool get isOperatorPackage => packageType == PackageType.operatorPackage;

  static List<TraverzaPackage> getCuratedPackages() {
    return [
      TraverzaPackage(
        id: 'pkg-corridor-01',
        slug: 'cultural-triangle-signature-escape',
        title: '3-Day Cultural Triangle Signature Escape',
        summary: 'From airport reception to Sigiriya rock fortress, royal botanical gardens, and highland tea estates.',
        description:
            'A seamlessly coordinated private journey connecting Bandaranaike International Airport with the UNESCO World Heritage sites of Sigiriya and Kandy, finishing amidst the misty hills of Nuwara Eliya. Includes luxury 4WD chauffeur transfer, certified SLTDA national guides, boutique heritage stays, and daily breakfast.',
        packageType: PackageType.operatorPackage,
        durationDays: 3,
        durationNights: 2,
        priceBasis: 'PER_PERSON',
        basePriceLkr: 68500.0,
        corridorName: 'Colombo · Sigiriya · Kandy · Nuwara Eliya',
        destinations: ['Colombo (CMB)', 'Sigiriya', 'Kandy', 'Nuwara Eliya'],
        coverImageUrl: 'assets/images/sigiriya.jpg',
        inclusions: [
          '2 Nights boutique heritage accommodation',
          'Private air-conditioned Toyota Prado SUV with chauffeur-guide',
          'Sigiriya Rock Fortress guided ascent with SLTDA certified guide',
          'Temple of the Sacred Tooth Relic entry & cultural guide',
          'All highway tolls, fuel, driver allowances & airport parking',
          'Daily organic breakfast & King Coconut hydration stops',
        ],
        exclusions: [
          'International flight tickets',
          'Lunches & dinners not specified in itinerary',
          'Personal travel insurance & optional gratuities',
        ],
        cancellationPolicy: '100% refund up to 72h before arrival. Reschedule anytime with 24h notice.',
        providerName: 'Ceylon Heritage Travel Guild',
        sltdaLicenseNo: 'SLTDA/SQA/2026/044',
        isVerified: true,
        rating: 4.9,
        reviewCount: 38,
        fitScoreReason: 'Matches your current active corridor & dates',
        itinerary: [
          DayItineraryItem(
            dayNumber: 1,
            title: 'Cultural Gateway & Rock Fortress',
            stops: ['Airport Meet & Greet (CMB)', 'Kurunegala Highland Transfer', 'Sigiriya Rock Fortress Ascent', 'Eco Villa Check-in'],
          ),
          DayItineraryItem(
            dayNumber: 2,
            title: 'Sacred Hill Capital & Temple of the Tooth',
            stops: ['Dambulla Golden Cave Temple', 'Matale Spice Sanctuary', 'Kandy Sacred Tooth Relic Temple', 'Kandy Lake Sunset'],
          ),
          DayItineraryItem(
            dayNumber: 3,
            title: 'Misty Highlands & Nuwara Eliya Tea Country',
            stops: ['Ramboda Waterfalls', 'Highland Tea Factory & Tasting', 'Nuwara Eliya Little England Tour', 'Departure Transfer'],
          ),
        ],
      ),
      TraverzaPackage(
        id: 'pkg-corridor-02',
        slug: 'hill-country-scenic-route-template',
        title: '5-Day Hill Country Scenic Route',
        summary: 'Suggested self-guided or tailor-made route covering colonial railways, misty peaks, and tea plantations.',
        description:
            'An editorial route template designed for independent travellers who prefer flexibility. Each hotel, scenic train transfer, and tea experience is booked independently according to your selected pace.',
        packageType: PackageType.itineraryTemplate,
        durationDays: 5,
        durationNights: 4,
        priceBasis: 'ESTIMATED_PER_PERSON',
        basePriceLkr: 89000.0,
        corridorName: 'Kandy · Hatton · Nuwara Eliya · Ella',
        destinations: ['Kandy', 'Nuwara Eliya', 'Ella'],
        coverImageUrl: 'assets/images/kandy.jpg',
        inclusions: [
          'Recommended stay: 4-star boutique colonial bungalows',
          'Recommended transport: Mainline First Class Observation Carriage',
          'Highlight: World’s End Horton Plains trek & Nine Arch Bridge',
        ],
        exclusions: [
          'Independent bookings required for each stay and transport ticket',
          'No single bundled cancellation contract',
        ],
        cancellationPolicy: 'Individual provider policies apply to each selected service.',
        providerName: 'TRAVERZA Curated Route Inspiration',
        sltdaLicenseNo: 'Editorial Template',
        isVerified: true,
        rating: 4.8,
        reviewCount: 52,
        fitScoreReason: 'Great alternative if extending beyond 3 days',
        itinerary: [
          DayItineraryItem(
            dayNumber: 1,
            title: 'Kandy Arrival & Royal Botanical Gardens',
            stops: ['Peradeniya Botanical Gardens', 'Kandy City Heritage Walk'],
          ),
          DayItineraryItem(
            dayNumber: 2,
            title: 'Scenic Blue Train to Nanu Oya',
            stops: ['Highland Mainline Train', 'Nuwara Eliya Town & Gregory Lake'],
          ),
          DayItineraryItem(
            dayNumber: 3,
            title: 'Horton Plains & World’s End',
            stops: ['Early Morning Cloud Forest Hike', 'Baker’s Falls'],
          ),
          DayItineraryItem(
            dayNumber: 4,
            title: 'Tea Estate Trail & Pedro Factory',
            stops: ['Tea Plucking Experience', 'Lovers Leap Waterfall'],
          ),
          DayItineraryItem(
            dayNumber: 5,
            title: 'Nine Arch Bridge & Ella Gap',
            stops: ['Nine Arch Bridge Historic Viaduct', 'Little Adam’s Peak Ascent'],
          ),
        ],
      ),
      TraverzaPackage(
        id: 'pkg-corridor-03',
        slug: 'luxury-wildlife-and-heritage-expedition',
        title: '4-Day Heritage & Minneriya Safari Operator Tour',
        summary: 'Complete wildlife safari and ancient ruins expedition with private naturalist.',
        description:
            'A fully managed operator package combining the UNESCO wonders of Sigiriya and Polonnaruwa with a private open-top 4x4 safari to observe the great elephant gathering at Minneriya National Park.',
        packageType: PackageType.operatorPackage,
        durationDays: 4,
        durationNights: 3,
        priceBasis: 'PER_PERSON',
        basePriceLkr: 94000.0,
        corridorName: 'Sigiriya · Polonnaruwa · Minneriya · Dambulla',
        destinations: ['Sigiriya', 'Polonnaruwa', 'Minneriya'],
        coverImageUrl: 'assets/images/sigiriya.jpg',
        inclusions: [
          '3 Nights 5-star eco-lodge accommodation',
          'Exclusive 4x4 Jeep Safari with DWC licensed wildlife tracker',
          'Polonnaruwa Ancient Kingdom bicycle tour with archaeologist',
          'All national park permits, tracker fees & taxes included',
        ],
        exclusions: [
          'Alcoholic beverages & personal expenditures',
        ],
        cancellationPolicy: 'Free cancellation up to 5 days prior to safari departure.',
        providerName: 'Wild Ceylon Safaris & Expeditions',
        sltdaLicenseNo: 'SLTDA/SQA/2026/108',
        isVerified: true,
        rating: 5.0,
        reviewCount: 29,
        fitScoreReason: 'Wildlife highlight in the Cultural Triangle corridor',
        itinerary: [
          DayItineraryItem(
            dayNumber: 1,
            title: 'Arrival & Sigiriya Sunset',
            stops: ['Eco Villa Welcome', 'Pidurangala Sunset Viewpoint'],
          ),
          DayItineraryItem(
            dayNumber: 2,
            title: 'Ancient Polonnaruwa & Minneriya Gathering',
            stops: ['Polonnaruwa Vatadage & Gal Vihara', 'Minneriya Elephant Safari'],
          ),
          DayItineraryItem(
            dayNumber: 3,
            title: 'Sigiriya Fortress & Village Gastronomy',
            stops: ['Lion Rock Morning Climb', 'Hiriwadunna Lake & Farmer Lunch'],
          ),
          DayItineraryItem(
            dayNumber: 4,
            title: 'Dambulla Caves & Colombo Return',
            stops: ['Cave Temple Murals', 'Return Chauffeur Transfer'],
          ),
        ],
      ),
    ];
  }
}

class DayItineraryItem {
  final int dayNumber;
  final String title;
  final List<String> stops;

  const DayItineraryItem({
    required this.dayNumber,
    required this.title,
    required this.stops,
  });
}
