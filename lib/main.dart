import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e, index, isHovered) {
              return AnimatedScale(
                scale: isHovered ? 1.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Draggable<int>(
                  data: index,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Opacity(
                      opacity: 0.7,
                      child: DockItem(icon: e),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: DockItem(icon: e),
                  ),
                  child: DockItem(icon: e),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DockItem extends StatelessWidget {
  final IconData icon;

  const DockItem({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
      ),
      child: Center(child: Icon(icon, color: Colors.white)),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;

  final Widget Function(T, int, bool) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();

  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: DragTarget<int>(
              onWillAccept: (draggedIndex) {
                setState(() => _hoveredIndex = index);
                return true;
              },
              onLeave: (_) => setState(() => _hoveredIndex = null),
              onAccept: (draggedIndex) {
                setState(() {
                  final draggedItem = _items.removeAt(draggedIndex);
                  _items.insert(index, draggedItem);
                  _hoveredIndex = null;
                });
              },
              builder: (context, _, __) {
                return widget.builder(
                  item,
                  index,
                  _hoveredIndex == index,
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
