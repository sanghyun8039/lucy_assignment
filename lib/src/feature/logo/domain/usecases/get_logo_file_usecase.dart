import 'dart:io';

import 'package:lucy_assignment/src/feature/logo/domain/repos/logo_repository.dart';

class GetLogoFileUseCase {
  final LogoRepository _logoRepository;

  GetLogoFileUseCase({required LogoRepository logoRepository})
    : _logoRepository = logoRepository;

  Future<File?> call(String code) async {
    return await _logoRepository.getLogoFile(code);
  }
}
