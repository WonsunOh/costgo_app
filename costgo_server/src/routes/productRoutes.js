const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
// const { protect, restrictToAdmin } = require('../middleware/authMiddleware'); // 관리자 인증 미들웨어 (향후 구현)

// 라우트 정의
router.route('/')
  .get(productController.getAllProducts) // GET /api/products
  .post(productController.addProduct); // POST /api/products - TODO: 관리자만 접근하도록 protect, restrictToAdmin 추가

router.route('/:id')
  .get(productController.getProductById)       // GET /api/products/:id
  .put(productController.updateProduct)      // PUT /api/products/:id - TODO: 관리자만
  .delete(productController.deleteProduct);  // DELETE /api/products/:id - TODO: 관리자만

module.exports = router;