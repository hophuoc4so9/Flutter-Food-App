import mongoose from 'mongoose';

interface IPayment extends Document {
  userId: mongoose.Types.ObjectId;
  orderId: string;
  amount: number;
  currency: string;
  paymentMethod?: string;
  transactionNo?: string;
  vnpayCode?: string;
  bankCode?: string;
  cardType?: string;
  status: 'PENDING' | 'SUCCESS' | 'FAILED' | 'REFUNDED';
  paymentUrl?: string;
  description?: string;
  createdAt: Date;
  updatedAt?: Date;
  completedAt?: Date;
}

const PaymentSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    orderId: {
      type: String,
      required: true,
      unique: true,
    },
    amount: {
      type: Number,
      required: true,
      min: 0,
    },
    currency: {
      type: String,
      default: 'VND',
    },
    paymentMethod: {
      type: String,
      enum: ['VNPAY', 'CREDIT_CARD', 'DEBIT_CARD'],
      default: 'VNPAY',
    },
    transactionNo: {
      type: String,
      default: null,
    },
    vnpayCode: {
      type: String,
      default: null,
    },
    bankCode: {
      type: String,
      default: null,
    },
    cardType: {
      type: String,
      default: null,
    },
    status: {
      type: String,
      enum: ['PENDING', 'SUCCESS', 'FAILED', 'REFUNDED'],
      default: 'PENDING',
    },
    paymentUrl: {
      type: String,
      default: null,
    },
    description: {
      type: String,
      required: true,
    },
    completedAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

export const Payment = mongoose.model<IPayment>('Payment', PaymentSchema);
