import 'package:flutter/material.dart';

class JournalHeaderOnlyPage extends StatefulWidget {
  const JournalHeaderOnlyPage({super.key});

  @override
  State<JournalHeaderOnlyPage> createState() => _JournalHeaderOnlyPageState();
}

class _JournalHeaderOnlyPageState extends State<JournalHeaderOnlyPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final Color _primaryPurple = const Color(0xFF9D4EDD);
  final List<Gradient> _headerGradients = [
    const LinearGradient(
      colors: [Color(0xFF9D4EDD), Color(0xFF4361EE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color backgroundColor,
    bool pulse = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulse ? _pulseAnimation : _slideController,
        builder: (context, child) {
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scale = (size.width / 420).clamp(0.78, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: EdgeInsets.all(16 * scale),
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  gradient: _headerGradients[0],
                  borderRadius: BorderRadius.circular(20 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPurple.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                      color: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Financial Journal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 24 * scale,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            'Animated summary header',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11 * scale,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    _buildIconButton(
                      icon: Icons.refresh_rounded,
                      onTap: () {},
                      color: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      pulse: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}