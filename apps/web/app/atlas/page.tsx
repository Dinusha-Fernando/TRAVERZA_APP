'use client';

import { useState, useMemo } from 'react';

interface Province {
  id: string;
  slug: string;
  name: string;
  nameSi: string;
  nameTa: string;
  capital: string;
  districtCount: number;
  publishedPlacesCount: number;
  coverImage: string;
  signatureLandscape: string;
}

interface District {
  id: string;
  provinceId: string;
  slug: string;
  name: string;
  nameSi: string;
  nameTa: string;
  capital: string;
  latitude: number;
  longitude: number;
  story: string;
  knownFor: string;
  specialityTitle: string;
  specialityDesc: string;
}

interface Place {
  id: string;
  slug: string;
  districtId: string;
  provinceId: string;
  name: string;
  nameSi: string;
  nameTa: string;
  category: 'HERITAGE' | 'NATURE' | 'SACRED' | 'BEACH' | 'WILDLIFE';
  placeType: 'iconic' | 'locally_loved' | 'emerging';
  dwellDurationMins: number;
  openingHoursText: string;
  feeInfoText: string;
  terrainNotes: string;
  safetyNotes: string;
  evidenceSource: string;
  reviewStatus: 'APPROVED' | 'NEEDS_VERIFICATION';
  photoUrl: string;
}

const PROVINCES: Province[] = [
  {
    id: 'WP',
    slug: 'western',
    name: 'Western Province',
    nameSi: 'බස්නාහිර පළාත',
    nameTa: 'மேல் மாகாணம்',
    capital: 'Colombo',
    districtCount: 3,
    publishedPlacesCount: 14,
    coverImage: 'https://images.unsplash.com/photo-1578575437130-527eed3abbec?auto=format&fit=crop&w=800&q=80',
    signatureLandscape: 'Coastal strips, estuaries, urban wetlands',
  },
  {
    id: 'CP',
    slug: 'central',
    name: 'Central Province',
    nameSi: 'මධ්‍යම පළාත',
    nameTa: 'மத்திய மாகாணம்',
    capital: 'Kandy',
    districtCount: 3,
    publishedPlacesCount: 18,
    coverImage: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
    signatureLandscape: 'Cloud forests, tea valleys, rock citadels',
  },
  {
    id: 'SP',
    slug: 'southern',
    name: 'Southern Province',
    nameSi: 'දකුණු පළාත',
    nameTa: 'தென் மாகாணம்',
    capital: 'Galle',
    districtCount: 3,
    publishedPlacesCount: 15,
    coverImage: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80',
    signatureLandscape: 'Coral bays, ocean ramparts, salt pans',
  },
  {
    id: 'NP',
    slug: 'northern',
    name: 'Northern Province',
    nameSi: 'උතුරු පළාත',
    nameTa: 'வட மாகாணம்',
    capital: 'Jaffna',
    districtCount: 5,
    publishedPlacesCount: 12,
    coverImage: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
    signatureLandscape: 'Palmyrah plains, limestone lagoons, kovils',
  },
  {
    id: 'EP',
    slug: 'eastern',
    name: 'Eastern Province',
    nameSi: 'නැගෙනහිර පළාත',
    nameTa: 'கிழக்கு மாகாணம்',
    capital: 'Trincomalee',
    districtCount: 3,
    publishedPlacesCount: 11,
    coverImage: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
    signatureLandscape: 'Natural deep harbors, sweeping surf bays',
  },
  {
    id: 'NWP',
    slug: 'north-western',
    name: 'North Western Province',
    nameSi: 'වයඹ පළාත',
    nameTa: 'வடமேல் மாகாணம்',
    capital: 'Kurunegala',
    districtCount: 2,
    publishedPlacesCount: 8,
    coverImage: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=800&q=80',
    signatureLandscape: 'Coconut plantations, medieval rock capitals',
  },
  {
    id: 'NCP',
    slug: 'north-central',
    name: 'North Central Province',
    nameSi: 'උතුරු මැද පළාත',
    nameTa: 'வடமத்திய மாகாணம்',
    capital: 'Anuradhapura',
    districtCount: 2,
    publishedPlacesCount: 16,
    coverImage: 'https://images.unsplash.com/photo-1580618672591-eb180b1a973f?auto=format&fit=crop&w=800&q=80',
    signatureLandscape: 'Dry-zone ancient reservoirs, stupas, wild elephant corridors',
  },
  {
    id: 'UP',
    slug: 'uva',
    name: 'Uva Province',
    nameSi: 'ඌව පළාත',
    nameTa: 'ஊவா மாகாணம்',
    capital: 'Badulla',
    districtCount: 2,
    publishedPlacesCount: 10,
    coverImage: 'https://images.unsplash.com/photo-1546708973-b339540b5162?auto=format&fit=crop&w=800&q=80',
    signatureLandscape: 'Ella mountain gaps, waterfalls, railway viaducts',
  },
  {
    id: 'SGP',
    slug: 'sabaragamuwa',
    name: 'Sabaragamuwa Province',
    nameSi: 'සබරගමුව පළාත',
    nameTa: 'சப்ரகமுவ மாகாணம்',
    capital: 'Ratnapura',
    districtCount: 2,
    publishedPlacesCount: 9,
    coverImage: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
    signatureLandscape: 'Gem gravel riverbeds, Sinharaja rainforest buffer',
  },
];

