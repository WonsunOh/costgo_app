import 'dart:convert';
import 'dart:io' as io show Directory, File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import 'models/admin_product_model.dart';
import 'providers/admin_product_providers.dart';

const _uuid = Uuid();

class AddEditProductScreenAdmin extends ConsumerStatefulWidget {
  final AdminProduct? existingProduct;
  const AddEditProductScreenAdmin({super.key, this.existingProduct});
  bool get isEditMode => existingProduct != null;

  @override
  ConsumerState<AddEditProductScreenAdmin> createState() =>
      _AddEditProductScreenAdminState();
}

class _AddEditProductScreenAdminState
    extends ConsumerState<AddEditProductScreenAdmin> {
  final _formKey = GlobalKey<FormState>();

  final QuillController _descriptionQuillController = () {
    return QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
          onImagePaste: (imageBytes) async {
            if (kIsWeb) {
              // Dart IO is unsupported on the web.
              return null;
            }
            // Save the image somewhere and return the image URL that will be
            // stored in the Quill Delta JSON (the document).
            final newFileName =
                'image-file-${DateTime.now().toIso8601String()}.png';
            final newPath = path.join(
              io.Directory.systemTemp.path,
              newFileName,
            );
            final file = await io.File(
              newPath,
            ).writeAsBytes(imageBytes, flush: true);
            return file.path;
          },
        ),
      ),
    );
  }();
  final FocusNode _editorFocus = FocusNode();
  final _editorScrollController = ScrollController();

  final _nameController = TextEditingController();
  final _descriptionController =
      TextEditingController(); // 일반 TextEditingController 사용
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String? _currentRepresentativeImageUrl;

  String? _selectedCategoryId;
  late String _selectedStatus;
  final List<String> _productStatuses = ['판매중', '품절', '숨김'];
  final Map<String, bool> _selectedProductTypes = {};

  XFile? _pickedRepresentativeImageFile;
  bool _isUploadingRepresentativeImage = false;

  bool _isQuillImageUploading = false;

  bool _isLoading = false;

  final Map<String, String> _productTypeMap = {
    '신상품': 'new',
    '인기상품': 'popular',
    '추천상품': 'recommended',
    '할인상품': 'discounted',
  };

  @override
  void initState() {
    super.initState();

    Document initialDocument;
    if (widget.isEditMode &&
        widget.existingProduct?.description != null &&
        widget.existingProduct!.description!.isNotEmpty) {
      try {
        final deltaJson = jsonDecode(widget.existingProduct!.description!);
        initialDocument = Document.fromJson(deltaJson);
      } catch (e) {
        initialDocument =
            Document()..insert(0, widget.existingProduct!.description!);
      }
    } else {
      initialDocument = Document();
    }
    _descriptionQuillController.document = initialDocument;

    if (widget.isEditMode && widget.existingProduct != null) {
      final product = widget.existingProduct!;
      _nameController.text = product.name;
      _descriptionController.text =
          product.description ?? ''; // 저장된 마크다운 텍스트 로드
      _priceController.text = product.price.toString();
      _stockController.text = product.stock.toString();
      _currentRepresentativeImageUrl = product.imageUrl;
      _selectedCategoryId = product.category;
      _selectedStatus = product.status;
      _productTypeMap.forEach((key, value) {
        _selectedProductTypes[value] = product.productTypes.contains(value);
      });
      // description은 HtmlEditor의 initialText 파라미터로 직접 전달
    } else {
      _selectedStatus = '판매중';
      _productTypeMap.forEach((key, value) {
        _selectedProductTypes[value] = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionQuillController.dispose();

    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAndSimulateRepresentativeImageUpload() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      setState(() {
        _isUploadingRepresentativeImage = true;
      });
      await Future.delayed(const Duration(seconds: 2));

      // ★★★ 파일명 대신 고유 ID(UUID)를 seed로 사용 ★★★
      final String imageSeed = _uuid.v4();
      final String simulatedImageUrl =
          'https://picsum.photos/seed/$imageSeed/400/300';

      setState(() {
        _currentRepresentativeImageUrl = simulatedImageUrl;
        _isUploadingRepresentativeImage = false;
        _pickedRepresentativeImageFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('대표 이미지 "업로드" 완료 (URL: $simulatedImageUrl)')),
      );
    } catch (e) {
      if (mounted) setState(() => _isUploadingRepresentativeImage = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('대표 이미지 처리 오류: $e')));
    }
  }

  Future<void> _saveProduct() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('상품 카테고리를 선택해주세요.')));
      return;
    }

    if (_currentRepresentativeImageUrl == null ||
        _currentRepresentativeImageUrl!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('상품 대표 이미지를 제공해주세요.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // HtmlEditorController에서 HTML 텍스트 가져오기
    final String descriptionMarkdown = _descriptionController.text.trim();
    final finalSelectedProductTypes =
        _selectedProductTypes.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();

    final AdminProduct productData = AdminProduct(
      id: widget.isEditMode ? widget.existingProduct!.id : null,
      name: _nameController.text.trim(),
      description: descriptionMarkdown, // 마크다운 텍스트 저장
      price: double.tryParse(_priceController.text) ?? 0.0,
      stock: int.tryParse(_stockController.text) ?? 0,
      imageUrl: _currentRepresentativeImageUrl!,
      category: _selectedCategoryId!,
      status: _selectedStatus,
      createdAt: widget.isEditMode ? widget.existingProduct!.createdAt : null,
      productTypes: finalSelectedProductTypes, // 저장
    );

    try {
      // ★★★ Notifier의 메소드 호출 ★★★
      if (widget.isEditMode) {
        await ref.read(productAdminProvider.notifier).updateProduct(productData);
      } else {
        await ref.read(productAdminProvider.notifier).addProduct(productData);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('상품이 성공적으로 ${widget.isEditMode ? "수정" : "저장"}되었습니다!')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '상품 ${widget.isEditMode ? "수정" : "저장"} 실패: ${e.toString()}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<MainCategory>> asyncMainCategories = ref.watch(
      mainCategoryListProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? '상품 수정' : '새 상품 추가'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton.icon(
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Icon(
                        widget.isEditMode
                            ? Icons.save_as_outlined
                            : Icons.save_alt_outlined,
                      ),
              label: Text(
                _isLoading ? '저장중...' : (widget.isEditMode ? '수정하기' : '저장하기'),
              ),
              onPressed: _isLoading ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: asyncMainCategories.when(
        data: (allMainCategories) {
          // 데이터 로드 성공 시, 기존 폼 UI를 표시합니다.
          // 모든 서브카테고리를 플랫 리스트로 만듭니다.
          final List<SubCategory> allSubCategories = [];
          if (allMainCategories.isNotEmpty) {
            // 로드된 카테고리가 있을 때만 처리
            for (var mainCategory in allMainCategories) {
              allSubCategories.addAll(mainCategory.subCategories);
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // --- 기본 정보 ---
                  _buildSectionTitle('기본 정보'),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '상품명',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (v) => (v == null || v.isEmpty) ? '상품명을 입력하세요' : null,
                  ),
                  const SizedBox(height: 16),

                  // --- 판매 정보 ---
                  _buildSectionTitle('판매 정보'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: '판매가격 (원)',
                            border: OutlineInputBorder(),
                            prefixText: '₩ ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return '가격을 입력하세요';
                            if (double.tryParse(v) == null) return '숫자만 입력';
                            if (double.parse(v) <= 0) return '0보다 커야함';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(
                            labelText: '재고 수량',
                            border: OutlineInputBorder(),
                            suffixText: '개',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return '재고를 입력하세요';
                            if (int.tryParse(v) == null) return '숫자만 입력';
                            if (int.parse(v) < 0) return '0 이상이어야 함';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 카테고리 선택 Dropdown
                  if (allSubCategories.isNotEmpty ||
                      widget.isEditMode && _selectedCategoryId != null)
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      // initState에서 설정된 값으로 시작
                      hint: const Text('카테고리 선택'),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items:
                          allSubCategories.map((SubCategory subCategory) {
                            // ... (DropdownMenuItem 생성 로직)
                            final mainCatName =
                                allMainCategories
                                    .firstWhere(
                                      (mc) => mc.subCategories.any(
                                        (sc) => sc.id == subCategory.id,
                                      ),
                                      orElse:
                                          () => MainCategory(
                                            id: '',
                                            name: '알수없음',
                                            iconPath: '',
                                          ),
                                    )
                                    .name;
                            return DropdownMenuItem<String>(
                              value: subCategory.id,
                              child: Text('$mainCatName > ${subCategory.name}'),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategoryId = newValue;
                        });
                      },
                      validator:
                          (value) => value == null ? '카테고리를 선택해주세요.' : null,
                    )
                  else if (allMainCategories.isEmpty &&
                      !widget.isEditMode) // 카테고리 로드는 성공했으나 비어있는 경우
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '선택 가능한 서브 카테고리가 없습니다. 먼저 카테고리를 등록해주세요.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // --- 상품 대표 이미지 ---
                  _buildSectionTitle('상품 대표 이미지'),
                  const SizedBox(height: 8),
                  InkWell(
                    // 대표 이미지 선택 영역
                    onTap:
                        _isUploadingRepresentativeImage
                            ? null
                            : _pickAndSimulateRepresentativeImageUpload,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child:
                          _isUploadingRepresentativeImage
                              ? const CircularProgressIndicator()
                              : (_pickedRepresentativeImageFile != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(7.0),
                                    child:
                                        kIsWeb // 웹에서는 XFile.path가 blob URL
                                            ? Image.network(
                                              _pickedRepresentativeImageFile!
                                                  .path,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (c, e, s) => const Center(
                                                    child: Text(
                                                      '미리보기 로드 실패 (파일)',
                                                    ),
                                                  ),
                                            )
                                            // 모바일에서는 Image.file(_pickedRepresentativeImageFile!.path) 사용 가능
                                            // 하지만 image_picker는 플랫폼에 따라 적절한 path를 제공하므로 Image.network도 웹에서 동작
                                            : Image.network(
                                              // 임시로 network 사용, 실제 모바일 테스트 시 Image.file 고려
                                              _pickedRepresentativeImageFile!
                                                  .path,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (c, e, s) => const Center(
                                                    child: Text(
                                                      '미리보기 로드 실패 (파일)',
                                                    ),
                                                  ),
                                            ),
                                  )
                                  : (_currentRepresentativeImageUrl != null &&
                                          _currentRepresentativeImageUrl!
                                              .isNotEmpty
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          7.0,
                                        ),
                                        child: Image.network(
                                          _currentRepresentativeImageUrl!,
                                          fit: BoxFit.contain,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Center(
                                              child: Icon(
                                                Icons.broken_image_outlined,
                                                color: Colors.red.shade400,
                                                size: 50,
                                              ),
                                            );
                                          },
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                        ),
                                      )
                                      : const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo_outlined,
                                            size: 50,
                                          ),
                                          Text('대표 이미지 선택'),
                                        ],
                                      ))),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- 상품 설명
                  _buildSectionTitle('상품 상세 설명'),

                  // ★★★ QuillSimpleToolbar 사용 ★★★
                  QuillSimpleToolbar(
                    controller: _descriptionQuillController,
                    // config 파라미터를 통해 툴바의 세부 버튼 및 동작 설정
                    config: QuillSimpleToolbarConfig(
                      embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                      customButtons: [
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.add_alarm_rounded),
                    onPressed: () {
                      _descriptionQuillController.document.insert(
                        _descriptionQuillController.selection.extentOffset,
                        TimeStampEmbed(
                          DateTime.now().toString(),
                        ),
                      );

                      _descriptionQuillController.updateSelection(
                        TextSelection.collapsed(
                          offset:_descriptionQuillController.selection.extentOffset + 1,
                        ),
                        ChangeSource.local,
                      );
                    },
                  ),
                ],
                      // 기타 필요한 툴바 버튼 활성화
                      showSmallButton: true,
                      showLineHeightButton: true,
                      showAlignmentButtons: true,
                      showDirection: true,
                      showClipboardCopy: true,
                      showClipboardPaste: true,
                      showClipboardCut: true,
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                        base: QuillToolbarBaseButtonOptions(
                          afterButtonPressed: () {
                            final isDesktop = {
                              TargetPlatform.linux,
                              TargetPlatform.windows,
                              TargetPlatform.macOS,
                            }.contains(defaultTargetPlatform);
                            if (isDesktop) {
                              _editorFocus.requestFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Container(
                    height: 400, // 예시 높이, 원하는 만큼 조절
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: QuillEditor(
                      focusNode: _editorFocus,
                      scrollController: _editorScrollController,
                      controller: _descriptionQuillController,
                      config: QuillEditorConfig(
                        padding: const EdgeInsets.all(16),
                        
                        embedBuilders: [
                  
                    ...FlutterQuillEmbeds.editorBuilders(
                      imageEmbedConfig: QuillEditorImageEmbedConfig(
                        imageProviderBuilder: (context, imageUrl) {
                          // https://pub.dev/packages/flutter_quill_extensions#-image-assets
                          if (imageUrl.startsWith('assets/')) {
                            return AssetImage(imageUrl);
                          }
                          return null;
                        },
                      ),
                      videoEmbedConfig: QuillEditorVideoEmbedConfig(
                        customVideoBuilder: (videoUrl, readOnly) {
                          // To load YouTube videos https://github.com/singerdmx/flutter-quill/releases/tag/v10.8.0
                          return null;
                        },
                      ),
                    ),
                    TimeStampEmbedBuilder(),
                  ],
                  
                      ),
                    ),
                  ),

                  if (_isQuillImageUploading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(strokeWidth: 2),
                            SizedBox(width: 8),
                            Text("이미지 처리 중..."),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // --- 상품 설명 끝 ---

                  // --- 상품 유형 선택 섹션 ---
                  _buildSectionTitle('상품 유형 (중복 선택 가능)'),
                  Wrap(
                    // 여러 줄로 자동 정렬되도록 Wrap 사용
                    spacing: 8.0, // 가로 간격
                    runSpacing: 0.0, // 세로 간격
                    children:
                        _productTypeMap.entries.map((entry) {
                          final displayLabel = entry.key; // '신상품', '인기상품' 등
                          final typeValue =
                              entry.value; // 'new', 'popular' 등 (저장될 값)
                          return SizedBox(
                            // 각 CheckboxListTile의 너비를 제한하기 위해
                            width:
                                MediaQuery.of(context).size.width / 2 -
                                24, // 화면 너비의 절반보다 약간 작게
                            child: CheckboxListTile(
                              title: Text(
                                displayLabel,
                                style: const TextStyle(fontSize: 15),
                              ),
                              value: _selectedProductTypes[typeValue] ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedProductTypes[typeValue] =
                                      value ?? false;
                                });
                              },
                              controlAffinity:
                                  ListTileControlAffinity
                                      .leading, // 체크박스를 앞에 표시
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // --- 상품 유형 선택 섹션 끝 ---
                  _buildSectionTitle('판매 상태'),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _productStatuses.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
        loading:
            () => const Center(child: CircularProgressIndicator()), // 카테고리 로딩 중
        error:
            (error, stackTrace) => Center(
              // 카테고리 로드 실패
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '카테고리를 불러오는 중 오류가 발생했습니다.\n$error',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(
    String value,
  ) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';

  static TimeStampEmbed fromDocument(Document document) =>
      TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(embedContext.node.value.data as String),
      ],
    );
  }
}
