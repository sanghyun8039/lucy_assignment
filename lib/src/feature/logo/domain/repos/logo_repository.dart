import 'dart:io';

abstract class LogoRepository {
  Future<void> syncLogos();
  Future<File?> getLogoFile(String code);
}
