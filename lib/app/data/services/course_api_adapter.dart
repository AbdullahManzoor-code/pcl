import '../models/course_model.dart';
import '../models/course_api_models.dart';

class CourseApiAdapter {
  static Course mapLanguageStatsToCourse(LanguageStats stats) {
    final progress = stats.totalTopics > 0
        ? (stats.topicsCompleted / stats.totalTopics) * 100
        : 0.0;
        
    final categoryName = stats.languageName.split(' ').first;
    final iconName = categoryName.toLowerCase().replaceAll('++', 'plusplus').replaceAll('+', 'p').replaceAll('#', 'sharp');

    return Course(
      id: stats.languageId,
      title: stats.languageName,
      category: categoryName,
      level: 'Medium', // Default if not provided
      image: 'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/$iconName/$iconName-original.svg',
      progress: progress,
      isCompleted: stats.topicsCompleted == stats.totalTopics && stats.totalTopics > 0,
      isEnrolled: true,
      description: 'Learning path for ${stats.languageName}',
      rating: 4.8,
      reviewCount: 0,
      reviews: [],
      accuracy: stats.avgAccuracy.toInt(),
      topicsCompleted: stats.topicsCompleted,
      totalTopics: stats.totalTopics,
      difficulty: 0.5,
      lastActivity: stats.lastPracticed ?? 'Never',
      intensity: 'Regular',
      topics: [], 
    );
  }

  static Course mapCurriculumToCourse(LanguageCurriculum curriculum) {
    final categoryName = curriculum.name.split(' ').first;
    final iconName = categoryName.toLowerCase().replaceAll('++', 'plusplus').replaceAll('+', 'p').replaceAll('#', 'sharp');

    return Course(
      id: curriculum.languageId,
      title: curriculum.name,
      category: categoryName,
      level: 'All Levels', 
      image: 'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/$iconName/$iconName-original.svg',
      progress: 0.0,
      isCompleted: false,
      isEnrolled: false,
      description: 'Complete roadmap for ${curriculum.name}',
      rating: 4.5,
      reviewCount: 0,
      reviews: [],
      accuracy: 0,
      topicsCompleted: 0,
      totalTopics: curriculum.roadmap.length,
      difficulty: 0.5,
      lastActivity: 'Never',
      intensity: 'Regular',
      topics: [], 
    );
  }
}
