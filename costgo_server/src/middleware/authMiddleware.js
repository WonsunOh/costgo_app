const jwt = require('jsonwebtoken');
const User = require('../models/User');

const isAuth = async (req, res, next) => {
  try {
    const token = req.header('x-auth-token');
    if (!token) {
      return res.status(401).json({ msg: '인증 토큰이 없어 인증이 거부되었습니다.' });
    }

    const verified = jwt.verify(token, process.env.JWT_SECRET);
    if (!verified) {
      return res.status(401).json({ msg: '토큰이 유효하지 않습니다.' });
    }

    req.user = await User.findById(verified.id);
    if (!req.user) {
        return res.status(401).json({ msg: '사용자를 찾을 수 없습니다.' });
    }
    next();
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

const isAdmin = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    return res.status(403).json({ msg: '접근이 거부되었습니다. 관리자 권한이 필요합니다.' });
  }
};

// isAuth와 isAdmin 함수를 모두 export 하도록 수정합니다.
module.exports = { isAuth, isAdmin };