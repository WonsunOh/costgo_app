const User = require('../models/User');

// 현재 사용자의 찜 목록 가져오기
exports.getWishlist = async (req, res) => {
  try {
    // protect 미들웨어에서 req.user에 저장된 사용자 정보를 사용
    // populate를 사용하여 찜한 상품들의 상세 정보까지 함께 가져옴
    const userWithWishlist = await User.findById(req.user.id).populate('wishlist');
    
    if (!userWithWishlist) {
      return res.status(404).json({ message: '사용자 정보를 찾을 수 없습니다.' });
    }
    
    res.status(200).json(userWithWishlist.wishlist);
  } catch (error) {
    res.status(500).json({ message: '찜 목록을 가져오는 중 오류 발생', error: error.message });
  }
};

// 찜 목록에 상품 추가
exports.addToWishlist = async (req, res) => {
  try {
    const { productId } = req.body;
    if (!productId) {
      return res.status(400).json({ message: '상품 ID가 필요합니다.' });
    }
    
    // $addToSet 연산자를 사용하여 중복 없이 상품 ID 추가
    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      { $addToSet: { wishlist: productId } },
      { new: true, runValidators: true }
    ).populate('wishlist');

    res.status(200).json({ message: '찜 목록에 추가되었습니다.', wishlist: updatedUser.wishlist });
  } catch (error) {
    res.status(500).json({ message: '찜 목록 추가 중 오류 발생', error: error.message });
  }
};

// 찜 목록에서 상품 제거
exports.removeFromWishlist = async (req, res) => {
  try {
    const { productId } = req.params; // URL 파라미터에서 상품 ID 가져오기

    // $pull 연산자를 사용하여 배열에서 상품 ID 제거
    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      { $pull: { wishlist: productId } },
      { new: true }
    ).populate('wishlist');
    
    res.status(200).json({ message: '찜 목록에서 삭제되었습니다.', wishlist: updatedUser.wishlist });
  } catch (error) {
    res.status(500).json({ message: '찜 목록 삭제 중 오류 발생', error: error.message });
  }
};