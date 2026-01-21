import 'package:flutter/material.dart';

class ResponsiveHome extends StatefulWidget {
  const ResponsiveHome({super.key});

  @override
  State<ResponsiveHome> createState() => _ResponsiveHomeState();
}

class _ResponsiveHomeState extends State<ResponsiveHome> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _customers = [
    {'name': 'John Doe', 'visits': 12, 'points': 240},
    {'name': 'Jane Smith', 'visits': 8, 'points': 160},
    {'name': 'Mike Johnson', 'visits': 15, 'points': 300},
    {'name': 'Sarah Williams', 'visits': 5, 'points': 100},
    {'name': 'Tom Brown', 'visits': 20, 'points': 400},
    {'name': 'Emily Davis', 'visits': 10, 'points': 200},
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;

    // Determine device type based on screen width
    final bool isPhone = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1200;
    final bool isDesktop = screenWidth >= 1200;

    // Dynamic padding based on screen size
    final double horizontalPadding = isPhone ? 16.0 : (isTablet ? 32.0 : 48.0);
    final double verticalPadding = isPhone ? 12.0 : (isTablet ? 20.0 : 24.0);

    // Dynamic text sizes
    final double titleSize = isPhone ? 24.0 : (isTablet ? 32.0 : 40.0);
    final double subtitleSize = isPhone ? 14.0 : (isTablet ? 16.0 : 18.0);
    final double bodySize = isPhone ? 16.0 : (isTablet ? 18.0 : 20.0);

    // Grid column count based on device type
    final int gridColumns = isPhone ? 1 : (isTablet ? 2 : 3);

    return Scaffold(
      // HEADER SECTION - AppBar with responsive title
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Customer Loop - Responsive Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: titleSize * 0.7,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        actions: [
          if (!isPhone)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  orientation == Orientation.portrait
                      ? 'Portrait'
                      : 'Landscape',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
        ],
      ),

      // MAIN CONTENT AREA
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards Section - Using Flexible and Expanded
                _buildStatsSection(
                  screenWidth: screenWidth,
                  isPhone: isPhone,
                  isTablet: isTablet,
                  subtitleSize: subtitleSize,
                  bodySize: bodySize,
                ),

                const SizedBox(height: 24),

                // Device Info Section
                _buildDeviceInfoCard(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  orientation: orientation,
                  isPhone: isPhone,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                  subtitleSize: subtitleSize,
                ),

                const SizedBox(height: 24),

                // Customer Grid - Adaptive layout
                Text(
                  'Recent Customers',
                  style: TextStyle(
                    fontSize: titleSize * 0.8,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),

                // GridView for adaptive customer cards
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridColumns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isPhone ? 3 : 2.5,
                  ),
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    return _buildCustomerCard(
                      _customers[index],
                      isPhone,
                      bodySize,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Responsive Buttons using Wrap
                _buildActionButtons(isPhone, bodySize),

                const SizedBox(height: 80), // Space for footer
              ],
            ),
          );
        },
      ),

      // FOOTER SECTION - Bottom navigation or action bar
      bottomNavigationBar: _buildFooter(isPhone, subtitleSize),
    );
  }

  // Stats Section with Flexible and Expanded widgets
  Widget _buildStatsSection({
    required double screenWidth,
    required bool isPhone,
    required bool isTablet,
    required double subtitleSize,
    required double bodySize,
  }) {
    final stats = [
      {
        'icon': Icons.people,
        'label': 'Customers',
        'value': '1,234',
        'color': Colors.blue,
      },
      {
        'icon': Icons.star,
        'label': 'Points',
        'value': '45.2K',
        'color': Colors.orange,
      },
      {
        'icon': Icons.trending_up,
        'label': 'Growth',
        'value': '+23%',
        'color': Colors.green,
      },
    ];

    if (isPhone) {
      // Single column layout for phones
      return Column(
        children:
            stats
                .map(
                  (stat) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildStatCard(stat, subtitleSize, bodySize, true),
                  ),
                )
                .toList(),
      );
    } else {
      // Row layout with Expanded for tablets and desktops
      return Row(
        children:
            stats
                .map(
                  (stat) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildStatCard(
                        stat,
                        subtitleSize,
                        bodySize,
                        false,
                      ),
                    ),
                  ),
                )
                .toList(),
      );
    }
  }

  Widget _buildStatCard(
    Map<String, dynamic> stat,
    double subtitleSize,
    double bodySize,
    bool isFullWidth,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (stat['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (stat['color'] as Color).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            stat['icon'] as IconData,
            size: 40,
            color: stat['color'] as Color,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    stat['value'] as String,
                    style: TextStyle(
                      fontSize: bodySize * 1.5,
                      fontWeight: FontWeight.bold,
                      color: stat['color'] as Color,
                    ),
                  ),
                ),
                Text(
                  stat['label'] as String,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Device Info Card with MediaQuery details
  Widget _buildDeviceInfoCard({
    required double screenWidth,
    required double screenHeight,
    required Orientation orientation,
    required bool isPhone,
    required bool isTablet,
    required bool isDesktop,
    required double subtitleSize,
  }) {
    String deviceType = isPhone ? 'Phone' : (isTablet ? 'Tablet' : 'Desktop');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.devices, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Device Information',
                  style: TextStyle(
                    fontSize: subtitleSize * 1.3,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildInfoChip('Type', deviceType, Icons.phone_android),
              _buildInfoChip(
                'Width',
                '${screenWidth.toInt()}px',
                Icons.width_full,
              ),
              _buildInfoChip(
                'Height',
                '${screenHeight.toInt()}px',
                Icons.height,
              ),
              _buildInfoChip(
                'Orientation',
                orientation == Orientation.portrait ? 'Portrait' : 'Landscape',
                Icons.screen_rotation,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Customer Card with AspectRatio
  Widget _buildCustomerCard(
    Map<String, dynamic> customer,
    bool isPhone,
    double bodySize,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isPhone ? 12 : 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: isPhone ? 24 : 30,
              backgroundColor: Colors.blue.shade700,
              child: Text(
                customer['name'].toString().substring(0, 1),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isPhone ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      customer['name'],
                      style: TextStyle(
                        fontSize: bodySize * 0.9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${customer['visits']} visits • ${customer['points']} pts',
                        style: TextStyle(
                          fontSize: bodySize * 0.7,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: isPhone ? 16 : 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Action Buttons using Wrap for responsive layout
  Widget _buildActionButtons(bool isPhone, double bodySize) {
    final buttons = [
      {'label': 'Add Customer', 'icon': Icons.person_add, 'color': Colors.blue},
      {'label': 'View Reports', 'icon': Icons.analytics, 'color': Colors.green},
      {'label': 'Settings', 'icon': Icons.settings, 'color': Colors.orange},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children:
          buttons
              .map(
                (btn) => Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(btn['icon'] as IconData),
                    label: Text(
                      btn['label'] as String,
                      style: TextStyle(fontSize: isPhone ? 14 : 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btn['color'] as Color,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isPhone ? 16 : 24,
                        vertical: isPhone ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  // Footer with Bottom Navigation
  Widget _buildFooter(bool isPhone, double subtitleSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isPhone ? 8 : 16,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFooterButton(Icons.home, 'Home', 0, isPhone),
              _buildFooterButton(Icons.people, 'Customers', 1, isPhone),
              _buildFooterButton(Icons.card_giftcard, 'Rewards', 2, isPhone),
              _buildFooterButton(Icons.person, 'Profile', 3, isPhone),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButton(
    IconData icon,
    String label,
    int index,
    bool isPhone,
  ) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isPhone ? 24 : 28,
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isPhone ? 11 : 13,
                  color:
                      isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
