import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionTab extends StatefulWidget {
  @override
  _TransactionTabState createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
  DateTime? selectedDate;
  String _userName = '';
  String? selectedAccount;
  String? selectedCategory;
  String payment = '';
  double amount = 0;
  bool isIncome = false;
  String? notes;

  List<Map<String, dynamic>> transaksiList = [];

  List<String> akunList = ['Tunai', 'Bank'];
  List<String> kategoriList = ['Jajan', 'Gaji', 'Transport'];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
   _loadUserName();
    _loadAccounts();
    _loadKategori();
    _loadTransaksi();
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

  Future<void> _loadAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accountsJson = prefs.getString('accounts');
      if (accountsJson != null) {
        final List<dynamic> accountsList = json.decode(accountsJson);
        setState(() {
          akunList = accountsList.map((account) => account['name'] as String).toList();
        });
      }
    } catch (e) {
      print('Error loading accounts: $e');
    }
  }

  Future<void> _loadKategori() async {
  try {
    // Mulai dengan kategori default
    List<String> allKategori = ['Kuliah', 'Makanan', 'Kos', 'Pakaian', 'Pekerjaan'];
    
    // Tambahkan kategori custom dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? kategoriJson = prefs.getString('custom_categories');
    
    if (kategoriJson != null) {
      final List<dynamic> customCategories = json.decode(kategoriJson);
      // Tambahkan kategori custom ke list
      for (var category in customCategories) {
        allKategori.add(category['name'] as String);
      }
    }
    
    setState(() {
      kategoriList = allKategori;
    });
    
    print('Kategori berhasil dimuat: ${kategoriList.length} kategori');
    print('Daftar kategori: $kategoriList');
  } catch (e) {
    print('Error loading kategori: $e');
    // Fallback ke kategori default jika ada error
    setState(() {
      kategoriList = ['Kuliah', 'Makanan', 'Kos', 'Pakaian', 'Pekerjaan'];
    });
  }
}

  Future<void> _saveTransaksi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Konversi DateTime ke string sebelum menyimpan
      final transaksiToSave = transaksiList.map((item) {
        final Map<String, dynamic> itemToSave = Map.from(item);
        if (itemToSave['tanggal'] is DateTime) {
          itemToSave['tanggal'] = (itemToSave['tanggal'] as DateTime).toIso8601String();
        }
        return itemToSave;
      }).toList();
      
      final String transaksiJson = json.encode(transaksiToSave);
      await prefs.setString('transaksi', transaksiJson);
      print('Data transaksi berhasil disimpan: ${transaksiToSave.length} transaksi');
    } catch (e) {
      print('Error saving transaksi: $e');
    }
  }

  Future<void> _loadTransaksi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? transaksiJson = prefs.getString('transaksi');
      if (transaksiJson != null) {
        final List<dynamic> loadedList = json.decode(transaksiJson);
        setState(() {
          transaksiList = loadedList.map<Map<String, dynamic>>((item) {
            final Map<String, dynamic> transaksi = Map<String, dynamic>.from(item);
            // Konversi string tanggal kembali ke DateTime
            if (transaksi['tanggal'] is String) {
              transaksi['tanggal'] = DateTime.parse(transaksi['tanggal']);
            }
            return transaksi;
          }).toList();
        });
        print('Data transaksi berhasil dimuat: ${transaksiList.length} transaksi');
      }
    } catch (e) {
      print('Error loading transaksi: $e');
    }
  }

  void _hapusTransaksi(int index) {
    setState(() {
      transaksiList.removeAt(index);
      _saveTransaksi(); // Simpan perubahan ke SharedPreferences
    });
  }

  void _tambahTransaksi() {
    if (_formKey.currentState!.validate() &&
        selectedDate != null &&
        selectedAccount != null &&
        selectedCategory != null &&
        amount != 0) {
      setState(() {
        transaksiList.add({
          'tanggal': selectedDate!, // Simpan sebagai DateTime
          'akun': selectedAccount!,
          'kategori': selectedCategory!,
          'pembayaran': payment,
          'jumlah': isIncome ? amount : -amount,
          'catatan': notes ?? ''
        });
        print('Transaksi baru ditambahkan: ${transaksiList.last}');
        _saveTransaksi(); // Simpan transaksi ke SharedPreferences
        _resetForm();
        Navigator.of(context).pop();
      });
    } else {
      // Show validation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap lengkapi semua field yang diperlukan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    selectedDate = null;
    selectedAccount = null;
    selectedCategory = null;
    payment = '';
    amount = 0;
    notes = null;
    isIncome = false;
    _amountController.clear();
    _paymentController.clear();
    _notesController.clear();
  }

  void _openFormPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaksi baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  'Buat transaksi baru.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20),

                // Date Picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                        SizedBox(width: 12),
                        Text(
                          selectedDate == null 
                            ? 'Pilih tanggal' 
                            : DateFormat('dd MMM yyyy').format(selectedDate!),
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedDate == null ? Colors.grey[600] : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Account Dropdown
                Text('Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedAccount,
                      hint: Text('Pilih akun', style: TextStyle(color: Colors.grey[600])),
                      isExpanded: true,
                      items: akunList.map((e) => DropdownMenuItem(
                        value: e, 
                        child: Text(e, style: TextStyle(fontSize: 16))
                      )).toList(),
                      onChanged: (val) {
                        setState(() => selectedAccount = val);
                        setModalState(() => selectedAccount = val);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Category Dropdown - FIXED: Now uses setModalState
                Text('Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      hint: Text('Pilih kategori', style: TextStyle(color: Colors.grey[600])),
                      isExpanded: true,
                      items: kategoriList.map((e) => DropdownMenuItem(
                        value: e, 
                        child: Text(e, style: TextStyle(fontSize: 16))
                      )).toList(),
                      onChanged: (val) {
                        setState(() => selectedCategory = val);
                        setModalState(() => selectedCategory = val);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Payment Field
                Text('Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                TextFormField(
                  controller: _paymentController,
                  decoration: InputDecoration(
                    hintText: 'Tambahkan pembayaran',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) => payment = val,
                ),
                SizedBox(height: 16),

                // Amount Field
                Text('Jumlah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Row(
                  children: [
                    // Income/Expense Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() => isIncome = false);
                              setModalState(() => isIncome = false);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: !isIncome ? Colors.red : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.remove,
                                color: !isIncome ? Colors.white : Colors.grey[600],
                                size: 20,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => isIncome = true);
                              setModalState(() => isIncome = true);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isIncome ? Colors.green : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.add,
                                color: isIncome ? Colors.white : Colors.grey[600],
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    // Amount Input
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (val) => amount = double.tryParse(val) ?? 0,
                        validator: (value) {
                          if (value == null || value.isEmpty || double.tryParse(value) == 0) {
                            return 'Masukkan jumlah yang valid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Notes Field
                Text('Catatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: 'Catatan opsional',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) => notes = val,
                ),
                SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _tambahTransaksi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E8B57),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Buat transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildRiwayatList() {
    if (transaksiList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Transaksi Anda akan muncul di sini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Sort transaksi berdasarkan tanggal (terbaru terlebih dahulu)
    List<Map<String, dynamic>> sortedTransaksi = List.from(transaksiList);
    sortedTransaksi.sort((a, b) {
      DateTime dateA = a['tanggal'] is DateTime ? a['tanggal'] : DateTime.parse(a['tanggal']);
      DateTime dateB = b['tanggal'] is DateTime ? b['tanggal'] : DateTime.parse(b['tanggal']);
      return dateB.compareTo(dateA);
    });

    return ListView.builder(
      itemCount: sortedTransaksi.length,
      itemBuilder: (context, index) {
        final transaction = sortedTransaksi[index];
        final isPositive = transaction['jumlah'] >= 0;
        final DateTime transactionDate = transaction['tanggal'] is DateTime 
            ? transaction['tanggal'] 
            : DateTime.parse(transaction['tanggal']);
        
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Amount
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${isPositive ? '+' : '-'}Rp ${transaction['jumlah'].abs().toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isPositive ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(width: 12),
              
              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['kategori'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      transaction['akun'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (transaction['pembayaran'] != null && transaction['pembayaran'].isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        transaction['pembayaran'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                    SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM yyyy').format(transactionDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Delete Button
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Hapus Transaksi'),
                        content: Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Cari index asli dari transaksi di transaksiList
                              int originalIndex = transaksiList.indexWhere((t) => 
                                t['tanggal'] == transaction['tanggal'] &&
                                t['akun'] == transaction['akun'] &&
                                t['kategori'] == transaction['kategori'] &&
                                t['jumlah'] == transaction['jumlah']
                              );
                              if (originalIndex != -1) {
                                _hapusTransaksi(originalIndex);
                              }
                              Navigator.of(context).pop();
                            },
                            child: Text('Hapus', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete_outline, color: Colors.red[300]),
              ),
            ],
          ),
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
          // Header Section
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
                    
                    // Summary info
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Transaksi: ${transaksiList.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Transaction History Section
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
                  // Header with buttons
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Riwayat Transaksi',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _openFormPanel,
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
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.file_download, color: Color(0xFF2E8B57)),
                                label: Text(
                                  'Import',
                                  style: TextStyle(color: Color(0xFF2E8B57), fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: Color(0xFF2E8B57)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Transaction List
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: _buildRiwayatList(),
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