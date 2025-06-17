const User = require('../models/User');
const jwt = require('jsonwebtoken');

// JWT 생성 헬퍼 함수
const createToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: '1d', // 토큰 유효기간: 1일
  });
};

// 회원가입
exports.signup = async (req, res) => {
  const { name, email, password, phoneNumber, address } = req.body;
  try {
    // 이메일 중복 확인
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: '이미 사용 중인 이메일입니다.' });
    }
    const user = await User.create({ name, email, password, phoneNumber, address });
    res.status(201).json({
      message: '회원가입이 성공적으로 완료되었습니다.',
      user: { id: user._id, name: user.name, email: user.email },
    });
  } catch (error) {
    res.status(400).json({ message: '회원가입 처리 중 오류 발생', error: error.message });
  }
};

// 로그인
exports.login = async (req, res) => {
  const { email, password } = req.body;
  try {
    // 이메일로 사용자 찾기
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: '이메일 또는 비밀번호가 잘못되었습니다.' });
    }
    // 비밀번호 비교
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: '이메일 또는 비밀번호가 잘못되었습니다.' });
    }
    // JWT 생성
    const token = createToken(user._id);
    res.status(200).json({
      token,
      user: { id: user._id, name: user.name, email: user.email, isAdmin: user.isAdmin },
    });
  } catch (error) {
    res.status(400).json({ message: '로그인 처리 중 오류 발생', error: error.message });
  }
};