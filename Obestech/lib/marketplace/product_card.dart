import 'package:flutter/material.dart';
import 'product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.shopping_basket, color: Color.fromARGB(255, 0, 97, 150), size: 32),
        title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(product.description),
        trailing: Text(product.category, style: const TextStyle(color: Color.fromARGB(255, 0, 102, 150))),
      ),
    );
  }
}
