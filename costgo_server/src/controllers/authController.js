const User = require('../models/User');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

exports.signup = async (req, res) => {
  try {
    // 프론트엔드에서 보낸 username을 받습니다.
    const { username, email, password } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ msg: '이미 사용 중인 이메일입니다.' });
    }

    const hashedPassword = await bcrypt.hash(password, 8);

    // User 모델을 생성할 때, DB 스키마의 'name' 필드에
    // 프론트에서 받은 'username' 값을 할당합니다.
    let user = new User({
      name: username, // <--- 이 부분이 핵심 수정사항입니다!
      email,
      password: hashedPassword,
    });

    user = await user.save();
    
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET);
    
    const userResponse = user.toObject();
    delete userResponse.password;

    res.status(200).json({ token, user: userResponse });

  } catch (e) {
    // 디버깅 로그는 이제 제거하셔도 좋습니다.
    res.status(500).json({ error: e.message });
  }
};

// login, getUserData 등 나머지 함수들은 그대로 둡니다.
exports.login = async (req, res) => {
    try {
      const { email, password } = req.body;
  
      const user = await User.findOne({ email });
      if (!user) {
        return res.status(400).json({ msg: '이메일 또는 비밀번호가 일치하지 않습니다.' });
      }
  
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(400).json({ msg: '이메일 또는 비밀번호가 일치하지 않습니다.' });
      }
  
      const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET);
      
      const userResponse = user.toObject();
      delete userResponse.password;
  
      res.status(200).json({ token, user: userResponse });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
};

exports.getUserData = async (req, res) => {
    try {
        const user = await User.findById(req.user)
            .select('-password')
            .populate({
                path: 'cart.product',
                model: 'Product',
            });
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }
        res.json(user);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
};