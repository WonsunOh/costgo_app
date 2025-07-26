// costgo_server/src/controllers/userController.js
const User = require('../models/User');

// [ADMIN] 모든 사용자 정보 가져오기
exports.getAllUsers = async (req, res) => {
  try {
    // 비밀번호를 제외한 모든 사용자 정보를 찾습니다.
    const users = await User.find({}).select('-password');
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ error: '사용자 정보를 불러오는 중 오류가 발생했습니다.' });
  }
};

// [USER/ADMIN] 사용자 정보 업데이트
exports.updateUser = async (req, res) => {
  // 본인 또는 관리자만 정보 수정이 가능하도록 로직 추가 가능
  // (예: if (req.user.id !== req.params.userId && req.user.role !== 'admin') { ... } )
  try {
    const { userId } = req.params;
    const updatedUser = await User.findByIdAndUpdate(userId, req.body, {
      new: true,
    }).select('-password');

    if (!updatedUser) {
      return res.status(404).json({ msg: '사용자를 찾을 수 없습니다.' });
    }
    res.status(200).json(updatedUser);
  } catch (error) {
    res.status(500).json({ error: '사용자 정보 업데이트 중 오류가 발생했습니다.' });
  }

};

// 장바구니에 상품 추가
exports.addToCart = async (req, res) => {
  try {
    const { productId } = req.body;
    const user = await User.findById(req.user.id);

    // 이미 장바구니에 있는 상품인지 확인
    const existingProductIndex = user.cart.findIndex(
      (item) => item.product.toString() === productId
    );

    if (existingProductIndex > -1) {
      // 이미 있으면 수량만 1 증가
      user.cart[existingProductIndex].quantity += 1;
    } else {
      // 없으면 새로 추가
      user.cart.push({ product: productId, quantity: 1 });
    }

    await user.save();
    res.status(200).json(user.cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 장바구니에서 상품 제거
exports.removeFromCart = async (req, res) => {
  try {
    const { productId } = req.params;
    await User.findByIdAndUpdate(req.user.id, {
      $pull: { cart: { product: productId } },
    });
    res.status(200).json({ msg: '상품이 장바구니에서 삭제되었습니다.' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 장바구니 상품 수량 변경
exports.updateCartQuantity = async (req, res) => {
  try {
    const { productId, quantity } = req.body;
    if (quantity <= 0) {
        // 수량이 0 이하면 상품 제거
        return exports.removeFromCart({ params: { productId }, user: req.user }, res);
    }

    const user = await User.findOneAndUpdate(
      { _id: req.user.id, 'cart.product': productId },
      { $set: { 'cart.$.quantity': quantity } },
      { new: true }
    );
    res.status(200).json(user.cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.completeProfile = async (req, res) => {
  try {
    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      { isProfileComplete: true },
      { new: true }
    ).select('-password');
    res.status(200).json(updatedUser);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};