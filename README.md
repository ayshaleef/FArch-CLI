# 🚀 FArch CLI Tool

FArch CLI Tool is a developer-friendly command-line interface (CLI) designed to simplify and streamline the process of creating feature structures in Flutter projects using different architectural patterns (Clean Architecture, MVC, MVVM). It saves time and effort for developers by automating repetitive tasks and generating necessary files with ease.

---


## ✨ Features

- **Multiple Architecture Support**: 
  - Clean Architecture
  - MVC (Model-View-Controller)
  - MVVM (Model-View-ViewModel)
- **State Management Integration**:
  - BLoC
  - GetX
  - Provider
- **Dependency Injection with GetIt**: Seamlessly integrate the GetIt package for dependency injection (available only for Clean Architecture)
- **Custom File Generation**: Generate specific files based on provided options
- **Effortless Setup**: Automatically register dependencies and prepare your project structure

---

## 🛠️ Installation

Install FArch CLI Tool globally using Dart's pub package manager:
```bash
dart pub global activate farch
```
Ensure you have Dart and Flutter installed.

---

## 🚀 Usage

### Basic Commands

1. Create a feature with interactive prompts:
```bash
farch "FeatureName"
```

2. Create a feature with specific architecture:
```bash
farch "FeatureName" --mvc    # For MVC architecture
farch "FeatureName" --mvvm   # For MVVM architecture
farch "FeatureName" --clean  # For Clean architecture
```

3. List existing features:
```bash
farch list
```

### Architecture-Specific Components

#### Clean Architecture
- Includes support for dependency injection with `GetIt`.
- Example command:
```bash
farch "FeatureName" -u "UseCaseName"     # Create use case
farch "FeatureName" -u "UseCaseName":"repsitoryName"    # Create use case & repository
farch "FeatureName" -m "ModelName"       # Create entity & model
farch "FeatureName" -r "RepositoryName"  # Create repository
farch "FeatureName" -d "DataSourceName"  # Create data source
```

#### MVC Architecture
- Simple structure without dependency injection.
- Example command:
```bash
farch "FeatureName" -m "ModelName"       # Create model
farch "FeatureName" -v "ViewName"        # Create view
```

#### MVVM Architecture
- Includes ViewModel and optional services.
- Example command:
```bash
farch "FeatureName" -m "ModelName"       # Create model
farch "FeatureName" -v "ViewName"        # Create view
farch "FeatureName" -vm "ViewModelName"  # Create viewmodel
farch "FeatureName" -s "ServiceName"     # Create service
```

### State Management Integration

Add state management to any feature:
```bash
farch "FeatureName" -sm "NameStateManagement" -bloc     # Add BLoC
farch "FeatureName" -sm "NameStateManagement" -getx     # Add GetX
farch "FeatureName" -sm "NameStateManagement" -provider # Add Provider
```

### Generated Structure Examples

#### Clean Architecture
```
features/auth/
├── data/
│   ├── data_sources/
│   ├── models/
│   ├── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── usecases/
├── presentation/
    ├── pages/
    ├── widgets/
    ├── manager/
```

#### MVC Architecture
```
features/auth/
├── models/
├── views/
├── controllers/
```

#### MVVM Architecture
```
features/auth/
├── models/
├── views/
├── viewmodels/
├── services/
├── repositories/
```

### Dependency Injection for Clean Architecture

When you choose **Clean Architecture**, you will see a prompt:
```
Do you want to use GetIt for dependency injection? (yes/no)
```
- Selecting **yes** will:
  - Add the `get_it` package to your project.
  - Generate an `injection.dart` file in the `lib/` directory.

### Example of `injection.dart`:
```dart
import 'features/auth/data/data_sources/auth_data_source.dart';
import 'features/auth/data/repositories/auth_repository_implement.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecase.dart';
import 'features/auth/presentation/manager/bloc/auth/auth_bloc.dart';

import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _setUpAuth();
}

Future<void> _setUpAuth() async {
  sl.registerFactory(() => AuthBloc());
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImplement(dataSource: sl()));
  sl.registerLazySingleton(() => AuthUseCase(repository: sl()));
  sl.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImplement());
}
```
You also need to update your `main.dart` file:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await injection.init();
  runApp(const MyApp());
}
```

---

## 💡 Notes

- The `injection.dart` file will only be generated if you select **Clean Architecture**.
- MVC and MVVM architectures do not include dependency injection setup.

---

## 🤝 Contribution

Feel free to contribute by reporting issues or suggesting improvements via [GitHub Issues](#).

---

Happy Coding! 🎉
