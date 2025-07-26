const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  products: [
    {
      product: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Product',
        required: true,
      },
      quantity: {
        type: Number,
        required: true,
      },
      price: {
        type: Number,
        required: true,
      }
    },
  ],
  totalPrice: {
    type: Number,
    required: true,
  },
  shippingAddress: {
    type: String,
    required: true,
  },
  orderedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  orderedAt: {
    type: Date,
    default: Date.now,
  },
  status: {
    type: String,
    default: 'Ordered', // 예: Ordered, Shipped, Delivered, Canceled
  },
});

const Order = mongoose.model('Order', orderSchema);
module.exports = Order;