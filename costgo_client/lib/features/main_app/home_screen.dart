// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:badges/badges.dart' as badges;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:costgo_app/admin_panel/products/models/admin_product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ConsumerStatefulWidget, ConsumerState import

import '../../admin_panel/admin_main_screen.dart';
import '../../admin_panel/products/providers/admin_product_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/main_screen_tab_provider.dart';
import '../cart/cart_screen.dart';
import '../product/product_card.dart';
import '../product_detail/product_detail_screen.dart';
import '../product_list/product_list_screen.dart';

// 임시 카테고리 데이터 모델 (이전에 정의했던 것과 동일)
class ProductCategory {
  final String id; // 카테고리 ID 추가 (필요시)
  final String name;
  final IconData icon;
  ProductCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

// ConsumerStatefulWidget으로 변경
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState(); // 반환 타입을 ConsumerState로 변경
}

// State를 ConsumerState<HomeScreen>으로 변경
class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentBannerIndex = 0; // 배너 인디케이터를 위한 상태 변수

  // 임시 배너 이미지 URL 목록
  final List<String> _bannerImageUrls = [
    'https://picsum.photos/seed/banner1/600/300',
    'https://picsum.photos/seed/banner2/600/300',
    'https://picsum.photos/seed/banner3/600/300',
  ];

  

// 이 _dummyProducts 리스트를 다른 곳에서도 접근 가능하도록 Provider로 제공하는 것이 좋습니다.
// 예: lib/providers/product_providers.dart

// final allProductsProvider = Provider<List<Product>>((ref) => _dummyProducts);

  // 임시 카테고리 목록
  final List<ProductCategory> _categories = [
    ProductCategory(name: '패션의류', icon: Icons.checkroom, id: 'fashion'),
    ProductCategory(name: '뷰티', icon: Icons.face_retouching_natural, id: 'beauty'),
    ProductCategory(name: '가전', icon: Icons.kitchen, id: 'electronics'),    
    ProductCategory(name: '디지털', icon: Icons.phone_iphone, id: 'distal'),
    ProductCategory(name: '도서', icon: Icons.book_online, id: 'book'),
    ProductCategory(name: '식품', icon: Icons.restaurant, id: 'food'),
    ProductCategory(name: '스포츠', icon: Icons.sports_soccer, id: 'sports'),
    ProductCategory(name: '더보기', icon: Icons.more_horiz, id: 'more'),
  ];

  @override
  Widget build(BuildContext context) { 
    // 상품 목록과 사용자 정보를 비동기적으로 가져옴
    final asyncAllProducts = ref.watch(productAdminProvider);
    final asyncCurrentUser = ref.watch(authProvider);// 현재 로그인된 Firebase User 객체 가져오기

    
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce 앱', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          // 사용자 환영 메시지
          asyncCurrentUser.when(
            data: (user) {
              // UserModel의 isAdmin 플래그 확인
              if (user != null && user.isAdmin) {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  tooltip: '관리자 패널',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminMainScreen()),
                    );
                  },
                );
              }
              return const SizedBox.shrink(); // 관리자가 아니면 표시 안 함
            },
            loading: () => const SizedBox.shrink(), // 로딩 중에는 표시 안 함
            error: (e, s) => const SizedBox.shrink(), // 에러 시 표시 안 함
          ), // 환영 메시지를 검색 아이콘 앞에 추가
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 검색 탭(인덱스 2)으로 이동
            ref.read(mainScreenCurrentTabProvider.notifier).state = 2;
          },
          ),
          badges.Badge(
            
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: '장바구니',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShoppingCartScreen()),
                );
              },
            ),
          ),
        ],
        elevation: 1,
      ),
      body: asyncAllProducts.when(
        data: (allProducts) {
          // allProducts는 이제 List<AdminProduct> 타입
          // 추천 상품 목록 (예: 전체 상품 중 앞 8개 또는 특정 조건)
          final List<AdminProduct> recommendedProductsForHome = allProducts.isNotEmpty && allProducts.length > 8
              ? allProducts.take(8).toList()
              : allProducts; // 8개 미만이면 전체 표시

          // 신상품 목록 (예: 전체 상품을 뒤집어서 앞 8개)
          final List<AdminProduct> newProductsForHome = allProducts.isNotEmpty && allProducts.length > 8
              ? allProducts.reversed.take(8).toList() // reversed는 Iterable을 반환하므로 toList() 필요
              : allProducts.reversed.toList();
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildMainBannerSlider(),
              const SizedBox(height: 24),
              _buildCategoryShortcuts(),
              const SizedBox(height: 30),
              _buildSectionTitle('🔥 지금 가장 인기있는 상품'),
              _buildProductList(recommendedProductsForHome),
              const SizedBox(height: 30),
              _buildSectionTitle('✨ 새로 들어온 상품'),
              _buildProductList(newProductsForHome),
              const SizedBox(height: 20),
            ],
          ),
        );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) { // 상품 목록 로드 에러
          print('HomeScreen 상품 로드 에러: $error');
          return Center(child: Text('상품 정보를 불러오는 중 오류가 발생했습니다: $error'));
        },
      ),
    );
  }

  // --- Helper Methods (State 클래스 내부로 이동) ---
  Widget _buildMainBannerSlider() {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _bannerImageUrls.length,
          itemBuilder: (context, index, realIndex) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  _bannerImageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade300, child: const Center(child: Text('이미지 로드 실패'))),
                  loadingBuilder: (context, child, loadingProgress) {
                     if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ));
                  },
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 180.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            aspectRatio: 16 / 9,
            onPageChanged: (index, reason) {
              setState(() { // StatefulWidget의 setState 사용
                _currentBannerIndex = index;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _bannerImageUrls.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                    .withValues(alpha:  _currentBannerIndex == entry.key ? 0.9 : 0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryShortcuts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return InkWell(
            onTap: () {
              String mainCategoryId = category.id; // ProductCategory에 id 필드가 메인 카테고리 ID여야 함
        String categoryScreenTitle = category.name;
        print('HomeScreen -> ProductListScreen으로 전달하는 mainCategoryId: $mainCategoryId');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListScreen(
              categoryId: mainCategoryId, // 메인 카테고리 ID 전달
              categoryName: categoryScreenTitle,
              // isMainCategoryView:  true, // 메인 카테고리이므로 prefix 매칭 사용
            ),
          ),
        );
              // --- 여기까지 ---
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).primaryColorLight.withValues(alpha: 0.5),
                  child: Icon(category.icon, size: 28, color: Theme.of(context).primaryColorDark),
                ),
                const SizedBox(height: 6),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProductList(List<AdminProduct> products) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ProductCard(
              product: product,
              onTap: () {
                print('${product.name} 클릭 -> 상세 화면으로 이동');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}