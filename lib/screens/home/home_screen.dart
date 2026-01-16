import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:myapp/screens/responsive_scaffold.dart';
import 'package:myapp/utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  Stream<QuerySnapshot>? _historyStream;

  @override
  void initState() {
    super.initState();
    _initHistoryStream();
  }

  void _initHistoryStream() {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _historyStream = FirebaseFirestore.instance
          .collection('scan_history')
          .where('scanResult.userId', isEqualTo: user!.uid)
          .snapshots();
    } else {
      _historyStream = const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Refresh user on build to be safe, though initState captures it mostly.
    // If relying on Provider for user changes, we should use didChangeDependencies.
    // unique User object check might be needed. For now simple fix.

    // Ensure stream is initialized (handles hot reload case where initState didn't run for new field)
    if (_historyStream == null) {
      _initHistoryStream();
    }

    final String displayName = user?.displayName ?? 'Bạn';
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      selectedIndex: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 800;

          if (isWeb) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.scale(context, 32.0),
                vertical: Responsive.scale(context, 32.0),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Main Dashboard
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeroSection(context, displayName),
                            SizedBox(height: Responsive.scale(context, 40)),
                            Text(
                              'Phím tắt',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.scale(context, 16)),
                            _buildQuickActions(context),
                            SizedBox(height: Responsive.scale(context, 40)),
                            _buildDailyTipCard(context),
                            SizedBox(height: Responsive.scale(context, 40)),

                            // [NEW] Featured News Section to fill space
                            Text(
                              'Tin nóng y tế',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Responsive.scale(context, 16)),
                            _buildFeaturedNews(context),
                          ],
                        ),
                      ),
                      SizedBox(width: Responsive.scale(context, 40)),

                      // Right Column: History Sidebar
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding:
                              EdgeInsets.all(Responsive.scale(context, 24)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Hoạt động gần đây',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward,
                                        color: theme.colorScheme.primary),
                                    onPressed: () => context.go('/history'),
                                  )
                                ],
                              ),
                              SizedBox(height: Responsive.scale(context, 20)),
                              // Show more history items on web
                              SizedBox(height: Responsive.scale(context, 20)),
                              // Show more history items on web
                              StreamBuilder<QuerySnapshot>(
                                stream: _historyStream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return _buildEmptyState(context);
                                  }
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(
                                            height:
                                                Responsive.scale(context, 16)),
                                    itemBuilder: (context, index) =>
                                        _buildHistoryTile(
                                            snapshot.data!.docs[index]),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            // ... Mobile Layout (Existing) ...
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.scale(context, 20.0),
                vertical: Responsive.scale(context, 24.0),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroSection(context, displayName),
                      SizedBox(height: Responsive.scale(context, 32)),
                      Text(
                        'Phím tắt',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: Responsive.scale(context, 16)),
                      _buildQuickActions(context),
                      SizedBox(height: Responsive.scale(context, 20)),
                      _buildRecentHistorySection(context),
                      _buildDailyTipCard(context),
                      SizedBox(height: Responsive.scale(context, 100)),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, String name) {
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String displayName = name;
          String? photoUrl = user?.photoURL;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            if (data.containsKey('displayName')) {
              displayName = data['displayName'] ?? name;
            }
            if (data.containsKey('photoUrl')) {
              photoUrl = data['photoUrl'];
            }
          }

          ImageProvider? backgroundImage;
          if (photoUrl != null && photoUrl.isNotEmpty) {
            if (photoUrl.startsWith('http')) {
              backgroundImage = NetworkImage(photoUrl);
            } else if (photoUrl.startsWith('assets')) {
              backgroundImage = AssetImage(photoUrl);
            }
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, $displayName 👋',
                      style: GoogleFonts.manrope(
                        fontSize: Responsive.fontSize(context, 28),
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.scale(context, 4)),
                    Text(
                      "Hôm nay bạn cảm thấy làn da thế nào?",
                      style: GoogleFonts.manrope(
                        fontSize: Responsive.fontSize(context, 16),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: Responsive.scale(context, 50),
                width: Responsive.scale(context, 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  image: backgroundImage != null
                      ? DecorationImage(
                          image: backgroundImage,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: backgroundImage == null
                    ? Center(
                        child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: Responsive.fontSize(context, 20)),
                      ))
                    : null,
              )
            ],
          );
        });
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            title: 'Quét Mới',
            icon: Icons.center_focus_weak,
            color: Theme.of(context).colorScheme.primary,
            onTap: () => context.go('/scan'),
          ),
        ),
        SizedBox(width: Responsive.scale(context, 16)),
        Expanded(
          child: _buildActionCard(
            context,
            title: 'Lịch Sử',
            icon: Icons.history_edu,
            color: Colors.orange.shade400,
            onTap: () => context.go('/history'),
          ),
        ),
        SizedBox(width: Responsive.scale(context, 16)),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: user != null
                ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .snapshots()
                : null,
            builder: (context, snapshot) {
              final role =
                  snapshot.data?.data().toString().contains('role: doctor') ==
                              true ||
                          (snapshot.data?.data()
                                  as Map<String, dynamic>?)?['role'] ==
                              'doctor'
                      ? 'doctor'
                      : 'user';

              return _buildActionCard(
                context,
                title: role == 'doctor' ? 'Trò Chuyện' : 'Tư Vấn',
                icon: role == 'doctor'
                    ? Icons.chat_bubble_outline
                    : Icons.video_camera_front_outlined,
                color: const Color(0xFF18A0FB),
                onTap: () =>
                    context.go(role == 'doctor' ? '/chats' : '/consult'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: Responsive.scale(context, 110),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.scale(context, 12)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(icon, color: color, size: Responsive.scale(context, 28)),
            ),
            SizedBox(height: Responsive.scale(context, 12)),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistorySection(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hoạt động gần đây',
              style: GoogleFonts.manrope(
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/history'),
              child: Text(
                'Xem tất cả',
                style: GoogleFonts.manrope(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.scale(context, 8)),
        // StreamBuilder to fetch recent history
        StreamBuilder<QuerySnapshot>(
          stream: _historyStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Lỗi: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState(context);
            }

            // Sort and limit data client-side to avoid Firestore Index issues
            final docs = List<QueryDocumentSnapshot>.from(snapshot.data!.docs);
            docs.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTime =
                  (aData['scanResult']?['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime(1970);
              final bTime =
                  (bData['scanResult']?['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime(1970);
              return bTime.compareTo(aTime); // Descending
            });

            final recentDocs = docs.take(3).toList();
            final itemCount = recentDocs.length;

            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: Responsive.scale(context, 12)),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                separatorBuilder: (context, index) =>
                    SizedBox(height: Responsive.scale(context, 12)),
                itemBuilder: (context, index) =>
                    _buildHistoryTile(recentDocs[index]),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.scale(context, 24)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Chưa có dữ liệu quét nào. Hãy thử quét ngay!',
              style: GoogleFonts.manrope(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final scanResultData = data['scanResult'] as Map<String, dynamic>?;
    final predictionData =
        scanResultData?['prediction'] as Map<String, dynamic>?;
    final predictionText =
        predictionData?['className'] as String? ?? 'Chưa xác định';
    final timestamp = (scanResultData?['timestamp'] as Timestamp?)?.toDate();

    // Simple color coding logic
    final bool isSafe = !predictionText.toLowerCase().contains('malignant');
    final Color statusColor = isSafe ? Colors.green : Colors.red;

    return Container(
      padding: EdgeInsets.all(Responsive.scale(context, 12)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isSafe ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  predictionText,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 14),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timestamp != null
                      ? DateFormat('dd/MM/yyyy • HH:mm').format(timestamp)
                      : '--/--/----',
                  style: GoogleFonts.manrope(
                    color: Colors.grey[500],
                    fontSize: Responsive.fontSize(context, 11),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  Widget _buildDailyTipCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.scale(context, 20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF26A69A),
            const Color(0xFF26A69A).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Mẹo mỗi ngày',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.scale(context, 12)),
                Text(
                  'Uống đủ nước giúp da ẩm mượt từ bên trong!',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: Responsive.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.scale(context, 16)),
          Icon(Icons.water_drop,
              color: Colors.white.withOpacity(0.8), size: 40),
        ],
      ),
    );
  }

  Widget _buildFeaturedNews(BuildContext context) {
    final news = [
      {
        'title': 'Cách bảo vệ da lão hóa sớm?',
        'desc':
            'Những thói quen hàng ngày tưởng chừng vô hại nhưng lại khiến...',
        'image': 'assets/images/pic_derm3.jpg'
      },
      {
        'title': 'Dấu hiệu nhận biết ung thư da',
        'desc': 'Các triệu chứng ban đầu thường bị bỏ qua dẫn đến...',
        'image': 'assets/images/pic_derm1.jpg'
      },
      {
        'title': 'Chăm sóc da mùa hè đúng cách',
        'desc': 'Nắng nóng là kẻ thù số 1 của làn da, hãy học cách...',
        'image': 'assets/images/pic_derm2.jpg'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns for news
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: news.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    news[index]['image']!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news[index]['title']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        news[index]['desc']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
