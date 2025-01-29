extension StringExtension on String {
  String capitalize() => isNotEmpty ? this[0].toUpperCase() + substring(1) : '';
}

enum ArchitectureType { MVC, MVVM, CLEAN }

class DartClass {
  final String model;
  final String? entity;

  DartClass({required this.model, this.entity});
}

class JsonToDartConverter {
  
  DartClass convert(String className, dynamic json, ArchitectureType type) {
    if (json is List) {
      if (json.isNotEmpty && json.first is Map) {
        return _generateClasses(
            className, Map<String, dynamic>.from(json.first), type);
      } else {
        throw Exception('List root must contain objects.');
      }
    } else if (json is Map<String, dynamic>) {
      return _generateClasses(className, json, type);
    } else {
      throw Exception('Unsupported JSON root type.');
    }
  }

  DartClass _generateClasses(
      String className, Map<String, dynamic> json, ArchitectureType type) {
    final formattedClassName = _formatClassName(className);

    final modelContent = _generateModel(formattedClassName, json, type, true);
    String? entityContent;

    if (type == ArchitectureType.CLEAN) {
      entityContent = _generateEntity(formattedClassName, json);
    }

    return DartClass(model: modelContent, entity: entityContent);
  }

  String _generateEntity(String className, Map<String, dynamic> json) {
    final buffer = StringBuffer();
    final nestedClasses = StringBuffer();

    buffer.writeln('class ${className.replaceAll('Entity', '')}Entity {');

    for (var entry in json.entries) {
      final key = entry.key;
      final value = entry.value;
      final variableName = _convertToCamelCase(key);
      final nestedClassName = '${_capitalize(key)}Entity';

      if (value is Map) {
        nestedClasses.writeln(
            _generateEntity(nestedClassName, Map<String, dynamic>.from(value)));
        buffer.writeln('  final $nestedClassName $variableName;');
      } else if (value is List && value.isNotEmpty && value.first is Map) {
        nestedClasses.writeln(_generateEntity(
            nestedClassName, Map<String, dynamic>.from(value.first)));
        buffer.writeln('  final List<$nestedClassName> $variableName;');
      } else {
        final type = _getVariableType(value, nestedClassName);
        buffer.writeln('  final $type $variableName;');
      }
    }

    buffer.writeln('\n  ${className.replaceAll('Entity', '')}Entity(');
    if (!_isJsonEmpty(json)) buffer.write('{');
    for (var key in json.keys) {
      buffer.writeln('    required this.${_convertToCamelCase(key)},');
    }
    if (!_isJsonEmpty(json)) buffer.write('}');
    buffer.writeln('  );\n');

    buffer.writeln('}\n');

    buffer.writeln(nestedClasses.toString());
    return buffer.toString();
  }

  String _generateModel(
      String className, Map<String, dynamic> json, ArchitectureType type,
      [bool isFirstCreateClass = false]) {
    final buffer = StringBuffer();
    final nestedClasses = StringBuffer();

    final extendsEntity = type == ArchitectureType.CLEAN
        ? ' extends ${className.replaceAll('Model', '')}Entity'
        : '';
    if (isFirstCreateClass && type == ArchitectureType.CLEAN) {
      buffer.writeln(
          "import '../../domain/entities/${className.replaceAll('Model', '').toLowerCase()}_entity.dart';");
    }
    buffer.writeln(
        'class ${className.replaceAll('Model', '')}Model$extendsEntity {');

    for (var entry in json.entries) {
      final key = entry.key;
      final value = entry.value;
      final variableName = _convertToCamelCase(key);
      final nestedClassName = '${_capitalize(key)}Model';

      if (value is Map) {
        nestedClasses.writeln(_generateModel(
            nestedClassName, Map<String, dynamic>.from(value), type));
        buffer.writeln('  final $nestedClassName $variableName;');
      } else if (value is List && value.isNotEmpty && value.first is Map) {
        nestedClasses.writeln(_generateModel(
            nestedClassName, Map<String, dynamic>.from(value.first), type));
        buffer.writeln('  final List<$nestedClassName> $variableName;');
      } else {
        final type = _getVariableType(value, nestedClassName);
        buffer.writeln('  final $type $variableName;');
      }
    }
    //Create Constructor
    _createConstructorModel(type, buffer, className, json);

    buffer.writeln(_generateFromJsonMethod(className, json));
    buffer.writeln(_generateToJsonMethod(json));

    buffer.writeln('}\n');

    buffer.writeln(nestedClasses.toString());
    return buffer.toString();
  }

