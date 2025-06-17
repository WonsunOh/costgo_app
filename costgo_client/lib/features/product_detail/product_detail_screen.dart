import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:intl/intl.dart';

import '../../admin_panel/products/models/admin_product_model.dart';
import '../../providers/wishlist_provider.dart';
// TODO: CartProvider도 Node.js 기반으로 수정 필요
// import 'package:YOUR_APP_NAME/providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final AdminProduct product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late QuillController _descriptionQuillController;

  @override
  void initState() {
    super.initState();
    Document initialDocument;
    if (widget.product.description != null && widget.product.description!.isNotEmpty) {
      try {
        // 백엔드에서 받은 description(HTML 또는 Delta JSON)을 파싱
        // 여기서는 Delta JSON으로 가정
        final deltaJson = jsonDecode(widget.product.description!);
        initialDocument = Document.fromJson(deltaJson);
      } catch (e) {
        // 파싱 실패 시 일반 텍스트로 표시
        initialDocument = Document()..insert(0, widget.product.description!);
      }
    } else {
      initialDocument = Document()..insert(0, "상세 설명이 아직 없습니다.");
    }
    _descriptionQuillController = QuillController(
      document: initialDocument,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _descriptionQuillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWishlisted = ref.watch(isProductWishlistedProvider(widget.product.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border_outlined,
              color: isWishlisted ? Colors.red : null,
            ),
            onPressed: () {
              ref.read(wishlistProvider.notifier).toggleWishlist(widget.product.id, context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product.imageUrl.isNotEmpty)
              Image.network(widget.product.imageUrl, fit: BoxFit.cover, width: double.infinity),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('${NumberFormat('#,###').format(widget.product.price)}원', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  const Divider(height: 32),
                  // TODO: 옵션 및 수량 선택 UI 추가
                  const SizedBox(height: 24),
                  const Text('상품 상세 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  QuillEditor.basic( 
                    controller: _descriptionQuillController,// 읽기 전용 에디터
                    config: QuillEditorConfig(
                      
                      showCursor: false,
                      padding: EdgeInsets.zero,
                      embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: () {
            // TODO: 장바구니 추가 로직을 Node.js API와 연동
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('장바구니 기능은 현재 준비 중입니다.')),
            );
          },
          child: const Text('장바구니 담기'),
        ),
      ),
    );
  }
}