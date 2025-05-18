import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class MarketplaceScreen extends StatefulWidget {
  final String token;
  const MarketplaceScreen({super.key, required this.token});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> cart = [];
  String selectedCategory = 'Tous';
  bool isLoading = true;
  String? errorMessage;

  final List<String> categories = ['Tous', 'Nutrition', 'Équipement', 'Suppléments'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('MarketplaceScreen: Cleared token, redirecting to /login');
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token') ?? '';
    print('MarketplaceScreen: Retrieved stored token: ${storedToken.isNotEmpty ? "[present]" : "[empty]"}');
    return storedToken.isNotEmpty ? storedToken : widget.token;
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final token = await _getToken();
      if (token.isEmpty) {
        setState(() {
          errorMessage = 'Aucun token d\'authentification trouvé. Veuillez vous reconnecter.';
          isLoading = false;
        });
        await _logout();
        return;
      }

      final productList = await ApiService.getProducts(token);
      print('MarketplaceScreen: Fetched ${productList.length} products');
      setState(() {
        products = productList;
        _filterProducts();
        isLoading = false;
      });
    } catch (e) {
      print('MarketplaceScreen: Fetch error: $e');
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
      if (errorMessage!.contains('Invalid token') || errorMessage!.contains('Aucun token')) {
        await _logout();
      }
    }
  }

  void _filterProducts() {
    setState(() {
      if (selectedCategory == 'Tous') {
        filteredProducts = products;
      } else {
        filteredProducts = products
            .where((product) => (product['category'] ?? '').toString().toLowerCase() == selectedCategory.toLowerCase())
            .toList();
      }
      print('MarketplaceScreen: Filtered products: ${filteredProducts.length} for category: $selectedCategory');
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      cart.add({...product, 'quantity': 1});
      print('MarketplaceScreen: Added ${product['name']} to cart. Cart size: ${cart.length}');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product['name']} ajouté au panier !',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    String? selectedCategory = categories[1]; // Default to Nutrition

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Ajouter un Produit',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A3C5A),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom du produit',
                    labelStyle: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Prix (€)',
                    labelStyle: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL de l\'image',
                    labelStyle: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Catégorie',
                    labelStyle: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: categories.skip(1).map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategory = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    imageUrlController.text.isEmpty ||
                    selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Veuillez remplir tous les champs',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  );
                  return;
                }
                try {
                  final token = await _getToken();
                  final product = {
                    'name': nameController.text,
                    'price': double.parse(priceController.text),
                    'category': selectedCategory,
                    'imageUrl': imageUrlController.text,
                  };
                  await ApiService.addProduct(token, product);
                  Navigator.pop(context);
                  _loadProducts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Produit ajouté avec succès !',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erreur: $e',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3C5A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Ajouter',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: const Color(0xFF1A3C5A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A3C5A)))
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          style: GoogleFonts.poppins(color: const Color(0xFFB91C1C), fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3C5A),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            'Se reconnecter',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Marketplace',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 36,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1A3C5A),
                            ),
                          ),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.shoppingCart, color: Color(0xFF1A3C5A)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CartScreen(
                                        cart: cart,
                                        onUpdateCart: (updatedCart) {
                                          setState(() {
                                            cart = updatedCart;
                                          });
                                        },
                                        token: widget.token,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (cart.isNotEmpty)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${cart.length}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Découvrez nos produits santé !',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A3C5A).withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Catégories',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: const Color(0xFF1A3C5A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButton<String>(
                              value: selectedCategory,
                              isExpanded: true,
                              items: categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF6B7280),
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedCategory = value;
                                    _filterProducts();
                                  });
                                }
                              },
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF1A3C5A),
                                fontSize: 14,
                              ),
                              dropdownColor: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Produits',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xFF1A3C5A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      filteredProducts.isEmpty
                          ? Text(
                              'Aucun produit disponible pour la catégorie "$selectedCategory".',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF6B7280),
                              ),
                              textAlign: TextAlign.center,
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.65,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1A3C5A).withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                          child: product['imageUrl'] != null
                                              ? Image.network(
                                                  product['imageUrl'],
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                                    LucideIcons.imageOff,
                                                    size: 50,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                )
                                              : const Icon(
                                                  LucideIcons.imageOff,
                                                  size: 50,
                                                  color: Color(0xFF6B7280),
                                                ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          product['name'] ?? 'Produit sans nom',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: const Color(0xFF1A3C5A),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          '${product['price'] ?? 0} €',
                                          style: GoogleFonts.poppins(
                                            color: Colors.teal,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          product['category'] ?? 'Sans catégorie',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                        child: ElevatedButton(
                                          onPressed: () => _addToCart(product),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF1A3C5A),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                          child: Text(
                                            'Ajouter au panier',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Function(List<Map<String, dynamic>>) onUpdateCart;
  final String token;

  const CartScreen({super.key, required this.cart, required this.onUpdateCart, required this.token});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> cart;

  @override
  void initState() {
    super.initState();
    cart = List.from(widget.cart);
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      setState(() {
        cart.removeAt(index);
      });
    } else {
      setState(() {
        cart[index]['quantity'] = newQuantity;
      });
    }
    widget.onUpdateCart(cart);
  }

  void _checkout() {
    setState(() {
      cart.clear();
    });
    widget.onUpdateCart(cart);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Achat effectué avec succès !',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  double _calculateTotal() {
    return cart.fold(0, (sum, item) => sum + (item['price'] ?? 0) * (item['quantity'] ?? 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A3C5A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Panier',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 24,
            color: const Color(0xFF1A3C5A),
          ),
        ),
      ),
      body: cart.isEmpty
          ? Center(
              child: Text(
                'Votre panier est vide',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF6B7280),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item['imageUrl'] != null
                                    ? Image.network(
                                        item['imageUrl'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          LucideIcons.imageOff,
                                          size: 40,
                                          color: Color(0xFF6B7280),
                                        ),
                                      )
                                    : const Icon(
                                        LucideIcons.imageOff,
                                        size: 40,
                                        color: Color(0xFF6B7280),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? 'Produit sans nom',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: const Color(0xFF1A3C5A),
                                      ),
                                    ),
                                    Text(
                                      '${item['price'] ?? 0} €',
                                      style: GoogleFonts.poppins(
                                        color: Colors.teal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Color(0xFF1A3C5A)),
                                    onPressed: () => _updateQuantity(index, (item['quantity'] ?? 1) - 1),
                                  ),
                                  Text(
                                    '${item['quantity'] ?? 1}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: const Color(0xFF1A3C5A),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Color(0xFF1A3C5A)),
                                    onPressed: () => _updateQuantity(index, (item['quantity'] ?? 1) + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A3C5A).withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF1A3C5A),
                            ),
                          ),
                          Text(
                            '${_calculateTotal().toStringAsFixed(2)} €',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: cart.isEmpty ? null : _checkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3C5A),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Passer la commande',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}