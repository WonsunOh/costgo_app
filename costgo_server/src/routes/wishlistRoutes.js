const express = require('express');
const router = express.Router();
const wishlistController = require('../controllers/wishlistController');
const { protect } = require('../middleware/authMiddleware'); // 인증 미들웨어 import

// 모든 찜 목록 관련 라우트는 로그인이 필요하므로 protect 미들웨어를 먼저 적용
router.use(protect);

router.route('/')
  .get(wishlistController.getWishlist)      // GET /api/wishlist
  .post(wishlistController.addToWishlist);     // POST /api/wishlist

router.route('/:productId')
  .delete(wishlistController.removeFromWishlist); // DELETE /api/wishlist/:productId

module.exports = router;