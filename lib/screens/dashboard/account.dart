import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Account {
  final String id;
  final String name;
  final String type;
  final double balance;
  final Color color;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.color,
  });

  // Convert Account to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'color': color.value,
    };
  }

  // Create Account from JSON
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      balance: json['balance'].toDouble(),
      color: Color(json['color']),
    );
  }
}

class AccountScreen extends StatefulWidget {

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _userName = '';
  List<Account> accounts = [];
  Set<String> selectedAccounts = {};
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadAccounts();
  }
  
 Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil nama lengkap yang disimpan saat login/registrasi
    String userName = prefs.getString('userName') ?? '';
    
    // Jika nama tidak tersedia, fallback ke email
    if (userName.isEmpty) {
      String userEmail = prefs.getString('userEmail') ?? '';
      if (userEmail.isNotEmpty) {
        // Ekstrak nama dari email (bagian sebelum @)
        userName = userEmail.split('@')[0];
        // Kapitalisasi huruf pertama
        userName = userName[0].toUpperCase() + userName.substring(1);
      }
    }
    
    setState(() {
      _userName = userName.isEmpty ? 'Pengguna' : userName;
    });
  }

  // Load accounts from SharedPreferences
  Future<void> _loadAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accountsJson = prefs.getString('accounts');
      
      if (accountsJson != null) {
        final List<dynamic> accountsList = json.decode(accountsJson);
        setState(() {
          accounts = accountsList.map((json) => Account.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        // Set default accounts if no saved data
        _setDefaultAccounts();
      }
    } catch (e) {
      print('Error loading accounts: $e');
      _setDefaultAccounts();
    }
  }

  // Save accounts to SharedPreferences
  Future<void> _saveAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String accountsJson = json.encode(
        accounts.map((account) => account.toJson()).toList()
      );
      await prefs.setString('accounts', accountsJson);
    } catch (e) {
      print('Error saving accounts: $e');
    }
  }

  // Set default accounts
  void _setDefaultAccounts() {
    setState(() {
      accounts = [
        Account(
          id: '1',
          name: 'Dana',
          type: 'E-Wallet',
          balance: 0.0,
          color: Color(0xFF00A8FF),
        ),
        Account(
          id: '2',
          name: 'Gopay',
          type: 'E-Wallet',
          balance: 0.0,
          color: Color(0xFF00AA13),
        ),
        Account(
          id: '3',
          name: 'Tunai',
          type: 'Cash',
          balance: 0.0,
          color: Color(0xFF8B4513),
        ),
        Account(
          id: '4',
          name: 'BSI',
          type: 'Bank',
          balance: 0.0,
          color: Color(0xFF2E8B57),
        ),
        Account(
          id: '5',
          name: 'Shopeepay',
          type: 'E-Wallet',
          balance: 0.0,
          color: Color(0xFFFF6B35),
        ),
      ];
      isLoading = false;
    });
    _saveAccounts(); // Save default accounts
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF8FFF8),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E8B57)),
          ),
        ),
      );
    }

    List<Account> filteredAccounts = accounts.where((account) {
      return account.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xFFF8FFF8),
      body: Column(
        children: [
          // Header dengan gradient
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
                    // Welcome section
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
          
          // Content area
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
                  // Header dengan tombol Add new
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
                          'Accounts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddAccountDialog(),
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
                  
                  // Search bar
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
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
                  
                  // Table header
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
                        Checkbox(
                          value: selectedAccounts.length == filteredAccounts.length && filteredAccounts.isNotEmpty,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedAccounts = filteredAccounts.map((a) => a.id).toSet();
                              } else {
                                selectedAccounts.clear();
                              }
                            });
                          },
                          activeColor: Color(0xFF2E8B57),
                        ),
                        SizedBox(width: 12),
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
                              Icon(
                                Icons.arrow_upward,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                  ),
                  
                  // Account list
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredAccounts.length,
                      itemBuilder: (context, index) {
                        final account = filteredAccounts[index];
                        final isSelected = selectedAccounts.contains(account.id);
                        
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade100,
                                width: 1,
                              ),
                            ),
                            color: isSelected ? Color(0xFF2E8B57).withOpacity(0.05) : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedAccounts.add(account.id);
                                    } else {
                                      selectedAccounts.remove(account.id);
                                    }
                                  });
                                },
                                activeColor: Color(0xFF2E8B57),
                              ),
                              SizedBox(width: 12),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: account.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      account.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      account.type,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton(
                                icon: Icon(
                                  Icons.more_horiz,
                                  color: Colors.grey.shade400,
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 16, color: Colors.grey.shade600),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 16, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditAccountDialog(account);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmation(account);
                                  }
                                },
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
                          '${selectedAccounts.length} dari ${filteredAccounts.length} baris terseleksi.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {},
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
                              onPressed: () {},
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
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    String selectedType = 'Bank';
    Color selectedColor = Color(0xFF2E8B57);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Tambah Akun Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Akun',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Tipe Akun',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Bank', 'E-Wallet', 'Cash'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedType = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Pilih Warna:'),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Color(0xFF2E8B57),
                      Color(0xFF00A8FF),
                      Color(0xFF00AA13),
                      Color(0xFF8B4513),
                      Color(0xFFFF6B35),
                      Color(0xFF9B59B6),
                      Color(0xFFE91E63),
                      Color(0xFFFF9800),
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E8B57),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      Navigator.of(context).pop();
                      setState(() {
                        accounts.add(Account(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          type: selectedType,
                          balance: 0.0,
                          color: selectedColor,
                        ));
                      });
                      _saveAccounts(); // Save after adding
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditAccountDialog(Account account) {
    final nameController = TextEditingController(text: account.name);
    String selectedType = account.type;
    Color selectedColor = account.color;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Edit Akun'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Akun',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Tipe Akun',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Bank', 'E-Wallet', 'Cash'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedType = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Pilih Warna:'),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Color(0xFF2E8B57),
                      Color(0xFF00A8FF),
                      Color(0xFF00AA13),
                      Color(0xFF8B4513),
                      Color(0xFFFF6B35),
                      Color(0xFF9B59B6),
                      Color(0xFFE91E63),
                      Color(0xFFFF9800),
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E8B57),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      Navigator.of(context).pop();
                      setState(() {
                        final index = accounts.indexWhere((a) => a.id == account.id);
                        if (index != -1) {
                          accounts[index] = Account(
                            id: account.id,
                            name: nameController.text,
                            type: selectedType,
                            balance: account.balance,
                            color: selectedColor,
                          );
                        }
                      });
                      _saveAccounts(); // Save after editing
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(Account account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Akun'),
          content: Text('Apakah Anda yakin ingin menghapus akun "${account.name}"?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Hapus'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  accounts.removeWhere((a) => a.id == account.id);
                  selectedAccounts.remove(account.id);
                });
                _saveAccounts(); // Save after deleting
              },
            ),
          ],
        );
      },
    );
  }
}