class Activity {
  final String id;
  final String userName;
  final String userInitials;
  final String action;
  final String movieTitle;
  final double? rating;
  final String? review;
  final String timeAgo;
  final int likes;
  final int comments;

  Activity({
    required this.id,
    required this.userName,
    required this.userInitials,
    required this.action,
    required this.movieTitle,
    this.rating,
    this.review,
    required this.timeAgo,
    required this.likes,
    required this.comments,
  });

  static List<Activity> recentActivities = [
    Activity(
      id: '1',
      userName: 'Sarah Johnson',
      userInitials: 'SJ',
      action: 'rated',
      movieTitle: 'Interstellar',
      rating: 5.0,
      review:
          'Absolutely mind-blowing! Nolan\'s masterpiece about love, time, and space. The visuals are stunning and the emotional depth is incredible.',
      timeAgo: '2 hours ago',
      likes: 24,
      comments: 8,
    ),
    Activity(
      id: '2',
      userName: 'Mike Chen',
      userInitials: 'MC',
      action: 'added to watchlist',
      movieTitle: 'Dune: Part Two',
      timeAgo: '5 hours ago',
      likes: 12,
      comments: 3,
    ),
    Activity(
      id: '3',
      userName: 'Emma Davis',
      userInitials: 'ED',
      action: 'rated',
      movieTitle: 'Poor Things',
      rating: 4.5,
      review:
          'Emma Stone delivers an outstanding performance. Visually stunning and darkly comedic. A unique cinematic experience!',
      timeAgo: '1 day ago',
      likes: 31,
      comments: 12,
    ),
    Activity(
      id: '4',
      userName: 'James Wilson',
      userInitials: 'JW',
      action: 'created a list',
      movieTitle: 'Best Thrillers of 2023',
      timeAgo: '1 day ago',
      likes: 18,
      comments: 5,
    ),
    Activity(
      id: '5',
      userName: 'Olivia Martinez',
      userInitials: 'OM',
      action: 'rated',
      movieTitle: 'Oppenheimer',
      rating: 5.0,
      review:
          'Cillian Murphy\'s performance is career-defining. The way Nolan tells this story is nothing short of brilliant.',
      timeAgo: '2 days ago',
      likes: 45,
      comments: 15,
    ),
  ];
}
