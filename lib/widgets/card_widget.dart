// widgets/card_widget.dart
import 'package:flutter/material.dart';
import '../models/playing_card.dart';
import '../constants.dart';

class PlayingCardWidget extends StatelessWidget {
  final PlayingCard card;
  final VoidCallback onTap;
  final bool isSelected;

  const PlayingCardWidget({
    Key? key,
    required this.card,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        
        child: Image.asset(
          card.imagePath,
          height: kCardHeight,
        ),
      ),
    );
  }
}