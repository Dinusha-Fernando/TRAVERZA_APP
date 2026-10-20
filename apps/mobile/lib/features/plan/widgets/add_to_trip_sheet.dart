import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AddToTripSheet extends StatefulWidget {
  final Function(String title, String category, String subtitle, String price)? onItemAdded;

  const AddToTripSheet({super.key, this.onItemAdded});

  static Future<void> show(BuildContext context, {Function(String title, String category, String subtitle, String price)? onItemAdded}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddToTripSheet(onItemAdded: onItemAdded),
    );
  }

  @override
  State<AddToTripSheet> createState() => _AddToTripSheetState();
}

class _AddToTripSheetState extends State<AddToTripSheet> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Places & POIs', 'icon': Icons.place_outlined},
    {'label': 'Stays', 'icon': Icons.hotel_outlined},
    {'label': 'Transport', 'icon': Icons.directions_car_outlined},
    {'label': 'Tours', 'icon': Icons.hiking_outlined},
    {'label': 'Guides', 'icon': Icons.person_pin_circle_outlined},
    {'label': 'Dining', 'icon': Icons.restaurant_outlined},
    {'label': 'Free Time', 'icon': Icons.coffee_outlined},
  ];

  final Map<int, List<Map<String, String>>> _sampleOptions = {
    0: [
      {'title': 'Dambulla Golden Rock Temple', 'subtitle': 'Ancient Cave Complex · UNESCO Heritage', 'price': 'LKR 3,500', 'cat': 'POI'},
      {'title': 'Pidurangala Rock Sunrise Viewpoint', 'subtitle': 'Panoramic 360 view facing Sigiriya Lion Rock', 'price': 'LKR 1,500', 'cat': 'POI'},
      {'title': 'Temple of the Sacred Tooth Relic (Sri Dalada Maligawa)', 'subtitle': 'Kandy historic royal palace complex', 'price': 'LKR 2,000', 'cat': 'POI'},
    ],
    1: [
      {'title': 'Amaya Hills Kandy Heritage Resort', 'subtitle': 'Kandyan architecture with mountain views', 'price': 'LKR 32,000 / night', 'cat': 'STAY'},
      {'title': 'Heritance Tea Factory Nuwara Eliya', 'subtitle': 'Converted colonial tea factory experience', 'price': 'LKR 46,000 / night', 'cat': 'STAY'},
    ],
    2: [
      {'title': 'Kandy to Nanu Oya Scenic First Class Train', 'subtitle': 'Mainline observation carriage reserved seats', 'price': 'LKR 5,500 / seat', 'cat': 'TRANSFER'},
      {'title': 'Private Chauffeur Sedan Daily Transfer', 'subtitle': 'English-speaking driver, fuel & tolls included', 'price': 'LKR 14,000 / day', 'cat': 'TRANSFER'},
    ],
    3: [
      {'title': 'Minneriya National Park Elephant Gathering Safari', 'subtitle': 'Private 4x4 open jeep safari with wildlife tracker', 'price': 'LKR 19,500', 'cat': 'ACTIVITY'},
      {'title': 'Peradeniya Royal Botanical Gardens Tour', 'subtitle': 'Historic orchid house & palm avenues', 'price': 'LKR 4,200', 'cat': 'ACTIVITY'},
    ],
    4: [
      {'title': 'Cultural Triangle SLTDA Certified Lecturer Guide', 'subtitle': 'Archeology specialist · English & French speaking', 'price': 'LKR 8,000 / day', 'cat': 'GUIDE'},
    ],
    5: [
      {'title': 'Helga’s Folly Art Nouveau High Tea', 'subtitle': 'Kandy hill forest bohemian estate', 'price': 'LKR 4,500', 'cat': 'MEAL'},
      {'title': 'Hiriwadunna Village Organic Farmer Lunch', 'subtitle': 'Traditional clay pot buffet on lotus lake', 'price': 'LKR 2,800', 'cat': 'MEAL'},
    ],
    6: [
      {'title': 'Afternoon Rest & Acclimatization Window', 'subtitle': 'Dedicated buffer block for highland adaptation', 'price': 'Free Time', 'cat': 'REST'},
      {'title': 'Kandy Lake Sunset Walk & Meditation', 'subtitle': 'Self-paced lakeside leisure buffer', 'price': 'Free Time', 'cat': 'REST'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentItems = _sampleOptions[_selectedCategoryIndex] ?? [];

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TraverzaColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Add to Your Trip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TraverzaColors.text,
                        ),
                      ),
                      Text(
                        'Select services, POIs or rest buffers to integrate',
                        style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: TraverzaColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Category pill selector
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedCategoryIndex;
                final cat = _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    showCheckmark: false,
                    avatar: Icon(
                      cat['icon'] as IconData,
                      size: 15,
                      color: isSelected ? Colors.white : TraverzaColors.secondary,
                    ),
                    label: Text(
                      cat['label'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : TraverzaColors.text,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedCategoryIndex = index);
                    },
                    backgroundColor: TraverzaColors.surface,
                    selectedColor: TraverzaColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? TraverzaColors.secondary : TraverzaColors.border,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: TraverzaColors.border),
          // Options List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: currentItems.length,
              itemBuilder: (context, index) {
                final item = currentItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: TraverzaColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TraverzaColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: TraverzaColors.text,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item['subtitle']!,
                              style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['price']!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: TraverzaColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TraverzaColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          widget.onItemAdded?.call(
                            item['title']!,
                            item['cat']!,
                            item['subtitle']!,
                            item['price']!,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added "${item['title']}" to itinerary'),
                              backgroundColor: TraverzaColors.secondary,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 14, color: Colors.white),
                        label: const Text(
                          'Add',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
