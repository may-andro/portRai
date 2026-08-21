import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:portrai/src/feature/service/service.dart';
import 'package:portrai/src/feature/testimonial/testimonial.dart';

class PortfolioEntity {
  PortfolioEntity({
    required this.profile,
    required this.expertises,
    required this.projects,
    required this.services,
    required this.experiences,
    required this.testimonials,
  });

  final ProfileEntity profile;
  final List<ExpertiseEntity> expertises;
  final List<ProjectEntity> projects;
  final List<ServiceEntity> services;
  final List<ExperienceEntity> experiences;
  final List<TestimonialEntity> testimonials;
}
