const express = require('express');
const productController = require('../controllers/productController');
const authMiddleware = require('../middleware/authMiddleware');
const multer = require('multer');


const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() });

// ======================================================
// ==               일반 사용자용 라우트                ==
// ======================================================

// GET /api/products - 모든 사용자가 전체 상품 목록을 조회
// (HomeScreen에서 사용)
router.get('/', productController.getProducts);

// GET /api/products/search/:query - 상품 검색
router.get('/search/:query', productController.searchProducts);

// [PUBLIC] GET /api/products/:id - 모든 사용자가 특정 상품 상세 정보 조회
router.get('/:id', productController.getProductById); // 필요시 주석 해제하여 사용



// ======================================================
// ==                 관리자용 라우트                   ==
// ======================================================
// '/admin'으로 시작하는 모든 경로는 관리자 인증(isAdmin) 미들웨어를 거칩니다.

// POST /api/products/admin - 관리자가 새 상품을 추가
router.post('/admin', authMiddleware.isAdmin, productController.createProduct);

// GET /api/products/admin - 관리자용 상품 목록 조회
router.get('/admin', authMiddleware.isAdmin, productController.getAdminProducts);

// PUT /api/products/admin/:id - 관리자가 특정 상품을 수정
router.put('/admin/:id', authMiddleware.isAdmin, productController.updateProduct);

// DELETE /api/products/admin/:id - 관리자가 특정 상품을 삭제
router.delete('/admin/:id', authMiddleware.isAdmin, productController.deleteProduct);


module.exports = router;