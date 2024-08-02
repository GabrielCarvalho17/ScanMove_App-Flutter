import 'package:flutter/material.dart';

class CustomTabs extends StatefulWidget {
  final List<String> tabNames;
  final List<Widget> tabContents;
  final String origem;
  final String destino;
  final List pecas;

  const CustomTabs({
    Key? key,
    required this.tabNames,
    required this.tabContents,
    required this.origem,
    required this.destino,
    required this.pecas,
  }) : super(key: key);

  @override
  _CustomTabsState createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabs> {
  int _activeTabIndex = 0;

  double _calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size.width;
  }

  void _setActiveTabIndex(int index) {
    setState(() {
      _activeTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double fontSize = 18.0; // Defina o tamanho da fonte aqui

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 0), // Ajuste a margem inferior
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.tabNames.length, (index) {
              final isSelected = _activeTabIndex == index;
              final textStyle = TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: fontSize, // Tamanho da fonte
              );
              final textWidth = _calculateTextWidth(widget.tabNames[index], textStyle);

              return GestureDetector(
                onTap: () {
                  _setActiveTabIndex(index);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 0.0), // Remova a margem superior
                        child: Text(
                          widget.tabNames[index],
                          style: textStyle,
                        ),
                      ),
                      Container(
                        height: 2.0, // Altura do sublinhado
                        width: textWidth,
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, // Mostra o sublinhado apenas se selecionado
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: widget.tabContents[_activeTabIndex],
        ),
      ],
    );
  }
}
