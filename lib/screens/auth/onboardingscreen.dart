import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart'; // Import halaman login

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  // Tema hijau keuangan yang elegan
  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Deteksi Bocor Halus",
      description: "Temukan kebocoran kecil dalam keuangan Anda yang sering terlewat dengan teknologi AI terdepan.",
      image: "assets/images/onboarding1.png",
      primaryColor: Color(0xFF2ECC71), // Emerald green
      accentColor: Color(0xFF27AE60), // Dark emerald
      lightColor: Color(0xFFE8F8F5), // Light mint
    ),
    OnboardingData(
      title: "Analisis Cerdas",
      description: "Dapatkan insight mendalam tentang pola pengeluaran dengan analisis yang akurat dan mudah dipahami.",
      image: "assets/images/onboarding2.png",
      primaryColor: Color(0xFF16A085), // Teal
      accentColor: Color(0xFF138D75), // Dark teal
      lightColor: Color(0xFFE0F2F1), // Light teal
    ),
    OnboardingData(
      title: "Kelola Lebih Baik",
      description: "Atur budget, pantau pengeluaran, dan capai tujuan finansial Anda dengan mudah dan efektif.",
      image: "assets/images/onboarding3.png",
      primaryColor: Color(0xFF1ABC9C), // Turquoise
      accentColor: Color(0xFF17A2B8), // Info blue-green
      lightColor: Color(0xFFE0F7FA), // Light cyan
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with skip button
            _buildTopSection(),
            
            // Main content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),
            
            // Bottom section with indicators and button
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo/Brand
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _onboardingData[_currentPage].primaryColor.withOpacity(0.1),
                  _onboardingData[_currentPage].lightColor,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _onboardingData[_currentPage].primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: _onboardingData[_currentPage].primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "BoncosApp",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _onboardingData[_currentPage].accentColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Skip button
          TextButton(
            onPressed: () => _navigateToLogin(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              "Lewati",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration container with elegant design
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  data.lightColor,
                  data.primaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: data.primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(80),
                boxShadow: [
                  BoxShadow(
                    color: data.primaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getIconForPage(_currentPage),
                size: 80,
                color: data.primaryColor,
              ),
            ),
          ),
          
          SizedBox(height: 48),
          
          // Title with gradient effect
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [data.primaryColor, data.accentColor],
            ).createShader(bounds),
            child: Text(
              data.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          SizedBox(height: 20),
          
          // Description with better typography
          Container(
            constraints: BoxConstraints(maxWidth: 280),
            child: Text(
              data.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.6,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          // Page indicators with elegant animation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => _buildDot(index),
            ),
          ),
          
          SizedBox(height: 32),
          
          // Navigation section - Next button positioned right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _onboardingData[_currentPage].primaryColor,
                      _onboardingData[_currentPage].accentColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: _onboardingData[_currentPage].primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _onboardingData.length - 1) {
                      _navigateToLogin();
                    } else {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 350),
                        curve: Curves.easeInOutCubic,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 6),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        gradient: isActive 
            ? LinearGradient(
                colors: [
                  _onboardingData[_currentPage].primaryColor,
                  _onboardingData[_currentPage].accentColor,
                ],
              )
            : null,
        color: !isActive ? Colors.grey[300] : null,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive ? [
          BoxShadow(
            color: _onboardingData[_currentPage].primaryColor.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ] : null,
      ),
    );
  }

  IconData _getIconForPage(int page) {
    switch (page) {
      case 0:
        return Icons.search_rounded;
      case 1:
        return Icons.analytics_rounded;
      case 2:
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.app_registration_rounded;
    }
  }

  void _navigateToLogin() async {
    // Simpan bahwa onboarding sudah selesai
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;
  final Color primaryColor;
  final Color accentColor;
  final Color lightColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.primaryColor,
    required this.accentColor,
    required this.lightColor,
  });
}