# Flutter 프로젝트를 위한 Makefile

# 의존성 가져오기
get:
	flutter pub get

# 앱 실행
run:
	flutter run

# 테스트 실행
test:
	flutter test

# build_runner 실행
build:
	flutter pub run build_runner build --delete-conflicting-outputs

# 프로젝트 정리
clean:
	flutter clean

# 생성된 파일까지 모두 삭제하는 deep clean
deep_clean: clean
	@echo "Deleting generated files..."
	@find . -name "*.g.dart" -delete
	@find . -name "*.freezed.dart" -delete
	@echo "Generated files deleted."

# 의존성 재설치 및 코드 재생성
reset: deep_clean
	flutter pub get
	flutter pub run build_runner build --delete-conflicting-outputs
	
# 위의 모든 작업을PHONY로 선언하여 파일 이름과의 충돌을 방지
.PHONY: get run test build clean

# 앱 번들 빌드
bundle:
	flutter build appbundle --release

apk:
	flutter build apk --release --target-platform=android-arm64