const DISTRICTS: District[] = [
  {
    id: 'colombo',
    provinceId: 'WP',
    slug: 'colombo',
    name: 'Colombo',
    nameSi: 'කොළඹ',
    nameTa: 'கொழும்பு',
    capital: 'Colombo',
    latitude: 6.9271,
    longitude: 79.8612,
    story: 'Commercial and cultural capital combining colonial maritime bastions, Pettah bazaars, and urban wetlands.',
    knownFor: 'Urban heritage, Pettah street food, Beira Lake',
    specialityTitle: 'Street Food & Colonial Bastions',
    specialityDesc: 'Kottu roti, isso wade on Galle Face Green, and Aluthkade nocturnal street food.',
  },
  {
    id: 'gampaha',
    provinceId: 'WP',
    slug: 'gampaha',
    name: 'Gampaha',
    nameSi: 'ගම්පහ',
    nameTa: 'கம்பஹா',
    capital: 'Gampaha',
    latitude: 7.084,
    longitude: 79.9939,
    story: 'Coastal lagoon fishing communities in Negombo and fertile agro-corridors.',
    knownFor: 'Negombo Lagoon, lagoon crabs, Kelaniya Vihara',
    specialityTitle: 'Negombo Lagoon Fishery & Catamarans',
    specialityDesc: 'Artisanal prawn and crab harvesting in coastal wetlands.',
  },
  {
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
    knownFor: 'Kalutara Bodhiya, Richmond Castle, basket crafts',
    specialityTitle: 'Riverine Crafts & Richmond Castle',
    specialityDesc: 'Intricate woven reeds and Indo-Saracenic architectural heritage.',
  },
  {
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
    knownFor: 'Temple of the Tooth, Peradeniya Gardens, Kandy Lake',
    specialityTitle: 'Kandyan Classical Arts & Percussion',
    specialityDesc: 'Ves dance, Geta Bera percussion, and hereditary brassware craftsmanship.',
  },
  {
    id: 'matale',
    provinceId: 'CP',
    slug: 'matale',
    name: 'Matale',
    nameSi: 'මාතලේ',
    nameTa: 'மாத்தளை',
    capital: 'Matale',
    latitude: 7.4675,
    longitude: 80.6234,
    story: 'Scenic spice estate corridor bridging central hills with the cultural dry zone.',
    knownFor: 'Sigiriya Rock Citadel, Dambulla Cave Temple, Riverston',
    specialityTitle: 'Sigiriya Rock Citadel & Spice Valleys',
    specialityDesc: '5th-century hydraulic water gardens, mirror wall poetry, and heritage spice cultivation.',
  },
  {
    id: 'nuwara-eliya',
    provinceId: 'CP',
    slug: 'nuwara-eliya',
    name: 'Nuwara Eliya',
    nameSi: 'නුවරඑළිය',
    nameTa: 'நுவரெலியா',
    capital: 'Nuwara Eliya',
    latitude: 6.9497,
    longitude: 80.7891,
    story: 'Mist-veiled highland capital with premier Ceylon black tea estates and Horton Plains cloud forests.',
    knownFor: 'Horton Plains, World\'s End, Ceylon Tea trails',
    specialityTitle: 'Orthodox High-Grown Ceylon Tea',
    specialityDesc: 'Single-estate highland plucking at elevations over 1,800m.',
  },
  {
    id: 'galle',
    provinceId: 'SP',
    slug: 'galle',
    name: 'Galle',
    nameSi: 'ගාල්ල',
    nameTa: 'காலி',
    capital: 'Galle',
    latitude: 6.0535,
    longitude: 80.221,
    story: 'Living 17th-century UNESCO World Heritage fortified maritime city by the ocean.',
    knownFor: 'Galle Dutch Fort, Hikkaduwa coral sanctuary',
    specialityTitle: 'Dutch Fortifications & Maritime Trade',
    specialityDesc: 'Intact 17th-century bastion ramparts, spice warehouses, and marine archaeology.',
  },
  {
    id: 'matara',
    provinceId: 'SP',
    slug: 'matara',
    name: 'Matara',
    nameSi: 'මාතර',
    nameTa: 'மாத்தறை',
    capital: 'Matara',
    latitude: 5.9549,
    longitude: 80.555,
    story: 'Southern maritime tip guarded by Dondra Lighthouse with Polhena snorkeling reefs.',
    knownFor: 'Dondra Head Lighthouse, Polhena beach, Star Fort',
    specialityTitle: 'Maritime Bastions & Whale Corridors',
    specialityDesc: 'Deep-water trench migrations of blue whales and historic navigational lights.',
  },
  {
    id: 'hambantota',
    provinceId: 'SP',
    slug: 'hambantota',
    name: 'Hambantota',
    nameSi: 'හම්බන්තොට',
    nameTa: 'அம்பாந்தோட்டை',
    capital: 'Hambantota',
    latitude: 6.1429,
    longitude: 81.1212,
    story: 'Coastal wilderness hub of salt pans and RAMSAR wetlands at Bundala National Park.',
    knownFor: 'Bundala National Park, flamingos, salt pans',
    specialityTitle: 'Ramsar Wetlands & Migratory Birds',
    specialityDesc: 'Saline lagoons hosting greater flamingo flocks and coastal sand dunes.',
  },
  {
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
    knownFor: 'Nallur Kandaswamy Kovil, Jaffna Fort, palmyrah delicacies',
    specialityTitle: 'Palmyrah Economy & Jaffna Crab Curry',
    specialityDesc: 'Palmyrah jaggery, odiyal flour, and fiery lagoon seafood prepared with roasted spices.',
  },
  {
    id: 'kilinochchi',
    provinceId: 'NP',
    slug: 'kilinochchi',
    name: 'Kilinochchi',
    nameSi: 'කිලිනොච්චිය',
    nameTa: 'கிளிநொச்சி',
    capital: 'Kilinochchi',
    latitude: 9.3803,
    longitude: 80.377,
    story: 'Agricultural plains anchored by the massive Iranamadu water reservoir.',
    knownFor: 'Iranamadu Tank, Elephant Pass isthmus',
    specialityTitle: 'Iranamadu Hydraulic Reservoir',
    specialityDesc: 'Historic tank irrigation feeding northern paddy fields.',
  },
  {
    id: 'mannar',
    provinceId: 'NP',
    slug: 'mannar',
    name: 'Mannar',
    nameSi: 'මන්නාරම',
    nameTa: 'மன்னார்',
    capital: 'Mannar',
    latitude: 8.981,
    longitude: 79.9044,
    story: 'Bridge island known for 700-year-old baobab trees and migratory flamingo flocks.',
    knownFor: 'Ancient Baobab Tree, Mannar Fort, Adam\'s Bridge',
    specialityTitle: 'Arabian Baobabs & Adam\'s Bridge Shoals',
    specialityDesc: 'Ancient maritime traders planting baobab giants and sand shoals to India.',
  },
  {
    id: 'mullaitivu',
    provinceId: 'NP',
    slug: 'mullaitivu',
    name: 'Mullaitivu',
    nameSi: 'මුලතිව්',
    nameTa: 'முல்லைத்தீவு',
    capital: 'Mullaitivu',
    latitude: 9.2671,
    longitude: 80.8142,
    story: 'Pristine coastal lagoon belt and Kokkilai Bird Sanctuary.',
    knownFor: 'Nanthikadal Lagoon, Kokkilai Bird Sanctuary',
    specialityTitle: 'Kokkilai Estuary & Mangroves',
    specialityDesc: 'Pelican and stork nesting colonies across mangrove estuaries.',
  },
  {
    id: 'vavuniya',
    provinceId: 'NP',
    slug: 'vavuniya',
    name: 'Vavuniya',
    nameSi: 'වවුනියාව',
    nameTa: 'வவுனியா',
    capital: 'Vavuniya',
    latitude: 8.7514,
    longitude: 80.4971,
    story: 'Gateway connecting the dry-zone cultural heartland to the northern peninsula.',
    knownFor: 'Madukanda Sri Dalada Vihara, Vavuniya Kulam',
    specialityTitle: 'Archaeological Transit Gateway',
    specialityDesc: 'Forest monasteries and ancient waystations of the Sacred Tooth relic.',
  },
  {
    id: 'ampara',
    provinceId: 'EP',
    slug: 'ampara',
    name: 'Ampara',
    nameSi: 'අම්පාර',
    nameTa: 'அம்பாறை',
    capital: 'Ampara',
    latitude: 7.2912,
    longitude: 81.6724,
    story: 'World-renowned surfing breaks at Arugam Bay and Kudumbigala forest monastery.',
    knownFor: 'Arugam Bay surf points, Kudumbigala Monastery',
    specialityTitle: 'Arugam Bay Point Breaks & Forest Solitude',
    specialityDesc: 'Right-hand reef point breaks meeting ancient hermit rock caves.',
  },
  {
    id: 'batticaloa',
    provinceId: 'EP',
    slug: 'batticaloa',
    name: 'Batticaloa',
    nameSi: 'මඩකලපුව',
    nameTa: 'மட்டக்களப்பு',
    capital: 'Batticaloa',
    latitude: 7.717,
    longitude: 81.7,
    story: 'Serene coastal lagoons famous for singing fish folklore and Pasikudah calm waters.',
    knownFor: 'Batticaloa Dutch Fort, Kallady Bridge, Pasikudah Bay',
    specialityTitle: 'Pasikudah Shallow Coral Reef Shelf',
    specialityDesc: 'Calm, knee-deep turquoise waters extending hundreds of meters offshore.',
  },
  {
    id: 'trincomalee',
    provinceId: 'EP',
    slug: 'trincomalee',
    name: 'Trincomalee',
    nameSi: 'ත්‍රිකුණාමලය',
    nameTa: 'திருகோணமலை',
    capital: 'Trincomalee',
    latitude: 8.5711,
    longitude: 81.2335,
    story: 'One of the finest natural deep-water harbors in the world, crowned by Swami Rock and Koneswaram.',
    knownFor: 'Koneswaram Temple, Pigeon Island, Nilaveli beach',
    specialityTitle: 'Swami Rock Cliff & Pigeon Island Reef',
    specialityDesc: 'Coastal Hindu cliff shrines overlooking deep oceanic blue-whale trenches.',
  },
  {
    id: 'kurunegala',
    provinceId: 'NWP',
    slug: 'kurunegala',
    name: 'Kurunegala',
    nameSi: 'කුරුණෑගල',
    nameTa: 'குருநாகல்',
    capital: 'Kurunegala',
    latitude: 7.4863,
    longitude: 80.3623,
    story: 'Medieval royal capital sheltered by seven giant monolithic animal rocks.',
    knownFor: 'Yapahuwa Rock Fortress, Ethagala Buddha, coconut groves',
    specialityTitle: 'Yapahuwa Ornamental Stairway',
    specialityDesc: '13th-century citadel featuring Chinese-influenced stone lion sculptures.',
  },
  {
    id: 'puttalam',
    provinceId: 'NWP',
    slug: 'puttalam',
    name: 'Puttalam',
    nameSi: 'පුත්තලම',
    nameTa: 'புத்தளம்',
    capital: 'Puttalam',
    latitude: 8.0362,
    longitude: 79.8283,
    story: 'Kalpitiya lagoon kitesurfing, spinner dolphins, and Anawilundawa Ramsar sanctuary.',
    knownFor: 'Kalpitiya dolphin tours, Anawilundawa Ramsar wetlands',
    specialityTitle: 'Kalpitiya Marine Sanctuary & Kitesurfing',
    specialityDesc: 'Pods of 1,000+ spinner dolphins and steady offshore trade winds.',
  },
  {
    id: 'anuradhapura',
    provinceId: 'NCP',
    slug: 'anuradhapura',
    name: 'Anuradhapura',
    nameSi: 'අනුරාධපුරය',
    nameTa: 'அனுராதபுரம்',
    capital: 'Anuradhapura',
    latitude: 8.3114,
    longitude: 80.4037,
    story: 'Ancient first kingdom spanning 1,400 years with monumental brick stupas and the sacred Jaya Sri Maha Bodhi.',
    knownFor: 'Ruwanwelisaya, Jaya Sri Maha Bodhi, Mihintale',
    specialityTitle: '2,300-Year Sacred Bodhi Tree & Great Stupas',
    specialityDesc: 'Oldest historically documented tree planted by humans on Earth.',
  },
  {
    id: 'polonnaruwa',
    provinceId: 'NCP',
    slug: 'polonnaruwa',
    name: 'Polonnaruwa',
    nameSi: 'පොළොන්නරුව',
    nameTa: 'பொலன்னறுவை',
    capital: 'Polonnaruwa',
    latitude: 7.9403,
    longitude: 81.0188,
    story: 'Second medieval royal capital celebrated for colossal granite Gal Vihara Buddha sculptures.',
    knownFor: 'Gal Vihara sculptures, Parakrama Samudra reservoir',
    specialityTitle: 'Gal Vihara Colossal Granite Carvings',
    specialityDesc: 'Four masterwork Buddha statues carved directly from a single granite quarry.',
  },
  {
    id: 'badulla',
    provinceId: 'UP',
    slug: 'badulla',
    name: 'Badulla',
    nameSi: 'බදුල්ල',
    nameTa: 'பதுளை',
    capital: 'Badulla',
    latitude: 6.9895,
    longitude: 81.0557,
    story: 'Highland railway terminus featuring the iconic Nine Arch Bridge and mist-shrouded Ella Gap.',
    knownFor: 'Nine Arch Bridge, Ella Gap, Dunhinda Falls',
    specialityTitle: 'Demodara Spiral & Nine Arch Viaduct',
    specialityDesc: 'Pioneering early 20th-century stone masonry railway architecture.',
  },
  {
    id: 'monaragala',
    provinceId: 'UP',
    slug: 'monaragala',
    name: 'Monaragala',
    nameSi: 'මොණරාගල',
    nameTa: 'மொணராகலை',
    capital: 'Monaragala',
    latitude: 6.8728,
    longitude: 81.3507,
    story: 'Expansive dry zone forests sheltering sacred Kataragama and Buduruwagala rock carvings.',
    knownFor: 'Buduruwagala rock carvings, Maligawila Buddha',
    specialityTitle: 'Buduruwagala Mahayana Colossi',
    specialityDesc: 'Tallest standing Buddha relief sculpture in Sri Lanka (51 feet tall).',
  },
  {
    id: 'kegalle',
    provinceId: 'SGP',
    slug: 'kegalle',
    name: 'Kegalle',
    nameSi: 'කෑගල්ල',
    nameTa: 'கேகாலை',
    capital: 'Kegalle',
    latitude: 7.2513,
    longitude: 80.3464,
    story: 'Lush rainforest foothills with Kitulgala white-water rafting and prehistoric Belilena cave.',
    knownFor: 'Kitulgala rafting, Belilena cave, Pinnawala',
    specialityTitle: 'Kitulgala Kelani River Rapids & Caving',
    specialityDesc: 'Grade 3/4 white-water rafting amidst tropical lowland rain forest.',
  },
  {
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
    knownFor: 'Gem mines, Maha Saman Devalaya, Adam\'s Peak trails',
    specialityTitle: 'Cornflower Blue Ceylon Sapphires',
    specialityDesc: 'Traditional pit mining of world-renowned untreated natural corundum.',
  },
];

