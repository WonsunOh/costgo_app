const Product = require('../models/Product');

// 함수들을 먼저 정의합니다.
const getProducts = async (req, res) => {
  try {
    const products = await Product.find({}).populate('category');
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ error: '상품을 불러오는 중 오류가 발생했습니다.' });
  }
};

const getProductById = async (req, res) => {
    try {
      const product = await Product.findById(req.params.id).populate('category');
      if (!product) {
        return res.status(404).json({ msg: '상품을 찾을 수 없습니다.' });
      }
      res.status(200).json(product);
    } catch (error) {
      if (error.kind === 'ObjectId') {
        return res.status(404).json({ msg: '상품을 찾을 수 없습니다.' });
      }
      res.status(500).json({ error: '상품 정보를 불러오는 중 오류가 발생했습니다.' });
    }
  };

const searchProducts = async (req, res) => {
    try {
      const { query } = req.params;
      const products = await Product.find({
        name: { $regex: query, $options: 'i' },
      }).populate('category');
  
      res.status(200).json(products);
    } catch (error) {
      res.status(500).json({ error: '상품 검색 중 오류가 발생했습니다.' });
    }
  };

const getAdminProducts = async (req, res) => {
  try {
    const products = await Product.find({}).populate('category');
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ error: '관리자용 상품 목록을 불러오는 중 오류가 발생했습니다.' });
  }
};

const createProduct = async (req, res) => {
  try {
    const { name, description, price, quantity, category, images } = req.body;
    const newProduct = new Product({
      name,
      description,
      price,
      quantity,
      category,
      images,
    });
    const savedProduct = await newProduct.save();
    res.status(201).json(savedProduct);
  } catch (error) {
    res.status(500).json({ error: '상품 생성 중 오류가 발생했습니다: ' + error.message });
  }
};

const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;
    const updatedProduct = await Product.findByIdAndUpdate(id, updateData, {
      new: true,
      runValidators: true,
    });
    if (!updatedProduct) {
      return res.status(404).json({ msg: '상품을 찾을 수 없습니다.' });
    }
    res.status(200).json(updatedProduct);
  } catch (error) {
    res.status(500).json({ error: '상품 수정 중 오류가 발생했습니다: ' + error.message });
  }
};

const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedProduct = await Product.findByIdAndDelete(id);
    if (!deletedProduct) {
      return res.status(404).json({ msg: '상품을 찾을 수 없습니다.' });
    }
    res.status(200).json({ msg: '상품이 성공적으로 삭제되었습니다.' });
  } catch (error) {
    res.status(500).json({ error: '상품 삭제 중 오류가 발생했습니다: ' + error.message });
  }
};

// 정의한 모든 함수들을 module.exports에 담아서 외부에서 사용할 수 있도록 합니다.
module.exports = {
    getProducts,
    getProductById,
    searchProducts,
    getAdminProducts,
    createProduct,
    updateProduct,
    deleteProduct
};