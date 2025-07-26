// costgo_server/src/routes/userRoutes.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');

// [ADMIN] GET /api/users/ - 관리자가 모든 사용자 목록을 조회
router.get(
  '/',
  authMiddleware.isAuth, // 먼저 로그인 여부 확인
  authMiddleware.isAdmin, // 그 다음 관리자 여부 확인
  userController.getAllUsers
);

// [USER/ADMIN] PUT /api/users/:userId - 사용자 정보 업데이트
router.put(
  '/:userId',
  authMiddleware.isAuth,
  userController.updateUser
);

// --- 장바구니 관련 라우트 추가 ---

// [POST] /api/users/cart/add - 장바구니에 상품 추가
router.post('/cart/add', authMiddleware.isAuth, userController.addToCart);

// [DELETE] /api/users/cart/remove/:productId - 장바구니에서 상품 제거
router.delete('/cart/remove/:productId', authMiddleware.isAuth, userController.removeFromCart);

// [PUT] /api/users/cart/quantity - 장바구니 상품 수량 변경
router.put('/cart/quantity', authMiddleware.isAuth, userController.updateCartQuantity);

// [PUT] /api/users/complete-profile - 프로필 완성 상태로 변경
router.put('/complete-profile', authMiddleware.isAuth, userController.completeProfile);



module.exports = router;