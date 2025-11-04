import 'package:flutter/material.dart';

void main() {
  runApp(const ECommerceApp());
}

class ECommerceApp extends StatelessWidget {
  const ECommerceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String image;
  final String description;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.description,
    required this.rating,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class AppState extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Wireless Headphones',
      category: 'Electronics',
      price: 299.99,
      image: '🎧',
      description: 'Premium wireless headphones with noise cancellation',
      rating: 4.5,
    ),
    Product(
      id: '2',
      name: 'Smart Watch',
      category: 'Electronics',
      price: 399.99,
      image: '⌚',
      description: 'Feature-rich smartwatch with health tracking',
      rating: 4.7,
    ),
    Product(
      id: '3',
      name: 'Running Shoes',
      category: 'Fashion',
      price: 149.99,
      image: '👟',
      description: 'Comfortable running shoes for daily workouts',
      rating: 4.3,
    ),
    Product(
      id: '4',
      name: 'Laptop Backpack',
      category: 'Accessories',
      price: 79.99,
      image: '🎒',
      description: 'Spacious backpack with laptop compartment',
      rating: 4.6,
    ),
    Product(
      id: '5',
      name: 'Coffee Maker',
      category: 'Home',
      price: 129.99,
      image: '☕',
      description: 'Automatic coffee maker with timer function',
      rating: 4.4,
    ),
    Product(
      id: '6',
      name: 'Sunglasses',
      category: 'Fashion',
      price: 89.99,
      image: '🕶️',
      description: 'Stylish sunglasses with UV protection',
      rating: 4.2,
    ),
    Product(
      id: '7',
      name: 'Bluetooth Speaker',
      category: 'Electronics',
      price: 79.99,
      image: '🔊',
      description: 'Portable speaker with excellent sound quality',
      rating: 4.5,
    ),
    Product(
      id: '8',
      name: 'Yoga Mat',
      category: 'Sports',
      price: 39.99,
      image: '🧘',
      description: 'Non-slip yoga mat for your practice',
      rating: 4.8,
    ),
  ];

  final List<String> _favorites = [];
  final List<CartItem> _cart = [];
  String _selectedCategory = 'All';

  List<Product> get products => _selectedCategory == 'All'
      ? _products
      : _products.where((p) => p.category == _selectedCategory).toList();

  List<String> get categories => ['All', ...{..._products.map((p) => p.category)}];

  List<String> get favorites => _favorites;
  List<CartItem> get cart => _cart;
  String get selectedCategory => _selectedCategory;

  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  double get cartTotal => _cart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites.add(productId);
    }
    notifyListeners();
  }

  bool isFavorite(String productId) => _favorites.contains(productId);

  void addToCart(Product product) {
    final existingItem = _cart.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity > 0) {
      existingItem.quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final item = _cart.firstWhere((item) => item.product.id == productId);
    item.quantity = quantity;
    notifyListeners();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final AppState _appState = AppState();

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      HomeScreen(appState: _appState),
      FavoritesScreen(appState: _appState),
      CartScreen(appState: _appState),
      ProfileScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
              BottomNavigationBarItem(
                icon: Badge(
                  label: Text('${_appState.cartItemCount}'),
                  isLabelVisible: _appState.cartItemCount > 0,
                  child: const Icon(Icons.shopping_cart),
                ),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final AppState appState;

  const HomeScreen({Key? key, required this.appState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ProductSearchDelegate(appState));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: appState.categories.length,
              itemBuilder: (context, index) {
                final category = appState.categories[index];
                final isSelected = category == appState.selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => appState.setCategory(category),
                    backgroundColor: Colors.white,
                    selectedColor: Colors.deepPurple.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.deepPurple : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: appState,
              builder: (context, _) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: appState.products.length,
                  itemBuilder: (context, index) {
                    final product = appState.products[index];
                    return ProductCard(product: product, appState: appState);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final AppState appState;

  const ProductCard({Key? key, required this.product, required this.appState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product, appState: appState),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Text(product.image, style: const TextStyle(fontSize: 64)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: ListenableBuilder(
                    listenable: appState,
                    builder: (context, _) {
                      final isFav = appState.isFavorite(product.id);
                      return CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                          onPressed: () => appState.toggleFavorite(product.id),
                          padding: EdgeInsets.zero,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final AppState appState;

  const ProductDetailScreen({Key? key, required this.product, required this.appState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          ListenableBuilder(
            listenable: appState,
            builder: (context, _) {
              final isFav = appState.isFavorite(product.id);
              return IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                color: isFav ? Colors.red : null,
                onPressed: () => appState.toggleFavorite(product.id),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 300,
                    color: Colors.grey[100],
                    child: Center(
                      child: Text(product.image, style: const TextStyle(fontSize: 120)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                product.category,
                                style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating} (120 reviews)',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Description',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    appState.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Added to cart'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(label: 'VIEW', onPressed: () {}),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add to Cart', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final AppState appState;

  const FavoritesScreen({Key? key, required this.appState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final favoriteProducts = appState.products
              .where((p) => appState.favorites.contains(p.id))
              .toList();

          if (favoriteProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No favorites yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(product: favoriteProducts[index], appState: appState);
            },
          );
        },
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  final AppState appState;

  const CartScreen({Key? key, required this.appState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          if (appState.cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appState.cart.length,
                  itemBuilder: (context, index) {
                    final item = appState.cart[index];
                    return CartItemWidget(item: item, appState: appState);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${appState.cartTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Order Placed!'),
                                content: const Text('Your order has been placed successfully.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Checkout', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final AppState appState;

  const CartItemWidget({Key? key, required this.item, required this.appState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(item.product.image, style: const TextStyle(fontSize: 40))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('\$${item.product.price.toStringAsFixed(2)}', 
                  style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => appState.updateQuantity(item.product.id, item.quantity - 1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => appState.updateQuantity(item.product.id, item.quantity + 1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => appState.removeFromCart(item.product.id),
                child: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 50, color: Colors.deepPurple),
                ),
                const SizedBox(height: 16),
                const Text('John Doe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('johndoe@example.com', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('My Orders'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Shipping Address'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payment Methods'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<Product?> {
  final AppState appState;

  ProductSearchDelegate(this.appState);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = appState.products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: Text(product.image, style: const TextStyle(fontSize: 32)),
          title: Text(product.name),
          subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
          onTap: () {
            close(context, product);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product, appState: appState),
              ),
            );
          },
        );
      },
    );
  }
}