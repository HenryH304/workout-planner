import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  String _level = 'beginner';
  int _frequency = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
        },
        children: [
          _buildWelcomePage(),
          _buildLevelSelectionPage(),
          _buildFrequencyPage(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildWelcomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Welcome to Workout Planner',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Your intelligent fitness companion\nwill guide you to peak performance',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelectionPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'What\'s your experience level?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ...['beginner', 'intermediate', 'advanced'].map((level) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ChoiceChip(
                label: Text(level.toUpperCase()),
                selected: _level == level,
                onSelected: (selected) {
                  setState(() => _level = level);
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFrequencyPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'How many days/week can you train?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Slider(
            value: _frequency.toDouble(),
            min: 3,
            max: 6,
            divisions: 3,
            label: '$_frequency days',
            onChanged: (value) {
              setState(() => _frequency = value.toInt());
            },
          ),
          const SizedBox(height: 16),
          Text(
            '$_frequency days per week',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        if (_currentPage < 2) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          widget.onComplete();
        }
      },
      child: Icon(_currentPage == 2 ? Icons.check : Icons.arrow_forward),
    );
  }
}
