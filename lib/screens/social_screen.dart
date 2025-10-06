import 'package:flutter/material.dart';
import '../widget/activity_card.dart';
import '../widget/friend_card.dart';
import '../models/activity.dart';
import '../models/user.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({Key? key}) : super(key: key);

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Social',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.chat_rounded), onPressed: () {}),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Friends'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFeedTab(), _buildFriendsTab(), _buildDiscoverTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post Review'),
      ),
    );
  }

  Widget _buildFeedTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: Activity.recentActivities.length,
      itemBuilder: (context, index) {
        return ActivityCard(activity: Activity.recentActivities[index]);
      },
    );
  }

  Widget _buildFriendsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: User.friends.length,
      itemBuilder: (context, index) {
        return FriendCard(user: User.friends[index]);
      },
    );
  }

  Widget _buildDiscoverTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Suggested Friends',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...User.suggestedFriends.map(
          (user) => FriendCard(user: user, showFollowButton: true),
        ),
        const SizedBox(height: 32),
        const Text(
          'Popular Lists',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildPopularList(
          'Best Sci-Fi Movies of All Time',
          'Sarah Johnson',
          42,
        ),
        _buildPopularList('Hidden Gems You Must Watch', 'Mike Chen', 38),
        _buildPopularList('Weekend Binge-Worthy Series', 'Emma Davis', 29),
      ],
    );
  }

  Widget _buildPopularList(String title, String author, int likes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'by $author',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.favorite_rounded,
                size: 16,
                color: Colors.red.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                '$likes',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
