import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';
import 'api_constants.dart';

class TMDBService {
  static final TMDBService _instance = TMDBService._internal();
  factory TMDBService() => _instance;
  TMDBService._internal();

  // Get API key from environment
  String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  
  // Base headers for requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Helper method to build URL with query parameters
  String _buildUrl(String endpoint, {Map<String, String>? queryParams}) {
    final params = {
      'api_key': _apiKey,
      'language': 'en-US',
      ...?queryParams,
    };
    
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return uri.replace(queryParameters: params).toString();
  }

  // Generic GET request handler
  Future<Map<String, dynamic>> _getRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Parse list of movies from API response
  List<Movie> _parseMovies(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>?;
    if (results == null) return [];
    
    return results.map((json) => Movie.fromJson(json)).toList();
  }

  // Fetch trending movies (day or week)
  Future<List<Movie>> getTrendingMovies({String timeWindow = 'day', int page = 1}) async {
    try {
      final url = _buildUrl(
        '${ApiConstants.trendingMovies}/$timeWindow',
        queryParams: {'page': page.toString()},
      );
      
      final data = await _getRequest(url);
      return _parseMovies(data);
    } catch (e) {
      print('Error fetching trending movies: $e');
      return Movie.trendingMovies; // Return fallback data
    }
  }

  // Fetch popular movies
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final url = _buildUrl(
        ApiConstants.popularMovies,
        queryParams: {'page': page.toString()},
      );
      
      final data = await _getRequest(url);
      return _parseMovies(data);
    } catch (e) {
      print('Error fetching popular movies: $e');
      return Movie.trendingMovies;
    }
  }

  // Fetch top rated movies
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    try {
      final url = _buildUrl(
        ApiConstants.topRatedMovies,
        queryParams: {'page': page.toString()},
      );
      
      final data = await _getRequest(url);
      return _parseMovies(data);
    } catch (e) {
      print('Error fetching top rated movies: $e');
      return Movie.topRatedMovies;
    }
  }

  // Fetch now playing movies
  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    try {
      final url = _buildUrl(
        ApiConstants.nowPlayingMovies,
        queryParams: {'page': page.toString()},
      );
      
      final data = await _getRequest(url);
      return _parseMovies(data);
    } catch (e) {
      print('Error fetching now playing movies: $e');
      return Movie.trendingMovies;
    }
  }

  // Fetch upcoming movies
  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    try {
      final url = _buildUrl(
        ApiConstants.upcomingMovies,
        queryParams: {'page': page.toString()},
      );
      
      final data = await _getRequest(url);
      return _parseMovies(data);
    } catch (e) {
      print('Error fetching upcoming movies: $e');
      return Movie.recommendedMovies;
    }
  }

  // Search movies
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final url = _buildUrl(
        ApiConstants.searchMovie,
        queryParams: {
          'query': query,
          'page': page.toString(),
          'include_adult': 'false',
        },
      );
      
      final data = await _getRequest(url);
      return _parseMovies(data);
    } catch (e) {
      print('Error searching movies: $e');
      return [];
    }
  }

  // Fetch movie details by ID
  Future<Map<String, dynamic>?> getMovieDetails(String movieId) async {
    try {
      final url = _buildUrl('${ApiConstants.movieDetails}/$movieId');
      return await _getRequest(url);
    } catch (e) {
      print('Error fetching movie details: $e');
      return null;
    }
  }

  // Fetch similar movies
  Future<List<Movie>> getSimilarMovies(String movieId, {int page = 1}) async {
    try {
      final url = _buildUrl(
        '${ApiConstants.movieDetails}/$movieId/similar',
        queryParams: {'page': page.toString()},
      );
      
      final data = await _getRequest(url);
      return _parseMovies(data);
    } catch (e) {
      print('Error fetching similar movies: $e');
      return [];
    }
  }

  // Fetch movie recommendations
  Future<List<Movie>> getMovieRecommendations(String movieId, {int page = 1}) async {
    try {
      final url = _buildUrl(
        '${ApiConstants.movieDetails}/$movieId/recommendations',
        queryParams: {'page': page.toString()},
      );
      
      final data = await _getRequest(url);
      return _parseMovies(data);
    } catch (e) {
      print('Error fetching movie recommendations: $e');
      return Movie.recommendedMovies;
    }
  }

  // Fetch movies by genre
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final url = _buildUrl(
        '/discover/movie',
        queryParams: {
          'with_genres': genreId.toString(),
          'page': page.toString(),
          'sort_by': 'popularity.desc',
        },
      );
      
      final data = await _getRequest(url);
      return _parseMovies(data);
    } catch (e) {
      print('Error fetching movies by genre: $e');
      return [];
    }
  }

  // Get genre ID from genre name
  static int? getGenreId(String genreName) {
    const genreMap = {
      'Action': 28,
      'Adventure': 12,
      'Animation': 16,
      'Comedy': 35,
      'Crime': 80,
      'Documentary': 99,
      'Drama': 18,
      'Family': 10751,
      'Fantasy': 14,
      'History': 36,
      'Horror': 27,
      'Music': 10402,
      'Mystery': 9648,
      'Romance': 10749,
      'Sci-Fi': 878,
      'TV Movie': 10770,
      'Thriller': 53,
      'War': 10752,
      'Western': 37,
    };
    return genreMap[genreName];
  }

  // Fetch movie cast and crew
  Future<Map<String, dynamic>?> getMovieCredits(String movieId) async {
    try {
      final url = _buildUrl('${ApiConstants.movieDetails}/$movieId/credits');
      return await _getRequest(url);
    } catch (e) {
      print('Error fetching movie credits: $e');
      return null;
    }
  }
}