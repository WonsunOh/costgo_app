import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../core/repositories/onboarding_repository.dart';
import '../models/onboarding_page_model.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPageIndex = 0;

  // 온보딩 페이지 데이터 (실제 앱에서는 더 의미있는 내용과 이미지를 사용하세요)
  final List<OnboardingPageModel> _pages = [
    OnboardingPageModel(
      title: '다양한 상품을 만나보세요',
      description: '수천 가지의 상품들이 당신을 기다리고 있습니다. 지금 바로 탐색해보세요!',
      icon: Icons.explore_outlined,
      backgroundColor: Colors.blue.shade100,
    ),
    OnboardingPageModel(
      title: '쉽고 빠른 쇼핑 경험',
      description: '간편한 결제와 빠른 배송으로 스트레스 없는 쇼핑을 즐기세요.',
      icon: Icons.shopping_cart_checkout_sharp,
      backgroundColor: Colors.green.shade100,
    ),
    OnboardingPageModel(
      title: '당신만을 위한 특별한 혜택',
      description: '맞춤 추천과 다양한 할인 혜택으로 더욱 스마트하게 쇼핑하세요. 지금 시작해보세요!',
      icon: Icons.card_giftcard_outlined,
      backgroundColor: Colors.orange.shade100,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    await ref.read(onboardingRepositoryProvider).setOnboardingComplete();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                color: page.backgroundColor,
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(page.icon, size: 150, color: Theme.of(context).primaryColorDark.withValues(alpha: 0.7)), // 아이콘 색상 조정
                    const SizedBox(height: 40.0),
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16.0, height: 1.5),
                    ),
                  ],
                ),
              );
            },
          ),

          // 상단 건너뛰기 버튼 (첫 페이지와 중간 페이지에만 표시)
          if (_currentPageIndex < _pages.length -1)
            Positioned(
              top: kToolbarHeight -10, // AppBar 높이 기준으로 조정
              right: 20,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('건너뛰기', style: TextStyle(fontSize: 16, color: Colors.black54)),
              ),
            ),

          // 하단 인디케이터 및 버튼
          Positioned(
            bottom: 40.0,
            left: 20.0,
            right: 20.0,
            child: Column(
              children: [
                // 페이지 인디케이터
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: WormEffect( // 다양한 효과 사용 가능: ExpandingDotsEffect, ScrollingDotsEffect 등
                    dotHeight: 10,
                    dotWidth: 10,
                    activeDotColor: Theme.of(context).primaryColor,
                    paintStyle: PaintingStyle.fill,
                  ),
                  onDotClicked: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                const SizedBox(height: 30.0),
                // 다음 / 시작하기 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // 버튼 최소 크기
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                  onPressed: () {
                    if (_currentPageIndex < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // 마지막 페이지일 경우 온보딩 완료 처리
                      _completeOnboarding();
                    }
                  },
                  child: Text(
                    _currentPageIndex < _pages.length - 1 ? '다음' : '시작하기',
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