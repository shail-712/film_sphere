class Movie {
  final String id;
  final String title;
  final String genre;
  final double rating;
  final int year;
  final String imageColor;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.rating,
    required this.year,
    required this.imageColor,
  });

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