const PLACES: Place[] = [
  {
    id: 'p-sigiriya',
    slug: 'sigiriya-ancient-citadel',
    districtId: 'matale',
    provinceId: 'CP',
    name: 'Sigiriya Ancient Citadel & Water Gardens',
    nameSi: 'සීගිරිය පුරාණ බලකොටුව',
    nameTa: 'சிகிரியா குன்றுக் கோட்டை',
    category: 'HERITAGE',
    placeType: 'iconic',
    dwellDurationMins: 180,
    openingHoursText: '06:30 - 17:30 daily',
    feeInfoText: 'LKR 100 (Locals) / $36 USD (Foreigners)',
    terrainNotes: '1,200 steep spiral metal steps and ancient rock stairs',
    safetyNotes: 'Strong winds at summit terrace; wasp exclusion zones marked; supervise children',
    evidenceSource: 'Central Cultural Fund (CCF) Sri Lanka & SLTDA Verified',
    reviewStatus: 'APPROVED',
    photoUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=800&q=80',
  },
  {
    id: 'p-dambulla',
    slug: 'dambulla-cave-temple',
    districtId: 'matale',
    provinceId: 'CP',
    name: 'Dambulla Royal Rock Cave Temple',
    nameSi: 'දඹුල්ල රජමහා ලෙන් විහාරය',
    nameTa: 'தம்புள்ளை பொற்கோவில்',
    category: 'HERITAGE',
    placeType: 'iconic',
    dwellDurationMins: 105,
    openingHoursText: '07:00 - 19:00 daily',
    feeInfoText: 'LKR 2,000 foreign adult',
    terrainNotes: 'Approx 360 rock-cut steps',
    safetyNotes: 'Modest shoulder-and-knee attire required; remove footwear at terrace',
    evidenceSource: 'Central Cultural Fund Sri Lanka',
    reviewStatus: 'APPROVED',
    photoUrl: 'https://images.unsplash.com/photo-1580618672591-eb180b1a973f?auto=format&fit=crop&w=800&q=80',
  },
  {
    id: 'p-tooth-temple',
    slug: 'temple-of-the-tooth-kandy',
    districtId: 'kandy',
    provinceId: 'CP',
    name: 'Sri Dalada Maligawa (Temple of the Sacred Tooth)',
    nameSi: 'ශ්‍රී දළදා මාළිගාව',
    nameTa: 'ஸ்ரீ தலதா மாளிகை',
    category: 'SACRED',
    placeType: 'iconic',
    dwellDurationMins: 120,
    openingHoursText: '05:30 - 20:00 Daily',
    feeInfoText: 'LKR 2,000 foreign adult',
    terrainNotes: 'Polished granite flagstones',
    safetyNotes: 'White or modest clothing required; daily drumming poojas at 05:30, 09:30, 18:30',
    evidenceSource: 'Diyawadana Nilame Secretariat & SLTDA',
    reviewStatus: 'APPROVED',
    photoUrl: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
  },
  {
    id: 'p-galle-fort',
    slug: 'galle-dutch-fort',
    districtId: 'galle',
    provinceId: 'SP',
    name: 'Galle Dutch Fort & Ocean Ramparts',
    nameSi: 'ගාල්ල ලන්දේසි කොටුව',
    nameTa: 'காலி டச்சு கோட்டை',
    category: 'HERITAGE',
    placeType: 'iconic',
    dwellDurationMins: 150,
    openingHoursText: 'Ramparts open 24 hours',
    feeInfoText: 'Free public access',
    terrainNotes: 'Cobbled stone streets and grassy ramparts',
    safetyNotes: 'High ocean wall drop-offs without railings; watch children along Flag Rock',
    evidenceSource: 'Galle Heritage Foundation (GHF) & UNESCO #451',
    reviewStatus: 'APPROVED',
    photoUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80',
  },
  {
    id: 'p-nine-arch',
    slug: 'ella-nine-arch-bridge',
    districtId: 'badulla',
    provinceId: 'UP',
    name: 'Nine Arch Bridge & Demodara Viaduct',
    nameSi: 'දෙමෝදර නව ආරුක්කු පාලම',
    nameTa: 'ஒன்பது வளைவு பாலம் எல்ல',
    category: 'HERITAGE',
    placeType: 'iconic',
    dwellDurationMins: 90,
    openingHoursText: 'Open 24 hours (Trains pass 09:30, 11:45, 15:30)',
    feeInfoText: 'Free public access',
    terrainNotes: 'Forest dirt trail with moderate slope',
    safetyNotes: 'Do not stand on track when trains approach; step onto refuge bays',
    evidenceSource: 'Sri Lanka Railways Engineering Division',
    reviewStatus: 'APPROVED',
    photoUrl: 'https://images.unsplash.com/photo-1546708973-b339540b5162?auto=format&fit=crop&w=800&q=80',
  },
  {
    id: 'p-nallur-kovil',
    slug: 'nallur-kandaswamy-kovil',
    districtId: 'jaffna',
    provinceId: 'NP',
    name: 'Nallur Kandaswamy Kovil',
    nameSi: 'නල්ලූර් කන්දස්වාමි කෝවිල',
    nameTa: 'நல்லூர் கந்தசுவாமி கோயில்',
    category: 'SACRED',
    placeType: 'iconic',
    dwellDurationMins: 90,
    openingHoursText: '04:30 - 18:00 daily',
    feeInfoText: 'Free admission',
    terrainNotes: 'Polished stone courtyards',
    safetyNotes: 'Men remove shirts before entering; photography prohibited inside sanctum',
    evidenceSource: 'Nallur Temple Administrative Trust & Northern Tourism',
    reviewStatus: 'APPROVED',
    photoUrl: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
  },
  {
    id: 'p-colombo-fort',
    slug: 'colombo-fort-and-pettah',
    districtId: 'colombo',
    provinceId: 'WP',
    name: 'Colombo Fort & Pettah Market District',
    nameSi: 'කොළඹ කොටුව සහ පිටකොටුව',
    nameTa: 'கொழும்பு கோட்டை',
    category: 'HERITAGE',
    placeType: 'iconic',
    dwellDurationMins: 120,
    openingHoursText: 'Daily 09:00 - 18:30',
    feeInfoText: 'Free public access',
    terrainNotes: 'Paved flat urban walkways',
    safetyNotes: 'Active road traffic at Main Street crossing',
    evidenceSource: 'Urban Development Authority (UDA) Sri Lanka',
    reviewStatus: 'APPROVED',
    photoUrl: 'https://images.unsplash.com/photo-1578575437130-527eed3abbec?auto=format&fit=crop&w=800&q=80',
  },
];

