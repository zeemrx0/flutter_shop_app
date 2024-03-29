import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void toggleFavoriteStatus(String? authToken, String userId) async {
    final url = Uri.parse(
        'https://flutter-shop-app-f93cf-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$authToken');

    isFavorite = !isFavorite;
    notifyListeners();

    try {
      await http.put(
        url,
        body: json.encode(isFavorite),
      );
    } catch (e) {
      isFavorite = !isFavorite;
      notifyListeners();

      rethrow;
    }
  }
}
