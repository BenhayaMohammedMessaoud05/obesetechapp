import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'product_card.dart';
import 'components/category_chip.dart';
import 'product_model.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String selectedCategory = 'Tous';

  // Simulated list of products (mocked for interface)
  final List<Product> products = [
    Product(title: 'Complément Protéiné', category: 'Nutrition', description: 'Aide à la récupération musculaire'),
    Product(title: 'Tapis de Yoga', category: 'Sport', description: 'Antidérapant, parfait pour la maison'),
    Product(title: 'Livre Recettes Saines', category: 'Cuisine', description: 'Idées repas équilibrés'),
  ];

  @override
  Widget build(BuildContext context) {
    List<Product> filtered = selectedCategory == 'Tous'
        ? products
        : products.where((p) => p.category == selectedCategory).toList();

    return Scaffold(
      body: Stack(
        children: [
          // Background without gradient (plain white background)
          Positioned.fill(
            child: Container(
              color: Colors.white, // Plain white background
            ),
          ),

          // The actual Scaffold content (AppBar, Categories, and Product List)
          Column(
            children: [
              // AppBar with Title
              AppBar(
                title: const Text("Marketplace"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddProductScreen()),
                      );
                    },
                  ),
                ],
              ),

              // Category filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    'Tous',
                    'Nutrition',
                    'Sport',
                    'Cuisine',
                    'Santé',
                  ].map((cat) {
                    return CategoryChip(
                      label: cat,
                      selected: selectedCategory == cat,
                      onTap: () => setState(() => selectedCategory = cat),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Product list
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: filtered[index]);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
