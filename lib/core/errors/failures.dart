import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class ExportFailure extends Failure {
  const ExportFailure(super.message);
}

class ImportFailure extends Failure {
  const ImportFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
