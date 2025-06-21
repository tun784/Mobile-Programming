import 'package:classroom/blocs/auth_bloc.dart';
import 'package:classroom/blocs/user_bloc.dart';
import 'package:classroom/screens/onboarding/single_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  final _kDuration = const Duration(milliseconds: 400);
  final _kCurve = Curves.easeInOutCubic;

  // Định nghĩa gradient colors cho từng trang
  final List<List<Color>> gradientColors = [
    [const Color(0xFF667eea), const Color(0xFF764ba2)], // Tím xanh
    [const Color(0xFFf093fb), const Color(0xFFf5576c)], // Hồng
    [const Color(0xFF4facfe), const Color(0xFF00f2fe)], // Xanh dương
    [const Color(0xFF43e97b), const Color(0xFF38f9d7)], // Xanh lá
  ];

  final List<IconData> pageIcons = [
    FontAwesomeIcons.graduationCap,
    FontAwesomeIcons.rocket,
    FontAwesomeIcons.userCheck,
    FontAwesomeIcons.shield,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeOutCubic));

    _animationController!.forward();
  }

  nextFunction() {
    _pageController.nextPage(duration: _kDuration, curve: _kCurve);
  }

  previousFunction() {
    _pageController.previousPage(duration: _kDuration, curve: _kCurve);
  }

  onChangedFunction(int index) {
    setState(() {
      currentIndex = index;
    });
    _animationController?.reset();
    _animationController?.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthenticationBloc ab = Provider.of<AuthenticationBloc>(context);
    UserBloc ub = Provider.of<UserBloc>(context);

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors[currentIndex],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              // Main PageView
              PageView(
                controller: _pageController,
                onPageChanged: onChangedFunction,
                physics: const BouncingScrollPhysics(),
                children: <Widget>[
                  SinglePage(
                    imagePath: "assets/images/onboard1.png",
                    title: "Chào mừng đến với Educhat",
                    subtitle: "Nền tảng học tập thông minh kết nối giáo viên và học sinh một cách hiệu quả nhất",
                    nextButton: _buildNextButton(0),
                    pageController: _pageController,
                    ab: ab,
                    ub: ub,
                  ),
                  SinglePage(
                    imagePath: "assets/images/onboard2.png",
                    title: "Nộp bài dễ dàng",
                    subtitle: "Giao và nộp bài tập một cách nhanh chóng, theo dõi tiến độ học tập realtime",
                    nextButton: _buildNextButton(1),
                    pageController: _pageController,
                    ab: ab,
                    ub: ub,
                  ),
                  SinglePage(
                    imagePath: "assets/images/onboard3.png",
                    title: "Trải nghiệm liền mạch",
                    subtitle: "Kiểm tra bài tập, lịch thi và điểm số mọi lúc mọi nơi với giao diện thân thiện",
                    nextButton: _buildNextButton(2),
                    pageController: _pageController,
                    ab: ab,
                    ub: ub,
                  ),
                  SinglePage(
                    imagePath: "assets/images/onboard4.png",
                    title: "Bảo mật tuyệt đối",
                    subtitle: "Dữ liệu của bạn được bảo vệ bởi công nghệ mã hóa hàng đầu thế giới",
                    nextButton: _buildNextButton(3),
                    pageController: _pageController,
                    ab: ab,
                    ub: ub,
                  ),
                ],
              ),

              // Header with navigation
              _buildHeader(size),

              // Bottom navigation
              _buildBottomNavigation(size, ab),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(int pageIndex) {
    return Container(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress indicator
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              value: (pageIndex + 1) / 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                gradientColors[pageIndex][0],
              ),
              backgroundColor: Colors.grey.withOpacity(0.3),
            ),
          ),
          // Button
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => nextPage(null),
              padding: EdgeInsets.zero,
              icon: Icon(
                pageIndex == 3 ? Icons.done : Icons.arrow_forward_rounded,
                color: gradientColors[pageIndex][0],
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            SizedBox(
              width: 48,
              child: AnimatedOpacity(
                opacity: currentIndex != 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: currentIndex != 0
                    ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: previousFunction,
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                )
                    : const SizedBox(),
              ),
            ),

            // Page indicator
            Flexible(
              child: AnimatedSmoothIndicator(
                activeIndex: currentIndex,
                count: 4,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white.withOpacity(0.4),
                  dotHeight: 6,
                  dotWidth: 6,
                  expansionFactor: 3,
                  spacing: 4,
                ),
              ),
            ),

            // Skip button
            SizedBox(
              width: 60,
              child: TextButton(
                onPressed: currentIndex == 3 ? null : () => _skipToEnd(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  currentIndex == 3 ? "" : "Bỏ qua",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(Size size, AuthenticationBloc ab) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Không cần login buttons ở đây nữa vì đã có trong SinglePage

            // Skip button (chỉ hiện khi không phải trang cuối)
            if (currentIndex != 3)
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => _skipToEnd(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Bỏ qua",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

  void nextPage(AuthenticationBloc? ab) {
    if (currentIndex < 3) {
      nextFunction();
    }
    // Trang cuối sẽ được xử lý bởi logic trong SinglePage
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      3,
      duration: _kDuration,
      curve: _kCurve,
    );
  }
}