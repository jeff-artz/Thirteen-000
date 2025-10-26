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

/*
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
          child: Image.asset(
          card.imagePath,
          height: kCardHeight ,
          width: kCardHeight * 0.7 ,
        ),
      );
  }
*/
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox.expand( // ✅ fills parent height and width
        child: Image.asset(
          card.imagePath,
          fit: BoxFit.contain, // ✅ scales image to fit
        ),
      ),
    );
  }


} 

