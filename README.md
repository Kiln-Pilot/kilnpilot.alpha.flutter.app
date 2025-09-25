# kilnpilot_alpha_flutter_app

Kiln pilot, the master of cement operations

## Getting Started

This project is a Flutter application for cement kiln operations monitoring and optimization.

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart (comes with Flutter)
- [json_serializable](https://pub.dev/packages/json_serializable) and [build_runner](https://pub.dev/packages/build_runner) for code generation

### Setup
1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd kilnpilot.alpha.flutter.app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App
To run the app on your device or emulator:
```bash
flutter run
```

### Generating Serializers (json_serializable)
If you add or update any model annotated with `@JsonSerializable()`, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```
This will generate or update the `.g.dart` files for your serializers.

### Useful Resources
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)
