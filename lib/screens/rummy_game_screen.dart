import 'package:flutter/material.dart';
import '../models/playing_card.dart';
import '../utils/deck_utils.dart';
import '../widgets/card_widget.dart';
import '../constants.dart';

class RummyGameScreen extends StatefulWidget {
  @override
  _RummyGameScreenState createState() => _RummyGameScreenState();
}

class _RummyGameScreenState extends State<RummyGameScreen> {
  late List<PlayingCard> deck;
  List<PlayingCard> playerHand = [];
  List<PlayingCard> selectedCards = [];
  PlayingCard? discardPileTop;

  @override
  void initState() {
    super.initState();
    deck = generateDeck();
    _dealInitialHand();
  }

  void _dealInitialHand() {
    int dealCount = HandSize;
    playerHand = deck.take(dealCount).toList();
    deck.removeRange(0, dealCount);
  }

  void _drawCard() {
    if (deck.isNotEmpty) {
      setState(() {
        playerHand.add(deck.removeAt(0));
      });
    }
  }

  // ignore: unused_element
  void _drawFromDiscard() {
    if (discardPileTop != null) {
      setState(() {
        playerHand.add(discardPileTop!);
        discardPileTop = null;
      });
    }
  }
  
  void _onReorderHand(int oldIndex, int newIndex) {
  setState(() {
    final card = playerHand.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex -= 1;
    playerHand.insert(newIndex, card);
  });
}
  // 
  void _selectCardForDiscard(PlayingCard card) {
    setState(() {
      selectedCards = [card];
    });
  }

  void _discardCard(PlayingCard card) {
    setState(() {
      playerHand.remove(card);
      discardPileTop = card;
      selectedCards.clear();
    });
  }

  void _toggleCardSelection(PlayingCard card) {
    setState(() {
      if (selectedCards.contains(card)) {
        selectedCards.remove(card);
      } else {
        selectedCards.add(card);
      }
    });
  }

  void _submitMeld() {
    if (_isValidMeld(selectedCards)) {
      setState(() {
        playerHand.removeWhere((card) => selectedCards.contains(card));
        selectedCards.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid meld!')),
      );
    }
  }

  bool _isValidMeld(List<PlayingCard> cards) {
    if (cards.length < 3) return false;

    bool isSet = cards.every((c) => c.rank == cards[0].rank) &&
                 cards.map((c) => c.suit).toSet().length == cards.length;

    bool isRun = cards.every((c) => c.suit == cards[0].suit) &&
                 _areConsecutive(cards.map((c) => c.rank).toList());

    return isSet || isRun;
  }

  bool _areConsecutive(List<int> ranks) {
    ranks.sort();
    for (int i = 0; i < ranks.length - 1; i++) {
      if (ranks[i + 1] != ranks[i] + 1) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Flutter Rummy')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top row: draw pile + discard pile
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
         // no worky       Text('13')),
                // =======================================================
                // DRAW Button (Blue Card back)
                GestureDetector(
                  onTap: _drawCard,
                  child: Image.asset(
                    'assets/cards/blue_back.png',
                    height: kCardHeight,
                  ),
                ),
                SizedBox(width: 20),
                
                // Discharge Pile Display
                DragTarget<PlayingCard>(
                  onAccept: (card) => _discardCard(card),
                  builder: (context, candidateData, rejectedData) {
                    return GestureDetector(
                      onTap: _drawFromDiscard,
                      child: Container(
                          height: kCardHeight,
                          width: kCardHeight * 0.7,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: candidateData.isNotEmpty ? Colors.green : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: discardPileTop != null
                              ? Image.asset(discardPileTop!.imagePath, fit: BoxFit.contain)
                              : Image.asset(
                                'assets/cards/empty_discard_pile.png',
                                height: kCardHeight,
                              ),
                        ),
                      );
                  },
                ),
                //------------------------------
                // Submit Meld Button
                ElevatedButton(
                  onPressed: _submitMeld,
                  child: Text('Go Out'),
                ),
              ],
            ),

  //          SizedBox(height: 16),

//            SizedBox(height: 16),

            // =======================================================
            // Your hand display goes below
            Expanded(
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: playerHand.length,
                onReorder: _onReorderHand,
                buildDefaultDragHandles: false,
                itemBuilder: (context, index) {
                  final card = playerHand[index];

                  return ReorderableDragStartListener(
                    key: ValueKey('${card.rank}_${card.suit}'), // ✅ unique key
                    index: index,
                    child: Draggable<PlayingCard>(
                      data: card,
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          height: kCardHeight,
                          width: kCardHeight * 0.7,
                          child: PlayingCardWidget(
                            card: card,
                            onTap: () {},
                            isSelected: selectedCards.contains(card),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.0,
                        child: Container(),
                      ),
                      onDragStarted: () => _selectCardForDiscard(card),
                      child: PlayingCardWidget(
                        card: card,
                        onTap: () => _toggleCardSelection(card),
                        isSelected: selectedCards.contains(card),
                      ),
                    ),
                  );
                }

              ),
            ),




        //   SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}