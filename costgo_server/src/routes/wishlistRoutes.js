const express = require('express');
const router = express.Router();
const wishlistController = require('../controllers/wishlistController');
const authMiddleware = require('../middleware/authMiddleware');

// 모든 경로는 먼저 로그인 여부를 확인합니다.
router.use(authMiddleware.isAuth);

// [GET] /api/wishlist - 현재 사용자의 위시리스트 가져오기
router.get('/', wishlistController.getWishlist);

// [POST] /api/wishlist/add - 위시리스트에 상품 추가
router.post('/add', wishlistController.addToWishlist);

// [DELETE] /api/wishlist/remove/:productId - 위시리스트에서 상품 제거
router.delete('/remove/:productId', wishlistController.removeFromWishlist);

module.exports = router;