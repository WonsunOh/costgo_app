// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'repositories/order_repository.dart';

// 관리 가능한 주문 상태 목록
const List<String> kOrderStatuses = ['결제완료', '배송준비중', '배송중', '배송완료', '주문취소'];

class AdminOrderScreen extends ConsumerWidget {
  const AdminOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOrders = ref.watch(orderListStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 관리'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: asyncOrders.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('접수된 주문이 없습니다.'));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16.0),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text('주문일')),
                  DataColumn(label: Text('주문번호')),
                  DataColumn(label: Text('주문자')),
                  DataColumn(label: Text('주문상품')),
                  DataColumn(label: Text('총 결제금액')),
                  DataColumn(label: Text('주문상태')),
                  DataColumn(label: Text('관리')),
                ],
                rows: orders.map((order) {
                  return DataRow(cells: [
                    DataCell(Text(DateFormat('yy-MM-dd HH:mm').format(order.createdAt.toDate()))),
                    DataCell(SelectableText(order.orderId, style: const TextStyle(fontSize: 12))),
                    DataCell(Text(order.customerName)),
                    DataCell(Text(
                      order.items.length > 1
                          ? '${order.items.first.productName} 외 ${order.items.length - 1}건'
                          : order.items.first.productName,
                    )),
                    DataCell(Text(
                      '${NumberFormat('#,###').format(order.totalAmount)}원',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(
                      // 주문 상태를 변경할 수 있는 DropdownButton
                      DropdownButton<String>(
                        value: order.orderStatus,
                        items: kOrderStatuses.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newStatus) async {
                          if (newStatus != null && newStatus != order.orderStatus) {
                            try {
                              await ref.read(orderRepositoryProvider).updateOrderStatus(order.orderId, newStatus);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('주문상태가 "$newStatus"(으)로 변경되었습니다.')),
                              );
                            } catch(e) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('상태 변경 실패: $e')),
                              );
                            }
                          }
                        },
                        underline: Container(), // 밑줄 제거
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined),
                        tooltip: '주문 상세 보기',
                        onPressed: () {
                          // TODO: 주문 상세 보기 화면으로 이동
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${order.orderId} 상세 보기 (구현 예정)')),
                          );
                        },
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('주문 목록 로드 오류: $err')),
      ),
    );
  }
}