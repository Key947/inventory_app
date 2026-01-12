import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';
import 'item.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    ),
    home: const LoginScreen(),
  ));
}

String formatRupiah(int number) {
  return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
}

// --- 1. HALAMAN LOGIN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800)); 
    
    if (!mounted) return;
    var user = await _dbHelper.loginUser(_usernameController.text, _passwordController.text);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      if (user['role'] == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminMainScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CashierDashboard()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username atau Password salah!"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF3F5EFB), Color(0xFFFC466B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.store_mall_directory_rounded, size: 60, color: Colors.indigo),
                    const SizedBox(height: 20),
                    const Text("Kasir Pintar", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    TextField(controller: _usernameController, decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.person))),
                    const SizedBox(height: 16),
                    TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock))),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo), onPressed: _isLoading ? null : _login, child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)))),
                    const SizedBox(height: 10),
                    TextButton(onPressed: () {
                       _dbHelper.registerUser(_usernameController.text, _passwordController.text).then((val) {
                         if (!mounted) return;
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(val != -1 ? "Berhasil daftar!" : "Username sudah ada!"), backgroundColor: val != -1 ? Colors.green : Colors.red));
                       });
                    }, child: const Text("Daftar Akun Baru"))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. ADMIN MAIN SCREEN ---
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});
  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const AdminInventoryTab(), const HistoryTab(), const ProfileTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: "Barang"),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Riwayat"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
          ],
        ),
      ),
    );
  }
}

// --- TAB 1: INVENTORY ---
class AdminInventoryTab extends StatefulWidget {
  const AdminInventoryTab({super.key});
  @override
  State<AdminInventoryTab> createState() => _AdminInventoryTabState();
}

class _AdminInventoryTabState extends State<AdminInventoryTab> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Item> _itemList = [];
  List<Item> _filteredList = [];
  final _searchController = TextEditingController();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _refreshItemList();
  }

  void _refreshItemList() async {
    final data = await _dbHelper.getItemList();
    if (mounted) {
      setState(() { 
        _itemList = data;
        _filterItems(_searchController.text);
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredList = _itemList;
      } else {
        _filteredList = _itemList.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  void _showForm(Item? item) async {
    if (item != null) {
      _nameController.text = item.name;
      _priceController.text = item.price.toString();
      _stockController.text = item.stock.toString();
      _selectedImagePath = item.imagePath;
    } else {
      _nameController.clear(); _priceController.clear(); _stockController.clear(); _selectedImagePath = null;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item == null ? 'Tambah Produk' : 'Edit Produk', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (image != null) setModalState(() { _selectedImagePath = image.path; });
                  },
                  child: Container(
                    height: 100, width: 100,
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
                    child: _selectedImagePath != null ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(_selectedImagePath!), fit: BoxFit.cover)) : const Icon(Icons.add_a_photo, color: Colors.indigo),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Barang')),
                const SizedBox(height: 10),
                Row(children: [Expanded(child: TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga'))), const SizedBox(width: 10), Expanded(child: TextField(controller: _stockController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok')))]),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo), onPressed: () async {
                  if (_nameController.text.isEmpty) return;
                  final newItem = Item(id: item?.id, name: _nameController.text, price: int.tryParse(_priceController.text) ?? 0, stock: int.tryParse(_stockController.text) ?? 0, imagePath: _selectedImagePath);
                  if (item == null) await _dbHelper.insertItem(newItem); else await _dbHelper.updateItem(newItem);
                  if(!mounted) return; Navigator.pop(context); _refreshItemList();
                }, child: const Text("SIMPAN")))
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Barang", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterItems,
              decoration: const InputDecoration(
                hintText: "Cari nama barang...",
                prefixIcon: Icon(Icons.search, color: Colors.indigo),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _filteredList.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off, size: 60, color: Colors.grey[300]), const Text("Barang tidak ditemukan")]))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      final item = _filteredList[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                height: 60, width: 60,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[200]),
                                child: item.imagePath != null ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(item.imagePath!), fit: BoxFit.cover)) : const Icon(Icons.image, color: Colors.grey),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(formatRupiah(item.price), style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: item.stock < 5 ? Colors.red.shade100 : Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                                      child: Text("Stok: ${item.stock}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: item.stock < 5 ? Colors.red.shade900 : Colors.green.shade900)),
                                    )
                                  ],
                                ),
                              ),
                              IconButton(icon: Icon(Icons.edit, color: Colors.orange.shade800), onPressed: () => _showForm(item)),
                              IconButton(icon: Icon(Icons.delete, color: Colors.red.shade800), onPressed: () async { await _dbHelper.deleteItem(item.id!); _refreshItemList(); }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo, 
        foregroundColor: Colors.white,
        onPressed: () => _showForm(null), 
        child: const Icon(Icons.add)
      ),
    );
  }
}

