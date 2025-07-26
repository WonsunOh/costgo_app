const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const authMiddleware = require('../middleware/authMiddleware');

// 모든 주문 관련 라우트는 로그인이 필요합니다.
router.use(authMiddleware.isAuth);

// [POST] /api/orders/ - 새 주문 생성
router.post('/', orderController.placeOrder);

// [GET] /api/orders/my-orders - 내 주문 내역 조회
router.get('/my-orders', orderController.getMyOrders);

// --- 관리자용 라우트 ---
router.use(authMiddleware.isAdmin);

// [GET] /api/orders/admin/all-orders - 모든 주문 내역 조회
router.get('/admin/all-orders', orderController.getAllOrders);

// [PUT] /api/orders/admin/update-status/:orderId - 주문 상태 변경
router.put('/admin/update-status/:orderId', orderController.updateOrderStatus);

module.exports = router;