import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

void main() {
  runApp(const VietGoApp());
}

ValueNotifier<String> currentLangNotifier = ValueNotifier<String>('vi');
ValueNotifier<bool> isLoggedInNotifier = ValueNotifier<bool>(false);
ValueNotifier<String> userEmailNotifier = ValueNotifier<String>('');
ValueNotifier<String> userNameNotifier = ValueNotifier<String>('');
ValueNotifier<Uint8List?> userAvatarNotifier =
    ValueNotifier<Uint8List?>(null);

List<Map<String, dynamic>> savedPlaces = [];

// ============================================================
// ĐA NGÔN NGỮ
// ============================================================

Map<String, Map<String, String>> localizedText = {
  'vi': {
    'app_title': 'VietGo - Trợ lý du lịch AI',
    'home': 'Trang chủ',
    'explore': 'Khám phá',
    'saved': 'Địa điểm đã lưu',
    'profile': 'Tài khoản',
    'search_hint': 'Bạn muốn đi đâu?',
    'featured': 'Điểm đến nổi bật',
    'see_all': 'Xem tất cả',
    'ai_title': 'VietGo AI Guide',
    'ai_desc':
        'Hỏi VietGo bất cứ điều gì về du lịch Việt Nam. Nhận gợi ý lịch trình, ăn uống...',
    'chat_btn': 'Bắt đầu trò chuyện',
    'login_google': 'Đăng nhập bằng Google (Gmail)',
    'logout': 'Đăng xuất',
    'language': 'Ngôn ngữ',
    'edit_profile': 'Chỉnh sửa hồ sơ',
    'directions': 'Chỉ đường',
    'save_place': 'Địa điểm đã lưu',
    'from_placeholder': 'Vị trí của bạn (Nhập tọa độ hoặc tên)',
    'to_placeholder': 'Chọn điểm đến...',
    'lang_confirm_title': 'Xác nhận đổi ngôn ngữ',
    'lang_confirm_content':
        'Bạn có chắc chắn muốn chuyển đổi ngôn ngữ ứng dụng không?',
    'yes': 'Có',
    'no': 'Không',
    'change_avatar': 'Đổi ảnh đại diện',
    'name_label': 'Tên hiển thị',
    'email_label': 'Email',
    'save_changes': 'Lưu thay đổi',
    'all': 'Tất cả',
    'entertainment': 'Vui chơi',
    'food': 'Quán ăn',
    'car': 'Ô tô',
    'bike': 'Xe máy',
    'walk': 'Đi bộ',
    'searching': 'Đang tìm kiếm...',
    'no_result': 'Không tìm thấy địa điểm',
    'search_error': 'Không thể tìm kiếm địa điểm',
    'select_place': 'Chọn địa điểm',
    'search_results': 'Kết quả tìm kiếm',
    'saved_success': 'Đã lưu địa điểm!',
  },
  'en': {
    'app_title': 'VietGo - AI Travel Assistant',
    'home': 'Home',
    'explore': 'Explore',
    'saved': 'Saved Places',
    'profile': 'Profile',
    'search_hint': 'Where do you want to go?',
    'featured': 'Featured Destinations',
    'see_all': 'See all',
    'ai_title': 'VietGo AI Guide',
    'ai_desc':
        'Ask VietGo anything about Vietnam travel. Get itinerary & dining tips...',
    'chat_btn': 'Start Chatting',
    'login_google': 'Sign in with Google (Gmail)',
    'logout': 'Log out',
    'language': 'Language',
    'edit_profile': 'Edit Profile',
    'directions': 'Directions',
    'save_place': 'Saved Place',
    'from_placeholder': 'Your location (Enter coords or name)',
    'to_placeholder': 'Choose destination...',
    'lang_confirm_title': 'Confirm Language Change',
    'lang_confirm_content':
        'Are you sure you want to change the app language?',
    'yes': 'Yes',
    'no': 'No',
    'change_avatar': 'Change Avatar',
    'name_label': 'Display Name',
    'email_label': 'Email',
    'save_changes': 'Save Changes',
    'all': 'All',
    'entertainment': 'Entertainment',
    'food': 'Food',
    'car': 'Car',
    'bike': 'Bike',
    'walk': 'Walk',
    'searching': 'Searching...',
    'no_result': 'No location found',
    'search_error': 'Unable to search for location',
    'select_place': 'Select location',
    'search_results': 'Search results',
    'saved_success': 'Place saved!',
  },
  'zh': {
    'app_title': 'VietGo - AI 旅游助手',
    'home': '首页',
    'explore': '探索',
    'saved': '已保存地点',
    'profile': '个人中心',
    'search_hint': '你想去哪里？',
    'featured': '热门目的地',
    'see_all': '查看全部',
    'ai_title': 'VietGo AI 导游',
    'ai_desc':
        '向 VietGo 咨询有关越南旅游的任何问题。获取行程和美食建议...',
    'chat_btn': '开始聊天',
    'login_google': '使用谷歌账号登录 (Gmail)',
    'logout': '登出',
    'language': '语言',
    'edit_profile': '编辑资料',
    'directions': '路线',
    'save_place': '保存地点',
    'email_label': '电子邮件',
    'save_changes': '保存更改',
    'all': '全部',
    'entertainment': '娱乐',
    'food': '美食',
    'from_placeholder': '您的位置（输入坐标或名称）',
    'to_placeholder': '选择目的地...',
    'lang_confirm_title': '确认更改语言',
    'lang_confirm_content': '您确定要更改应用程序语言吗？',
    'yes': '是',
    'no': '否',
    'change_avatar': '更改头像',
    'name_label': '显示名称',
    'car': '汽车',
    'bike': '摩托车',
    'walk': '步行',
    'searching': '正在搜索...',
    'no_result': '没有找到地点',
    'search_error': '无法搜索地点',
    'select_place': '选择地点',
    'search_results': '搜索结果',
    'saved_success': '地点已保存！',
  },
};

