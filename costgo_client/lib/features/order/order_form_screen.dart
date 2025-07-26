import 'package:costgo_app/models/cart_item_model.dart';
import 'package:costgo_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:costgo_app/providers/cart_provider.dart';
import 'package:costgo_app/core/repositories/order_repository.dart';
import 'package:costgo_app/utils/kr_price_format.dart';

class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 로그인한 사용자의 기본 주소가 있다면 불러와서 컨트롤러에 설정
    final user = (ref.read(authNotifierProvider) as Authenticated).user;
    if (user.address != null && user.address!.isNotEmpty) {
      _addressController.text = user.address!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true);

      final cartItems = ref.read(cartNotifierProvider);
      final totalPrice = ref.read(cartTotalProvider);
      final shippingAddress = _addressController.text;

      // API에 보낼 데이터 형식으로 변환
      final List<Map<String, dynamic>> productData = cartItems.map((item) {
        return {
          'product': item.product.id,
          'quantity': item.quantity,
          'price': item.product.price,
        };
      }).toList();

      try {
        await ref.read(orderRepositoryProvider).placeOrder(
              products: productData,
              totalPrice: totalPrice,
              shippingAddress: shippingAddress,
            );
        
        // 주문 성공 시, 서버에서 장바구니가 비워졌으므로 클라이언트 상태도 갱신
        await ref.read(authNotifierProvider.notifier).checkAuthState();

        if (mounted) {
          // 주문 완료 화면으로 이동 (뒤로가기 스택 모두 제거)
          context.go('/order-complete');
        }
      } catch (e) {
        if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('주문 생성 실패: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('주문서 작성')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('배송지 정보', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: '주소',
                  hintText: '배송 받으실 주소를 입력해주세요.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? '주소를 입력해주세요.' : null,
              ),
              const SizedBox(height: 24),
              Text('결제 금액', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('총 주문 금액: ${krPriceFormat(cartTotal)}'),
              // 필요한 경우 할인, 포인트 등 추가
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _isLoading ? null : _placeOrder,
          child: _isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
              : const Text('결제 및 주문 완료'),
        ),
      ),
    );
  }
}