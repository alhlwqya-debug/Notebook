import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/template_repository_impl.dart';
import '../../domain/entities/template.dart';
import '../../domain/repositories/template_repository.dart';

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepositoryImpl();
});

class TemplatesNotifier extends StateNotifier<AsyncValue<List<Template>>> {
  final TemplateRepository _repository;

  TemplatesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTemplates();
  }

  Future<void> loadTemplates({int? typeId, int? categoryId}) async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllTemplates(typeId: typeId, categoryId: categoryId);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (templates) => state = AsyncValue.data(templates),
    );
  }

  Future<Template?> createTemplate(Template template) async {
    final result = await _repository.createTemplate(template);
    result.fold((_) {}, (_) => loadTemplates());
    return result.fold((_) => null, (t) => t);
  }

  Future<bool> updateTemplate(Template template) async {
    final result = await _repository.updateTemplate(template);
    result.fold((_) {}, (_) => loadTemplates());
    return result.isRight();
  }

  Future<void> deleteTemplate(int id) async {
    await _repository.deleteTemplate(id);
    loadTemplates();
  }

  Future<void> duplicateTemplate(int id) async {
    await _repository.duplicateTemplate(id);
    loadTemplates();
  }
}

final templatesProvider = StateNotifierProvider<TemplatesNotifier, AsyncValue<List<Template>>>((ref) {
  return TemplatesNotifier(ref.watch(templateRepositoryProvider));
});
