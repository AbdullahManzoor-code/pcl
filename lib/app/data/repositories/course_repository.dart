import '../models/course_model.dart';
import '../models/topic_model.dart';
import '../models/quiz_model.dart';
import '../services/mock_api_service.dart';

abstract class CourseRepository {
  List<Course> getAllCourses();
  List<Course> getEnrolledCourses();
  List<Course> getCompletedCourses();
  List<Course> getRecommendedCourses();
  Quiz? getQuizForCourse(String courseId);
  List<Topic> getTopics(String courseId);
  void enrollInCourse(String courseId);
  void addReview(String courseId, Map<String, dynamic> review);
  Future<Map<String, dynamic>> submitQuiz(
    String courseId,
    int correct,
    int total,
  );
}

class CourseRepositoryImpl implements CourseRepository {
  final MockApiService _apiService;

  CourseRepositoryImpl(this._apiService);

  @override
  List<Course> getAllCourses() {
    return _apiService
        .getAllCourses()
        .map((data) => Course.fromJson(data))
        .toList();
  }

  @override
  List<Course> getEnrolledCourses() {
    final uniqueCourses = <String, Course>{};
    for (var data in _apiService.getEnrolledCourses()) {
      final course = Course.fromJson(data);
      uniqueCourses[course.id] = course;
    }
    return uniqueCourses.values.toList();
  }

  @override
  List<Course> getCompletedCourses() {
    final courseList = _apiService
        .getCompletedCourses()
        .map((data) => Course.fromJson(data))
        .toList();
    return courseList;
  }

  @override
  List<Course> getRecommendedCourses() {
    final courseList = _apiService
        .getRecommendedCourses()
        .map((data) => Course.fromJson(data))
        .toList();
    return courseList;
  }

  Quiz? getDiagnosticQuizForCourse(String courseId) {
    final data = _apiService.getDiagnosticQuizForCourse(courseId);
    if (data != null) {
      return Quiz.fromJson(data);
    }
    return null;
  }

  @override
  Quiz? getQuizForCourse(String courseId) {
    final data = _apiService.getQuizForCourse(courseId);
    if (data != null) {
      return Quiz.fromJson(data);
    }
    return null;
  }

  @override
  List<Topic> getTopics(String courseId) {
    final topicList = _apiService
        .getTopics(courseId)
        .map((data) => Topic.fromJson(data))
        .toList();
    return topicList;
  }

  @override
  void enrollInCourse(String courseId) {
    _apiService.enrollInCourse(courseId);
  }

  @override
  void addReview(String courseId, Map<String, dynamic> review) {
    _apiService.addReview(courseId, review);
  }

  @override
  Future<Map<String, dynamic>> submitQuiz(
    String courseId,
    int correct,
    int total,
  ) {
    return _apiService.submitQuiz(courseId, correct, total);
  }
}
