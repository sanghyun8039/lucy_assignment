import 'package:lucy_assignment/src/feature/logo/domain/repos/logo_repository.dart';

class SyncLogosUseCase {
  final LogoRepository _logoRepository;

  SyncLogosUseCase({required LogoRepository logoRepository})
    : _logoRepository = logoRepository;

  Future<void> call() async {
    await _logoRepository.syncLogos();
  }
}
