// 환경 변수 로드
require('dotenv').config();

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

// 라우트 파일 import 
const authRoutes = require('./src/routes/authRoutes');
const productRoutes = require('./src/routes/productRoutes');
const categoryRoutes = require('./src/routes/categoryRoutes');
const userRoutes = require('./src/routes/userRoutes');
const wishlistRoutes = require('./src/routes/wishlistRoutes');

// Express 앱 생성
const app = express();

// 미들웨어 설정
app.use(cors()); // CORS 허용
app.use(express.json()); // JSON 요청 본문 파싱

// 기본 라우트 (서버가 살아있는지 확인용)
app.get('/', (req, res) => {
  res.send('E-commerce API 서버가 실행 중입니다.');
});

// API 라우트 연결
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/users', userRoutes); // 관리자용 회원 관리 라우트
app.use('/api/wishlist', wishlistRoutes);

// MongoDB 연결
mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('MongoDB에 성공적으로 연결되었습니다.');
    // DB 연결 성공 시에만 서버 실행
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      console.log(`서버가 http://localhost:${PORT} 에서 실행 중입니다.`);
    });
  })
  .catch(err => {
    console.error('MongoDB 연결 실패:', err);
  });

// 에러 처리 미들웨어 (선택 사항이지만 권장)
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('서버에서 오류가 발생했습니다!');
});