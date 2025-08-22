const express = require('express');
const productController = require('../controllers/productController');
const authMiddleware = require('../middleware/authMiddleware');
const multer = require('multer');

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() });

// 이 파일의 모든 경로는 '/api/admin/products'를 기준으로 합니다.

// GET /api/admin/products - 관리자용 상품 목록 조회
router.get('/', authMiddleware, productController.getAdminProducts);

// POST /api/admin/products - 관리자가 새 상품을 추가
router.post('/', authMiddleware, upload.array('images', 10), productController.createProduct);

// PUT /api/admin/products/:id - 관리자가 특정 상품을 수정
router.put('/:id', authMiddleware, upload.array('images', 10), productController.updateProduct);

// DELETE /api/admin/products/:id - 관리자가 특정 상품을 삭제
router.delete('/:id', authMiddleware, productController.deleteProduct);

module.exports = router;