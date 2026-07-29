import 'package:dartz/dartz.dart';

import '../entities/template.dart';
import '../../core/errors/failures.dart';

abstract class TemplateRepository {
  Future<Either<Failure, List<Template>>> getAllTemplates({int? typeId, int? categoryId});
  Future<Either<Failure, Template>> getTemplateById(int id);
  Future<Either<Failure, Template>> createTemplate(Template template);
  Future<Either<Failure, Template>> updateTemplate(Template template);
  Future<Either<Failure, void>> deleteTemplate(int id);
  Future<Either<Failure, Template>> duplicateTemplate(int id);
}
