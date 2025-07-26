import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:costgo_app/admin_panel/products/providers/admin_product_providers.dart';
import 'package:costgo_app/admin_panel/products/repositories/admin_product_repository.dart';
import 'add_edit_product_screen_admin.dart';

class ProductListScreenAdmin extends ConsumerWidget {
  const ProductListScreenAdmin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminProductsProvider),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              leading: product.images.isNotEmpty
                  ? Image.network(product.images.first, width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported, size: 50),
              title: Text(product.name),
              subtitle: Text('${product.price.toStringAsFixed(0)}원'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditProductScreenAdmin(product: product),
                        ),
                      ).then((_) => ref.invalidate(adminProductsProvider));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(context, ref, product.id),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('상품 목록 로딩 실패: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditProductScreenAdmin(),
            ),
          ).then((_) => ref.invalidate(adminProductsProvider));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteProduct(BuildContext context, WidgetRef ref, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('상품 삭제'),
        content: const Text('정말로 이 상품을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(adminProductRepositoryProvider).deleteProduct(productId);
                ref.invalidate(adminProductsProvider);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('상품이 삭제되었습니다.')),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('상품 삭제 실패: $e')),
                );
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}