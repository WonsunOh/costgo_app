const User = require('../models/User');

// 찜목록 가져오기
exports.getWishlist = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).populate({
      path: 'wishlist',
      populate: {
        path: 'category',
        model: 'Category'
      }
    });

    if (!user) {
      return res.status(404).json({ msg: '사용자를 찾을 수 없습니다.' });
    }
    res.status(200).json(user.wishlist);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 찜목록에 상품 추가
exports.addToWishlist = async (req, res) => {
  try {
    const { productId } = req.body;
    if (!productId) {
      return res.status(400).json({ msg: '상품 ID가 필요합니다.' });
    }

    // $addToSet 연산자는 중복을 방지하며 아이템을 배열에 추가합니다.
    await User.findByIdAndUpdate(req.user.id, {
      $addToSet: { wishlist: productId },
    });

    res.status(200).json({ msg: '찜목록에 추가되었습니다.' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 찜목록에서 상품 제거
exports.removeFromWishlist = async (req, res) => {
  try {
    const { productId } = req.params;

    // $pull 연산자는 배열에서 특정 조건의 아이템을 제거합니다.
    await User.findByIdAndUpdate(req.user.id, {
      $pull: { wishlist: productId },
    });
    
    res.status(200).json({ msg: '찜목록에서 제거되었습니다.' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};