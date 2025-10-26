class Movie {
  final String id;
  final String title;
  final String genre;
  final double rating;
  final int year;
  final String imageColor;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final List<int>? genreIds;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.rating,
    required this.year,
    required this.imageColor,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.genreIds,
  });

  // Factory constructor to create Movie from TMDB API response
  factory Movie.fromJson(Map<String, dynamic> json) {
    // Extract year from release_date
    int year = 0;
    if (json['release_date'] != null && json['release_date'].isNotEmpty) {
      try {
        year = int.parse(json['release_date'].split('-')[0]);
      } catch (e) {
        year = 0;
      }
    }

    // Map genre IDs to genre names
    String genre = _getGenreFromIds(json['genre_ids'] ?? []);

    // Generate a color from the poster path or use a default
    String imageColor = _generateColorFromPath(json['poster_path'] ?? '');

    return Movie(
      id: json['id'].toString(),
      title: json['title'] ?? json['original_title'] ?? 'Unknown',
      genre: genre,
      rating: (json['vote_average'] ?? 0.0).toDouble(),
      year: year,
      imageColor: imageColor,
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'],
      genreIds: (json['genre_ids'] as List<dynamic>?)?.cast<int>(),
    );
  }

  // Convert Movie to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'vote_average': rating,
      'release_date': '$year-01-01',
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'overview': overview,
      'genre_ids': genreIds,
    };
  }

  // Helper method to map genre IDs to genre names
  static String _getGenreFromIds(List<dynamic> genreIds) {
    if (genreIds.isEmpty) return 'Unknown';
    
    // TMDB Genre IDs mapping
    const genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };

    int firstGenreId = genreIds[0] as int;
    return genreMap[firstGenreId] ?? 'Unknown';
  }

  // Generate a color hex from poster path
  static String _generateColorFromPath(String path) {
    if (path.isEmpty) return 'FF6366F1';
    
    // Use hash code of path to generate consistent color
    final hash = path.hashCode.abs();
    final colors = [
      'FF9800', 'E91E63', '424242', 'FFEB3B', '795548',
      '5D4037', 'D32F2F', '607D8B', '1A237E', 'E0E0E0',
      'C62828', '546E7A', 'FF6F00', '37474F', '212121',
      '4CAF50', '1B5E20', '6D4C41', '6366F1', 'A78BFA',
    ];
    return colors[hash % colors.length];
  }

  // Sample data for development/fallback
  static List<Movie> trendingMovies = [
    Movie(
      id: '1',
      title: 'Dune: Part Two',
      genre: 'Sci-Fi',
      rating: 8.7,
      year: 2024,
      imageColor: 'FF9800',
    ),
    Movie(
      id: '2',
      title: 'Oppenheimer',
      genre: 'Biography',
      rating: 8.5,
      year: 2023,
      imageColor: 'E91E63',
    ),
    Movie(
      id: '3',
      title: 'The Batman',
      genre: 'Action',
      rating: 7.9,
      year: 2022,
      imageColor: '424242',
    ),
    Movie(
      id: '4',
      title: 'Poor Things',
      genre: 'Comedy',
      rating: 8.1,
      year: 2023,
      imageColor: 'FFEB3B',
    ),
    Movie(
      id: '5',
      title: 'Demon Slayer',
      genre: 'Drama',
      rating: 7.8,
      year: 2023,
      imageColor: '795548',
    ),
  ];

  static List<Movie> topRatedMovies = [
    Movie(
      id: '6',
      title: 'The Godfather',
      genre: 'Crime',
      rating: 9.2,
      year: 1972,
      imageColor: '5D4037',
    ),
    Movie(
      id: '7',
      title: 'Pulp Fiction',
      genre: 'Crime',
      rating: 8.9,
      year: 1994,
      imageColor: 'D32F2F',
    ),
    Movie(
      id: '8',
      title: 'Inception',
      genre: 'Sci-Fi',
      rating: 8.8,
      year: 2010,
      imageColor: '607D8B',
    ),
    Movie(
      id: '9',
      title: 'Interstellar',
      genre: 'Sci-Fi',
      rating: 8.7,
      year: 2014,
      imageColor: '1A237E',
    ),
  ];

  static List<Movie> recommendedMovies = [
    Movie(
      id: '10',
      title: 'Everything Everywhere All at Once',
      genre: 'Action',
      rating: 8.0,
      year: 2022,
      imageColor: 'E0E0E0',
    ),
    Movie(
      id: '11',
      title: 'Parasite',
      genre: 'Thriller',
      rating: 8.6,
      year: 2019,
      imageColor: 'C62828',
    ),
    Movie(
      id: '12',
      title: 'The Truman Show',
      genre: 'Drama',
      rating: 8.2,
      year: 1998,
      imageColor: '546E7A',
    ),
    Movie(
      id: '13',
      title: 'Blade Runner 2049',
      genre: 'Sci-Fi',
      rating: 8.0,
      year: 2017,
      imageColor: 'FF6F00',
    ),
  ];

  static List<Movie> watchlist = [
    Movie(
      id: '14',
      title: 'The Shawshank Redemption',
      genre: 'Drama',
      rating: 9.3,
      year: 1994,
      imageColor: '37474F',
    ),
    Movie(
      id: '15',
      title: 'The Dark Knight',
      genre: 'Action',
      rating: 9.0,
      year: 2008,
      imageColor: '212121',
    ),
    Movie(
      id: '16',
      title: 'Forrest Gump',
      genre: 'Drama',
      rating: 8.8,
      year: 1994,
      imageColor: '4CAF50',
    ),
    Movie(
      id: '17',
      title: 'The Matrix',
      genre: 'Sci-Fi',
      rating: 8.7,
      year: 1999,
      imageColor: '1B5E20',
    ),
    Movie(
      id: '18',
      title: 'Goodfellas',
      genre: 'Crime',
      rating: 8.7,
      year: 1990,
      imageColor: '6D4C41',
    ),
  ];
}