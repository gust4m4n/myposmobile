import 'package:flutter/material.dart';

void main() {
  runApp(const MyPOSMobileApp());
}

class MyPOSMobileApp extends StatelessWidget {
  const MyPOSMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPOSMobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const POSHomePage(),
    );
  }
}

class Product {
  final String name;
  final double price;
  final String category;

  Product({required this.name, required this.price, required this.category});
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

class POSHomePage extends StatefulWidget {
  const POSHomePage({super.key});

  @override
  State<POSHomePage> createState() => _POSHomePageState();
}

class _POSHomePageState extends State<POSHomePage> {
  final List<Product> _products = [
    Product(name: 'Nasi Goreng', price: 25000, category: 'Makanan'),
    Product(name: 'Mie Goreng', price: 20000, category: 'Makanan'),
    Product(name: 'Ayam Goreng', price: 30000, category: 'Makanan'),
    Product(name: 'Sate Ayam', price: 35000, category: 'Makanan'),
    Product(name: 'Es Teh', price: 5000, category: 'Minuman'),
    Product(name: 'Es Jeruk', price: 7000, category: 'Minuman'),
    Product(name: 'Kopi', price: 10000, category: 'Minuman'),
    Product(name: 'Jus Alpukat', price: 15000, category: 'Minuman'),
  ];

  final List<CartItem> _cart = [];
  String _selectedCategory = 'Semua';

  void _addToCart(Product product) {
    setState(() {
      final existingItem = _cart.firstWhere(
        (item) => item.product.name == product.name,
        orElse: () => CartItem(product: product, quantity: 0),
      );

      if (existingItem.quantity == 0) {
        _cart.add(CartItem(product: product));
      } else {
        existingItem.quantity++;
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  double get _totalPrice {
    return _cart.fold(0, (sum, item) => sum + item.total);
  }

  void _checkout() {
    if (_cart.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Checkout'),
          content: Text(
            'Total pembayaran: Rp ${_totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _cart.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi berhasil!')),
                );
              },
              child: const Text('Bayar'),
            ),
          ],
        );
      },
    );
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Semua') {
      return _products;
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _buildCartContent(scrollController: scrollController);
        },
      ),
    );
  }

  Widget _buildCartContent({ScrollController? scrollController}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart),
                const SizedBox(width: 8),
                const Text(
                  'Keranjang Belanja',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (scrollController != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _cart.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Keranjang Kosong',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(item.product.name),
                          subtitle: Text(
                            'Rp ${item.product.price.toStringAsFixed(0)} x ${item.quantity}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Rp ${item.total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                color: Colors.red,
                                onPressed: () {
                                  setState(() {
                                    _removeFromCart(index);
                                  });
                                  Navigator.pop(context);
                                  if (_cart.isNotEmpty) {
                                    _showCartBottomSheet(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${_totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _cart.isEmpty ? null : _checkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(fontSize: 18),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth >= 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPOSMobile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          if (!isTabletOrDesktop)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => _showCartBottomSheet(context),
                ),
                if (_cart.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '${_cart.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
      body: isTabletOrDesktop
          ? Row(
              children: [
                // Produk Section
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Category Filter
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 8,
                          children: ['Semua', 'Makanan', 'Minuman'].map((
                            category,
                          ) {
                            return ChoiceChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      // Product Grid
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate optimal maxCrossAxisExtent based on available width
                            double maxExtent = 180;
                            if (constraints.maxWidth < 500) {
                              maxExtent = 120;
                            } else if (constraints.maxWidth < 700) {
                              maxExtent = 150;
                            }

                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: maxExtent,
                                    childAspectRatio: 0.85,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                return Card(
                                  elevation: 3,
                                  child: InkWell(
                                    onTap: () => _addToCart(product),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            child: Icon(
                                              product.category == 'Makanan'
                                                  ? Icons.restaurant
                                                  : Icons.local_drink,
                                              size: 36,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Flexible(
                                            flex: 2,
                                            child: Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Flexible(
                                            flex: 1,
                                            child: Text(
                                              'Rp ${product.price.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart Section
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(left: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: const Row(
                          children: [
                            Icon(Icons.shopping_cart),
                            SizedBox(width: 8),
                            Text(
                              'Keranjang Belanja',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _cart.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Keranjang Kosong',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: _cart.length,
                                itemBuilder: (context, index) {
                                  final item = _cart[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      title: Text(item.product.name),
                                      subtitle: Text(
                                        'Rp ${item.product.price.toStringAsFixed(0)} x ${item.quantity}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Rp ${item.total.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle,
                                            ),
                                            color: Colors.red,
                                            onPressed: () =>
                                                _removeFromCart(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Rp ${_totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _cart.isEmpty ? null : _checkout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Checkout',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // Category Filter untuk mobile
                Container(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Makanan', 'Minuman'].map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Product Grid untuk mobile
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxExtent = 160;
                      if (constraints.maxWidth < 400) {
                        maxExtent = constraints.maxWidth / 2 - 24;
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: maxExtent,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Card(
                            elevation: 3,
                            child: InkWell(
                              onTap: () => _addToCart(product),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: Icon(
                                        product.category == 'Makanan'
                                            ? Icons.restaurant
                                            : Icons.local_drink,
                                        size: 32,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Flexible(
                                      flex: 2,
                                      child: Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        'Rp ${product.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: !isTabletOrDesktop && _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCartBottomSheet(context),
              backgroundColor: Colors.blue,
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_cart.length}',
                        style: const TextStyle(
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
              label: Text(
                'Rp ${_totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}
