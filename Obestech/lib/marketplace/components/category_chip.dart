import 'package:flutter/material.dart';

class CategoryChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  _CategoryChipState createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _scale = 0.95; // Slight scale down on tap
          });
        },
        onTapUp: (_) {
          setState(() {
            _scale = 1.0; // Return to normal scale
          });
          widget.onTap();
        },
        onTapCancel: () {
          setState(() {
            _scale = 1.0; // Return to normal scale if tap is canceled
          });
        },
        child: AnimatedScale(
          scale: _scale,
          duration: Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: widget.selected ? Colors.blue : Colors.blue[50],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: widget.selected ? Colors.white : Colors.grey[800],
              ),
            ),
          ),
        ),
      ),
    );
  }
}