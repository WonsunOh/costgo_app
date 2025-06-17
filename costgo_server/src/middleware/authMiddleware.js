const jwt = require('jsonwebtoken');
const User = require('../models/User');

exports.protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      // 'Bearer <TOKEN>' 형식에서 토큰 부분만 추출
      token = req.headers.authorization.split(' ')[1];

      // 토큰 검증
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // 토큰의 ID를 사용하여 사용자 정보를 DB에서 찾음 (비밀번호 제외)
      // 이 사용자 정보는 이후의 모든 라우트 핸들러에서 req.user로 접근 가능
      req.user = await User.findById(decoded.id).select('-password');

      if (!req.user) {
        return res.status(401).json({ message: '인증 실패: 사용자를 찾을 수 없습니다.' });
      }

      next(); // 다음 미들웨어 또는 컨트롤러로 이동
    } catch (error) {
      console.error('인증 에러:', error);
      res.status(401).json({ message: '인증 실패: 토큰이 유효하지 않습니다.' });
    }
  }

  if (!token) {
    res.status(401).json({ message: '인증 실패: 토큰이 없습니다.' });
  }
};

// 관리자 권한 확인 미들웨어 (선택 사항)
exports.restrictToAdmin = (req, res, next) => {
  if (req.user && req.user.isAdmin) {
    next();
  } else {
    res.status(403).json({ message: '권한 없음: 관리자만 접근할 수 있습니다.' });
  }
};