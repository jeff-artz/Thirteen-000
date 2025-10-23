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

  void _restartGame() {
    setState(() {
      deck = generateDeck(); // fresh deck
      discardPileTop = null;
      selectedCards.clear();
      _dealInitialHand(); // re-deal hand
    });
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
    if (newIndex > oldIndex) newIndex -= 1;
    final card = playerHand.removeAt(oldIndex);
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

  void _reorderCard(PlayingCard draggedCard, int newIndex) {
    setState(() {
      playerHand.remove(draggedCard);
      playerHand.insert(newIndex, draggedCard);
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
         
                // Hand Size Manual Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Round'),
                    SizedBox(width: 8),
                    DropdownButton<int>(
                      value: HandSize,
                      items: handSizeOptions.map((option) {
                        return DropdownMenuItem<int>(
                          value: option['value'],
                          child: Text(option['label']),
                        );
                      }).toList(),
                      onChanged: (newSize) {
                        if (newSize != null) {
                          setState(() {
                            HandSize = newSize;
                            _restartGame();
                          });
                        }
                      },
                    ),


                  ],
                ),

                // Restart Game manual selection (Re-Deal?)
                ElevatedButton(
                  onPressed: _restartGame,
                  child: Text('Restart'),
                ),


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
                          width: kCardHeight * 0.6,
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 8,
                  children: List.generate(playerHand.length, (index) {
                    final card = playerHand[index];

                    return DragTarget<PlayingCard>(
                      onWillAccept: (incomingCard) => incomingCard != card,
                      onAccept: (incomingCard) {
                        _reorderCard(incomingCard, index);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Draggable<PlayingCard>(
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
                            opacity: 0.1,
                            child: Container(),
                          ),
                          onDragStarted: () => _selectCardForDiscard(card),
                          child: PlayingCardWidget(
                            card: card,
                            onTap: () => _toggleCardSelection(card),
                            isSelected: selectedCards.contains(card),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
            //   SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}