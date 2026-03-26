import 'dart:io';
import 'package:pure_svg/src/vector_graphics/vector_graphics_compiler/vector_graphics_compiler.dart' as vg;

void main() {
  final file = File('test/icon.svg');
  final svgString = file.readAsStringSync();
  
  final instructions = vg.parseWithoutOptimizers(svgString);
  
  print('Width: ${instructions.width}, Height: ${instructions.height}');
  print('Paths count: ${instructions.paths.length}');
  print('Paints count: ${instructions.paints.length}');
  print('Commands count: ${instructions.commands.length}');
  
  for (int i = 0; i < instructions.paints.length; i++) {
    final paint = instructions.paints[i];
    print('Paint $i: fill=${paint.fill}, stroke=${paint.stroke}');
    if (paint.fill?.shader != null) {
      print('  Shader: ${paint.fill!.shader}');
    }
  }
  
  for (int i = 0; i < instructions.commands.length; i++) {
    final cmd = instructions.commands[i];
    print('Command $i: type=${cmd.type}, objectId=${cmd.objectId}, paintId=${cmd.paintId}');
  }
}
