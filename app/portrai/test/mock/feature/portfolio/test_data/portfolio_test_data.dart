import 'package:portrai/src/feature/experience/experience.dart';
import 'package:portrai/src/feature/expertise/expertise.dart';
import 'package:portrai/src/feature/portfolio/domain/entity/portfolio_entity.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:portrai/src/feature/service/service.dart';
import 'package:portrai/src/feature/testimonial/testimonial.dart';

import '../../profile/test_data/profile_test_data.dart';
import '../../project/test_data/project_test_data.dart';
import '../../testimonial/test_data/testimonial_test_data.dart';

PortfolioEntity createPortfolioEntity({
  List<ExpertiseEntity>? expertises,
  List<ProjectEntity>? projects,
  List<ServiceEntity>? services,
  List<ExperienceEntity>? experiences,
  List<TestimonialEntity>? testimonials,
}) {
  return PortfolioEntity(
    profile: createProfileEntity(),
    expertises:
        expertises ??
        const [
          ExpertiseEntity(
            image: 'flutter.png',
            title: 'Flutter',
            skills: ['Dart', 'Bloc'],
          ),
        ],
    projects: projects ?? [createProjectEntity()],
    services:
        services ??
        const [
          ServiceEntity(
            image: 'consulting.png',
            title: 'Consulting',
            description: 'Architecture guidance',
            detail: 'Architecture guidance for Flutter teams',
          ),
        ],
    experiences:
        experiences ??
        [
          ExperienceEntity(
            company: 'PortRai',
            position: 'Tech Lead',
            location: 'Alicante',
            startDate: DateTime(2024),
            endDate: null,
            current: true,
            employmentType: 'Full-time',
            description: 'Leading Flutter projects',
            longDescription: 'Leading Flutter projects with a modular setup',
            responsibilities: const ['Architecture'],
            achievements: const ['Launch'],
            technologies: const ['Flutter', 'Firebase'],
            companyLogo: 'https://example.com/company.png',
            url: 'https://example.com/company',
            id: 'portrai-tech-lead',
          ),
        ],
    testimonials: testimonials ?? [createTestimonialEntity()],
  );
}
