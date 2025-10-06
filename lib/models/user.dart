class User {
  final String id;
  final String name;
  final String username;
  final int moviesWatched;
  final int mutualFriends;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.moviesWatched,
    this.mutualFriends = 0,
  });

  static List<User> friends = [
    User(
      id: '1',
      name: 'Sarah Johnson',
      username: '@sarahj',
      moviesWatched: 342,
    ),
    User(id: '2', name: 'Mike Chen', username: '@mikechen', moviesWatched: 287),
    User(id: '3', name: 'Emma Davis', username: '@emmad', moviesWatched: 419),
    User(
      id: '4',
      name: 'James Wilson',
      username: '@jwilson',
      moviesWatched: 256,
    ),
  ];

  static List<User> suggestedFriends = [
    User(
      id: '5',
      name: 'Olivia Martinez',
      username: '@oliviam',
      moviesWatched: 198,
      mutualFriends: 12,
    ),
    User(
      id: '6',
      name: 'Noah Brown',
      username: '@noahb',
      moviesWatched: 234,
      mutualFriends: 8,
    ),
    User(
      id: '7',
      name: 'Ava Taylor',
      username: '@avataylor',
      moviesWatched: 167,
      mutualFriends: 15,
    ),
  ];
}
