// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/repositories/user_repository.dart'; // 날짜 포맷을 위해 intl 패키지 필요

class AdminUserScreen extends ConsumerStatefulWidget {
  const AdminUserScreen({super.key});

  @override
  ConsumerState<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends ConsumerState<AdminUserScreen> {
String _searchQuery = '';
final _searchController = TextEditingController();

 @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 검색어 유무에 따라 다른 Provider를 watch
    final asyncUsers = _searchQuery.trim().isEmpty
        ? ref.watch(userListProvider)
        : ref.watch(searchedUserProvider(_searchQuery.trim()));

       

    return Scaffold(
      
      appBar: AppBar(
        title: const Text('회원 관리'),
        // AppBar는 AdminMainScreen에서 관리하므로 여기서는 필요 없을 수 있음
        // 만약 각 화면이 독립적인 AppBar를 갖는다면 이 코드 유지
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
              decoration: const InputDecoration(hintText: '이름 또는 이메일로 검색...', prefixIcon: Icon(Icons.search)),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            ),
          Expanded(
            child: asyncUsers.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('등록된 회원이 없습니다.'));
          }
          // 스크롤 가능한 데이터 테이블
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text('가입일', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('이름', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('이메일', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('연락처', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('주소', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('관리', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: users.map((user) {
                  // ★★★ 가입일 포매팅 부분 수정 ★★★
                  final String joinDate = user.createdAt != null
                      ? DateFormat('yyyy-MM-dd').format(user.createdAt!) // null이 아닐 때 포매팅
                      : '날짜 정보 없음'; // null일 때 표시할 텍스트
                  return DataRow(cells: [
                    DataCell(Text(joinDate)),
                    DataCell(Text(user.name)),
                    DataCell(SelectableText(user.email)), // 이메일은 복사 가능하도록
                    DataCell(Text(user.phoneNumber ?? '-')),
                    DataCell(Text(user.address ?? '-')),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_note, size: 20, color: Colors.blue),
                            tooltip: '회원 정보 수정',
                            onPressed: () {
                              // TODO: 회원 정보 수정 화면으로 이동
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${user.name} 회원 정보 수정 (구현 예정)')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.block, size: 20, color: Colors.red),
                            tooltip: '회원 비활성화/삭제',
                            onPressed: () {
                              // TODO: 회원 비활성화 또는 삭제 로직
                               ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${user.name} 회원 비활성화 (구현 예정)')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('회원 목록을 불러오는 중 오류 발생: $err')),
    
          ),
          ),

      ],
      ),
    );
  }
}