String t(String key) {
  String lang = currentLangNotifier.value;
  return localizedText[lang]?[key] ?? key;
}

// ============================================================
// APP
// ============================================================

class VietGoApp extends StatelessWidget {
  const VietGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: currentLangNotifier,
      builder: (context, lang, child) {
        return MaterialApp(
          title: t('app_title'),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            fontFamily: 'Roboto',
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}

// ============================================================
// AUTH
// ============================================================

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoggedInNotifier,
      builder: (context, isLoggedIn, child) {
        if (!isLoggedIn) {
          return const LoginScreen();
        }

        return const MainNavigationScreen();
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _simulateGmailLogin(BuildContext context) {
    userNameNotifier.value = "Phạm Mai Chi";
    userEmailNotifier.value = "maichi106@gmail.com";
    isLoggedInNotifier.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.travel_explore,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'VietGo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Trợ lý du lịch AI & Bản đồ Offline thông minh',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onPressed: () => _simulateGmailLogin(context),
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 32,
                    color: Colors.red,
                  ),
                  label: Text(
                    t('login_google'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MAIN NAVIGATION
// ============================================================

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreMapScreen(),
    const SavedPlacesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: currentLangNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: t('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.explore_outlined),
                activeIcon: const Icon(Icons.explore),
                label: t('explore'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite_outline),
                activeIcon: const Icon(Icons.favorite),
                label: t('saved'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: t('profile'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// ACTIVE DESTINATION
// ============================================================

ValueNotifier<Map<String, dynamic>> activeDestinationNotifier =
    ValueNotifier<Map<String, dynamic>>({
  'name': 'Phở Thìn Bờ Hồ',
  'point': const LatLng(21.0285, 105.8542),
  'address': '61 Phố Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội',
  'rating': 4.7,
  'price': '50.000đ - 70.000đ',
  'category': 'Quán ăn',
});

// ============================================================
// HOME
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToMap(
    BuildContext context,
    Map<String, dynamic> place,
  ) {
    activeDestinationNotifier.value = place;

    final navState =
        context.findAncestorStateOfType<_MainNavigationScreenState>();

    if (navState != null) {
      navState.setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController =
        TextEditingController();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VietGo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      t('ai_title'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder<String>(
                  valueListenable: userNameNotifier,
                  builder: (context, name, child) {
                    return Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1528127269322-539801943592?q=80&w=1000',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khám Phá Việt Nam',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Đi xa hơn. Hiểu sâu hơn.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: t('search_hint'),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.green,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _navigateToMap(
                    context,
                    {
                      'name': value,
                      'point': const LatLng(
                        21.0350,
                        105.8500,
                      ),
                      'address': 'Kết quả tìm kiếm',
                      'rating': 4.5,
                      'price': 'N/A',
                      'category': 'Khác',
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t('featured'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  t('see_all'),
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () => _navigateToMap(
                      context,
                      {
                        'name': 'Phở Thìn Bờ Hồ',
                        'point': const LatLng(
                          21.0285,
                          105.8542,
                        ),
                        'address':
                            '61 Phố Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội',
                        'rating': 4.7,
                        'price': '50.000đ - 70.000đ',
                        'category': 'Quán ăn',
                      },
                    ),
                    child: _buildDestCard(
                      'Phở Thìn Bờ Hồ',
                      'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=500',
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _navigateToMap(
                      context,
                      {
                        'name': 'Lăng Chủ tịch Hồ Chí Minh',
                        'point': const LatLng(
                          21.0368,
                          105.8346,
                        ),
                        'address':
                            '2 Hùng Vương, Ba Đình, Hà Nội',
                        'rating': 4.9,
                        'price': 'Miễn phí',
                        'category': 'Vui chơi',
                      },
                    ),
                    child: _buildDestCard(
                      'Lăng Bác',
                      'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?q=80&w=500',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('ai_title'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t('ai_desc'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AiChatScreen(),
                          ),
                        );
                      },
                      child: Text(t('chat_btn')),
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

  Widget _buildDestCard(
    String title,
    String imageUrl,
  ) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EXPLORE MAP
// ============================================================

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() =>
      _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  // ==========================================================
  // ĐIỂM XUẤT PHÁT
  // ==========================================================

  LatLng startPoint = const LatLng(
    21.0285,
    105.8542,
  );

  late Map<String, dynamic> currentDestination;

  final TextEditingController _fromController =
      TextEditingController(
    text: "21.0285, 105.8542",
  );

  final TextEditingController _toController =
      TextEditingController();

  final MapController _mapController =
      MapController();

  // ==========================================================
  // ROUTE
  // ==========================================================

  List<LatLng> routePoints = [];

  String routeInfo =
      "Đang chuẩn bị lộ trình...";

  String selectedTransport = 'car';

  String selectedFilter = 'Tất cả';

  // ==========================================================
  // SEARCH
  // ==========================================================

  List<Map<String, dynamic>> searchResults = [];

  bool isSearching = false;

  // ==========================================================
  // CÁC ĐỊA ĐIỂM GỢI Ý CÓ SẴN
  // GIỮ NGUYÊN
  // ==========================================================

  final List<Map<String, dynamic>> suggestions = [
    {
      'name': 'Phở Thìn Bờ Hồ',
      'point': const LatLng(
        21.0285,
        105.8542,
      ),
      'address':
          '61 Phố Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội',
      'rating': 4.7,
      'price': '50.000đ - 70.000đ',
      'category': 'Quán ăn',
    },
    {
      'name': 'Lăng Chủ tịch Hồ Chí Minh',
      'point': const LatLng(
        21.0368,
        105.8346,
      ),
      'address':
          '2 Hùng Vương, Ba Đình, Hà Nội',
      'rating': 4.9,
      'price': 'Miễn phí',
      'category': 'Vui chơi',
    },
    {
      'name': 'Hồ Tây lộng gió',
      'point': const LatLng(
        21.0583,
        105.8235,
      ),
      'address':
          'Đường Thanh Niên, Tây Hồ, Hà Nội',
      'rating': 4.8,
      'price': 'Miễn phí',
      'category': 'Vui chơi',
    },
    {
      'name': 'Bún chả Hương Liên',
      'point': const LatLng(
        21.0142,
        105.8500,
      ),
      'address':
          '24 Lê Văn Hưu, Hai Bà Trưng, Hà Nội',
      'rating': 4.6,
      'price': '40.000đ - 60.000đ',
      'category': 'Quán ăn',
    },
  ];

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    currentDestination =
        activeDestinationNotifier.value;

    _toController.text =
        currentDestination['name'];

    activeDestinationNotifier.addListener(
      _onDestinationChanged,
    );

    fetchRoute();
  }

  @override
  void dispose() {
    activeDestinationNotifier.removeListener(
      _onDestinationChanged,
    );

    _fromController.dispose();
    _toController.dispose();

    super.dispose();
  }

  // ==========================================================
  // DESTINATION THAY ĐỔI
  // ==========================================================

  void _onDestinationChanged() {
    if (!mounted) return;

    setState(() {
      currentDestination =
          activeDestinationNotifier.value;

      _toController.text =
          currentDestination['name'];

      searchResults = [];
    });

    _mapController.move(
      currentDestination['point'],
      14.0,
    );

    fetchRoute();
  }

  // ==========================================================
  // TÌM KIẾM ĐỊA ĐIỂM BẰNG NOMINATIM
  // ==========================================================

Future<void> _searchDestination(
  String text,
) async {
  final query = text.trim();

  if (query.isEmpty) {
    setState(() {
      searchResults = [];
    });
    return;
  }

  setState(() {
    isSearching = true;
    searchResults = [];
  });

  try {
    // Flutter Web không gọi Nominatim trực tiếp.
    // Gọi qua Backend Java để tránh lỗi CORS.
    final uri = Uri.parse(
      'http://localhost:8080/search?q=${Uri.encodeQueryComponent(query)}',
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);

      if (decoded is! List) {
        throw Exception('Backend trả về dữ liệu không hợp lệ');
      }

      final List<Map<String, dynamic>> results =
          decoded.map<Map<String, dynamic>>((item) {
        return {
          'name': item['display_name']?.toString() ??
              'Không có tên',
          'lat': double.tryParse(
                item['lat']?.toString() ?? '',
              ) ??
              0.0,
          'lon': double.tryParse(
                item['lon']?.toString() ?? '',
              ) ??
              0.0,
          'type': item['type']?.toString() ?? '',
          'category': item['category']?.toString() ?? '',
        };
      }).where((item) {
        return item['lat'] != 0.0 &&
            item['lon'] != 0.0;
      }).toList();

      if (!mounted) return;

      setState(() {
        searchResults = results;
      });

      if (results.isEmpty) {
        _showMessage(
          '${t('no_result')}: "$query"',
        );
      }
    } else {
      throw Exception(
        'Backend search lỗi ${response.statusCode}: ${response.body}',
      );
    }
  } catch (e) {
    debugPrint(
      'Backend search error: $e',
    );

    if (!mounted) return;

    setState(() {
      searchResults = [];
    });

    _showMessage(
      '${t('search_error')}: $e',
    );
  } finally {
    if (mounted) {
      setState(() {
        isSearching = false;
      });
    }
  }
}

  // ==========================================================
  // CHỌN KẾT QUẢ TÌM KIẾM
  // ==========================================================

  void _selectSearchResult(
    Map<String, dynamic> result,
  ) {
    final LatLng point = LatLng(
      result['lat'],
      result['lon'],
    );

    final String fullAddress =
        result['name'].toString();

    final String shortName =
        fullAddress.split(',').first.trim();

    final Map<String, dynamic> place = {
      'name': shortName,
      'point': point,
      'address': fullAddress,
      'rating': 0.0,
      'price': 'Chưa có thông tin',
      'category': 'Địa điểm',
    };

    setState(() {
      currentDestination = place;

      _toController.text =
          shortName;

      searchResults = [];
    });

    activeDestinationNotifier.value =
        place;

    _mapController.move(
      point,
      16.0,
    );

    fetchRoute();
  }

  // ==========================================================
  // GEOCODING CHO ĐIỂM XUẤT PHÁT
  // ==========================================================

Future<LatLng?> _geocodePlace(
  String text,
) async {
  final query = text.trim();

  if (query.isEmpty) {
    return null;
  }

  try {
    final uri = Uri.parse(
      'http://localhost:8080/search?q=${Uri.encodeQueryComponent(query)}',
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      debugPrint(
        'Backend geocoding error: '
        '${response.statusCode} ${response.body}',
      );
      return null;
    }

    final dynamic decoded = json.decode(response.body);

    if (decoded is! List || decoded.isEmpty) {
      return null;
    }

    final firstResult = decoded.first;

    final double? lat = double.tryParse(
      firstResult['lat']?.toString() ?? '',
    );

    final double? lon = double.tryParse(
      firstResult['lon']?.toString() ?? '',
    );

    if (lat == null || lon == null) {
      return null;
    }

    return LatLng(lat, lon);
  } catch (e) {
    debugPrint(
      'Backend geocoding error: $e',
    );

    return null;
  }
}

  // ==========================================================
  // XỬ LÝ ĐIỂM XUẤT PHÁT
  // ==========================================================

  Future<void> _parseStartPoint(
    String text,
  ) async {
    final query = text.trim();

    if (query.isEmpty) return;

    // --------------------------------------------------------
    // TRƯỜNG HỢP 1: NHẬP TỌA ĐỘ
    // Ví dụ: 21.0285, 105.8542
    // --------------------------------------------------------

    try {
      final parts = query.split(',');

      if (parts.length >= 2) {
        final double lat =
            double.parse(parts[0].trim());

        final double lon =
            double.parse(parts[1].trim());

        setState(() {
          startPoint =
              LatLng(lat, lon);
        });

        _mapController.move(
          startPoint,
          14.0,
        );

        fetchRoute();

        return;
      }
    } catch (_) {}

    // --------------------------------------------------------
    // TRƯỜNG HỢP 2: NHẬP TÊN ĐỊA ĐIỂM
    // --------------------------------------------------------

    setState(() {
      routeInfo =
          "Đang tìm điểm xuất phát...";
    });

    final LatLng? point =
        await _geocodePlace(query);

    if (point == null) {
      setState(() {
        routeInfo =
            'Không tìm thấy địa điểm "$query"';
      });

      return;
    }

    setState(() {
      startPoint = point;
    });

    _mapController.move(
      point,
      14.0,
    );

    fetchRoute();
  }

  // ==========================================================
  // ROUTING GRAPHOPPER
  // ==========================================================

  Future<void> fetchRoute() async {
    final LatLng endPoint =
        currentDestination['point'];

    final url = Uri.parse(
      'http://localhost:8080/route'
      '?fromLat=${startPoint.latitude}'
      '&fromLon=${startPoint.longitude}'
      '&toLat=${endPoint.latitude}'
      '&toLon=${endPoint.longitude}',
    );

    try {
      if (!mounted) return;

      setState(() {
        routeInfo =
            "Đang kết nối Server Java Offline ($selectedTransport)...";
      });

      final response =
          await http.get(url);

      if (response.statusCode == 200) {
        final data =
            json.decode(response.body);

        List coords =
            data['coordinates'];

        double distance =
            (data['distance_meters'] as num)
                .toDouble();

        double time =
            (data['time_seconds'] as num)
                .toDouble();

        // ----------------------------------------------------
        // GIỮ NGUYÊN LOGIC PHƯƠNG TIỆN CŨ CỦA M
        // ----------------------------------------------------

        if (selectedTransport ==
            'bike') {
          time = time * 0.8;
        }

        if (selectedTransport ==
            'walk') {
          time = time * 3.5;
        }

        if (!mounted) return;

        setState(() {
          routePoints =
              coords.map<LatLng>((c) {
            return LatLng(
              (c[0] as num).toDouble(),
              (c[1] as num).toDouble(),
            );
          }).toList();

          routeInfo =
              "Khoảng cách: "
              "${(distance / 1000).toStringAsFixed(2)} km"
              "  •  "
              "Thời gian: "
              "${(time / 60).toStringAsFixed(1)} phút";
        });
      } else {
        if (!mounted) return;

        setState(() {
          routeInfo =
              "Lỗi server: ${response.body}";
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        routeInfo =
            "Không kết nối được Backend Java: $e";
      });
    }
  }

  // ==========================================================
  // POPUP ĐỊA ĐIỂM
  // ==========================================================

  void _showPlacePopup(
    Map<String, dynamic> place,
  ) {
    showModalBottomSheet(
      context: context,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      place['name'],
                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                    ),
                    onPressed: () =>
                        Navigator.pop(
                      context,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    '${place['rating']} • ${place['price']}',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Địa chỉ: ${place['address']}',
                style:
                    const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton.icon(
                      style:
                          OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        if (!savedPlaces
                            .any(
                          (p) =>
                              p['name'] ==
                              place['name'],
                        )) {
                          setState(() {
                            savedPlaces
                                .add(
                              place,
                            );
                          });
                        }

                        Navigator.pop(
                          context,
                        );

                        ScaffoldMessenger
                            .of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              t('saved_success'),
                            ),
                          ),
                        );
                      },
                      icon:
                          const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      label: Text(
                        t('save_place'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child:
                        ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );

                        activeDestinationNotifier
                                .value =
                            place;
                      },
                      icon:
                          const Icon(
                        Icons.directions,
                      ),
                      label: Text(
                        t('directions'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // BUILD MAP
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    List<Map<String, dynamic>>
        filteredSuggestions =
        suggestions;

    if (selectedFilter !=
        t('all')) {
      String cat =
          (selectedFilter ==
                  t('entertainment'))
              ? 'Vui chơi'
              : 'Quán ăn';

      filteredSuggestions =
          suggestions
              .where(
                (p) =>
                    p['category'] ==
                    cat,
              )
              .toList();
    }

    return Scaffold(
      body: Stack(
        children: [
          // ==================================================
          // MAP
          // ==================================================

          FlutterMap(
            mapController:
                _mapController,
            options: MapOptions(
              initialCenter:
                  currentDestination[
                      'point'],
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const [
                  'a',
                  'b',
                  'c',
                  'd',
                ],
              ),

              // ----------------------------------------------
              // ROUTE
              // ----------------------------------------------

              PolylineLayer(
                polylines: [
                  Polyline(
                    points:
                        routePoints,
                    color:
                        Colors.blue,
                    strokeWidth:
                        5.0,
                  ),
                ],
              ),

              // ----------------------------------------------
              // MARKERS
              // ----------------------------------------------

              MarkerLayer(
                markers: [
                  Marker(
                    point:
                        startPoint,
                    width: 40,
                    height: 40,
                    child:
                        const Icon(
                      Icons.my_location,
                      color:
                          Colors.green,
                      size: 35,
                    ),
                  ),

                  ...filteredSuggestions
                      .map(
                    (place) =>
                        Marker(
                      point:
                          place['point'],
                      width: 40,
                      height: 40,
                      child:
                          GestureDetector(
                        onTap: () =>
                            _showPlacePopup(
                          place,
                        ),
                        child:
                            Icon(
                          place['category'] ==
                                  'Quán ăn'
                              ? Icons
                                  .restaurant
                              : Icons.place,
                          color: place[
                                      'name'] ==
                                  currentDestination[
                                      'name']
                              ? Colors
                                  .red
                              : Colors
                                  .orange,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ==================================================
          // KHUNG TÌM KIẾM
          // ==================================================

          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Card(
              elevation: 6,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  12.0,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    // ----------------------------------------
                    // PHƯƠNG TIỆN
                    // ----------------------------------------

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceAround,
                      children: [
                        _buildTransportIcon(
                          'car',
                          Icons
                              .directions_car,
                          t('car'),
                        ),
                        _buildTransportIcon(
                          'bike',
                          Icons
                              .two_wheeler,
                          t('bike'),
                        ),
                        _buildTransportIcon(
                          'walk',
                          Icons
                              .directions_walk,
                          t('walk'),
                        ),
                      ],
                    ),

                    const Divider(
                      height: 16,
                    ),

                    // ========================================
                    // ĐIỂM XUẤT PHÁT
                    // ========================================

                    TextField(
                      controller:
                          _fromController,
                      decoration:
                          InputDecoration(
                        prefixIcon:
                            const Icon(
                          Icons
                              .trip_origin,
                          color:
                              Colors.green,
                          size: 20,
                        ),
                        labelText:
                            t(
                          'from_placeholder',
                        ),
                        border:
                            const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted:
                          (value) {
                        _parseStartPoint(
                          value,
                        );
                      },
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    // ========================================
                    // ĐIỂM ĐẾN
                    // ========================================

                    TextField(
                      controller:
                          _toController,
                      decoration:
                          InputDecoration(
                        prefixIcon:
                            const Icon(
                          Icons
                              .location_on,
                          color:
                              Colors.red,
                          size: 20,
                        ),

                        // ------------------------------------
                        // ICON SEARCH / LOADING
                        // ------------------------------------

                        suffixIcon:
                            isSearching
                                ? const Padding(
                                    padding:
                                        EdgeInsets.all(
                                      12,
                                    ),
                                    child:
                                        SizedBox(
                                      width:
                                          18,
                                      height:
                                          18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon:
                                        const Icon(
                                      Icons.search,
                                    ),
                                    onPressed:
                                        () {
                                      _searchDestination(
                                        _toController
                                            .text,
                                      );
                                    },
                                  ),

                        labelText:
                            t(
                          'to_placeholder',
                        ),
                        border:
                            const OutlineInputBorder(),
                        isDense: true,
                      ),

                      // --------------------------------------
                      // ENTER ĐỂ TÌM
                      // --------------------------------------

                      onSubmitted:
                          (value) {
                        _searchDestination(
                          value,
                        );
                      },
                    ),

                    // ==================================================
                    // KẾT QUẢ TÌM KIẾM
                    // ==================================================

                    if (searchResults
                        .isNotEmpty)
                      Container(
                        margin:
                            const EdgeInsets
                                .only(
                          top: 8,
                        ),
                        constraints:
                            const BoxConstraints(
                          maxHeight:
                              250,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                          border:
                              Border.all(
                            color: Colors
                                .grey
                                .shade300,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .black
                                  .withOpacity(
                                0.08,
                              ),
                              blurRadius:
                                  8,
                              offset:
                                  const Offset(
                                0,
                                3,
                              ),
                            ),
                          ],
                        ),
                        child:
                            ListView.builder(
                          shrinkWrap:
                              true,
                          itemCount:
                              searchResults
                                  .length,
                          itemBuilder:
                              (context,
                                  index) {
                            final result =
                                searchResults[
                                    index];

                            final String
                                fullName =
                                result[
                                        'name']
                                    .toString();

                            final String
                                shortName =
                                fullName
                                    .split(
                                        ',')
                                    .first
                                    .trim();

                            return ListTile(
                              dense:
                                  true,

                              leading:
                                  const Icon(
                                Icons
                                    .location_on,
                                color:
                                    Colors.red,
                              ),

                              title:
                                  Text(
                                shortName,
                                maxLines:
                                    1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),

                              subtitle:
                                  Text(
                                fullName,
                                maxLines:
                                    2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      11,
                                  color:
                                      Colors.grey,
                                ),
                              ),

                              onTap:
                                  () {
                                _selectSearchResult(
                                  result,
                                );
                              },
                            );
                          },
                        ),
                      ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================================================
                    // FILTER
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        _buildFilterChip(
                          t('all'),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        _buildFilterChip(
                          t(
                            'entertainment',
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        _buildFilterChip(
                          t('food'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================
          // ROUTE INFO
          // ==================================================

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 6,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16.0,
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedTransport ==
                              'car'
                          ? Icons
                              .directions_car
                          : (selectedTransport ==
                                  'bike'
                              ? Icons
                                  .two_wheeler
                              : Icons
                                  .directions_walk),
                      color:
                          Colors.green,
                      size: 28,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Text(
                            currentDestination[
                                'name'],
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            routeInfo,
                            style:
                                const TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey,
                            ),
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
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

  // ==========================================================
  // TRANSPORT BUTTON
  // ==========================================================

  Widget _buildTransportIcon(
    String type,
    IconData icon,
    String label,
  ) {
    bool isSelected =
        selectedTransport == type;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTransport = type;
        });

        fetchRoute();
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration:
            BoxDecoration(
          color: isSelected
              ? Colors.green.shade50
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.green
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.green
                  : Colors.grey,
              size: 22,
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w500,
                color: isSelected
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  Widget _buildFilterChip(
    String label,
  ) {
    bool isSelected =
        selectedFilter == label;

    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration:
            BoxDecoration(
          color: isSelected
              ? Colors.black87
              : Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color:
                Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.black87,
            fontSize: 11,
            fontWeight:
                FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

// ============================================================
// SAVED PLACES
// ============================================================

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() =>
      _SavedPlacesScreenState();
}

class _SavedPlacesScreenState
    extends State<SavedPlacesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('saved')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: savedPlaces.isEmpty
          ? Center(
              child: Text(
                'Chưa có địa điểm nào được lưu.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount:
                  savedPlaces.length,
              itemBuilder:
                  (context, index) {
                var place =
                    savedPlaces[index];

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: ListTile(
                    leading:
                        const CircleAvatar(
                      backgroundColor:
                          Colors.green,
                      child: Icon(
                        Icons.favorite,
                        color:
                            Colors.white,
                      ),
                    ),
                    title: Text(
                      place['name'],
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    subtitle:
                        Text(
                      place['address'],
                    ),
                    trailing:
                        IconButton(
                      icon:
                          const Icon(
                        Icons.delete,
                        color:
                            Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          savedPlaces
                              .removeAt(
                            index,
                          );
                        });
                      },
                    ),
                    onTap: () {
                      activeDestinationNotifier
                              .value =
                          place;

                      final navState =
                          context.findAncestorStateOfType<
                              _MainNavigationScreenState>();

                      if (navState !=
                          null) {
                        navState
                            .setState(
                          () {},
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfileScreen
    extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  Future<void> _pickAvatar() async {
    final ImagePicker picker =
        ImagePicker();

    final XFile? image =
        await picker.pickImage(
      source:
          ImageSource.gallery,
    );

    if (image != null) {
      Uint8List bytes =
          await image.readAsBytes();

      userAvatarNotifier.value =
          bytes;
    }
  }

  void _showLanguageDialog(
      BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
        title: Text(
          t('language'),
        ),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            ListTile(
              title:
                  const Text(
                'Tiếng Việt',
              ),
              onTap: () =>
                  _confirmAndChangeLang(
                context,
                'vi',
              ),
            ),
            ListTile(
              title:
                  const Text(
                'English',
              ),
              onTap: () =>
                  _confirmAndChangeLang(
                context,
                'en',
              ),
            ),
            ListTile(
              title:
                  const Text(
                '中文 (Chinese)',
              ),
              onTap: () =>
                  _confirmAndChangeLang(
                context,
                'zh',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAndChangeLang(
    BuildContext context,
    String newLang,
  ) {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
        title: Text(
          t('lang_confirm_title'),
        ),
        content: Text(
          t('lang_confirm_content'),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
            ),
            child:
                Text(t('no')),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.green,
              foregroundColor:
                  Colors.white,
            ),
            onPressed: () {
              currentLangNotifier
                  .value = newLang;

              Navigator.pop(
                context,
              );

              setState(() {});
            },
            child:
                Text(t('yes')),
          ),
        ],
      ),
    );
  }

  void _showEditProfileModal(
      BuildContext context) {
    TextEditingController
        nameController =
        TextEditingController(
      text: userNameNotifier.value,
    );

    TextEditingController
        emailController =
        TextEditingController(
      text:
          userEmailNotifier.value,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) =>
          Padding(
        padding:
            EdgeInsets.only(
          bottom: MediaQuery.of(
                  context)
              .viewInsets
              .bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  t('edit_profile'),
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(
                    Icons.close,
                  ),
                  onPressed: () =>
                      Navigator.pop(
                    context,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              controller:
                  nameController,
              decoration:
                  InputDecoration(
                labelText:
                    t('name_label'),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller:
                  emailController,
              decoration:
                  InputDecoration(
                labelText:
                    t('email_label'),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 14,
                  ),
                ),
                onPressed: () {
                  userNameNotifier
                          .value =
                      nameController
                          .text;

                  userEmailNotifier
                          .value =
                      emailController
                          .text;

                  Navigator.pop(
                    context,
                  );

                  setState(() {});
                },
                child: Text(
                  t('save_changes'),
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return SafeArea(
      child: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          Text(
            t('profile'),
            style:
                const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Stack(
                children: [
                  ValueListenableBuilder<
                      Uint8List?>(
                    valueListenable:
                        userAvatarNotifier,
                    builder: (
                      context,
                      avatarBytes,
                      child,
                    ) {
                      return CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            Colors.purple,
                        backgroundImage:
                            avatarBytes !=
                                    null
                                ? MemoryImage(
                                    avatarBytes)
                                : null,
                        child:
                            avatarBytes ==
                                    null
                                ? const Text(
                                    'MC',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize:
                                          22,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  )
                                : null,
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child:
                        InkWell(
                      onTap:
                          _pickAvatar,
                      child:
                          const CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            Colors.white,
                        child:
                            Icon(
                          Icons
                              .camera_alt,
                          size: 14,
                          color:
                              Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 16,
              ),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  ValueListenableBuilder<
                      String>(
                    valueListenable:
                        userNameNotifier,
                    builder: (
                      context,
                      name,
                      child,
                    ) {
                      return Text(
                        name,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<
                      String>(
                    valueListenable:
                        userEmailNotifier,
                    builder: (
                      context,
                      email,
                      child,
                    ) {
                      return Text(
                        email,
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.grey
                              .shade200,
                      foregroundColor:
                          Colors.black87,
                      elevation: 0,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            12,
                        vertical:
                            4,
                      ),
                    ),
                    onPressed: () =>
                        _showEditProfileModal(
                      context,
                    ),
                    child: Text(
                      t('edit_profile'),
                      style:
                          const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          _buildMenuItem(
            context,
            Icons.language,
            t('language'),
            onTap: () =>
                _showLanguageDialog(
              context,
            ),
          ),
          _buildMenuItem(
            context,
            Icons.logout,
            t('logout'),
            isLogout: true,
            onTap: () {
              isLoggedInNotifier
                  .value = false;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      decoration:
          BoxDecoration(
        color: isLogout
            ? Colors.red.shade50
            : const Color(
                0xFFE8F5E9,
              ),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout
              ? Colors.red
              : Colors.green,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight:
                FontWeight.w500,
            color: isLogout
                ? Colors.red
                : Colors.black87,
          ),
        ),
        trailing:
            const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================
// AI CHAT
// ============================================================

class AiChatScreen
    extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() =>
      _AiChatScreenState();
}

class _AiChatScreenState
    extends State<AiChatScreen> {
  final TextEditingController
      _controller =
      TextEditingController();

  final List<
      Map<String, String>> _messages = [
    {
      "sender": "ai",
      "text":
          "Xin chào! Tôi là VietGo AI Guide. Bạn muốn tìm hiểu thông tin du lịch hoặc quán ăn nào?"
    }
  ];

  bool _isLoading = false;

  // ==========================================================
  // GEMINI API
  // ==========================================================

  Future<void> _callGeminiApi(
    String prompt,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      const String apiKey =
          "YOUR_GEMINI_API_KEY";

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );

      final response =
          await http.post(
        url,
        headers: {
          'Content-Type':
              'application/json',
        },
        body: json.encode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Bạn là trợ lý du lịch AI VietGo. Hãy trả lời ngắn gọn: $prompt"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode ==
          200) {
        final data =
            json.decode(
          response.body,
        );

        String aiReply =
            data['candidates'][0]
                ['content']['parts'][0]
                ['text'];

        setState(() {
          _messages.add({
            "sender": "ai",
            "text": aiReply,
          });
        });
      } else {
        final localUrl =
            Uri.parse(
          'http://localhost:8080/ai-chat',
        );

        final localRes =
            await http.post(
          localUrl,
          headers: {
            'Content-Type':
                'application/json',
          },
          body: json.encode({
            'message': prompt,
          }),
        );

        if (localRes.statusCode ==
            200) {
          final localData =
              json.decode(
            localRes.body,
          );

          setState(() {
            _messages.add({
              "sender": "ai",
              "text":
                  localData['reply'],
            });
          });
        } else {
          setState(() {
            _messages.add({
              "sender": "ai",
              "text":
                  "AI gợi ý: Hãy khám phá các quán ăn và điểm vui chơi trên bản đồ offline của VietGo!",
            });
          });
        }
      }
    } catch (_) {
      setState(() {
        _messages.add({
          "sender": "ai",
          "text":
              "AI phản hồi: Du lịch Việt Nam rất phong phú. Bạn hãy chọn điểm đến trên bản đồ nhé!",
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendMessage() {
    if (_controller.text
        .trim()
        .isEmpty) {
      return;
    }

    String userText =
        _controller.text;

    setState(() {
      _messages.add({
        "sender": "user",
        "text": userText,
      });

      _controller.clear();
    });

    _callGeminiApi(userText);
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VietGo AI Guide',
        ),
        backgroundColor:
            Colors.white,
        foregroundColor:
            Colors.black87,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                ListView.builder(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              itemCount:
                  _messages.length,
              itemBuilder:
                  (context, index) {
                bool isUser =
                    _messages[index]
                            ['sender'] ==
                        'user';

                return Align(
                  alignment:
                      isUser
                          ? Alignment
                              .centerRight
                          : Alignment
                              .centerLeft,
                  child:
                      Container(
                    margin:
                        const EdgeInsets
                            .symmetric(
                      vertical: 4,
                    ),
                    padding:
                        const EdgeInsets
                            .all(
                      12,
                    ),
                    decoration:
                        BoxDecoration(
                      color: isUser
                          ? Colors
                              .green
                          : Colors
                              .grey
                              .shade200,
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                    child:
                        Text(
                      _messages[
                          index]['text']!,
                      style:
                          TextStyle(
                        color: isUser
                            ? Colors
                                .white
                            : Colors
                                .black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding:
                  EdgeInsets.all(8.0),
              child:
                  LinearProgressIndicator(
                color:
                    Colors.green,
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.all(
              8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child:
                      TextField(
                    controller:
                        _controller,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Hỏi VietGo bất cứ điều gì...',
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          24,
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            16,
                      ),
                    ),
                    onSubmitted:
                        (_) =>
                            _sendMessage(),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                CircleAvatar(
                  backgroundColor:
                      Colors.green,
                  child:
                      IconButton(
                    icon:
                        const Icon(
                      Icons.send,
                      color:
                          Colors.white,
                      size: 18,
                    ),
                    onPressed:
                        _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}