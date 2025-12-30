import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../data/services/theme_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildProfileHeader(context, isDark),
                    const SizedBox(height: 24),
                    _buildStatsGrid(context, isDark),
                    const SizedBox(height: 32),
                    _buildAchievementsCarousel(context, isDark),
                    const SizedBox(height: 32),
                    _buildSettingsSection(context, themeService, isDark),
                    const SizedBox(height: 32),
                    AppButton(
                      text: 'Logout',
                      onPressed: () => _handleLogout(),
                      color: Colors.redAccent,
                      icon: Icons.logout_rounded,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      title: const Text('Profile'),
      actions: [
        IconButton(
          onPressed: () => Get.toNamed('/notifications'),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => _showSettingsBottomSheet(context, Get.find()),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark) {
    final user = controller.user.value;
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                child: user?.profilePic == null
                    ? Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showEditProfileDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? 'User',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (user?.bio != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              user!.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isDark) {
    final stats = controller.user.value?.stats;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          'Streak',
          '${stats?.consecutiveDays ?? 0} Days',
          Icons.local_fire_department_rounded,
          Colors.orange,
        ),
        _buildStatCard(
          context,
          'Total XP',
          '${stats?.totalXP ?? 0}',
          Icons.bolt_rounded,
          Colors.amber,
        ),
        _buildStatCard(
          context,
          'Completed',
          '${stats?.completedCourses ?? 0}',
          Icons.check_circle_rounded,
          Colors.green,
        ),
        _buildStatCard(
          context,
          'Studying',
          '${stats?.totalHours ?? 0}h',
          Icons.timer_rounded,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAchievementsCarousel(BuildContext context, bool isDark) {
    final badges = controller.user.value?.stats?.badges ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badges[index],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    ThemeService themeService,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildSettingTile(
                context,
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Obx(
                  () => Switch(
                    value: themeService.isDarkMode(),
                    onChanged: (val) => themeService.changeThemeMode(val),
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                context,
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () => Get.toNamed('/notifications'),
                trailing: Obx(
                  () => Switch(
                    value: Get.find<NotificationService>().isEnabled.value,
                    onChanged: (val) => Get.find<NotificationService>()
                        .toggleNotifications(val),
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                context,
                icon: Icons.security_rounded,
                title: 'Privacy & Security',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildSettingTile(
                context,
                icon: Icons.language_rounded,
                title: 'Language',
                onTap: () {},
                trailing: const Text(
                  'English',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                context,
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }

  void _handleLogout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Logout',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        // Handle actual logout logic
        Get.back();
      },
    );
  }

  void _showSettingsBottomSheet(
    BuildContext context,
    ThemeService themeService,
  ) {}

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: controller.user.value?.name,
    );
    final bioController = TextEditingController(
      text: controller.user.value?.bio,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.updateProfile(
                name: nameController.text,
                bio: bioController.text,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
