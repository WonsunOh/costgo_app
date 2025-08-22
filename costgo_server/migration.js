// migration.js
require('dotenv').config(); // .env 파일에서 환경 변수를 불러옵니다.

const { MongoClient } = require('mongodb');
const { createClient } = require('@supabase/supabase-js');

// 1. MongoDB 연결 정보 (.env 파일에서 가져옴)
const MONGO_URI = process.env.MONGODB_URI;
// MongoDB URI에서 데이터베이스 이름을 자동으로 추출합니다.
const MONGO_DB_NAME = MONGO_URI.split('/').pop().split('?')[0];

// 2. Supabase 연결 정보 (이전과 동일)
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

async function migrateData() {
  console.log('Migration script started...');
  if (!MONGO_URI) {
    console.error('MongoDB URI not found in .env file. Please check your configuration.');
    return;
  }

  const mongoClient = new MongoClient(MONGO_URI);
  
  try {
    // DB 연결
    await mongoClient.connect();
    const db = mongoClient.db(MONGO_DB_NAME);
    console.log(`Successfully connected to MongoDB database: ${MONGO_DB_NAME}`);

    // --- 상품 데이터 이전 (products -> shop_products) ---
    console.log('\nStarting product migration...');
    const mongoProducts = await db.collection('products').find({}).toArray();
    console.log(`Found ${mongoProducts.length} products to migrate.`);

    for (const mongoProduct of mongoProducts) {
      // 1. 기본 상품 정보 삽입
      const { data: newProduct, error: productError } = await supabase
        .from('shop_products')
        .insert({
          name: mongoProduct.name,
          description: mongoProduct.description,
          display_price: mongoProduct.price,
          main_image_url: mongoProduct.images ? `http://YOUR_NODE_SERVER_IP:3000/image/${mongoProduct.images[0]}` : null,
          is_active: mongoProduct.stock > 0,
        })
        .select()
        .single();

      if (productError) {
        console.error(`  - Error inserting product "${mongoProduct.name}":`, productError.message);
        continue;
      }
      
      // 2. 상품 옵션 정보 삽입 (옵션이 있는 경우)
      if (mongoProduct.options && Array.isArray(mongoProduct.options) && mongoProduct.options.length > 0) {
        for (const option of mongoProduct.options) {
            await supabase.from('shop_product_options').insert({
              product_id: newProduct.id,
              option_name: option.name, // 예: "색상"
              option_value: option.value, // 예: "블랙"
              stock_quantity: option.stock || 0,
            });
        }
      } else {
        // 옵션이 없는 상품의 경우, 기본 재고를 하나의 옵션으로 만들어줌
        await supabase.from('shop_product_options').insert({
            product_id: newProduct.id,
            option_name: '기본',
            option_value: '기본',
            stock_quantity: mongoProduct.stock || 0,
        });
      }
      console.log(`  - Successfully migrated product: "${mongoProduct.name}"`);
    }
    console.log('Product migration finished.');

    // TODO: 회원(users), 주문(orders) 데이터 이전 로직을 여기에 추가할 수 있습니다.

  } catch (err) {
    console.error('An unexpected error occurred during migration:', err);
  } finally {
    await mongoClient.close();
    console.log('\nMongoDB connection closed.');
    console.log('Migration script finished.');
  }
}

// 스크립트 실행
migrateData();