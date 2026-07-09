// ignore_for_file: dangling_library_doc_comments

/// Minimal shadows used by the local Soft SaaS button/panel subset.

import 'package:flutter/material.dart';

class NeumorphicShadows {
  NeumorphicShadows._();

  static const level2Light = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 2), blurRadius: 4),
  ];

  static const level2Dark = [
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 2), blurRadius: 4),
  ];

  static const blueTintedLight = [
    BoxShadow(color: Color(0x1F2563EB), offset: Offset(0, 2), blurRadius: 5),
  ];

  static const redTintedLight = [
    BoxShadow(color: Color(0x1FDC2626), offset: Offset(0, 2), blurRadius: 5),
  ];

  static List<BoxShadow> getLevel2(Brightness brightness) =>
      brightness == Brightness.light ? level2Light : level2Dark;

  static List<BoxShadow> insetShadow(Brightness brightness) => [
        BoxShadow(
          color: brightness == Brightness.light
              ? const Color(0x1A000000)
              : const Color(0x66000000),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ];
}
