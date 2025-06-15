import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class KategoriScreen extends StatefulWidget {
  @override
  _KategoriScreenState createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  String _userName = '';
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _filteredCategories = [];
  TextEditingController _searchController = TextEditingController();
  List<bool> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadDefaultCategories();
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('userName') ?? '';
    
    if (userName.isEmpty) {
      String userEmail = prefs.getString('userEmail') ?? '';
      if (userEmail.isNotEmpty) {
        userName = userEmail.split('@')[0];
        userName = userName[0].toUpperCase() + userName.substring(1);
      }
    }
    
    setState(() {
      _userName = userName.isEmpty ? 'Pengguna' : userName;
    });
  }

  void _loadDefaultCategories() {
    // Load default categories + any saved custom categories
    _categories = [
      {'name': 'Kuliah', 'isDefault': true},
      {'name': 'Makanan', 'isDefault': true},
      {'name': 'Kos', 'isDefault': true},
      {'name': 'Pakaian', 'isDefault': true},
      {'name': 'Pekerjaan', 'isDefault': true},
    ];
    
    _filteredCategories = List.from(_categories);
    _selectedCategories = List.generate(_categories.length, (index) => false);
    _loadCustomCategories();
  }

  Future<void> _loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    String? categoriesJson = prefs.getString('custom_categories');
    
    if (categoriesJson != null) {
      List<dynamic> customCategories = json.decode(categoriesJson);
      for (var category in customCategories) {
        _categories.add({
          'name': category['name'],
          'isDefault': false,
        });
      }
      
      setState(() {
        _filteredCategories = List.from(_categories);
        _selectedCategories = List.generate(_categories.length, (index) => false);
      });
    }
  }

  Future<void> _saveCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> customCategories = _categories
        .where((category) => !category['isDefault'])
        .toList();
    
    String categoriesJson = json.encode(customCategories);
    await prefs.setString('custom_categories', categoriesJson);
  }

  void _filterCategories() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _categories.where((category) {
        return category['name'].toLowerCase().contains(query);
      }).toList();
      _selectedCategories = List.generate(_filteredCategories.length, (index) => false);
    });
  }

  void _showAddCategoryDialog() {
    TextEditingController categoryController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Kategori Baru'),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(
              hintText: 'Nama kategori',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                String categoryName = categoryController.text.trim();
                if (categoryName.isNotEmpty) {
                  _addCategory(categoryName);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E8B57),
              ),
              child: Text('Tambah', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _addCategory(String categoryName) {
    // Check if category already exists
    bool exists = _categories.any((category) => 
        category['name'].toLowerCase() == categoryName.toLowerCase());
    
    if (!exists) {
      setState(() {
        _categories.add({
          'name': categoryName,
          'isDefault': false,
        });
        _filterCategories(); // Refresh filtered list
      });
      _saveCustomCategories();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kategori "$categoryName" berhasil ditambahkan'),
          backgroundColor: Color(0xFF2E8B57),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kategori "$categoryName" sudah ada'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _deleteSelectedCategories() {
    List<Map<String, dynamic>> categoriesToDelete = [];
    
    for (int i = 0; i < _selectedCategories.length; i++) {
      if (_selectedCategories[i]) {
        int originalIndex = _categories.indexOf(_filteredCategories[i]);
        if (originalIndex != -1 && !_categories[originalIndex]['isDefault']) {
          categoriesToDelete.add(_categories[originalIndex]);
        }
      }
    }
    
    if (categoriesToDelete.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hapus Kategori'),
            content: Text('Apakah Anda yakin ingin menghapus ${categoriesToDelete.length} kategori yang dipilih?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    for (var category in categoriesToDelete) {
                      _categories.remove(category);
                    }
                    _filterCategories();
                  });
                  _saveCustomCategories();
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${categoriesToDelete.length} kategori berhasil dihapus'),
                      backgroundColor: Color(0xFF2E8B57),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Hapus', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih kategori yang ingin dihapus (hanya kategori custom yang bisa dihapus)'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _deleteCategory(int index) {
    Map<String, dynamic> category = _filteredCategories[index];
    
    if (category['isDefault']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kategori default tidak dapat dihapus'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Kategori'),
          content: Text('Apakah Anda yakin ingin menghapus kategori "${category['name']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _categories.remove(category);
                  _filterCategories();
                });
                _saveCustomCategories();
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kategori "${category['name']}" berhasil dihapus'),
                    backgroundColor: Color(0xFF2E8B57),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FFF8),
      body: Column(
        children: [
          // Header dengan gradient - sama seperti AccountScreen
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2E8B57),
                  Color(0xFF3CB371),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Row(
                      children: [
                        Icon(
                         Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 24,
                          ),
                        SizedBox(width: 8),
                        Text(
                           'BoncosApp',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Deteksi Bocor Halus Pada Keuangan Anda',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // Categories Section
          Expanded(
            child: Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header with Add button
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showAddCategoryDialog,
                          icon: Icon(Icons.add, size: 16),
                          label: Text('Add new'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2E8B57),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search Field
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Filter payee...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF2E8B57)),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  
                  // Categories List
                  Expanded(
                    child: Column(
                      children: [
                        // Header Row
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 40), // Space for checkbox
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      'Nama',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_upward, size: 12, color: Colors.grey.shade500),
                                  ],
                                ),
                              ),
                              SizedBox(width: 40), // Space for menu button
                            ],
                          ),
                        ),
                        
                        // Categories List Items
                        Expanded(
                          child: ListView.builder(
                            itemCount: _filteredCategories.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade100,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _selectedCategories.length > index ? _selectedCategories[index] : false,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (_selectedCategories.length > index) {
                                            _selectedCategories[index] = value ?? false;
                                          }
                                        });
                                      },
                                      activeColor: Color(0xFF2E8B57),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _filteredCategories[index]['name'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (String value) {
                                        if (value == 'delete' && !_filteredCategories[index]['isDefault']) {
                                          _deleteCategory(index);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
                                        if (!_filteredCategories[index]['isDefault'])
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, color: Colors.red, size: 16),
                                                SizedBox(width: 8),
                                                Text('Hapus', style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                      ],
                                      child: Icon(
                                        Icons.more_horiz,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Footer
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedCategories.where((selected) => selected).length} dari ${_filteredCategories.length} baris terseleksi.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Row(
                                children: [
                                  if (_selectedCategories.any((selected) => selected))
                                    TextButton.icon(
                                      onPressed: _deleteSelectedCategories,
                                      icon: Icon(Icons.delete, color: Colors.red, size: 16),
                                      label: Text('Hapus Terpilih', style: TextStyle(color: Colors.red)),
                                    ),
                                  TextButton(
                                    onPressed: () {
                                      // Previous page action
                                    },
                                    child: Text(
                                      'Previous',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () {
                                      // Next page action
                                    },
                                    child: Text(
                                      'Next',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}