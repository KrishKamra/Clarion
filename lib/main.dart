import 'package:flutter/material.dart';

void main() {
  runApp(const ClarionApp());
}

/// Root widget for the Clarion application.
class ClarionApp extends StatelessWidget {
  const ClarionApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryNavy = Color(0xFF0F172A); // Slate 900
    const secondarySlate = Color(0xFF334155); // Slate 700
    const backgroundSlate = Color(0xFFF8FAFC); // Slate 50
    const cardSurface = Colors.white;

    return MaterialApp(
      title: 'Clarion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryNavy,
          primary: primaryNavy,
          secondary: secondarySlate,
          surface: cardSurface,
        ),
        scaffoldBackgroundColor: backgroundSlate,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          color: cardSurface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryNavy, width: 2),
          ),
        ),
      ),
      home: const ClarionHomeScreen(),
    );
  }
}

/// Data model representing a product evaluated by Clarion's DSS engine.
class Product {
  final String id;
  final String title;
  final String category;
  final double price;
  final int fitScore;
  final String fitReason;
  final IconData icon;
  final Color scoreColor;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.fitScore,
    required this.fitReason,
    required this.icon,
    required this.scoreColor,
  });
}

/// Main Home Screen featuring Intent Search and Personal Fit product feed.
class ClarionHomeScreen extends StatefulWidget {
  const ClarionHomeScreen({super.key});

  @override
  State<ClarionHomeScreen> createState() => _ClarionHomeScreenState();
}

class _ClarionHomeScreenState extends State<ClarionHomeScreen> {
  final TextEditingController _intentController = TextEditingController();
  int _selectedNavIndex = 0;
  String _activeIntentFilter = 'All Intents';

  // Sample seed data representing Clarion's Decision Support Engine output
  final List<Product> _sampleProducts = const [
    Product(
      id: 'prod_1',
      title: 'Ergonomic Split Mechanical Keyboard',
      category: 'Workspace & Ergonomics',
      price: 149.00,
      fitScore: 94,
      fitReason:
          'High posture alignment & silent tactile switches ideal for deep work sessions.',
      icon: Icons.keyboard_rounded,
      scoreColor: Color(0xFF059669), // Emerald 600
    ),
    Product(
      id: 'prod_2',
      title: 'Active Noise-Canceling Headphones',
      category: 'Focus & Audio',
      price: 229.00,
      fitScore: 88,
      fitReason:
          'Acoustic isolation matches your intent for distraction-free office work.',
      icon: Icons.headphones_rounded,
      scoreColor: Color(0xFF0284C7), // Light Blue 600
    ),
    Product(
      id: 'prod_3',
      title: 'Minimalist Warm LED Desk Light',
      category: 'Lighting & Wellness',
      price: 59.00,
      fitScore: 81,
      fitReason:
          'Circadian dimming reduces eye fatigue during evening coding tasks.',
      icon: Icons.lightbulb_outline_rounded,
      scoreColor: Color(0xFF4F46E5), // Indigo 600
    ),
  ];

  @override
  void dispose() {
    _intentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clarion',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Clear Intent. Conscious Commerce.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8), // Slate 400
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Budget Guardian Status',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      r'Budget Guardian: $450.00 monthly headroom remaining.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Top Intent Header & Search Bar
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'What are you looking to accomplish?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _intentController,
                    style: const TextStyle(color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText:
                          'e.g., Set up a noise-free home office for focused work...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF475569),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded,
                            color: Color(0xFF0F172A)),
                        onPressed: () {
                          if (_intentController.text.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Evaluating intent: "${_intentController.text}"'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quick Intent Tags
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildIntentChip('All Intents'),
                        const SizedBox(width: 8),
                        _buildIntentChip('Ergonomic Focus'),
                        const SizedBox(width: 8),
                        _buildIntentChip('Deep Work'),
                        const SizedBox(width: 8),
                        _buildIntentChip('Night Reading'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section Title: Personal Fit Recommendations
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Fit Recommendations',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Evaluated by Clarion DSS Heuristics',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: const Text('Criteria'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Feed of Stubbed Products with Fit Score Badges
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = _sampleProducts[index];
                  return _buildProductCard(context, product);
                },
                childCount: _sampleProducts.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.compass_calibration_outlined),
            selectedIcon: Icon(Icons.compass_calibration_rounded),
            label: 'Decision Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer_rounded),
            label: 'Anti-Impulse',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildIntentChip(String label) {
    final isSelected = _activeIntentFilter == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.white,
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.white : const Color(0xFF334155),
        ),
      ),
      onSelected: (selected) {
        setState(() {
          _activeIntentFilter = label;
        });
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category + Fit Score Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                // Personal Fit Score Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: product.scoreColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: product.scoreColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.fitScore}% Fit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: product.scoreColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Icon + Title & Price Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    product.icon,
                    size: 28,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Heuristic Rationale Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.psychology_outlined,
                    size: 18,
                    color: Color(0xFF475569),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.fitReason,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF334155),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action Buttons: Trade-offs & Save
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Opening Trade-Off Matrix for ${product.title}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                    label: const Text('Trade-offs'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${product.title} added to Anti-Impulse Vault.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                    label: const Text('Vault Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
