const jwt = require('jsonwebtoken');
const User = require('../models/User');
const jwksClient = require('jwks-rsa');
require('dotenv').config();

// 💡 1. .env 파일에서 Supabase URL을 가져옵니다.
const supabaseUrl = process.env.SUPABASE_URL;
if (!supabaseUrl) {
  throw new Error("Supabase URL is not defined in .env file");
}

const client = jwksClient({
  jwksUri: `${supabaseUrl}/auth/v1/jwks`
});

// 키를 가져오는 함수
function getKey(header, callback) {
  client.getSigningKey(header.kid, function(err, key) {
    if (err) {
      return callback(err);
    }
    const signingKey = key.publicKey || key.rsaPublicKey;
    callback(null, signingKey);
  });
}

// 💡 2. 실제 인증을 처리하는 미들웨어 함수
const authMiddleware = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: '인증 토큰이 없거나 형식이 올바르지 않습니다.' });
  }

  const token = authHeader.split(' ')[1];

  jwt.verify(token, getKey, { algorithms: ['RS256'] }, (err, decoded) => {
    if (err) {
      console.error("JWT Verification Error:", err);
      return res.status(401).json({ message: '유효하지 않은 토큰입니다.' });
    }
    // 💡 3. 토큰이 유효하면, 요청 객체(req)에 사용자 정보를 추가하고 다음 단계로 넘어갑니다.
    req.user = decoded; // decoded 안에는 user_id(sub), email 등이 들어있습니다.
    next();
  });
};


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
module.exports = { isAuth, isAdmin, authMiddleware};