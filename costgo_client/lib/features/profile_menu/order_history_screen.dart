import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/order_provider.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myOrdersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('주문 내역')),
      body: myOrdersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('주문 내역이 없습니다.'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text('주문 #${order.id.substring(0, 8)}...'),
                  subtitle: Text('주문일: ${order.orderedAt.toString().substring(0, 10)}'),
                  trailing: Text(order.status),
                  children: [
                    for (var item in order.products)
                      ListTile(
                        title: Text(item.product.name),
                        subtitle: Text('${item.quantity}개'),
                        trailing: Text('${item.price}원'),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('총액: ${order.totalPrice}원', style: const TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류: $err')),
      ),
    );
  }
}