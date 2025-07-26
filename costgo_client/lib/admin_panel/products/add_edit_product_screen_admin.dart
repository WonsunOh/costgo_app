import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/models/product_model.dart';
import 'package:costgo_app/models/category_model.dart';
import 'package:costgo_app/providers/category_provider.dart';
import 'package:costgo_app/admin_panel/products/repositories/admin_product_repository.dart';

class AddEditProductScreenAdmin extends ConsumerStatefulWidget {
  final ProductModel? product;

  const AddEditProductScreenAdmin({super.key, this.product});

  @override
  ConsumerState<AddEditProductScreenAdmin> createState() =>
      _AddEditProductScreenAdminState();
}

class _AddEditProductScreenAdminState extends ConsumerState<AddEditProductScreenAdmin> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  CategoryModel? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _quantityController = TextEditingController(text: widget.product?.quantity.toString() ?? '');
    _selectedCategory = widget.product?.category;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카테고리를 선택해주세요.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final productData = ProductModel(
          id: widget.product?.id ?? '',
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          quantity: int.parse(_quantityController.text),
          category: _selectedCategory!,
          images: widget.product?.images ?? [], // 이미지 처리 로직은 별도 구현 필요
        );
        
        if (widget.product == null) {
          await ref.read(adminProductRepositoryProvider).createProduct(productData);
        } else {
          await ref.read(adminProductRepositoryProvider).updateProduct(productData);
        }

        Navigator.of(context).pop(true); // 성공 시 true 반환
      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      } finally {
        if(mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? '상품 추가' : '상품 수정'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: CircularProgressIndicator(color: Colors.white,)),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '상품명'),
                validator: (value) => value!.isEmpty ? '상품명을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '설명'),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? '설명을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: '가격'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? '가격을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: '수량'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? '수량을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                data: (categories) {
                  // _selectedCategory를 초기화 할 때 id가 일치하는 category 객체를 찾아 설정합니다.
                  if (_selectedCategory != null && categories.isNotEmpty) {
                    final found = categories.where((c) => c.id == _selectedCategory!.id);
                    if (found.isNotEmpty) {
                      _selectedCategory = found.first;
                    } else {
                      _selectedCategory = null;
                    }
                  }

                  return DropdownButtonFormField<CategoryModel>(
                    value: _selectedCategory,
                    hint: const Text('카테고리 선택'),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) => value == null ? '카테고리를 선택해주세요.' : null,
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => const Text('카테고리를 불러올 수 없습니다.'),
              ),
              // TODO: 이미지 업로드 UI 추가
            ],
          ),
        ),
      ),
    );
  }
}