import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EVBenefits extends StatefulWidget {
  const EVBenefits({Key? key}) : super(key: key);

  @override
  State<EVBenefits> createState() => _EVBenefitsState();
}

class _EVBenefitsState extends State<EVBenefits> {
  final ScrollController _scrollController = ScrollController();
  int _currentCategory = 0;

  final List<String> _categories = [
    'Environmental',
    'Economic',
    'Performance',
    'Health',
    'Convenience',
    'Policy Benefits',
    'Latest News',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'EV Benefits & News',
          style: TextStyle(
            fontSize: 20,
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [_buildCategorySelector(), Expanded(child: _buildContent())],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentCategory = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color:
                    _currentCategory == index
                        ? Colors.green
                        : Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      _currentCategory == index
                          ? Colors.green
                          : Colors.grey.shade800,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _categories[index],
                style: TextStyle(
                  color:
                      _currentCategory == index ? Colors.black : Colors.white,
                  fontWeight:
                      _currentCategory == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentCategory) {
      case 0:
        return _buildEnvironmentalBenefits();
      case 1:
        return _buildEconomicBenefits();
      case 2:
        return _buildPerformanceBenefits();
      case 3:
        return _buildHealthBenefits();
      case 4:
        return _buildConvenienceBenefits();
      case 5:
        return _buildPolicyBenefits();
      case 6:
        return _buildLatestNews();
      default:
        return _buildEnvironmentalBenefits();
    }
  }

  Widget _buildEnvironmentalBenefits() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Environmental Benefits',
            'Driving towards a greener future',
            Icons.eco,
          ),
          SizedBox(height: 24),

          _buildBenefitCard(
            'Zero Tailpipe Emissions',
            'Electric vehicles produce zero direct emissions, which helps improve air quality, especially in urban areas.',
            Icons.air,
            Colors.green.shade300,
          ),

          _buildBenefitCard(
            'Reduced Carbon Footprint',
            'Even when accounting for electricity generation, EVs typically have a lower carbon footprint than conventional vehicles over their lifetime.',
            Icons.co2,
            Colors.green.shade400,
          ),

          _buildBenefitCard(
            'Less Noise Pollution',
            'Electric motors are much quieter than internal combustion engines, reducing noise pollution in communities.',
            Icons.volume_off,
            Colors.green.shade500,
          ),

          _buildBenefitCard(
            'Resource Conservation',
            'EVs help reduce dependence on fossil fuels and promote the use of renewable energy sources.',
            Icons.water_drop,
            Colors.green.shade600,
          ),

