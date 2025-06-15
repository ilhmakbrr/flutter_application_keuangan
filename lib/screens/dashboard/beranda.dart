import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class BerandaScreen extends StatefulWidget {
  @override
  _BerandaScreenState createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String _userName = '';
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _remaining = 0.0;
  List<Map<String, dynamic>> _transaksiList = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadAndCalculateTransactions();
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

  Future<void> _loadAndCalculateTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? transaksiJson = prefs.getString('transaksi');
      
      if (transaksiJson != null) {
        final List<dynamic> loadedList = json.decode(transaksiJson);
        _transaksiList = loadedList.map<Map<String, dynamic>>((item) {
          final Map<String, dynamic> transaksi = Map<String, dynamic>.from(item);
          // Konversi string tanggal kembali ke DateTime jika diperlukan
          if (transaksi['tanggal'] is String) {
            transaksi['tanggal'] = DateTime.parse(transaksi['tanggal']);
          }
          return transaksi;
        }).toList();
        
        _calculateFinancialSummary();
      } else {
        // Jika tidak ada data transaksi, set semua ke 0
        setState(() {
          _totalIncome = 0.0;
          _totalExpenses = 0.0;
          _remaining = 0.0;
        });
      }
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() {
        _totalIncome = 0.0;
        _totalExpenses = 0.0;
        _remaining = 0.0;
      });
    }
  }

  void _calculateFinancialSummary() {
    double income = 0.0;
    double expenses = 0.0;
    
    for (var transaksi in _transaksiList) {
      double amount = (transaksi['jumlah'] ?? 0.0).toDouble();
      
      if (amount > 0) {
        // Transaksi positif = Income
        income += amount;
      } else {
        // Transaksi negatif = Expenses (ubah ke positif untuk perhitungan)
        expenses += amount.abs();
      }
    }
    
    setState(() {
      _totalIncome = income;
      _totalExpenses = expenses;
      _remaining = income - expenses;
    });
  }

  // Method untuk refresh data ketika kembali dari screen lain
  void refreshData() {
    _loadAndCalculateTransactions();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _getPercentageChange(double current, double previous) {
    if (previous == 0) {
      return current > 0 ? '+100%' : '0%';
    }
    double percentage = ((current - previous) / previous) * 100;
    return '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FFF8),
      body: Column(
        children: [
          // Header dengan gradient - menggunakan design yang sama dengan AccountScreen
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
                    // App title dengan icon
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
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
                    SizedBox(height: 20),
                    
                    // Welcome section dengan icon waving hand
                    Row(
                      children: [
                        Icon(
                          Icons.waving_hand,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Selamat Datang, $_userName',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                    
                    // Date Range Selector
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Total Transaksi: ${_transaksiList.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.receipt_long,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('MMM yyyy').format(DateTime.now()),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Cards Section
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Financial Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildFinancialCard(
                            'Remaining',
                            _formatCurrency(_remaining),
                            _remaining >= 0 ? 'Saldo tersisa' : 'Saldo kurang',
                            _remaining >= 0 ? Icons.trending_up : Icons.trending_down,
                            _remaining >= 0 ? Colors.green : Colors.red,
                            'Real-time',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildFinancialCard(
                            'Income',
                            _formatCurrency(_totalIncome),
                            'Total pemasukan',
                            Icons.trending_up,
                            Colors.green,
                            'Real-time',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFinancialCard(
                            'Expenses',
                            _formatCurrency(_totalExpenses),
                            'Total pengeluaran',
                            Icons.trending_down,
                            Colors.red,
                            'Real-time',
                          ),
                        ),
                        SizedBox(width: 12),
                        // Financial Health Indicator
                        Expanded(
                          child: _buildFinancialCard(
                            'Health',
                            _totalIncome > 0 ? '${((_remaining / _totalIncome) * 100).toStringAsFixed(1)}%' : '0%',
                            'Kesehatan keuangan',
                            _remaining >= 0 ? Icons.favorite : Icons.warning,
                            _remaining >= 0 ? Colors.green : Colors.orange,
                            'Indikator',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    
                    // Charts Section
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTransactionChart(),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildCategoryChart(),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    
                    // Quick Actions
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ringkasan Keuangan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Pemasukan:', style: TextStyle(color: Colors.grey[600])),
                              Text(_formatCurrency(_totalIncome), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Pengeluaran:', style: TextStyle(color: Colors.grey[600])),
                              Text(_formatCurrency(_totalExpenses), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Sisa Saldo:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                _formatCurrency(_remaining), 
                                style: TextStyle(
                                  color: _remaining >= 0 ? Colors.green : Colors.red, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(String title, String amount, String subtitle, IconData trendIcon, Color trendColor, String period) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Icon(trendIcon, color: trendColor, size: 16),
            ],
          ),
          SizedBox(height: 4),
          Text(
            period,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionChart() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaksi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.grey.shade400, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Bar Chart',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('Income', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              SizedBox(width: 16),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('Expenses', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          
          Container(
            height: 120,
            child: _transaksiList.isEmpty 
              ? Center(
                  child: Text(
                    'Belum ada data transaksi',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _buildChartBars(),
                ),
          ),
          
          // Days labels
          if (_transaksiList.isNotEmpty) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildDayLabels(),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildChartBars() {
    // Buat data chart berdasarkan transaksi 7 hari terakhir
    Map<String, Map<String, double>> dailyData = {};
    DateTime now = DateTime.now();
    
    // Initialize data untuk 7 hari terakhir
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String dateKey = DateFormat('dd/MM').format(date);
      dailyData[dateKey] = {'income': 0.0, 'expenses': 0.0};
    }
    
    // Hitung total income dan expenses per hari
    for (var transaksi in _transaksiList) {
      DateTime transactionDate = transaksi['tanggal'] is DateTime 
          ? transaksi['tanggal'] 
          : DateTime.parse(transaksi['tanggal']);
      
      String dateKey = DateFormat('dd/MM').format(transactionDate);
      if (dailyData.containsKey(dateKey)) {
        double amount = (transaksi['jumlah'] ?? 0.0).toDouble();
        if (amount > 0) {
          dailyData[dateKey]!['income'] = dailyData[dateKey]!['income']! + amount;
        } else {
          dailyData[dateKey]!['expenses'] = dailyData[dateKey]!['expenses']! + amount.abs();
        }
      }
    }
    
    // Cari nilai maksimum untuk scaling
    double maxValue = 0;
    dailyData.values.forEach((dayData) {
      double maxForDay = math.max(dayData['income']!, dayData['expenses']!);
      if (maxForDay > maxValue) maxValue = maxForDay;
    });
    
    if (maxValue == 0) maxValue = 1; // Avoid division by zero
    
    return dailyData.entries.map((entry) {
      double incomeHeight = (entry.value['income']! / maxValue) * 100;
      double expensesHeight = (entry.value['expenses']! / maxValue) * 100;
      return _buildDualChartBar(incomeHeight, expensesHeight);
    }).toList();
  }

  List<Widget> _buildDayLabels() {
    List<String> labels = [];
    DateTime now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      labels.add(DateFormat('dd').format(date));
    }
    
    return labels.map((label) => Text(
      label,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[500],
      ),
    )).toList();
  }

  Widget _buildDualChartBar(double incomeHeight, double expensesHeight) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Income bar (green)
        Container(
          width: 8,
          height: incomeHeight,
          margin: EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        // Expenses bar (red)
        Container(
          width: 8,
          height: expensesHeight,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.pie_chart, color: Colors.grey.shade400, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Pie chart',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          
          Center(
            child: Container(
              width: 100,
              height: 100,
              child: _buildPieChart(),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Category legends
          ..._buildCategoryLegends(),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    Map<String, int> categoryCount = _getCategoryUsageCount();
    
    if (categoryCount.isEmpty) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Center(
          child: Text(
            'No Data',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ),
      );
    }
    
    int totalTransactions = categoryCount.values.fold(0, (sum, count) => sum + count);
    List<Color> colors = [
      Color(0xFF4CAF50), // Green
      Color(0xFF2196F3), // Blue
      Color(0xFFFF9800), // Orange
      Color(0xFFE91E63), // Pink
      Color(0xFF9C27B0), // Purple
      Color(0xFF607D8B), // Blue Grey
    ];
    
    return CustomPaint(
      painter: PieChartPainter(categoryCount, totalTransactions, colors),
      child: Container(),
    );
  }

  Map<String, int> _getCategoryUsageCount() {
    Map<String, int> categoryCount = {};
    
    for (var transaksi in _transaksiList) {
      String kategori = transaksi['kategori'] ?? 'Unknown';
      categoryCount[kategori] = (categoryCount[kategori] ?? 0) + 1;
    }
    
    return categoryCount;
  }

  List<Widget> _buildCategoryLegends() {
    Map<String, int> categoryCount = _getCategoryUsageCount();
    
    if (categoryCount.isEmpty) {
      return [
        Text(
          'Belum ada kategori',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ];
    }
    
    int totalTransactions = categoryCount.values.fold(0, (sum, count) => sum + count);
    List<Color> colors = [
      Color(0xFF4CAF50), // Green
      Color(0xFF2196F3), // Blue
      Color(0xFFFF9800), // Orange
      Color(0xFFE91E63), // Pink
      Color(0xFF9C27B0), // Purple
      Color(0xFF607D8B), // Blue Grey
    ];
    
    List<Widget> legends = [];
    int colorIndex = 0;
    
    // Sort categories by usage count (descending)
    var sortedEntries = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (var entry in sortedEntries.take(6)) { // Show max 6 categories
      double percentage = (entry.value / totalTransactions) * 100;
      
      legends.add(
        Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors[colorIndex % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${entry.key} ${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
      colorIndex++;
    }
    
    return legends;
  }
}

// Custom Painter untuk Pie Chart
class PieChartPainter extends CustomPainter {
  final Map<String, int> categoryCount;
  final int totalTransactions;
  final List<Color> colors;
  
  PieChartPainter(this.categoryCount, this.totalTransactions, this.colors);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (categoryCount.isEmpty) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    double startAngle = -math.pi / 2; // Start from top
    int colorIndex = 0;
    
    // Sort categories by usage count (descending)
    var sortedEntries = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (var entry in sortedEntries.take(6)) { // Show max 6 categories
      double sweepAngle = (entry.value / totalTransactions) * 2 * math.pi;
      
      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
      colorIndex++;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}