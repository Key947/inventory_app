class Item {
  int? id;
  String name;
  int price;        // Buat harga jual
  int stock;
  String? imagePath; // INI DIA: Menyimpan lokasi foto di memori HP

  Item({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imagePath,
  });

  // Convert dari Database (Map) ke Object Item
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      stock: map['stock'],
      imagePath: map['imagePath'],
    );
  }

  // Convert dari Object Item ke Database (Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'imagePath': imagePath,
    };
  }
}