// ignore_for_file: prefer_final_fields

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_shop_app/providers/product.dart';
import 'package:flutter_shop_app/providers/products.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  String? authToken;
  String? userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse(
        'https://flutter-shop-app-f93cf-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken');

    final fetchedOrders = [];

    try {
      final response = await http.get(url);

      if (json.decode(response.body) != null) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        data.forEach(
          (orderId, orderData) {
            fetchedOrders.insert(
              0,
              OrderItem(
                id: orderId,
                amount: orderData['amount'],
                products: (orderData['products'] as List<dynamic>).map(
                  (item) {
                    return CartItem(
                      id: item['id'],
                      product: Product(
                        id: item['product']['id'],
                        title: item['product']['title'],
                        description: item['product']['description'],
                        price: item['product']['price'],
                        imageUrl: item['product']['imageUrl'],
                      ),
                      quantity: item['quantity'],
                    );
                  },
                ).toList(),
                dateTime: DateTime.parse(orderData['dateTime']),
              ),
            );
          },
        );
      }

      _orders = [...fetchedOrders];

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://flutter-shop-app-f93cf-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken');

    try {
      final currentDateTime = DateTime.now();

      final response = await http.post(
        url,
        body: json.encode(
          {
            'amount': total,
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'product': {
                        'id': cp.product.id,
                        'title': cp.product.title,
                        'description': cp.product.description,
                        'price': cp.product.price,
                        'imageUrl': cp.product.imageUrl,
                      },
                      'quantity': cp.quantity,
                    })
                .toList(),
            'dateTime': currentDateTime.toIso8601String()
          },
        ),
      );

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: currentDateTime,
          products: cartProducts,
        ),
      );
    } catch (e) {
      rethrow;
    }

    notifyListeners();
  }
}
