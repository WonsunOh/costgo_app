const Order = require('../models/Order');
const User = require('../models/User');

exports.placeOrder = async (req, res) => {
  try {
    const { products, totalPrice, shippingAddress } = req.body;
    const userId = req.user.id;

    if (!products || products.length === 0) {
      return res.status(400).json({ msg: '주문할 상품이 없습니다.' });
    }

    const order = new Order({
      products,
      totalPrice,
      shippingAddress,
      orderedBy: userId,
    });

    await order.save();
    
    // 주문 완료 후 사용자 장바구니 비우기
    await User.findByIdAndUpdate(userId, { cart: [] });

    res.status(201).json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ orderedBy: req.user.id }).populate(
      'products.product'
    ).sort({ orderedAt: -1 });
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find({})
      .populate('products.product')
      .populate('orderedBy', 'username email')
      .sort({ orderedAt: -1 });
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.updateOrderStatus = async (req, res) => {
    try {
        const { orderId } = req.params;
        const { status } = req.body;

        const order = await Order.findByIdAndUpdate(orderId, { status }, { new: true });
        
        if (!order) {
            return res.status(404).json({ msg: '주문을 찾을 수 없습니다.' });
        }

        res.status(200).json(order);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};