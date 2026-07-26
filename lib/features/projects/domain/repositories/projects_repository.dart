import '../entities/project.dart';

abstract interface class ProjectsRepository {
  Future<List<Project>> getProjects();

  Future<Project> create(Project project);
}
