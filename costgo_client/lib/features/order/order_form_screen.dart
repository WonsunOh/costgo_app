import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/cart_item_model.dart';
import 'order_complete.dart';
// import 'package:your_app_name/presentation/order/order_complete_screen.dart'; // 주문 완료 화면 (추후 생성)

// 임시 결제 수단 모델
enum PaymentMethod { card, bankTransfer, phonePayment, kakaoPay, naverPay }

class OrderFormScreen extends ConsumerStatefulWidget {
  final List<CartItem> orderedItems;

  const OrderFormScreen({super.key, required this.orderedItems});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // 배송 정보 컨트롤러
  final _nameController = TextEditingController(text: "홍길동"); // 기본값 설정 (실제로는 사용자 정보에서)
  final _phoneController = TextEditingController(text: "010-1234-5678");
  final _addressController = TextEditingController(text: "서울시 강남구 테헤란로 123");
  final _detailAddressController = TextEditingController(text: "456호");
  final _shippingRequestController = TextEditingController();

  // 할인 및 결제 정보 상태
  double _couponDiscount = 0.0; // 임시 쿠폰 할인액
  double _pointsUsed = 0.0;     // 임시 사용 포인트
  PaymentMethod? _selectedPaymentMethod = PaymentMethod.card; // 기본 결제 수단

  bool _agreeToPaymentTerms = false;
  bool _isProcessingOrder = false;

  late double _totalProductPrice;
  late double _shippingFee;

  @override
  void initState() {
    super.initState();
    _totalProductPrice = widget.orderedItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    // 임시 배송비 로직 (예: 5만원 이상 무료배송)
    _shippingFee = _totalProductPrice >= 50000 ? 0.0 : 3000.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _shippingRequestController.dispose();
    super.dispose();
  }

  double get _finalPaymentAmount {
    return _totalProductPrice + _shippingFee - _couponDiscount - _pointsUsed;
  }

