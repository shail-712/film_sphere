import 'package:flutter/material.dart';
import '../widget/stat_card.dart';
import '../models/movie.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F0F),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.3),
                      const Color(0xFF0F0F0F),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6366F1),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Center(
                        child: Text(
                          'SS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Shail Shaji',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@shailshaji',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                onPressed: () {},
              ),
            ],
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  StatCard(
                    icon: Icons.movie_rounded,
                    value: '247',
                    label: 'Watched',
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    icon: Icons.star_rounded,
                    value: '4.3',
                    label: 'Avg Rating',
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    icon: Icons.people_rounded,
                    value: '156',
                    label: 'Friends',
                  ),
                ],
              ),
            ),
          ),

          // Bio Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Movie enthusiast | Sci-Fi lover | Always up for a good thriller',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Recent Activity
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('View All')),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildActivityItem(
                  Movie.watchlist[index].title,
                  '5 stars',
                  Icons.star_rounded,
                  Colors.amber,
                );
              },
              childCount: Movie.watchlist.length > 3
                  ? 3
                  : Movie.watchlist.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Favorite Genres
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Favorite Genres',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildGenreChip('Sci-Fi'),
                      _buildGenreChip('Thriller'),
                      _buildGenreChip('Drama'),
                      _buildGenreChip('Action'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Settings Options
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildSettingOption(
                    Icons.person_outline_rounded,
                    'Edit Profile',
                  ),
                  _buildSettingOption(Icons.privacy_tip_outlined, 'Privacy'),
                  _buildSettingOption(
                    Icons.notifications_outlined,
                    'Notifications',
                  ),
                  _buildSettingOption(
                    Icons.help_outline_rounded,
                    'Help & Support',
                  ),
                  _buildSettingOption(
                    Icons.logout_rounded,
                    'Logout',
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String action,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  action,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '2d ago',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6366F1),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSettingOption(
    IconData icon,
    String label, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF6366F1),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.white.withOpacity(0.3),
        ),
        onTap: () {},
      ),
    );
  }
}
