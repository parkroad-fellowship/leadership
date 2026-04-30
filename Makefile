icons:
		dart run flutter_launcher_icons:main && dart run icons_launcher:create && dart run icons_launcher:create --flavor dev && dart run icons_launcher:create --flavor stg

splash:
		dart run flutter_native_splash:create

gen:
		dart run build_runner build --delete-conflicting-outputs

fmt:
		dart fix --apply && dart format lib test

l10n:
		flutter gen-l10n

apk:
		flutter build apk  --flavor production --target lib/main_production.dart -vv

clean:
		flutter clean && flutter pub get -v && make pods

aab:
		flutter build appbundle  --flavor production --target lib/main_production.dart --release --obfuscate --split-debug-info=debug-symbols -v

run:
		flutter run --release  --flavor production --target lib/main_production.dart
	
build: 	# Run the app on a new computer with Flutter 2.3 installed
		flutter pub get && make gen && make run

ipa:
		flutter build ipa  --flavor production --target lib/main_production.dart -vv

web:
		flutter build web --target lib/main_development.dart

base64:
		cat path/to/file.png | openssl base64 | tr -d '\n' | pbcopy

sha1:
		keytool -list -v -keystore ~/.android/debug.keystore

pods:
		cd ios && pod install --verbose && cd ..

gallery-cert:
		keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_certificate.pem

pub:
	# 1. Get the latest from the public world
	git fetch public
	# 2. Create/Reset the local branch to match the public main EXACTLY
	git checkout -B public-deploy public/main
	# 3. Overwrite the files with your private main's state
	git checkout main -- .
	# 4. Commit and push
	git add .
	git commit -m "Automated sync from private repo"
	git push public public-deploy:main
	# 5. Back to main
	git checkout main