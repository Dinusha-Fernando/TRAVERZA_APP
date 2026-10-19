import 'package:flutter/material.dart';

void main() {
  runApp(const TraverzaApp());
}

class TraverzaApp extends StatelessWidget {
  const TraverzaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRAVERZA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070B12),
        primaryColor: const Color(0xFF10B981),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF0E1624),
          error: Color(0xFFF43F5E),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF0E1624),
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B1320),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const MainTripScreen(),
    );
  }
}

class MainTripScreen extends StatefulWidget {
  const MainTripScreen({super.key});

  @override
  State<MainTripScreen> createState() => _MainTripScreenState();
}

class _MainTripScreenState extends State<MainTripScreen> {
  int _currentIndex = 0;

  // State for interactive confirmation
  bool _hotelConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildTimelineView(),
      _buildFitToTripCatalogue(),
      _buildReadinessView(),
      _buildEmergencyVault(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'T',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'TRAVERZA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'SRI LANKA OPERATING PLATFORM',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0B1320),
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.white54,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.route_outlined),
            activeIcon: Icon(Icons.route),
            label: 'Timeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Fit-to-Trip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check),
            label: 'Readiness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            activeIcon: Icon(Icons.shield),
            label: 'SOS Vault',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    final statusText = _hotelConfirmed
        ? 'Fully Confirmed (3/3)'
        : 'Partially Confirmed (2/3)';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF122238), Color(0xFF0E1624)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trip Timeline',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _hotelConfirmed
                            ? const Color(0x2610B981)
                            : const Color(0x26F59E0B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _hotelConfirmed
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: _hotelConfirmed
                              ? const Color(0xFF34D399)
                              : const Color(0xFFFBBF24),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'ID: TRIP-LK-2026-9041',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFF10B981),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Colombo - Sigiriya - Kandy - Nuwara Eliya (3 Days)',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 16, color: Colors.white54),
                    const SizedBox(width: 6),
                    const Text('2 Travellers', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.payments_outlined, size: 16, color: Colors.white54),
                    const SizedBox(width: 6),
                    const Text('LKR 68,500 Total', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Day 1: Cultural Gateway',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _hotelConfirmed = !_hotelConfirmed;
                    });
                  },
                  child: Text(
                    _hotelConfirmed ? 'Simulate Unconfirmed' : 'Simulate Provider Accept',
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Stop 1: Flight Arrival
          _buildStopCard(
            time: '09:00 - 10:00',
            title: 'Bandaranaike Intl Airport (CMB) Arrival',
            subtitle: 'Flight UL-504 • Customs & Immigration',
            category: 'FLIGHT',
            status: 'NONE',
            icon: Icons.flight_land,
            iconColor: Colors.blueAccent,
            price: null,
          ),

          // Transit buffer connector
          _buildTransitConnector(
            duration: '30m customs buffer',
            note: 'Highland transit calculator verified',
          ),

          // Stop 2: Chauffeur Transfer
          _buildStopCard(
            time: '10:30 - 14:00',
            title: 'Chauffeur Transfer to Sigiriya Cultural Triangle',
            subtitle: 'Ceylon Chauffeurs Guild • Fleet #LK-402 (Toyota Prado)',
            category: 'TRANSFER',
            status: 'CONFIRMED',
            icon: Icons.directions_car,
            iconColor: const Color(0xFF10B981),
            price: 'LKR 18,500',
          ),

          // Transit buffer connector
          _buildTransitConnector(
            duration: '45m check-in buffer',
            note: 'Rest period before ascent',
          ),

          // Stop 3: Sigiriya Rock Fortress Ascent
          _buildStopCard(
            time: '15:00 - 17:30',
            title: 'Sigiriya Rock Fortress Guided Ascent',
            subtitle: 'Cultural Heritage Guide Guild • SLTDA Lic #044',
            category: 'ACTIVITY',
            status: 'CONFIRMED',
            icon: Icons.landscape,
            iconColor: Colors.amberAccent,
            price: 'LKR 12,000',
          ),

          // Stop 4: Eco Villa
          _buildStopCard(
            time: '18:30 Check-in',
            title: 'Sigiriya Water Garden Eco Villa',
            subtitle: 'Deluxe Chalet with Private Plunge Pool',
            category: 'STAY',
            status: _hotelConfirmed ? 'CONFIRMED' : 'REQUEST_SUBMITTED',
            icon: Icons.hotel,
            iconColor: _hotelConfirmed ? const Color(0xFF10B981) : Colors.orangeAccent,
            price: 'LKR 38,000',
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStopCard({
    required String time,
    required String title,
    required String subtitle,
    required String category,
    required String status,
    required IconData icon,
    required Color iconColor,
    String? price,
  }) {
    Color badgeColor = Colors.grey;
    String badgeText = status;
    if (status == 'CONFIRMED') {
      badgeColor = const Color(0xFF10B981);
      badgeText = 'Confirmed';
    } else if (status == 'REQUEST_SUBMITTED') {
      badgeColor = const Color(0xFFF59E0B);
      badgeText = 'Request Pending';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: iconColor.withOpacity(0.15),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (status != 'NONE')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: badgeColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            if (price != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fixed Price Basis (Taxes Included)',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransitConnector({required String duration, required String note}) {
    return Padding(
      padding: const EdgeInsets.only(left: 34, top: 4, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 28,
            color: const Color(0xFF10B981).withOpacity(0.3),
          ),
          const SizedBox(width: 16),
          Icon(Icons.directions_car_outlined, size: 14, color: Colors.white.withOpacity(0.4)),
          const SizedBox(width: 6),
          Text(
            '$duration • $note',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.4),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFitToTripCatalogue() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Fit-to-Trip Verified Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        const Text(
          'Services matched against corridor route, dates, and vehicle capacity.',
          style: TextStyle(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 16),

        _buildCatalogueItem(
          category: 'TRANSFER',
          title: 'Airport to Sigiriya Luxury Transfer',
          provider: 'Ceylon Chauffeurs Guild (Pvt) Ltd',
          license: 'SLTDA/CG/2026/102',
          price: 'LKR 18,500',
          policy: 'Free cancellation up to 24h before pickup',
          rating: '4.98 (124 reviews)',
        ),
        _buildCatalogueItem(
          category: 'STAY',
          title: 'Sigiriya Water Garden Eco Villa',
          provider: 'Boutique Heritage Stays (Pvt) Ltd',
          license: 'SLTDA/SQ/2026/089',
          price: 'LKR 38,000 / night',
          policy: 'Standard 48h cancellation',
          rating: '4.95 (88 reviews)',
        ),
        _buildCatalogueItem(
          category: 'GUIDE',
          title: 'Sacred City of Kandy Walking Tour',
          provider: 'Cultural Heritage Guide Guild',
          license: 'SLTDA/GD/2026/044',
          price: 'LKR 9,500',
          policy: 'Free cancellation up to 24h',
          rating: '4.92 (54 reviews)',
        ),
        _buildCatalogueItem(
          category: 'ACTIVITY',
          title: 'Pedro Tea Estate Heritage Factory Walk',
          provider: 'Highland Tea Excursions (Pvt) Ltd',
          license: 'SLTDA/AC/2026/015',
          price: 'LKR 8,000',
          policy: 'Standard 24h policy',
          rating: '4.89 (42 reviews)',
        ),
      ],
    );
  }

  Widget _buildCatalogueItem({
    required String category,
    required String title,
    required String provider,
    required String license,
    required String price,
    required String policy,
    required String rating,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  rating,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '$provider • $license',
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  policy,
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF34D399),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Trip Readiness Check',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        const Text(
          'Authoritative audit of booking statuses, highland transit feasibility, and compliance.',
          style: TextStyle(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 16),

        _buildCheckItem(
          title: 'Transit Buffer Feasibility',
          subtitle: 'All travel gaps exceed Sri Lanka terrain transit calculator requirements.',
          isOk: true,
        ),
        _buildCheckItem(
          title: 'SLTDA Provider Verification',
          subtitle: 'All 3 booked providers hold active, audited SLTDA licenses.',
          isOk: true,
        ),
        _buildCheckItem(
          title: 'Booking Confirmation Coverage',
          subtitle: _hotelConfirmed
              ? '3 of 3 services fully confirmed.'
              : '2 of 3 confirmed. Sigiriya Eco Villa is in REQUEST_SUBMITTED status.',
          isOk: _hotelConfirmed,
        ),
        _buildCheckItem(
          title: 'Opening Hours & Schedule Invariants',
          subtitle: 'Zero overlapping activities detected by TripGraph.',
          isOk: true,
        ),
      ],
    );
  }

  Widget _buildCheckItem({required String title, required String subtitle, required bool isOk}) {
    return Card(
      child: ListTile(
        leading: Icon(
          isOk ? Icons.check_circle : Icons.warning_amber_rounded,
          color: isOk ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
          size: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
      ),
    );
  }

  Widget _buildEmergencyVault() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Offline SOS & Emergency Vault',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        const Text(
          'Available 100% offline during low-connectivity travel across mountain tea routes.',
          style: TextStyle(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 16),

        _buildEmergencyContact(
          title: 'Sri Lanka Tourist Police Hotline',
          number: '1912',
          description: 'Official SLTDA emergency tourist assistance desk',
          icon: Icons.local_police_outlined,
        ),
        _buildEmergencyContact(
          title: 'Suwa Seriya Emergency Ambulance',
          number: '1990',
          description: 'Free nationwide medical paramedic dispatch',
          icon: Icons.medical_services_outlined,
        ),
        _buildEmergencyContact(
          title: 'TRAVERZA 24/7 Operations Rescue Desk',
          number: '+94 11 289 0123',
          description: 'Emergency vehicle dispatch and supplier re-routing',
          icon: Icons.headset_mic_outlined,
        ),
        _buildEmergencyContact(
          title: 'Assigned Chauffeur (Lalith J.)',
          number: '+94 71 234 8899',
          description: 'Fleet #LK-402 • Direct vehicle mobile',
          icon: Icons.phone_android_outlined,
        ),
      ],
    );
  }

  Widget _buildEmergencyContact({
    required String title,
    required String number,
    required String description,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF43F5E).withOpacity(0.15),
          child: Icon(icon, color: const Color(0xFFF43F5E)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 11, color: Colors.white60),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF43F5E).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
