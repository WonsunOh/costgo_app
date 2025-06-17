const User = require('../models/User');

// 모든 사용자 목록 가져오기 (관리자용)
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find({}).sort({ createdAt: -1 }); // 최신 가입순 정렬
    // 비밀번호 필드는 제외하고 전송
    const usersWithoutPassword = users.map(user => {
        const { password, ...userData } = user.toObject();
        return userData;
    });
    res.status(200).json(usersWithoutPassword);
  } catch (error) {
    res.status(500).json({ message: '사용자 목록을 가져오는 중 오류 발생', error: error.message });
  }
};