const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, '이름을 입력해주세요.'],
    trim: true,
  },
  email: {
    type: String,
    required: [true, '이메일을 입력해주세요.'],
    unique: true, // 이메일은 고유해야 함
    trim: true,
    lowercase: true,
  },
  password: {
    type: String,
    required: [true, '비밀번호를 입력해주세요.'],
  },
  phoneNumber: {
    type: String,
    default: '',
  },
  address: {
    type: String,
    default: '',
  },
  additionalInfoCompleted: {
    type: Boolean,
    default: false,
  },
  isAdmin: {
    type: Boolean,
    default: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
  },

 // ★★★ 찜한 상품 ID 목록을 저장할 배열 필드 추가 ★★★
  wishlist: [{
    type: mongoose.Schema.Types.ObjectId, // Product의 _id를 참조
    ref: 'Product'
  }],

}, { timestamps: true }); // createdAt, updatedAt 자동 생성 옵션




// 비밀번호 해시화 미들웨어: 저장하기 전에 비밀번호를 암호화
userSchema.pre('save', async function (next) {
  // 비밀번호 필드가 수정되었을 때만 해시화 실행
  if (!this.isModified('password')) {
    return next();
  }
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    return next();
  } catch (error) {
    return next(error);
  }
});

// 비밀번호 비교 메소드 추가
userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

const User = mongoose.model('User', userSchema);

module.exports = User;