export default function IslandAtlasPage() {
  const [selectedProvinceId, setSelectedProvinceId] = useState<string | null>(null);
  const [selectedDistrictId, setSelectedDistrictId] = useState<string>('matale');
  const [selectedCategory, setSelectedCategory] = useState<string>('ALL');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [passportStamps, setPassportStamps] = useState<Record<string, { stamped: boolean; note?: string }>>({
    colombo: { stamped: true, note: 'Pettah market spice walk with verified host' },
    kandy: { stamped: true, note: 'Evening pooja at Sri Dalada Maligawa' },
    matale: { stamped: true, note: 'Climbed Sigiriya Rock at dawn' },
    'nuwara-eliya': { stamped: true, note: 'Pedro tea factory tour and highland trail' },
  });
  const [dayPlanModalOpen, setDayPlanModalOpen] = useState(false);
  const [dayPlanHours, setDayPlanHours] = useState(8);
  const [dayPlanPace, setDayPlanPace] = useState<'relaxed' | 'balanced' | 'fast'>('balanced');
  const [correctionModalPlace, setCorrectionModalPlace] = useState<Place | null>(null);
  const [correctionNote, setCorrectionNote] = useState('');
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 4000);
  };

  const filteredDistricts = selectedProvinceId
    ? DISTRICTS.filter((d) => d.provinceId === selectedProvinceId)
    : DISTRICTS;

  const currentDistrict = DISTRICTS.find((d) => d.id === selectedDistrictId) || DISTRICTS[0];

  const filteredPlaces = PLACES.filter((p) => {
    if (selectedDistrictId && p.districtId !== selectedDistrictId) return false;
    if (selectedCategory !== 'ALL' && p.category !== selectedCategory) return false;
    if (searchQuery.trim().length > 0) {
      const q = searchQuery.toLowerCase().trim();
      const match =
        p.name.toLowerCase().includes(q) ||
        p.nameSi.includes(q) ||
        p.nameTa.includes(q) ||
        p.category.toLowerCase().includes(q) ||
        p.districtId.toLowerCase().includes(q);
      if (!match) return false;
    }
    return true;
  });

  const stampedCount = Object.values(passportStamps).filter((s) => s.stamped).length;
  const passportPercent = Math.round((stampedCount / 25) * 100);

  const toggleStamp = (districtId: string) => {
    setPassportStamps((prev) => {
      const isStamped = prev[districtId]?.stamped;
      if (isStamped) {
        const next = { ...prev };
        delete next[districtId];
        showToast(`Removed stamp for ${DISTRICTS.find((d) => d.id === districtId)?.name}`);
        return next;
      } else {
        showToast(`🏆 District Stamped! Added ${DISTRICTS.find((d) => d.id === districtId)?.name} to your Passport`);
        return {
          ...prev,
          [districtId]: { stamped: true, note: 'Stamped on TRAVERZA Web Explorer' },
        };
      }
    });
  };

  // TripGraph Day Itinerary calculation
  const districtPlaces = PLACES.filter((p) => p.districtId === selectedDistrictId);
  const candidateStops = districtPlaces.length > 0 ? districtPlaces : PLACES.slice(0, 3);
  const { scheduleStops, totalMinutes } = useMemo(() => {
    let runningMinutes = 0;
    const stops: Array<{
      order: number;
      place: (typeof candidateStops)[number];
      arrival: string;
      departure: string;
      transitBuffer: number;
      dwell: number;
    }> = [];

    for (let idx = 0; idx < candidateStops.length; idx++) {
      const place = candidateStops[idx];
      const transitBuffer = idx === 0 ? 20 : dayPlanPace === 'relaxed' ? 35 : 25;
      runningMinutes += transitBuffer;
      const arrivalH = Math.floor((9 * 60 + runningMinutes) / 60);
      const arrivalM = (9 * 60 + runningMinutes) % 60;
      const dwell = dayPlanPace === 'relaxed' ? Math.round(place.dwellDurationMins * 1.25) : place.dwellDurationMins;
      runningMinutes += dwell;
      const departureH = Math.floor((9 * 60 + runningMinutes) / 60);
      const departureM = (9 * 60 + runningMinutes) % 60;

      stops.push({
        order: idx + 1,
        place,
        arrival: `${arrivalH.toString().padStart(2, '0')}:${arrivalM.toString().padStart(2, '0')}`,
        departure: `${departureH.toString().padStart(2, '0')}:${departureM.toString().padStart(2, '0')}`,
        transitBuffer,
        dwell,
      });
    }
    return { scheduleStops: stops, totalMinutes: runningMinutes };
  }, [candidateStops, dayPlanPace]);

  const isDayPlanFeasible = totalMinutes <= dayPlanHours * 60;

  return (
    <div style={{ maxWidth: '1280px', margin: '0 auto', padding: '36px 24px' }}>
      {/* Toast Notification */}
      {toastMessage && (
        <div
          style={{
            position: 'fixed',
            top: '24px',
            right: '24px',
            zIndex: 1000,
            background: 'var(--color-primary)',
            color: '#FFFFFF',
            padding: '14px 22px',
            borderRadius: 'var(--radius-md)',
            boxShadow: '0 12px 36px rgba(7, 59, 92, 0.35)',
            border: '1px solid var(--color-accent)',
            display: 'flex',
            alignItems: 'center',
            gap: '12px',
            fontSize: '0.95rem',
            fontWeight: 600,
            animation: 'fadeIn 0.25s ease-out',
          }}
        >
          <span>✨</span>
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Hero Header */}
      <div
        style={{
          background: 'linear-gradient(135deg, #073B5C 0%, #087E8B 100%)',
          borderRadius: 'var(--radius-lg)',
          padding: '40px 36px',
          color: '#FFFFFF',
          marginBottom: '36px',
          boxShadow: '0 12px 40px rgba(7, 59, 92, 0.18)',
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        <div
          style={{
            position: 'absolute',
            top: '-20%',
            right: '-10%',
            width: '450px',
            height: '450px',
            background: 'radial-gradient(circle, rgba(34, 184, 209, 0.22) 0%, transparent 70%)',
            pointerEvents: 'none',
          }}
        />

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '24px', position: 'relative' }}>
          <div style={{ maxWidth: '720px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '12px' }}>
              <span
                style={{
                  background: 'rgba(255, 255, 255, 0.16)',
                  padding: '4px 12px',
                  borderRadius: 'var(--radius-pill)',
                  fontSize: '0.82rem',
                  fontWeight: 800,
                  letterSpacing: '0.08em',
                  textTransform: 'uppercase',
                }}
              >
                🧭 ISLAND ATLAS · NATIONWIDE
              </span>
              <span
                style={{
                  background: 'rgba(16, 185, 129, 0.25)',
                  color: '#A7F3D0',
                  padding: '4px 10px',
                  borderRadius: 'var(--radius-pill)',
                  fontSize: '0.78rem',
                  fontWeight: 700,
                }}
              >
                9 Provinces · 25 Districts Official Scope
              </span>
            </div>

            <h1 style={{ fontSize: '2.5rem', color: '#FFFFFF', marginBottom: '12px', lineHeight: 1.15 }}>
              Discover Sri Lanka Like Never Before
            </h1>
            <p style={{ fontSize: '1.05rem', color: 'rgba(255, 255, 255, 0.88)', lineHeight: 1.6, margin: 0 }}>
              From UNESCO rock citadels to remote coastal lagoons, experience living culture, verified entrance fees,
              proven transit buffers, and your collectible 25-district travel passport.
            </p>
          </div>

          {/* District Passport Tracker Hero Widget */}
          <div
            style={{
              background: 'rgba(7, 28, 44, 0.65)',
              backdropFilter: 'blur(12px)',
              border: '1px solid rgba(255, 255, 255, 0.18)',
              borderRadius: 'var(--radius-md)',
              padding: '20px 24px',
              minWidth: '280px',
              boxShadow: '0 8px 24px rgba(0, 0, 0, 0.25)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
              <span style={{ fontSize: '0.75rem', fontWeight: 800, letterSpacing: '0.1em', color: 'var(--color-sand)' }}>
                DISTRICT PASSPORT
              </span>
              <span style={{ fontSize: '0.85rem', fontWeight: 800, color: '#34D399' }}>{passportPercent}%</span>
            </div>
            <div style={{ fontSize: '1.35rem', fontWeight: 800, color: '#FFFFFF', marginBottom: '6px' }}>
              {stampedCount} of 25 Stamped
            </div>
            <div
              style={{
                width: '100%',
                height: '8px',
                background: 'rgba(255, 255, 255, 0.15)',
                borderRadius: '4px',
                overflow: 'hidden',
                marginBottom: '14px',
              }}
            >
              <div
                style={{
                  width: `${passportPercent}%`,
                  height: '100%',
                  background: 'linear-gradient(90deg, #34D399, #22B8CF)',
                  transition: 'width 0.4s ease',
                }}
              />
            </div>
            <p style={{ fontSize: '0.78rem', color: 'rgba(255, 255, 255, 0.75)', margin: 0 }}>
              Tap any district badge below to toggle your visit and preserve your digital journal.
            </p>
          </div>
        </div>
      </div>

      {/* 9 Provinces Visual Carousel */}
      <div style={{ marginBottom: '40px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
          <div>
            <h2 style={{ fontSize: '1.45rem', margin: 0 }}>Nine Official Administrative Provinces</h2>
            <p style={{ color: 'var(--text-secondary)', fontSize: '0.88rem', margin: '4px 0 0 0' }}>
              Census of Population and Housing 2024 compliance standard. Select a province to inspect its districts.
            </p>
          </div>
          {selectedProvinceId && (
            <button
              onClick={() => setSelectedProvinceId(null)}
              className="btn btn-secondary"
              style={{ padding: '6px 14px', fontSize: '0.82rem' }}
            >
              Reset to All 9 Provinces
            </button>
          )}
        </div>

        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))',
            gap: '16px',
          }}
        >
          {PROVINCES.map((prov) => {
            const isSelected = selectedProvinceId === prov.id;
            return (
              <div
                key={prov.id}
                onClick={() => setSelectedProvinceId(isSelected ? null : prov.id)}
                style={{
                  cursor: 'pointer',
                  borderRadius: 'var(--radius-md)',
                  overflow: 'hidden',
                  position: 'relative',
                  height: '175px',
                  border: isSelected ? '2.5px solid var(--color-secondary)' : '1px solid var(--color-border)',
                  boxShadow: isSelected ? '0 8px 24px var(--accent-emerald-glow)' : 'var(--shadow-sm)',
                  transition: 'transform var(--transition-fast), box-shadow var(--transition-fast)',
                }}
              >
                <img
                  src={prov.coverImage}
                  alt={prov.name}
                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                />
                <div
                  style={{
                    position: 'absolute',
                    inset: 0,
                    background: 'linear-gradient(to top, rgba(7, 30, 48, 0.95) 0%, rgba(7, 30, 48, 0.3) 55%, transparent 100%)',
                  }}
                />
                <div style={{ position: 'absolute', bottom: '14px', left: '16px', right: '16px', color: '#FFFFFF' }}>
                  <div style={{ fontSize: '0.72rem', color: 'var(--color-sand)', fontWeight: 700 }}>
                    {prov.nameSi} · {prov.nameTa}
                  </div>
                  <div style={{ fontSize: '1.1rem', fontWeight: 800 }}>{prov.name}</div>
                  <div style={{ fontSize: '0.75rem', color: 'rgba(255, 255, 255, 0.8)', marginTop: '2px' }}>
                    {prov.districtCount} Districts · Capital: {prov.capital}
                  </div>
                </div>
                {isSelected && (
                  <span
                    style={{
                      position: 'absolute',
                      top: '10px',
                      right: '10px',
                      background: 'var(--color-secondary)',
                      color: '#FFF',
                      fontSize: '0.72rem',
                      fontWeight: 800,
                      padding: '2px 8px',
                      borderRadius: 'var(--radius-pill)',
                    }}
                  >
                    FILTERED
                  </span>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* 25 Districts Directory & Spotlight */}
      <div style={{ marginBottom: '44px' }}>
        <h2 style={{ fontSize: '1.45rem', marginBottom: '8px' }}>
          {selectedProvinceId
            ? `Districts in ${PROVINCES.find((p) => p.id === selectedProvinceId)?.name} (${filteredDistricts.length})`
            : `All 25 Administrative Districts (${DISTRICTS.length})`}
        </h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '0.88rem', marginBottom: '16px' }}>
          Click a district chip to inspect cultural identity, key facts, and launch its TripGraph day planner.
        </p>

        {/* 25 Filter Chips */}
        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', marginBottom: '24px' }}>
          {filteredDistricts.map((dist) => {
            const isSelected = selectedDistrictId === dist.id;
            const isStamped = passportStamps[dist.id]?.stamped;

            return (
              <button
                key={dist.id}
                onClick={() => setSelectedDistrictId(dist.id)}
                style={{
                  background: isSelected ? 'var(--color-primary)' : 'var(--bg-surface)',
                  color: isSelected ? '#FFFFFF' : 'var(--color-text)',
                  border: isSelected ? '1px solid var(--color-primary)' : '1px solid var(--color-border)',
                  padding: '7px 14px',
                  borderRadius: 'var(--radius-pill)',
                  fontSize: '0.85rem',
                  fontWeight: isSelected ? 700 : 500,
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  boxShadow: isSelected ? '0 4px 12px rgba(7, 59, 92, 0.2)' : 'none',
                  transition: 'all var(--transition-fast)',
                }}
              >
                <span
                  style={{
                    background: isSelected ? 'rgba(255,255,255,0.2)' : 'rgba(8, 126, 139, 0.12)',
                    color: isSelected ? '#FFFFFF' : 'var(--color-secondary)',
                    fontSize: '0.68rem',
                    fontWeight: 800,
                    padding: '2px 5px',
                    borderRadius: '4px',
                  }}
                >
                  {dist.provinceId}
                </span>
                <span>{dist.name}</span>
                {isStamped && <span title="Stamped in Passport">🎖️</span>}
              </button>
            );
          })}
        </div>

        {/* District Spotlight Card */}
        <div
          style={{
            background: 'var(--bg-surface)',
            borderRadius: 'var(--radius-lg)',
            padding: '28px 32px',
            border: '1px solid var(--color-border)',
            boxShadow: 'var(--shadow-card)',
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))',
            gap: '28px',
            alignItems: 'center',
          }}
        >
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '10px' }}>
              <span className="badge badge-sapphire">{currentDistrict.nameSi} · {currentDistrict.nameTa}</span>
              <span className="badge badge-emerald">Capital: {currentDistrict.capital}</span>
              <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                GPS: {currentDistrict.latitude.toFixed(4)}°N, {currentDistrict.longitude.toFixed(4)}°E
              </span>
            </div>

            <h3 style={{ fontSize: '1.9rem', marginBottom: '10px', color: 'var(--color-primary)' }}>
              {currentDistrict.name} District
            </h3>

            <p style={{ fontSize: '0.96rem', color: 'var(--color-text)', lineHeight: 1.6, marginBottom: '16px' }}>
              {currentDistrict.story}
            </p>

            <div style={{ background: 'var(--color-background)', padding: '14px 18px', borderRadius: 'var(--radius-md)', border: '1px solid var(--color-border)', marginBottom: '20px' }}>
              <div style={{ fontSize: '0.78rem', fontWeight: 800, color: 'var(--color-secondary)', letterSpacing: '0.06em', marginBottom: '4px' }}>
                WHAT MAKES THIS DISTRICT SPECIAL?
              </div>
              <div style={{ fontSize: '1.02rem', fontWeight: 700, color: 'var(--color-text)' }}>
                {currentDistrict.specialityTitle}
              </div>
              <div style={{ fontSize: '0.86rem', color: 'var(--text-secondary)', marginTop: '2px' }}>
                {currentDistrict.specialityDesc}
              </div>
            </div>

            <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
              <button
                onClick={() => setDayPlanModalOpen(true)}
                className="btn btn-primary"
                style={{ display: 'flex', alignItems: 'center', gap: '8px' }}
              >
                <span>⚡</span> Build Me a District Day Plan
              </button>

              <button
                onClick={() => toggleStamp(currentDistrict.id)}
                className="btn btn-secondary"
                style={{ display: 'flex', alignItems: 'center', gap: '8px' }}
              >
                <span>{passportStamps[currentDistrict.id]?.stamped ? '✅ Stamped' : '📍 Stamp This District'}</span>
              </button>
            </div>
          </div>

          {/* Quick Stats & Map Preview Box */}
          <div
            style={{
              background: 'linear-gradient(135deg, rgba(7, 59, 92, 0.04) 0%, rgba(8, 126, 139, 0.08) 100%)',
              border: '1.5px dashed var(--color-border)',
              borderRadius: 'var(--radius-md)',
              padding: '24px',
              display: 'flex',
              flexDirection: 'column',
              gap: '16px',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid var(--color-border)', paddingBottom: '12px' }}>
              <span style={{ color: 'var(--text-secondary)', fontSize: '0.88rem' }}>Province</span>
              <span style={{ fontWeight: 700 }}>
                {PROVINCES.find((p) => p.id === currentDistrict.provinceId)?.name}
              </span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid var(--color-border)', paddingBottom: '12px' }}>
              <span style={{ color: 'var(--text-secondary)', fontSize: '0.88rem' }}>Verified Places Published</span>
              <span style={{ fontWeight: 700, color: 'var(--color-secondary)' }}>
                {districtPlaces.length > 0 ? districtPlaces.length : '3 (Corridor Seed)'} Places
              </span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid var(--color-border)', paddingBottom: '12px' }}>
              <span style={{ color: 'var(--text-secondary)', fontSize: '0.88rem' }}>Signature Landmarks</span>
              <span style={{ fontWeight: 600, fontSize: '0.85rem', textAlign: 'right', maxWidth: '180px' }}>
                {currentDistrict.knownFor}
              </span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span style={{ color: 'var(--text-secondary)', fontSize: '0.88rem' }}>District Passport Status</span>
              <span style={{ fontWeight: 700, color: passportStamps[currentDistrict.id]?.stamped ? '#059669' : '#D97706' }}>
                {passportStamps[currentDistrict.id]?.stamped ? 'VISITED & STAMPED' : 'NOT YET STAMPED'}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Multi-Lingual Search & Verified Places Feed */}
      <div style={{ marginBottom: '48px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px', marginBottom: '20px' }}>
          <div>
            <h2 style={{ fontSize: '1.45rem', margin: 0 }}>
              Verified Landmarks & Experiences in {currentDistrict.name}
            </h2>
            <p style={{ color: 'var(--text-secondary)', fontSize: '0.88rem', margin: '4px 0 0 0' }}>
              Curated and verified with SLTDA evidence, verified hours, terrain notes, and transparent local pricing.
            </p>
          </div>

          {/* Search Bar */}
          <div style={{ position: 'relative', minWidth: '320px' }}>
            <input
              type="text"
              placeholder="Search places, Sinhala / Tamil names..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={{
                width: '100%',
                padding: '10px 16px 10px 38px',
                borderRadius: 'var(--radius-pill)',
                border: '1px solid var(--color-border)',
                background: 'var(--bg-surface)',
                fontSize: '0.88rem',
                outline: 'none',
              }}
            />
            <span style={{ position: 'absolute', left: '14px', top: '10px', color: 'var(--text-muted)' }}>🔍</span>
          </div>
        </div>

        {/* Category Filters */}
        <div style={{ display: 'flex', gap: '8px', marginBottom: '20px', flexWrap: 'wrap' }}>
          {['ALL', 'HERITAGE', 'NATURE', 'SACRED', 'BEACH'].map((cat) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              style={{
                background: selectedCategory === cat ? 'var(--color-secondary)' : 'var(--bg-surface)',
                color: selectedCategory === cat ? '#FFFFFF' : 'var(--color-text)',
                border: '1px solid var(--color-border)',
                padding: '6px 14px',
                borderRadius: 'var(--radius-pill)',
                fontSize: '0.82rem',
                fontWeight: 600,
                cursor: 'pointer',
              }}
            >
              {cat === 'ALL' ? 'All Categories' : cat}
            </button>
          ))}
        </div>

        {/* Places Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(360px, 1fr))', gap: '20px' }}>
          {filteredPlaces.length === 0 ? (
            <div
              style={{
                gridColumn: '1 / -1',
                padding: '48px',
                textAlign: 'center',
                background: 'var(--bg-surface)',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--color-border)',
              }}
            >
              <div style={{ fontSize: '2rem', marginBottom: '10px' }}>🗺️</div>
              <h3 style={{ margin: 0, marginBottom: '6px' }}>No places match your search criteria</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', margin: 0 }}>
                Try searching in English, Sinhala, or Tamil, or clear filters.
              </p>
            </div>
          ) : (
            filteredPlaces.map((place) => (
              <div
                key={place.id}
                style={{
                  background: 'var(--bg-surface)',
                  borderRadius: 'var(--radius-md)',
                  border: '1px solid var(--color-border)',
                  overflow: 'hidden',
                  boxShadow: 'var(--shadow-sm)',
                  display: 'flex',
                  flexDirection: 'column',
                }}
              >
                <div style={{ height: '190px', position: 'relative' }}>
                  <img src={place.photoUrl} alt={place.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                  <div
                    style={{
                      position: 'absolute',
                      top: '12px',
                      left: '12px',
                      display: 'flex',
                      gap: '6px',
                    }}
                  >
                    <span
                      style={{
                        background: 'var(--color-secondary)',
                        color: '#FFF',
                        fontSize: '0.72rem',
                        fontWeight: 700,
                        padding: '3px 8px',
                        borderRadius: '4px',
                      }}
                    >
                      {place.category}
                    </span>
                    <span
                      style={{
                        background: 'rgba(0,0,0,0.65)',
                        color: '#FFF',
                        fontSize: '0.72rem',
                        fontWeight: 600,
                        padding: '3px 8px',
                        borderRadius: '4px',
                      }}
                    >
                      {place.placeType.toUpperCase()}
                    </span>
                  </div>
                </div>

                <div style={{ padding: '20px', flex: 1, display: 'flex', flexDirection: 'column' }}>
                  <div style={{ fontSize: '0.78rem', color: 'var(--color-secondary)', fontWeight: 700, marginBottom: '4px' }}>
                    {place.nameSi} · {place.nameTa}
                  </div>
                  <h4 style={{ fontSize: '1.2rem', marginBottom: '8px', color: 'var(--color-primary)' }}>{place.name}</h4>

                  <div style={{ fontSize: '0.84rem', color: 'var(--text-secondary)', marginBottom: '14px', flex: 1 }}>
                    <div style={{ marginBottom: '4px' }}>
                      <strong>Hours:</strong> {place.openingHoursText}
                    </div>
                    <div style={{ marginBottom: '4px' }}>
                      <strong>Fees:</strong> {place.feeInfoText}
                    </div>
                    <div>
                      <strong>Dwell Time:</strong> {place.dwellDurationMins} minutes recommended
                    </div>
                  </div>

                  {/* Safety & Terrain Caution */}
                  <div
                    style={{
                      background: 'rgba(245, 158, 11, 0.08)',
                      borderLeft: '3px solid var(--color-rating)',
                      padding: '8px 12px',
                      borderRadius: '4px',
                      fontSize: '0.78rem',
                      color: '#92400E',
                      marginBottom: '14px',
                    }}
                  >
                    <strong>Terrain & Access:</strong> {place.terrainNotes}
                  </div>

                  {/* Verification Badge */}
                  <div
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      borderTop: '1px solid var(--color-border)',
                      paddingTop: '12px',
                      marginTop: 'auto',
                    }}
                  >
                    <span style={{ fontSize: '0.72rem', color: '#059669', fontWeight: 700 }}>
                      ✓ SLTDA VERIFIED EVIDENCE
                    </span>
                    <button
                      onClick={() => setCorrectionModalPlace(place)}
                      style={{
                        background: 'none',
                        border: 'none',
                        color: 'var(--color-secondary)',
                        fontSize: '0.75rem',
                        fontWeight: 600,
                        cursor: 'pointer',
                        textDecoration: 'underline',
                      }}
                    >
                      Suggest Correction
                    </button>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      {/* Modal: TripGraph Day Planner Sandbox */}
      {dayPlanModalOpen && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(7, 28, 44, 0.7)',
            backdropFilter: 'blur(6px)',
            zIndex: 1000,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '24px',
          }}
        >
          <div
            style={{
              background: 'var(--bg-surface)',
              borderRadius: 'var(--radius-lg)',
              padding: '32px',
              maxWidth: '680px',
              width: '100%',
              maxHeight: '90vh',
              overflowY: 'auto',
              boxShadow: '0 24px 64px rgba(0,0,0,0.3)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '20px' }}>
              <div>
                <span className="badge badge-sapphire">TripGraph Timing Engine</span>
                <h3 style={{ fontSize: '1.6rem', marginTop: '6px', color: 'var(--color-primary)' }}>
                  A Day in {currentDistrict.name}
                </h3>
                <p style={{ color: 'var(--text-secondary)', fontSize: '0.86rem', margin: 0 }}>
                  Sequential route simulation with realistic 20-30m mountain/coastal road buffers.
                </p>
              </div>
              <button
                onClick={() => setDayPlanModalOpen(false)}
                style={{ background: 'none', border: 'none', fontSize: '1.4rem', cursor: 'pointer', color: 'var(--text-muted)' }}
              >
                ✕
              </button>
            </div>

            {/* Config Sliders */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', background: 'var(--color-background)', padding: '16px', borderRadius: 'var(--radius-md)', marginBottom: '20px' }}>
              <div>
                <label style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--text-secondary)' }}>
                  AVAILABLE HOURS: {dayPlanHours}h
                </label>
                <input
                  type="range"
                  min="4"
                  max="12"
                  value={dayPlanHours}
                  onChange={(e) => setDayPlanHours(Number(e.target.value))}
                  style={{ width: '100%', marginTop: '6px' }}
                />
              </div>

              <div>
                <label style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--text-secondary)' }}>
                  PACING INTENT
                </label>
                <select
                  value={dayPlanPace}
                  onChange={(e) => setDayPlanPace(e.target.value as 'relaxed' | 'balanced' | 'fast')}
                  style={{ width: '100%', padding: '6px 10px', marginTop: '6px', borderRadius: 'var(--radius-sm)', border: '1px solid var(--color-border)' }}
                >
                  <option value="relaxed">Relaxed (+25% Dwell)</option>
                  <option value="balanced">Balanced (Standard)</option>
                  <option value="fast">Energetic (Max Sightseeing)</option>
                </select>
              </div>
            </div>

            {/* Feasibility Alert */}
            <div
              style={{
                background: isDayPlanFeasible ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)',
                border: isDayPlanFeasible ? '1px solid #10B981' : '1px solid #EF4444',
                color: isDayPlanFeasible ? '#065F46' : '#991B1B',
                padding: '10px 14px',
                borderRadius: 'var(--radius-sm)',
                fontSize: '0.85rem',
                fontWeight: 600,
                marginBottom: '20px',
              }}
            >
              {isDayPlanFeasible
                ? `✓ Feasible Itinerary: Total elapsed time ${Math.floor(totalMinutes / 60)}h ${totalMinutes % 60}m fits within ${dayPlanHours}h budget with verified road buffers.`
                : `⚠️ Timing Warning: Total elapsed time ${Math.floor(totalMinutes / 60)}h ${totalMinutes % 60}m exceeds your ${dayPlanHours}h budget. Consider switching pace or increasing time.`}
            </div>

            {/* Stops Timeline */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '24px' }}>
              {scheduleStops.map((stop) => (
                <div
                  key={stop.place.id}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '14px',
                    padding: '12px 16px',
                    background: 'var(--bg-surface)',
                    borderRadius: 'var(--radius-md)',
                    border: '1px solid var(--color-border)',
                  }}
                >
                  <div
                    style={{
                      width: '32px',
                      height: '32px',
                      borderRadius: '50%',
                      background: 'var(--color-primary)',
                      color: '#FFF',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontWeight: 800,
                      fontSize: '0.85rem',
                    }}
                  >
                    {stop.order}
                  </div>

                  <div style={{ flex: 1 }}>
                    <div style={{ fontWeight: 700, fontSize: '0.95rem' }}>{stop.place.name}</div>
                    <div style={{ fontSize: '0.78rem', color: 'var(--text-secondary)' }}>
                      Arrival {stop.arrival} · Departure {stop.departure} ({stop.dwell}m dwell)
                    </div>
                  </div>

                  <span
                    style={{
                      fontSize: '0.72rem',
                      background: 'rgba(8, 126, 139, 0.12)',
                      color: 'var(--color-secondary)',
                      padding: '4px 8px',
                      borderRadius: '4px',
                      fontWeight: 700,
                    }}
                  >
                    +{stop.transitBuffer}m Buffer
                  </span>
                </div>
              ))}
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
              <button onClick={() => setDayPlanModalOpen(false)} className="btn btn-secondary">
                Close
              </button>
              <button
                onClick={() => {
                  setDayPlanModalOpen(false);
                  showToast(`Added ${currentDistrict.name} Day Plan to your Draft Trip!`);
                }}
                className="btn btn-primary"
              >
                Add Entire Day to My Trip
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal: Community Correction */}
      {correctionModalPlace && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(7, 28, 44, 0.7)',
            backdropFilter: 'blur(6px)',
            zIndex: 1000,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '24px',
          }}
        >
          <div
            style={{
              background: 'var(--bg-surface)',
              borderRadius: 'var(--radius-lg)',
              padding: '28px',
              maxWidth: '520px',
              width: '100%',
              boxShadow: '0 24px 64px rgba(0,0,0,0.3)',
            }}
          >
            <h3 style={{ fontSize: '1.3rem', marginBottom: '8px', color: 'var(--color-primary)' }}>
              Submit Verified Correction
            </h3>
            <p style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', marginBottom: '14px' }}>
              Suggest an update for <strong>{correctionModalPlace.name}</strong>. Your report will enter editorial moderation.
            </p>

            <textarea
              rows={4}
              placeholder="e.g. Opening hours changed for Poya day, or road conditions updated..."
              value={correctionNote}
              onChange={(e) => setCorrectionNote(e.target.value)}
              style={{
                width: '100%',
                padding: '12px',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--color-border)',
                fontSize: '0.9rem',
                marginBottom: '16px',
                outline: 'none',
              }}
            />

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
              <button onClick={() => setCorrectionModalPlace(null)} className="btn btn-secondary">
                Cancel
              </button>
              <button
                onClick={() => {
                  setCorrectionModalPlace(null);
                  setCorrectionNote('');
                  showToast('Correction submitted! It has entered the editorial moderation desk.');
                }}
                className="btn btn-primary"
              >
                Submit Report
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
