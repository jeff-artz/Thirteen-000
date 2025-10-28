// utils/deck_utils.dart
import '../models/playing_card.dart';
import '../constants.dart';


List<PlayingCard> generateDeck(numDecks,handSize) {
  List<PlayingCard> deck = [];
  for (int ndecks = 1; ndecks <= numDecks; ndecks++) {
    for (var suit in Suit.values) {
      for (int rank = 1; rank <= 13; rank++) {
        deck.add(PlayingCard(
          suit: suit,
          rank: rank,
          imagePath: 'assets/cards/${suit.name}_$rank.png',
          isWild: false,
        ));
      }
    }
    // 🔹 Add 2 Jokers
    deck.add(PlayingCard(
      suit: Suit.spades, // Arbitrary suit for Joker
      rank: 0, // Use 0 to represent Joker
      imagePath: 'assets/cards/joker_1.png',
      isWild: true,
    ));
    deck.add(PlayingCard(
      suit: Suit.hearts,
      rank: 0,
      imagePath: 'assets/cards/joker_2.png',
      isWild: true,
    ));
  }

  deck.shuffle();
  return deck;
}
