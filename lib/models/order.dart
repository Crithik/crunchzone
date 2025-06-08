class OrderItem {
  final String name;
  final String price;
  final int quantity;
  final double totalPrice;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });
}

class Order {
  final String orderId;
  final DateTime orderDate;
  final List<OrderItem> items;
  final double totalAmount;

  Order({
    required this.orderId,
    required this.orderDate,
    required this.items,
    required this.totalAmount,
  });

  String get formattedOrderId => 'CZ${orderId.substring(0, 8).toUpperCase()}';
  
  String get formattedDate {
    return '${orderDate.day}/${orderDate.month}/${orderDate.year} at ${orderDate.hour}:${orderDate.minute.toString().padLeft(2, '0')}';
  }
}