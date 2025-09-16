import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';
import 'package:serenityai/services/supabase_auth_service.dart';
import 'package:serenityai/services/user_profile_service.dart';
import './widgets/daily_checkin_card.dart';
import './widgets/progress_ring_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_activity_card.dart';
import './widgets/stress_level_card.dart';
import './widgets/todays_meditation_card.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _notificationCount = 3;
  bool _isRefreshing = false;
  bool _isLoading = true;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Real user data from Supabase
  Map<String, dynamic>? _userData;
  String _userFirstName = 'User';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserProfile();
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _fabAnimationController.forward();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Check if user is authenticated
      if (!SupabaseAuthService.isAuthenticated) {
        setState(() {
          _isLoading = false;
          _userFirstName = 'Guest';
        });
        return;
      }

      // Load user profile from Supabase
      final profile = await UserProfileService.getCurrentUserProfile();

      if (profile != null && mounted) {
        setState(() {
          _userData = profile;
          _userFirstName =
              UserProfileService.getFirstName(profile['full_name']);
          _isLoading = false;
        });
      } else {
        // Fallback to auth user data
        final user = SupabaseAuthService.currentUser;
        if (user != null && mounted) {
          setState(() {
            _userFirstName = UserProfileService.getFirstName(
                user.userMetadata?['full_name'] ??
                    user.email?.split('@').first ??
                    'User');
            _isLoading = false;
          });
        }
      }
    } catch (error) {
      print('Error loading user profile: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _userFirstName = 'User';
        });
      }
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Refresh user profile and data
    await _loadUserProfile();

    setState(() {
      _isRefreshing = false;
      // Update notification count or other data
      _notificationCount = _notificationCount > 0 ? _notificationCount - 1 : 3;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to different screens based on index
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/mood-tracking');
        break;
      case 2:
        Navigator.pushNamed(context, '/meditation-player');
        break;
      case 3:
        Navigator.pushNamed(context, '/user-profile');
        break;
    }
  }

  void _handleNotificationTap() {
    setState(() {
      _notificationCount = 0;
    });
    // Navigate to notifications screen or show notifications
  }

  void _handleMoodSelected() {
    // Update mood tracking logic
  }

  void _handleMilestoneReached() {
    // Show celebration dialog or animation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'celebration',
              color: AppTheme.lightTheme.colorScheme.tertiary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Congratulations!'),
          ],
        ),
        content: Text(
            'You\'ve reached your daily meditation goal! Keep up the great work.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _startQuickMeditation() {
    Navigator.pushNamed(context, '/meditation-player');
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomImageWidget(
            imageUrl:
                "https://images.pexels.com/photos/3822622/pexels-photo-3822622.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
            width: 60.w,
            height: 30.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 3.h),
          Text(
            'Start Your Wellness Journey',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Complete your first mood check-in or start a meditation session to begin tracking your progress.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: _startQuickMeditation,
            child: Text('Start First Meditation'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.colorScheme.primary,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()}, $_userFirstName!',
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              _getCurrentDate(),
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _handleNotificationTap,
                        child: Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppTheme.lightTheme.colorScheme.shadow,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CustomIconWidget(
                                iconName: 'notifications',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            if (_notificationCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(1.w),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.lightTheme.colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 5.w,
                                    minHeight: 5.w,
                                  ),
                                  child: Text(
                                    '$_notificationCount',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main content
              if (_isRefreshing)
                SliverToBoxAdapter(
                  child: Container(
                    height: 60.h,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                )
              else if (_userData == null ||
                  (_userData?['totalSessions'] ?? 0) == 0)
                SliverToBoxAdapter(
                  child: Container(
                    height: 60.h,
                    padding: EdgeInsets.all(4.w),
                    child: _buildEmptyState(),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildListDelegate([
                    // Daily Check-in Card
                    DailyCheckinCard(
                      onMoodSelected: _handleMoodSelected,
                    ),

                    // Today's Meditation Card
                    TodaysMeditationCard(
                      onPlayPressed: () {
                        Navigator.pushNamed(context, '/meditation-player');
                      },
                      onBookmark: () {
                        // Handle bookmark
                      },
                      onShare: () {
                        // Handle share
                      },
                    ),

                    // Progress Ring
                    ProgressRingWidget(
                      progress: _userData?['dailyGoalProgress'] ?? 0.0,
                      title: 'Daily Meditation Goal',
                      subtitle: '20 minutes of mindfulness practice',
                      onMilestoneReached: _handleMilestoneReached,
                    ),

                    // Stress Level Card
                    StressLevelCard(),

                    // Quick Actions
                    QuickActionsWidget(),

                    // Recent Activity Card
                    RecentActivityCard(),

                    // Bottom spacing
                    SizedBox(height: 10.h),
                  ]),
                ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentIndex == 0
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'mood',
              color: _currentIndex == 1
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Mood',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'self_improvement',
              color: _currentIndex == 2
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Meditate',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentIndex == 3
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton(
              onPressed: _startQuickMeditation,
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              child: CustomIconWidget(
                iconName: 'play_arrow',
                color: Colors.white,
                size: 28,
              ),
              tooltip: 'Quick Meditation',
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