          _buildInfoCard(
            'Carbon Emission Savings',
            'A typical EV can save approximately 1.5 million grams of CO2 annually compared to the average gasoline-powered vehicle.',
          ),
        ],
      ),
    );
  }

  Widget _buildEconomicBenefits() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Economic Benefits',
            'Save money while saving the planet',
            Icons.savings,
          ),
          SizedBox(height: 24),

          _buildBenefitCard(
            'Lower Operating Costs',
            'EVs cost less to run than conventional vehicles, with electricity being cheaper than petrol or diesel.',
            Icons.bolt,
            Colors.amber.shade300,
          ),

          _buildBenefitCard(
            'Reduced Maintenance',
            'EVs have fewer moving parts and dont require oil changes, resulting in lower maintenance costs.',
            Icons.build,
            Colors.amber.shade400,
          ),

          _buildBenefitCard(
            'Government Incentives',
            'Many governments offer tax credits, rebates, and other incentives to reduce the upfront cost of purchasing an EV.',
            Icons.credit_card,
            Colors.amber.shade500,
          ),

          _buildBenefitCard(
            'Higher Resale Value',
            'EVs are increasingly retaining their value better than traditional vehicles as demand for used EVs grows.',
            Icons.trending_up,
            Colors.amber.shade600,
          ),

          _buildCalculatorCard(),
        ],
      ),
    );
  }

  Widget _buildPerformanceBenefits() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Performance Benefits',
            'Experience the future of driving',
            Icons.speed,
          ),
          SizedBox(height: 24),

          _buildBenefitCard(
            'Instant Torque',
            'Electric motors deliver instant torque, providing quick acceleration from a standstill.',
            Icons.flash_on,
            Colors.blue.shade300,
          ),

          _buildBenefitCard(
            'Smooth Operation',
            'EVs offer a smooth driving experience with no gear shifting and less vibration than internal combustion engines.',
            Icons.timeline,
            Colors.blue.shade400,
          ),

          _buildBenefitCard(
            'Lower Center of Gravity',
            'The battery placement gives EVs a lower center of gravity, improving handling and reducing the risk of rollover.',
            Icons.layers,
            Colors.blue.shade500,
          ),

          _buildBenefitCard(
            'Regenerative Braking',
            'EVs can recover energy during braking, increasing efficiency and extending driving range.',
            Icons.battery_charging_full,
            Colors.blue.shade600,
          ),

          _buildComparisonCard(),
        ],
      ),
    );
  }

  Widget _buildHealthBenefits() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Health Benefits',
            'Breathe easier with clean transportation',
            Icons.favorite,
          ),
          SizedBox(height: 24),

          _buildBenefitCard(
            'Improved Air Quality',
            'By eliminating tailpipe emissions, EVs help reduce harmful air pollutants that cause respiratory issues.',
            Icons.cloud,
            Colors.red.shade300,
          ),

          _buildBenefitCard(
            'Reduced Smog',
            'EVs produce no ground-level ozone, a major component of smog that can trigger health problems.',
            Icons.visibility,
            Colors.red.shade400,
          ),

          _buildBenefitCard(
            'Lower Particulate Matter',
            'EVs dont emit particulate matter, which can penetrate deeply into lungs and cause health issues.',
            Icons.air,
            Colors.red.shade500,
          ),

          _buildBenefitCard(
            'Quieter Environment',
            'The reduction in noise pollution from EVs can lead to less stress and better sleep quality in urban areas.',
            Icons.nightlight,
            Colors.red.shade600,
          ),

          _buildFactCard(
            'According to WHO, air pollution causes approximately 7 million premature deaths worldwide each year, with vehicle emissions being a significant contributor.',
          ),
        ],
      ),
    );
  }

  Widget _buildConvenienceBenefits() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Convenience Benefits',
            'Making daily life easier',
            Icons.thumb_up,
          ),
          SizedBox(height: 24),

          _buildBenefitCard(
            'Home Charging',
            'Charge your vehicle overnight at home, eliminating trips to the gas station.',
            Icons.home,
            Colors.purple.shade300,
          ),

          _buildBenefitCard(
            'Special Parking',
            'Many locations offer preferred parking spots with charging stations for electric vehicles.',
            Icons.local_parking,
            Colors.purple.shade400,
          ),

          _buildBenefitCard(
            'HOV Lane Access',
            'In some regions, EVs qualify for high-occupancy vehicle (HOV) lane access regardless of the number of occupants.',
            Icons.directions_car,
            Colors.purple.shade500,
          ),

          _buildBenefitCard(
            'Smartphone Integration',
            'Many EVs offer advanced smartphone apps to monitor charging, pre-condition the cabin, and more.',
            Icons.smartphone,
            Colors.purple.shade600,
          ),

          _buildChargingNetworkCard(),
        ],
      ),
    );
  }

  Widget _buildPolicyBenefits() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Policy Benefits in India',
            'Government support for EV adoption',
            Icons.policy,
          ),
          SizedBox(height: 24),

          _buildBenefitCard(
            'FAME India Scheme',
            'Faster Adoption and Manufacturing of Electric Vehicles (FAME) provides incentives for purchasing electric vehicles.',
            Icons.attach_money,
            Colors.teal.shade300,
          ),

          _buildBenefitCard(
            'GST Benefits',
            'Reduced GST rates on electric vehicles (5% compared to 28% for conventional vehicles) and EV chargers.',
            Icons.percent,
            Colors.teal.shade400,
          ),

          _buildBenefitCard(
            'Income Tax Benefits',
            'Income tax deductions on interest paid on loans taken to purchase electric vehicles.',
            Icons.monetization_on,
            Colors.teal.shade500,
          ),

          _buildBenefitCard(
            'State-Level Incentives',
            'Many Indian states offer additional incentives like road tax exemptions, registration fee waivers, etc.',
            Icons.location_city,
            Colors.teal.shade600,
          ),

          _buildPolicyHighlightCard(),
        ],
      ),
    );
  }

  Widget _buildLatestNews() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          'Latest EV News',
          'Stay informed about the electric revolution',
          Icons.article,
        ),
        SizedBox(height: 16),

        _buildNewsCard(
          'India\'s EV Sales Cross Major Milestone',
          'Electric vehicle sales in India have surpassed 1 million units, marking a significant milestone in the country\'s transition to clean mobility.',
          'April 26, 2025',
          'https://example.com/news1',
        ),

        _buildNewsCard(
          'New Fast-Charging Network Announced',
          'A major initiative to install 1,000 fast-charging stations across national highways has been announced, addressing range anxiety concerns.',
          'April 22, 2025',
          'https://example.com/news2',
        ),

        _buildNewsCard(
          'Battery Technology Breakthrough',
          'Scientists develop new lithium-sulfur batteries that could double EV range while reducing costs and environmental impact.',
          'April 18, 2025',
          'https://example.com/news3',
        ),

        _buildNewsCard(
          'Government Extends FAME Scheme',
          'India\'s government has announced a three-year extension to the FAME subsidy scheme with increased budget allocation to boost EV adoption.',
          'April 15, 2025',
          'https://example.com/news4',
        ),

        _buildNewsCard(
          'Automaker Pledges to Go All-Electric',
          'Major Indian automaker announces plans to phase out internal combustion engines by 2030, focusing entirely on electric vehicle production.',
          'April 10, 2025',
          'https://example.com/news5',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green, size: 30),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.green,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }

  Widget _buildBenefitCard(
    String title,
    String description,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: iconColor.withOpacity(0.5), width: 1),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildCalculatorCard() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade900.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: Colors.green, size: 22),
              SizedBox(width: 8),
              Text(
                'Savings Calculator',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'A typical EV owner can save approximately:',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSavingsItem('₹15,00', 'Monthly on fuel'),
              _buildSavingsItem('₹8,00', 'Monthly on maintenance'),
              _buildSavingsItem('₹5,00', 'Tax benefits'),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Potential Lifetime Savings: ',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  '₹2,80,000+',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsItem(String amount, String description) {
    return Column(
      children: [
        Text(
          amount,
          style: TextStyle(
            color: Colors.green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildComparisonCard() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade900.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EV vs ICE Performance Comparison',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildComparisonItem(
            'Acceleration',
            'Instant torque provides better acceleration',
            'Delayed power delivery',
          ),
          _buildComparisonItem(
            'Noise Level',
            'Whisper quiet operation',
            'Engine noise and vibration',
          ),
          _buildComparisonItem(
            'Efficiency',
            'Up to 80% energy efficient',
            'Only 20-30% energy efficient',
          ),
          _buildComparisonItem(
            'Maintenance',
            'Fewer moving parts, less maintenance',
            'Regular oil changes and tune-ups required',
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(
    String category,
    String evBenefit,
    String iceBenefit,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              category,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    evBenefit,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    iceBenefit,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Did You Know?',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFactCard(String fact) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: Colors.red.shade300, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              fact,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargingNetworkCard() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Growing Charging Infrastructure in India',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('10,00+', 'Charging Stations'),
              _buildStatItem('1,70+', 'Fast Chargers'),
              _buildStatItem('35+', 'Cities Covered'),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'The charging network in India is expanding rapidly, with new stations being added every month across all major cities and highways.',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.purple.shade300,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPolicyHighlightCard() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.teal.shade300,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Policy Highlight',
                style: TextStyle(
                  color: Colors.teal.shade300,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'FAME II Scheme',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The government has allocated ₹10,000 crore for the second phase of FAME scheme, which aims to provide subsidies for 7,000 e-buses, 5 lakh e-3 wheelers, 55,000 e-4 wheeler passenger cars and 10 lakh e-2 wheelers.',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade300,
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Up to ₹1.5 lakh subsidy available for electric cars.',
                  style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(String title, String content, String date, String url) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade900.withOpacity(0.3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'News',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
                SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final Uri uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Read more',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16, color: Colors.green),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