// --- TAB 2: HISTORY ---
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Laporan Penjualan", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getOrderHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Belum ada transaksi"));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ExpansionTile(
                  leading: CircleAvatar(backgroundColor: Colors.indigo.shade50, child: const Icon(Icons.check, color: Colors.indigo)),
                  title: Text(formatRupiah(order['totalAmount']), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  subtitle: Text(order['transactionDate'].toString().split('.')[0]),
                  children: [Padding(padding: const EdgeInsets.all(16.0), child: Text(order['itemSummary']))],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- TAB 3: PROFILE ---
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Colors.indigo, child: Icon(Icons.person, size: 50, color: Colors.white)),
            const SizedBox(height: 20),
            const Text("Administrator", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("admin@tokokita.com", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)), 
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())), 
              icon: const Icon(Icons.logout), 
              label: const Text("Keluar Aplikasi")
            )
          ],
        ),
      ),
    );
  }
}

// --- 3. CASHIER DASHBOARD (UPDATE FITUR URUNGKAN) ---
class CashierDashboard extends StatefulWidget {
  const CashierDashboard({super.key});
  @override
  State<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends State<CashierDashboard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Item> _itemList = [];
  List<Item> _filteredList = [];
  final _searchController = TextEditingController();
  final Map<int, int> _cart = {};

  @override
  void initState() {
    super.initState();
    _refreshItemList();
  }

  void _refreshItemList() async {
    final data = await _dbHelper.getItemList();
    if (mounted) {
      setState(() { 
        _itemList = data;
        _filterItems(_searchController.text);
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredList = _itemList;
      } else {
        _filteredList = _itemList.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  void _addToCart(int id) {
    setState(() { _cart[id] = (_cart[id] ?? 0) + 1; });
  }

  // --- BARU: Logic Kurangi Item (Urungkan Per Item) ---
  void _removeFromCart(int id) {
    setState(() {
      if (_cart.containsKey(id)) {
        if (_cart[id]! > 1) {
          _cart[id] = _cart[id]! - 1;
        } else {
          _cart.remove(id); // Hapus kalau sisa 0
        }
      }
    });
  }

  // --- BARU: Logic Reset Cart (Urungkan Semua) ---
  void _resetCart() {
    setState(() {
      _cart.clear();
    });
  }

  void _checkout() {
    if (_cart.isEmpty) return;
    int total = 0;
    String summary = "";
    _cart.forEach((key, qty) {
      final item = _itemList.firstWhere((e) => e.id == key);
      total += item.price * qty;
      summary += "${item.name} x$qty, ";
      item.stock -= qty;
      _dbHelper.updateItem(item);
    });
    _dbHelper.createOrder(total, summary);
    showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text("Sukses!"), 
        content: Text("Total: ${formatRupiah(total)}"), 
        actions: [TextButton(onPressed: () { setState(() { _cart.clear(); _refreshItemList(); }); Navigator.pop(context); }, child: const Text("OK"))]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kasir", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())))
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
            decoration: const BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Halo Kasir, Semangat!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(
                  controller: _searchController,
                  onChanged: _filterItems,
                  decoration: InputDecoration(
                    hintText: "Cari produk...",
                    prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredList.isEmpty 
            ? const Center(child: Text("Produk tidak ditemukan"))
            : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, mainAxisSpacing: 16, crossAxisSpacing: 16),
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                final item = _filteredList[index];
                int qty = _cart[item.id] ?? 0;
                return InkWell(
                  onTap: item.stock > 0 ? () => _addToCart(item.id!) : null,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), image: item.imagePath != null ? DecorationImage(image: FileImage(File(item.imagePath!)), fit: BoxFit.cover) : null, color: Colors.grey[200]),
                                child: item.imagePath == null ? const Icon(Icons.fastfood, size: 40, color: Colors.grey) : null,
                              ),
                              // --- BADGE JUMLAH (KANAN ATAS) ---
                              if (qty > 0) 
                                Positioned(top: 8, right: 8, child: CircleAvatar(backgroundColor: Colors.indigo, radius: 14, child: Text("$qty", style: const TextStyle(color: Colors.white, fontSize: 12)))),
                              
                              // --- TOMBOL MINUS (KIRI ATAS) - URUNGKAN PILIHAN ---
                              if (qty > 0)
                                Positioned(
                                  top: 8, left: 8,
                                  child: InkWell(
                                    onTap: () => _removeFromCart(item.id!),
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 14, 
                                      child: Icon(Icons.remove, size: 16, color: Colors.white)
                                    ),
                                  ),
                                ),

                              if (item.stock <= 0) Container(color: Colors.white.withValues(alpha: 0.7), child: const Center(child: Text("HABIS", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(item.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(formatRupiah(item.price), textAlign: TextAlign.center, style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                              Text("Sisa: ${item.stock}", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total", style: TextStyle(color: Colors.grey)),
                      Text("${_cart.length} Item", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  // --- TOMBOL RESET (SAMPAH) ---
                  IconButton(
                    onPressed: _resetCart, 
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 30),
                    tooltip: "Batalkan Semua",
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo), 
                    onPressed: _checkout, 
                    child: const Text("BAYAR")
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}