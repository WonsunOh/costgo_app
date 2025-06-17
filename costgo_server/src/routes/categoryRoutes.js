const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
// const { protect, restrictToAdmin } = require('../middleware/authMiddleware'); // 관리자 인증 미들웨어 (향후 구현)

// 메인 카테고리 라우트
router.route('/')
  .get(categoryController.getAllCategories)   // GET /api/categories
  .post(categoryController.addMainCategory);  // POST /api/categories (TODO: 관리자 전용)

router.route('/:id')
  .put(categoryController.updateMainCategory)     // PUT /api/categories/:id (TODO: 관리자 전용)
  .delete(categoryController.deleteMainCategory); // DELETE /api/categories/:id (TODO: 관리자 전용)

// 서브 카테고리 라우트
router.post('/:mainId/subcategories', categoryController.addSubCategory); // POST /api/categories/:mainId/subcategories (TODO: 관리자 전용)
router.put('/:mainId/subcategories/:subId', categoryController.updateSubCategory); // PUT /api/categories/:mainId/subcategories/:subId (TODO: 관리자 전용)
router.delete('/:mainId/subcategories/:subId', categoryController.deleteSubCategory); // DELETE /api/categories/:mainId/subcategories/:subId (TODO: 관리자 전용)

module.exports = router;