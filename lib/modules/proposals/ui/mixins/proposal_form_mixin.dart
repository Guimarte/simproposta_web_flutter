import 'package:flutter/material.dart';

mixin ProposalFormMixin<T extends StatefulWidget> on State<T> {
  final List<Map<String, dynamic>> blocks = [];

  void addTextBlock() {
    setState(() {
      blocks.add({
        'type': 'TEXT',
        'title': 'Descrição dos Serviços',
        'content': {'text': 'Descreva detalhadamente o escopo do projeto aqui...'},
      });
    });
  }

  void addVideoBlock() {
    setState(() {
      blocks.add({
        'type': 'VIDEO',
        'title': 'Vídeo de Apresentação',
        'content': {'videoUrl': 'https://www.youtube.com/embed/dQw4w9WgXcQ'},
      });
    });
  }

  void addPriceTableBlock() {
    setState(() {
      blocks.add({
        'type': 'PRICE_TABLE',
        'title': 'Tabela de Preços & Pacotes',
        'content': {
          'items': [
            {'name': 'Serviço Principal', 'description': 'Descrição do serviço principal', 'price': 1500.0},
            {'name': 'Opcional 1', 'description': 'Item adicional opcional', 'price': 500.0},
          ]
        },
      });
    });
  }

  void removeBlock(int index) {
    setState(() {
      blocks.removeAt(index);
    });
  }
}
