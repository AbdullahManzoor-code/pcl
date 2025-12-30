import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_details_controller.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/course_model.dart';
import '../../../routes/app_pages.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

class CourseDetailsView extends GetView<CourseDetailsController> {
  const CourseDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final course = controller.course.value;
        if (course == null)
          return const Center(child: Text('Course not found'));

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, course),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCourseMeta(context, course, isDark),
                    const SizedBox(height: 32),
                    Text(
                      'About this Course',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Course Content',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildTopicsList(context, isDark),
            _buildReviewsSection(context, course, isDark),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
      }),
      bottomSheet: Obx(() {
        final course = controller.course.value;
        if (course == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
          ),
          child: AppButton(
            text: course.isEnrolled ? 'Continue Learning' : 'Enroll Now',
            onPressed: course.isEnrolled
                ? controller.continueLearning
                : controller.enroll,
          ),
        );
      }),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, course) {
    return SliverAppBar(
      expandedHeight: 240.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: Get.arguments is Course
              ? 'dashboard_course_image_${course.id}' // Default or fallback
              : (Get.arguments as Map<String, dynamic>?)?['heroTag'] ??
                    'course_image_${course.id}',
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -40,
                  bottom: -40,
                  child: Icon(
                    Icons.code,
                    size: 200,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_circle_fill_rounded,
                          size: 64,
                          color: Colors.white70,
                        ),
                        Obx(() {
                          if (controller.course.value?.isEnrolled ?? false) {
                            final progress =
                                controller.course.value?.progress ?? 0.0;
                            return Column(
                              children: [
                                const SizedBox(height: 16),
                                if (progress == 0.0)
                                  AppButton(
                                    text: 'Start Diagnostic Test',
                                    onPressed: () => Get.toNamed(
                                      Routes.QUIZ,
                                      arguments: {
                                        'courseId': controller.course.value?.id,
                                        'isDiagnostic': true,
                                      },
                                    ),
                                    isLoading: false,
                                    color: Theme.of(context).primaryColorLight,
                                  )
                                else
                                  AppButton(
                                    text: 'Take Course Test',
                                    onPressed: () => Get.toNamed(
                                      Routes.QUIZ,
                                      arguments: {
                                        'courseId': controller.course.value?.id,
                                        'isDiagnostic': false,
                                      },
                                    ),
                                    isLoading: false,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseMeta(BuildContext context, course, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildMetaInfo(
              context,
              Icons.star_rounded,
              '${course.rating}',
              Colors.amber,
            ),
            const SizedBox(width: 16),
            _buildMetaInfo(
              context,
              Icons.person_outline_rounded,
              '${course.reviewCount} Students',
              Colors.grey,
            ),
            const SizedBox(width: 16),
            _buildMetaInfo(
              context,
              Icons.bar_chart_rounded,
              course.level,
              Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaInfo(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTopicsList(BuildContext context, bool isDark) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final topic = controller.topics[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  topic.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                children: topic.subTopics.map((subTopic) {
                  final isLocked = subTopic.isLocked;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: Icon(
                      isLocked
                          ? Icons.lock_outline_rounded
                          : (subTopic.type == 'quiz'
                                ? Icons.quiz_outlined
                                : Icons.play_circle_outline_rounded),
                      size: 20,
                      color: isLocked
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      subTopic.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: isLocked ? Colors.grey : null,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                    onTap: () => controller.openSubTopic(subTopic),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }, childCount: controller.topics.length),
    );
  }

  Widget _buildReviewsSection(BuildContext context, course, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Student Reviews',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${course.rating} ⭐',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (course.reviews.isEmpty)
              const Center(child: Text('No reviews yet.'))
            else
              ...course.reviews
                  .map((review) => _buildReviewCard(context, review, isDark))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                child: Text(
                  review.userName[0],
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: index < review.rating
                              ? Colors.amber
                              : Colors.grey[300],
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                '${review.date.day}/${review.date.month}/${review.date.year}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              height: 1.5,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
