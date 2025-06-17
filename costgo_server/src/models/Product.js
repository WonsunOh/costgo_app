const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  // _id는 MongoDB가 자동으로 생성하므로, Flutter에서 생성한 id를 저장하고 싶다면 별도 필드 사용 가능
  // 여기서는 _id를 기본 키로 사용하고, Flutter에서 필요 시 이 값을 id로 사용한다고 가정
  name: {
    type: String,
    required: [true, '상품명을 입력해주세요.'],
    trim: true,
  },
  description: { // Quill Editor의 Delta JSON 문자열 저장
    type: String,
    required: [true, '상품 설명을 입력해주세요.'],
  },
  imageUrl: { // 대표 이미지 URL
    type: String,
    required: [true, '대표 이미지 URL을 입력해주세요.'],
  },
  price: {
    type: Number,
    required: [true, '가격을 입력해주세요.'],
    min: [0, '가격은 0 이상이어야 합니다.'],
  },
  stock: { // 재고
    type: Number,
    required: [true, '재고를 입력해주세요.'],
    min: [0, '재고는 0 이상이어야 합니다.'],
    default: 0,
  },
  category: { // 서브 카테고리 ID
    type: String,
    required: [true, '카테고리를 선택해주세요.'],
  },
  status: { // 판매 상태
    type: String,
    enum: ['판매중', '품절', '숨김'],
    default: '판매중',
  },
  productTypes: { // 상품 유형 (신상품, 인기상품 등)
    type: [String],
    default: [],
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
  },
});

// updatedAt 필드를 저장/업데이트 시 자동으로 설정
productSchema.pre('save', function (next) {
  this.updatedAt = Date.now();
  next();
});
productSchema.pre('findOneAndUpdate', function (next) {
  this.set({ updatedAt: Date.now() });
  next();
});


const Product = mongoose.model('Product', productSchema);

module.exports = Product;