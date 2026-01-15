import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/responsive_scaffold.dart';
import 'package:myapp/utils/responsive.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isEditing = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate; // New state for date filtering

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<QueryDocumentSnapshot>> _groupAnalysesByMonth(
      List<QueryDocumentSnapshot> docs) {
    final Map<String, List<QueryDocumentSnapshot>> grouped = {};
    docs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>?;
      final bData = b.data() as Map<String, dynamic>?;
      final aTimestamp =
          (aData?['scanResult']?['timestamp'] as Timestamp?)?.toDate() ??
              DateTime(1970);
      final bTimestamp =
          (bData?['scanResult']?['timestamp'] as Timestamp?)?.toDate() ??
              DateTime(1970);
      return bTimestamp.compareTo(aTimestamp);
    });

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final scanResult = data['scanResult'] as Map<String, dynamic>?;
      final timestamp = (scanResult?['timestamp'] as Timestamp?)?.toDate();

      if (timestamp != null) {
        final monthYear = DateFormat('MMMM yyyy').format(timestamp);
        if (grouped[monthYear] == null) {
          grouped[monthYear] = [];
        }
        grouped[monthYear]!.add(doc);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      selectedIndex: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: _isEditing
              ? Text('Chọn để xóa',
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: 20))
              : Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0), // Request: push down a bit
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm lịch sử...',
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.manrope(color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _selectedDate != null
                              ? Icons.close
                              : Icons.calendar_month,
                          color: theme.primaryColor,
                        ),
                        onPressed: () async {
                          if (_selectedDate != null) {
                            setState(() => _selectedDate = null);
                          } else {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _selectedDate = date);
                            }
                          }
                        },
                      ),
                    ),
                    style: GoogleFonts.manrope(
                        color: theme.colorScheme.onSurface, fontSize: 18),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit,
                  color: theme.colorScheme.primary),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    // Reset selection or handle completion if needed
                  }
                });
              },
            )
          ],
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: user == null
            ? Center(
                child: Text('Vui lòng đăng nhập để xem lịch sử.',
                    style: GoogleFonts.manrope()))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('scan_history')
                    .where('scanResult.userId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final scanResult =
                        data['scanResult'] as Map<String, dynamic>?;
                    final prediction =
                        scanResult?['prediction'] as Map<String, dynamic>?;
                    final className =
                        (prediction?['className'] as String? ?? '')
                            .toLowerCase();

                    // Filter by text
                    final matchesText = className.contains(_searchQuery);

                    // Filter by date
                    bool matchesDate = true;
                    if (_selectedDate != null) {
                      final timestamp =
                          (scanResult?['timestamp'] as Timestamp?)?.toDate();
                      if (timestamp == null) {
                        matchesDate = false;
                      } else {
                        matchesDate = timestamp.year == _selectedDate!.year &&
                            timestamp.month == _selectedDate!.month &&
                            timestamp.day == _selectedDate!.day;
                      }
                    }

                    return matchesText && matchesDate;
                  }).toList();
                  final groupedData = _groupAnalysesByMonth(docs);
                  final months = groupedData.keys.toList();

                  return ListView.builder(
                    padding: EdgeInsets.all(Responsive.scale(context, 16)),
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final month = months[index];
                      final records = groupedData[month]!;
                      return _buildMonthSection(month, records);
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text(
            'Chưa có lịch sử',
            style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Các kết quả phân tích da của bạn sẽ được lưu trữ tự động tại đây.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => context.go('/scan'),
            icon: const Icon(Icons.center_focus_weak),
            label: const Text('Bắt đầu quét ngay'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(String month, List<QueryDocumentSnapshot> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, left: 4.0, top: 16.0),
          child: Text(
            month,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Web: Grid Layout
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 2.2, // Adjusted to prevent bottom overflow
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: records.length,
                itemBuilder: (context, index) =>
                    _buildHistoryCard(context, records[index]),
              );
            } else {
              // Mobile: List Layout
              return Column(
                children: records
                    .map((record) => _buildHistoryCard(context, record))
                    .toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final scanResultData = data['scanResult'] as Map<String, dynamic>?;
    final predictionData =
        scanResultData?['prediction'] as Map<String, dynamic>?;
    final predictionText =
        predictionData?['className'] as String? ?? 'Không rõ';
    final confidenceScore = predictionData?['confidenceScore'] as num? ?? 0.0;
    final timestamp = (scanResultData?['timestamp'] as Timestamp?)?.toDate();

    final isDanger = predictionText.toLowerCase().contains('malignant') ||
        predictionText.toLowerCase().contains('carcinoma');
    final statusColor = isDanger ? Colors.redAccent : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: Theme.of(context).cardTheme.shadowColor != null
            ? [
                BoxShadow(
                    color: Theme.of(context).cardTheme.shadowColor!,
                    blurRadius: 10)
              ]
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(Responsive.scale(context, 16)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDanger
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: statusColor,
                size: Responsive.scale(context, 24),
              ),
            ),
            SizedBox(width: Responsive.scale(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    predictionText,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timestamp != null
                        ? DateFormat('EEEE, dd MMM HH:mm').format(timestamp)
                        : '',
                    style:
                        GoogleFonts.manrope(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Tin cậy: ',
                        style: GoogleFonts.manrope(
                            fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${(confidenceScore * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: const Text(
                          'Bạn có chắc chắn muốn xóa bản ghi này không?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Hủy')),
                        TextButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await FirebaseFirestore.instance
                                  .collection('scan_history')
                                  .doc(doc.id)
                                  .delete();
                            },
                            child: const Text('Xóa',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }
}
