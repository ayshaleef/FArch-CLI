import 'package:farch/farch_commands.dart';

void main(List<String> arguments) async {
  final farch = FArch();
  await farch.run(arguments);
}
