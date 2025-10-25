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
  List<PlayingCard> player2Hand = [];
  List<PlayingCard> selectedCards = [];
  PlayingCard? discardPileTop;

  bool _showWildcards = true; // or false by default

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
    if (deck.isNotEmpty && playerHand.length < HandSize + 1) {
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
  

  void _restartGame() {
    setState(() {
      deck = generateDeck(); // fresh deck
      discardPileTop = null;
      selectedCards.clear();
      _dealInitialHand(); // re-deal hand
    });
  }

  /*  UNUSED currently
  void _onReorderHand(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final card = playerHand.removeAt(oldIndex);
      playerHand.insert(newIndex, card);
    });
  }
  */

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
    if (_isValidMeld(playerHand)) {
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

  bool isWildcard(PlayingCard card) {
    return card.rank == 0 || card.rank == HandSize;
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
         
                // ------------------------------------------
                // Hand Size Manual Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ------------------------------------------
                    // Restart Game manual selection (Re-Deal?)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                        textStyle: TextStyle(fontSize: 10),
                      ),
                      onPressed: _restartGame,
                      child: Text('Restart'),
                    ),
                    // -----------------------------------------
                    // Manual Hand size selection
                    SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Round'),
                        SizedBox(height: 1),
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
                  ],
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
                
                // =======================================================
                // Discharge Pile Display
                DragTarget<PlayingCard>(
                  onAccept: (card) => _discardCard(card),
                  builder: (context, candidateData, rejectedData) {
                    return GestureDetector(
                      onTap: _drawFromDiscard,
                      child: Container(
                          height: kCardHeight,
                          //width: kCardHeight * 0.6,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _showWildcards,
                      onChanged: (value) {
                        setState(() {
                          _showWildcards = value!;
                        });
                      },
                    ),
                    Text('Highlight Wildcards'),
                  ],
                ),
              ],
            ),

            // =======================================================
            // Your hand display goes below
            /* HORIZONTAL */
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 0,
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
                            opacity: 1.0,
                            child: Container(),
                          ),
                          onDragStarted: () => _selectCardForDiscard(card),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: (_showWildcards && isWildcard(card)) ? Colors.cyan : Colors.transparent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: PlayingCardWidget(
                              card: card,
                              onTap: () => _toggleCardSelection(card),
                              isSelected: selectedCards.contains(card),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),


/* FANNED
            Expanded(
              child: Center(
                child: SizedBox(
                  height: kCardHeight * 1.5, // give room for rotation
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: List.generate(playerHand.length, (index) {
                      final card = playerHand[index];
                      final total = playerHand.length;
                      final spread = 30.0; // total fan angle in degrees
                      final angle = -spread / 2 + (spread / (total - 1)) * index;
                      final offset = (index - total / 2) * 12.0;

                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: Transform.rotate(
                          angle: angle * 3.1416 / 180,
                          child: Draggable<PlayingCard>(
                            data: card,
                            feedback: Material(
                              color: Colors.transparent,
                              child: PlayingCardWidget(
                                card: card,
                                onTap: () {},
                                isSelected: selectedCards.contains(card),
                              ),
                            ),
                            childWhenDragging: Opacity(opacity: 1.0, child: Container()),
                            onDragStarted: () => _selectCardForDiscard(card),
                            child: PlayingCardWidget(
                              card: card,
                              onTap: () => _toggleCardSelection(card),
                              isSelected: selectedCards.contains(card),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
*/
            //   SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}