  void _createConstructorModel(ArchitectureType type, StringBuffer buffer,
      String className, Map<String, dynamic> json) {
    if (type == ArchitectureType.CLEAN) {
      buffer.writeln('  ${className.replaceAll('Model', '')}Model(');
      if (!_isJsonEmpty(json)) buffer.write('{');
      for (var key in json.keys) {
        buffer.writeln('    required this.${_convertToCamelCase(key)},');
      }
      if (!_isJsonEmpty(json)) buffer.write('}');
      buffer.writeln(') : super(');
      for (var key in json.keys) {
        buffer.writeln(
            '          ${_convertToCamelCase(key)}: ${_convertToCamelCase(key)},');
      }
      buffer.writeln('        );\n');
    } else {
      buffer.writeln('\n  ${className.replaceAll('Model', '')}Model(');
      if (!_isJsonEmpty(json)) buffer.write('{');
      for (var key in json.keys) {
        buffer.writeln('    required this.${_convertToCamelCase(key)},');
      }
      if (!_isJsonEmpty(json)) buffer.write('}');
      buffer.writeln(');\n');
    }
  }

  String _generateFromJsonMethod(String className, Map<String, dynamic> json) {
    final buffer = StringBuffer();
    buffer.writeln(
        '  factory ${className.replaceAll('Model', '')}Model.fromJson(Map<String, dynamic> json) => ${className.replaceAll('Model', '')}Model(');
    for (var entry in json.entries) {
      final key = entry.key;
      final variableName = _convertToCamelCase(key);
      final nestedClassName = _capitalize(key) + 'Model';

      if (entry.value is Map) {
        buffer.writeln(
            '    $variableName: $nestedClassName.fromJson(json["$key"] as Map<String, dynamic>),');
      } else if (entry.value is List &&
          entry.value.isNotEmpty &&
          entry.value.first is Map) {
        buffer.writeln(
            '    $variableName: (json["$key"] as List).map((item) => $nestedClassName.fromJson(item as Map<String, dynamic>)).toList(),');
      } else {
        buffer.writeln(
            '    $variableName: json["$key"] as ${_getVariableType(entry.value, nestedClassName)},');
      }
    }
    buffer.writeln('  );\n');
    return buffer.toString();
  }

  String _generateToJsonMethod(Map<String, dynamic> json) {
    final buffer = StringBuffer();
    buffer.writeln('  Map<String, dynamic> toJson() => {');
    for (var entry in json.entries) {
      final key = entry.key;
      final variableName = _convertToCamelCase(key);

      if (entry.value is Map) {
        buffer.writeln('    "$key": $variableName.toJson(),');
      } else if (entry.value is List &&
          entry.value.isNotEmpty &&
          entry.value.first is Map) {
        buffer.writeln(
            '    "$key": $variableName.map((item) => item.toJson()).toList(),');
      } else {
        buffer.writeln('    "$key": $variableName,');
      }
    }
    buffer.writeln('  };\n');
    return buffer.toString();
  }

  String _getVariableType(dynamic value, String nestedClassName) {
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is String) return 'String';
    if (value is List) {
      if (value.isNotEmpty) {
        final itemType = value.first is Map
            ? nestedClassName
            : _getVariableType(value.first, nestedClassName);
        return 'List<$itemType>';
      }
      return 'List<dynamic>';
    }
    if (value is Map) return '${_formatClassName(nestedClassName)}Entity';
    return 'dynamic';
  }

  String _convertToCamelCase(String input) {
    final parts = input.split('_');
    return parts.asMap().entries.map((entry) {
      return entry.key == 0 ? entry.value : entry.value.capitalize();
    }).join('');
  }

  String _formatClassName(String input) {
    return input.split('_').map((word) => word.capitalize()).join('');
  }

  String _capitalize(String input) => input.capitalize();

  bool _isJsonEmpty(dynamic json) {
    if (json == null) return true; 
    if (json is Map) return json.isEmpty; 
    if (json is List) return json.isEmpty; 
    return false;
  }
}
