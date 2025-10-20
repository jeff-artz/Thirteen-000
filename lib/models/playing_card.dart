// models/playing_card.dart
enum Suit { hearts, diamonds, clubs, spades }

class PlayingCard {
  final Suit suit;
  final int rank; // 1 = Ace, 11 = Jack, etc.
  final String imagePath;

  PlayingCard({required this.suit, required this.rank, required this.imagePath});
}