  void _processOrder() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('배송 정보를 올바르게 입력해주세요.')),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('결제 수단을 선택해주세요.')),
      );
      return;
    }

    if (!_agreeToPaymentTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('결제 진행 동의가 필요합니다.')),
      );
      return;
    }

    setState(() {
      _isProcessingOrder = true;
    });

    // TODO: 실제 주문 생성 로직 (OrderRepository 사용)
    // 예: await ref.read(orderRepositoryProvider).createOrder(
    //   orderedItems: widget.orderedItems,
    //   shippingInfo: { ... },
    //   paymentInfo: { ... },
    //   finalAmount: _finalPaymentAmount,
    // );

    await Future.delayed(const Duration(seconds: 2)); // API 호출 시뮬레이션

    setState(() {
      _isProcessingOrder = false;
    });

    if (mounted) {
      // TODO: 실제 주문 생성 성공 후, 장바구니에서 주문된 상품들만 제거하는 로직 필요.
      // 예: final orderedProductIds = widget.orderedItems.map((item) => item.uniqueId).toList();
      // ref.read(cartProvider.notifier).removeItemsByUniqueIds(orderedProductIds); 
      // 또는, 주문 완료 시 장바구니 전체 비우기 (정책에 따라 다름)
      // ref.read(cartProvider.notifier).clearCart();


      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => OrderCompleteScreen(orderNumber: 'ORD123456')),
        (route) => route.isFirst, // 홈 화면까지 모든 스택 제거
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주문이 완료되었습니다! (시뮬레이션)'), duration: Duration(seconds: 3)),
      );
      // 현재는 이전 화면(장바구니)으로 돌아가고, 장바구니 화면에서 popUntil로 홈으로 가거나 해야함.
      // 간단하게는 홈으로 바로 보내기
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주문/결제'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('배송 정보'),
              _buildShippingInfoForm(),
              const SizedBox(height: 24),

              _buildSectionTitle('주문 상품 (${widget.orderedItems.length}건)'),
              _buildOrderedItemsList(),
              const SizedBox(height: 24),
              
              // TODO: 쿠폰 및 적립금 사용 섹션 (UI만 간단히)
              _buildSectionTitle('할인 및 적립금'),
              _buildDiscountSection(),
              const SizedBox(height: 24),

              _buildSectionTitle('결제 금액'),
              _buildPaymentSummary(),
              const SizedBox(height: 24),

              _buildSectionTitle('결제 수단'),
              _buildPaymentMethodSelection(),
              const SizedBox(height: 24),

              _buildTermsAgreement(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCheckoutButton(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildShippingInfoForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: '받는 사람 이름', border: OutlineInputBorder()),
          validator: (value) => (value == null || value.isEmpty) ? '이름을 입력해주세요.' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: '연락처', border: OutlineInputBorder()),
          keyboardType: TextInputType.phone,
          validator: (value) => (value == null || value.isEmpty) ? '연락처를 입력해주세요.' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(labelText: '주소', border: OutlineInputBorder()),
           // TODO: 주소 검색 API 연동 버튼 추가 가능
          validator: (value) => (value == null || value.isEmpty) ? '주소를 입력해주세요.' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _detailAddressController,
          decoration: const InputDecoration(labelText: '상세주소', border: OutlineInputBorder()),
          validator: (value) => (value == null || value.isEmpty) ? '상세주소를 입력해주세요.' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _shippingRequestController,
          decoration: const InputDecoration(labelText: '배송 요청사항 (선택)', border: OutlineInputBorder()),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildOrderedItemsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.orderedItems.length,
      itemBuilder: (context, index) {
        final item = widget.orderedItems[index];
        return ListTile(
          leading: SizedBox(
            width: 50, height: 50,
            child: item.product.imageUrl.startsWith('http')
                ? Image.network(item.product.imageUrl, fit: BoxFit.cover, errorBuilder: (c,o,s)=> const Icon(Icons.image))
                : const Icon(Icons.image, size: 50),
          ),
          title: Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('옵션: ${item.selectedOptionsDescription ?? "기본"} / 수량: ${item.quantity}개'),
          trailing: Text('${item.totalPrice.toStringAsFixed(0)}원', style: const TextStyle(fontWeight: FontWeight.w600)),
          contentPadding: EdgeInsets.zero,
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 10),
    );
  }

  Widget _buildDiscountSection() {
    // TODO: 실제 쿠폰 선택 및 포인트 사용 로직 구현
    return Column(
      children: [
        ListTile(
          title: const Text('쿠폰 할인'),
          trailing: TextButton(onPressed: () { /* 쿠폰 선택 다이얼로그 */ }, child: Text('${_couponDiscount.toStringAsFixed(0)}원 >')),
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          title: const Text('적립금 사용'),
          trailing: TextButton(onPressed: () { /* 적립금 입력 다이얼로그 */ }, child: Text('${_pointsUsed.toStringAsFixed(0)}원 >')),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow('총 상품 금액', '${_totalProductPrice.toStringAsFixed(0)}원'),
            _buildSummaryRow('배송비', '+ ${_shippingFee.toStringAsFixed(0)}원'),
            _buildSummaryRow('쿠폰 할인', '- ${_couponDiscount.toStringAsFixed(0)}원', isDiscount: true),
            _buildSummaryRow('적립금 사용', '- ${_pointsUsed.toStringAsFixed(0)}원', isDiscount: true),
            const Divider(height: 20, thickness: 1),
            _buildSummaryRow('최종 결제 금액', '${_finalPaymentAmount.toStringAsFixed(0)}원', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: isTotal ? 16 : 15, color: Colors.black54)),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : (isTotal ? Theme.of(context).primaryColor : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    // 실제 앱에서는 각 결제수단 아이콘 등 UI 개선 필요
    return Column(
      children: PaymentMethod.values.map((method) {
        return RadioListTile<PaymentMethod>(
          title: Text(_getPaymentMethodName(method)),
          value: method,
          groupValue: _selectedPaymentMethod,
          onChanged: (PaymentMethod? value) {
            setState(() {
              _selectedPaymentMethod = value;
            });
          },
          contentPadding: EdgeInsets.zero,
          activeColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card: return '신용/체크카드';
      case PaymentMethod.bankTransfer: return '무통장입금 (가상계좌)';
      case PaymentMethod.phonePayment: return '휴대폰 결제';
      case PaymentMethod.kakaoPay: return '카카오페이';
      case PaymentMethod.naverPay: return '네이버페이';
      }
  }
  
  Widget _buildTermsAgreement() {
    return CheckboxListTile(
      title: const Text('주문 내용을 확인하였으며, 결제 진행에 동의합니다. (필수)', style: TextStyle(fontSize: 14)),
      value: _agreeToPaymentTerms,
      onChanged: (bool? value) {
        setState(() {
          _agreeToPaymentTerms = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading, // 체크박스를 앞에 표시
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _isProcessingOrder ? null : _processOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: _isProcessingOrder
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Text('${_finalPaymentAmount.toStringAsFixed(0)}원 결제하기'),
      ),
    );
  }

  
}