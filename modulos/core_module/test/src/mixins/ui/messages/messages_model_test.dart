import 'package:core_module/core_module.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Deve retornar a rota message info', () {
    final message = MessageModel(
      title: "teste message info",
      message: "message teste",
      type: MessageType.info,
    );

    if (kDebugMode) {
      print(message.type.color);
    }
    expect(message.title, isA<String>());
    expect(message.message, isA<String>());
    expect(message.type, isA<MessageType>());
    expect(message.type.color, equals(Colors.blue));
  });

  test('Deve retornar a rota message error', () {
    final message = MessageModel(
      title: "teste message erro",
      message: "message teste",
      type: MessageType.error,
    );

    if (kDebugMode) {
      print(message.type.color);
    }
    expect(message.title, isA<String>());
    expect(message.message, isA<String>());
    expect(message.type, isA<MessageType>());
    expect(message.type.color, equals(Colors.red));
  });
}
