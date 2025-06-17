const Product = require('../models/Product');

// 모든 상품 목록 가져오기
exports.getAllProducts = async (req, res) => {
  try {
    const products = await Product.find({}).sort({ createdAt: -1 });
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ message: '상품 목록을 가져오는 중 오류 발생', error: error.message });
  }
};

// 새 상품 추가
exports.addProduct = async (req, res) => {
  try {
    const newProduct = new Product(req.body);
    const savedProduct = await newProduct.save();
    res.status(201).json(savedProduct);
  } catch (error) {
    res.status(400).json({ message: '상품 추가 중 오류 발생', error: error.message });
  }
};

// 특정 상품 수정
exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params; // URL에서 상품 ID 가져오기
    // MongoDB의 _id로 문서를 찾아 업데이트
    const updatedProduct = await Product.findByIdAndUpdate(
      id,
      req.body,
      { new: true, runValidators: true } // new: true는 업데이트된 문서를 반환, runValidators는 스키마 유효성 검사 실행
    );
    if (!updatedProduct) {
      return res.status(404).json({ message: '해당 ID의 상품을 찾을 수 없습니다.' });
    }
    res.status(200).json(updatedProduct);
  } catch (error) {
    res.status(400).json({ message: '상품 수정 중 오류 발생', error: error.message });
  }
};

// 특정 상품 삭제
exports.deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedProduct = await Product.findByIdAndDelete(id);
    if (!deletedProduct) {
      return res.status(404).json({ message: '해당 ID의 상품을 찾을 수 없습니다.' });
    }
    res.status(200).json({ message: '상품이 성공적으로 삭제되었습니다.' });
  } catch (error) {
    res.status(500).json({ message: '상품 삭제 중 오류 발생', error: error.message });
  }
};

// (선택 사항) 특정 상품 하나 가져오기
exports.getProductById = async (req, res) => {
  try {
    const { id } = req.params;
    const product = await Product.findById(id);
    if (!product) {
      return res.status(404).json({ message: '해당 ID의 상품을 찾을 수 없습니다.' });
    }
    res.status(200).json(product);
  } catch (error) {
    res.status(500).json({ message: '상품 정보를 가져오는 중 오류 발생', error: error.message });
  }
};