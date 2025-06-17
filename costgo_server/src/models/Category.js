const mongoose = require('mongoose');

// 서브 카테고리를 위한 스키마
const subCategorySchema = new mongoose.Schema({
  // _id는 MongoDB가 자동으로 생성하므로, Flutter 모델의 id와 매핑됩니다.
  name: { 
    type: String, 
    required: [true, '서브 카테고리 이름을 입력해주세요.'],
    trim: true,
  }
});

// 메인 카테고리를 위한 스키마
const mainCategorySchema = new mongoose.Schema({
  name: { 
    type: String, 
    required: [true, '메인 카테고리 이름을 입력해주세요.'],
    unique: true, // 메인 카테고리 이름은 고유해야 함
    trim: true,
  },
  iconPath: { 
    type: String, 
    default: 'assets/icons/default_category.png' 
  },
  subCategories: [subCategorySchema] // 서브 카테고리를 내장 문서 배열로 관리
}, {
  timestamps: true // createdAt, updatedAt 필드 자동 생성
});

const Category = mongoose.model('Category', mainCategorySchema);

module.exports = Category;