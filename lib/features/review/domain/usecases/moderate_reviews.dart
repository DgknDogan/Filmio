import 'package:fpdart/fpdart.dart';

import '../../../../core/resource/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/review_report.dart';
import '../repositories/review_moderation_repository.dart';

/// Files a report and hides the review on this device.
class ReportReviewUseCase extends UseCase<Either<Failure, Unit>, ReviewReport> {
  final ReviewModerationRepository _repository;

  ReportReviewUseCase(this._repository);

  @override
  Future<Either<Failure, Unit>> call({ReviewReport? params}) => _repository.report(params!);
}

/// Hides everything one author has written, on this device.
class BlockReviewAuthorUseCase extends UseCase<Either<Failure, Unit>, String> {
  final ReviewModerationRepository _repository;

  BlockReviewAuthorUseCase(this._repository);

  @override
  Future<Either<Failure, Unit>> call({String? params}) => _repository.blockAuthor(params!);
}

/// What is already hidden, as the details screen opens.
typedef Moderation = ({Set<String> blockedAuthors, Set<String> hiddenReviewIds});

class GetModerationUseCase extends UseCase<Moderation, void> {
  final ReviewModerationRepository _repository;

  GetModerationUseCase(this._repository);

  @override
  Future<Moderation> call({void params}) async => (
        blockedAuthors: _repository.blockedAuthors,
        hiddenReviewIds: _repository.hiddenReviewIds,
      );
}
