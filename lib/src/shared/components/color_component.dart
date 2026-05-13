import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flutter/material.dart';

/// Stores the [Paint] used to draw an entity.

class ColorComponent extends Component<Paint> {
  Paint? data;

  @override
  void init([Paint? data]) {
    this.data = data ?? (Paint()..color = const Color(0xFFFFFFFF));
  }

  @override
  void reset() {
    data = null;
  }
}
