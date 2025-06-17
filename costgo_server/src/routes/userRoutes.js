const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// TODO: 이 라우트는 관리자만 접근 가능하도록 인증 미들웨어 추가 필요
router.get('/', userController.getAllUsers);

module.exports = router;