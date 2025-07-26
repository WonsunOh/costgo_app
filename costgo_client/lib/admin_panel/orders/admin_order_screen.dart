import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/order_provider.dart';
import 'package:costgo_app/core/repositories/order_repository.dart';

class AdminOrderScreen extends ConsumerWidget {
  const AdminOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrdersAsync = ref.watch(allOrdersAdminProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 주문 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allOrdersAdminProvider),
          ),
        ],
      ),
      body: allOrdersAsync.when(
        data: (orders) => ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text('주문자: ${order.orderedBy.username}'),
                subtitle: Text('주문 ID: ${order.id}'),
                trailing: DropdownButton<String>(
                  value: order.status,
                  items: ['Ordered', 'Shipped', 'Delivered', 'Canceled']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (newStatus) async {
                    if (newStatus != null) {
                      await ref.read(orderRepositoryProvider)
                          .updateOrderStatusAdmin(order.id, newStatus);
                      ref.invalidate(allOrdersAdminProvider);
                    }
                  },
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류: $err')),
      ),
    );
  }
}