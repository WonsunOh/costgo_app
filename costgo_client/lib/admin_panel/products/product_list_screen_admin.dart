import 'package:costgo_app/utils/kr_price_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/product_detail/product_detail_screen.dart';
import '../../providers/category_provider.dart';
import '../categories/catrgory_management_screen_admin.dart';
import 'add_edit_product_screen_admin.dart';
import 'models/admin_product_model.dart';
import 'providers/admin_product_providers.dart';



class ProductListScreenAdmin extends ConsumerStatefulWidget { // 또는 ConsumerStatefulWidget
  const ProductListScreenAdmin({super.key});

  @override
  ConsumerState<ProductListScreenAdmin> createState() => _ProductListScreenAdminState();
}

class _ProductListScreenAdminState extends ConsumerState<ProductListScreenAdmin> {
  final _searchController = TextEditingController();
  _ProductDataSource? _dataSource;

  @override
  void initState() {
    super.initState();
    // 검색어가 변경될 때마다 adminProductSearchQueryProvider 상태 업데이트
    _searchController.addListener(() {
      // Notifier를 통해 상태를 업데이트하여 디바운싱 등 추가 로직 구현 가능
      ref.read(adminProductSearchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  // 상품 수정 처리 메소드
  void _handleEditProduct(AdminProduct productToEdit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // "수정 모드"로 진입: existingProduct에 수정할 상품 정보 전달
        builder: (context) => AddEditProductScreenAdmin(existingProduct: productToEdit),
      ),
    ).then((isSuccess) {
      if (isSuccess == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상품 정보가 업데이트되었습니다.')),
        );
      }
    });
  }

  // ★★★ 새 상품 추가 처리 메소드 분리 ★★★
  void _handleAddNewProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // "추가 모드"로 진입: existingProduct를 전달하지 않음
        builder: (context) => const AddEditProductScreenAdmin(),
      ),
    ).then((isSuccess) {
      if (isSuccess == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('새 상품이 추가되었습니다.')),
        );
      }
    });
  }


  // 상품 삭제 처리 메소드
  Future<void> _handleDeleteProduct(AdminProduct productToDelete) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('상품 삭제 확인'),
          content: Text("'${productToDelete.name}' 상품을 정말 삭제하시겠습니까?"),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(dialogContext, false), child: const Text("취소")), 
            TextButton(onPressed: ()=>Navigator.pop(dialogContext, true), style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error), child: const Text("삭제"))
          ],
        )
    );

    if (confirmDelete == true) {
      try {
        await ref.read(productAdminProvider.notifier).deleteProduct(productToDelete.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("'${productToDelete.name}' 상품이 삭제되었습니다.")),
          );
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('상품 삭제 실패: ${e.toString()}')),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(adminProductSearchQueryProvider);
    // 검색어 유무에 따라 다른 Provider를 watch
    final asyncProducts = searchQuery.trim().isEmpty
        ? ref.watch(productAdminProvider) // 전체 목록
        : ref.watch(adminSearchedProductsProvider(searchQuery.trim())); // 검색 결과
    
    // 카테고리 이름 매핑을 위해 카테고리 정보도 watch
    final asyncMainCategories = ref.watch(mainCategoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 관리'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.dns_outlined),
            label: Text('카테고리 관리', style: TextStyle(color: Theme.of(context).appBarTheme.actionsIconTheme?.color)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementScreenAdmin())),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('새 상품 추가'),
              onPressed: _handleAddNewProduct, // 수정 모드가 아닌 추가 모드로 진입
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '상품명으로 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(adminProductSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          Expanded(
            child: asyncMainCategories.when(
              data: (allMainCategories) {
                // 카테고리 이름 맵 생성
                final Map<String, String> subCategoryNamesMap = {
                  for (var mainCat in allMainCategories)
                    for (var subCat in mainCat.subCategories)
                      subCat.id: '${mainCat.name} > ${subCat.name}'
                };

                return asyncProducts.when(
                  data: (products) {
                    _dataSource = _ProductDataSource(products, context, subCategoryNamesMap, _handleEditProduct, _handleDeleteProduct);
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(16),
                        child: PaginatedDataTable(
                          header: const Text('상품 목록'),
                          rowsPerPage: 10,
                          columns: const [ /* ... 기존 DataColumn 정의 ... */ ],
                          source: _dataSource!,
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('상품 로드 오류: $e')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('카테고리 로드 오류: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

// PaginatedDataTable을 위한 데이터 소스 클래스
class _ProductDataSource extends DataTableSource {
  final List<AdminProduct> _products;
  final BuildContext context; // Navigator 사용 등을 위해 context 전달
  final Map<String, String> subCategoryNamesMap; // 카테고리 이름 맵 수신
  final Function(AdminProduct product) onEditProduct;    // 수정 콜백 함수 타입 변경
  final Function(AdminProduct product) onDeleteProduct;  // 삭제 콜백 함수 추가

  _ProductDataSource(this._products, this.context, this.subCategoryNamesMap, this.onEditProduct, this.onDeleteProduct);

  @override
  DataRow? getRow(int index) {
    if (index >= _products.length) {
      return null;
    }
    final adminProduct = _products[index];
    final String categoryDisplayName = subCategoryNamesMap[adminProduct.category] ?? adminProduct.category; // ID를 이름으로 변환, 없으면 ID 표시

    return DataRow.byIndex(index: index, 
      selected: true,
    // ★★★ 행 전체를 탭했을 때의 동작을 위해 onSelectChanged 사용 ★★★
      onSelectChanged: (bool? selected) {
        // selected 값은 여기서는 중요하지 않지만, 탭 이벤트 자체를 활용
        if (selected != null) { // 탭 이벤트가 발생했다는 의미 (selected는 true/false일 수 있음)
          print('${adminProduct.name} 행(row) 탭됨 -> 상세 보기로 이동');
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: adminProduct),
            ),
          );
        }
      },
    cells: [
      DataCell(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: (adminProduct.imageUrl.isNotEmpty && adminProduct.imageUrl.startsWith('http'))
              ? Image.network(adminProduct.imageUrl, width: 40, height: 40, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print("이미지 로드 실패 (URL: ${adminProduct.imageUrl}): $error");
                    return const Icon(Icons.error, size: 30, color: Colors.grey);
                    },
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ); // 로딩 중 표시
                    },
                    )
              : const Icon(Icons.image_not_supported, size: 30),
        )
      ),
      DataCell(
        Text(
          adminProduct.name, overflow: TextOverflow.ellipsis, maxLines: 2)
          ,),
      DataCell(Text(categoryDisplayName)),
      DataCell(Text('${formatPrice(adminProduct.price)}원')),
      DataCell(Text('${adminProduct.stock}개')),
      DataCell(
        Chip(
          label: Text(adminProduct.status),
          backgroundColor: adminProduct.status == '판매중' ? Colors.green.shade100 : (adminProduct.status == '품절' ? Colors.red.shade100 : Colors.grey.shade200),
          labelStyle: TextStyle(
            color: adminProduct.status == '판매중' ? Colors.green.shade800 : (adminProduct.status == '품절' ? Colors.red.shade800 : Colors.grey.shade800),
            fontSize: 12,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        )
      ),
      DataCell(Text('${adminProduct.createdAt?.year}-${adminProduct.createdAt?.month}-${adminProduct.createdAt?.day}')),
      DataCell(
        Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: Colors.blue,
            tooltip: '수정',
            onPressed: () {
              // TODO: 상품 수정 화면으로 이동
              print('상품 수정: ${adminProduct.name}');
            
              onEditProduct(adminProduct); // 수정 콜백 호출
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.red,
            tooltip: '삭제',
            onPressed: () {
              // TODO: 상품 삭제 확인 및 로직 실행
              print('상품 삭제: ${adminProduct.name}');
               onDeleteProduct(adminProduct); // 삭제 콜백 호출
            },
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _products.length;

  @override
  int get selectedRowCount => 0; // 선택 기능 사용 시 구현

  // 데이터가 변경되었음을 PaginatedDataTable에 알리기 위해 필요할 수 있음
  // (하지만 여기서는 _ProductListScreenAdminState에서 setState를 통해
  //  새로운 _ProductDataSource 인스턴스를 전달하므로 직접 호출은 불필요할 수 있음)
  // void refreshDatasource() {
  //   notifyListeners();
  // }
  
}