class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';
  
  // Image Sizes
  static const String posterSizeSmall = '/w185';
  static const String posterSizeMedium = '/w342';
  static const String posterSizeLarge = '/w500';
  static const String posterSizeOriginal = '/original';
  
  static const String backdropSizeSmall = '/w300';
  static const String backdropSizeMedium = '/w780';
  static const String backdropSizeLarge = '/w1280';
  static const String backdropSizeOriginal = '/original';
  
  // Endpoints
  static const String trendingMovies = '/trending/movie';
  static const String popularMovies = '/movie/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String upcomingMovies = '/movie/upcoming';
  static const String searchMovie = '/search/movie';
  static const String movieDetails = '/movie';
  static const String movieCredits = '/movie/{movie_id}/credits';
  static const String similarMovies = '/movie/{movie_id}/similar';
  static const String movieRecommendations = '/movie/{movie_id}/recommendations';
  
  // Helper method to build image URL
  static String getImageUrl(String path, {String size = posterSizeMedium}) {
    if (path.isEmpty) return '';
    return '$imageBaseUrl$size$path';
  }
  
  // Helper method to get poster URL
  static String getPosterUrl(String? path, {bool isLarge = false}) {
    if (path == null || path.isEmpty) return '';
    final size = isLarge ? posterSizeLarge : posterSizeMedium;
    return '$imageBaseUrl$size$path';
  }
  
  // Helper method to get backdrop URL
  static String getBackdropUrl(String? path, {bool isLarge = false}) {
    if (path == null || path.isEmpty) return '';
    final size = isLarge ? backdropSizeLarge : backdropSizeMedium;
    return '$imageBaseUrl$size$path';
  }
}