import 'package:flutter/material.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const Color primaryBlue = Color(0xFF3B5BDB);
  static const Color pullGreen = Color(0xFF10B981);
  static const Color legsOrange = Color(0xFFF59E0B);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF6B7280);

  int _selectedPeriod = 0;
  final List<String> _periods = ['Week', 'Month', 'All Time'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(_periods.length, (index) {
                  final isSelected = _selectedPeriod == index;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      child: ChoiceChip(
                        label: Text(_periods[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedPeriod = index);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : textGray,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Volume chart placeholder
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Volume',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar('Mon', 0.6, primaryBlue),
                        _buildBar('Tue', 0.0, textGray),
                        _buildBar('Wed', 0.8, pullGreen),
                        _buildBar('Thu', 0.0, textGray),
                        _buildBar('Fri', 0.7, legsOrange),
                        _buildBar('Sat', 0.5, primaryBlue),
                        _buildBar('Sun', 0.0, textGray),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard('Total Volume', '8,450 kg', Icons.bar_chart)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Workouts', '4', Icons.fitness_center)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard('Avg Duration', '52 min', Icons.timer)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Calories', '~2,100', Icons.local_fire_department)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Muscle distribution
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Muscle Group Distribution',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDistributionRow('Push', 0.35, primaryBlue),
                  _buildDistributionRow('Pull', 0.30, pullGreen),
                  _buildDistributionRow('Legs', 0.25, legsOrange),
                  _buildDistributionRow('Core', 0.10, textGray),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Personal Records
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Personal Records',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            _buildPRCard('Bench Press', '90 kg', '5 reps'),
            _buildPRCard('Deadlift', '140 kg', '3 reps'),
            _buildPRCard('Squat', '110 kg', '5 reps'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 100 * value,
          decoration: BoxDecoration(
            color: value > 0 ? color : color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: textGray)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryBlue),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: const TextStyle(color: textGray, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 12,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('${(value * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPRCard(String exercise, String weight, String reps) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events, color: primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('$reps @ $weight', style: const TextStyle(color: textGray, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'PR',
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
