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
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You already have ${HandSize + 1} cards!  You can\'t pick up any more cards.')),
     );

    }
  }

  // ignore: unused_element
  void _drawFromDiscard() {
    if (discardPileTop != null) {
       if (deck.isNotEmpty && playerHand.length < HandSize + 1) {
         setState(() {
          playerHand.add(discardPileTop!);
          discardPileTop = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You already have ${HandSize + 1} cards!  You can\'t pick up any more cards.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You already have ${HandSize + 1} cards!  You can\'t pick up any more cards.')),
      );

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
    if (deck.isNotEmpty && playerHand.length == HandSize + 1) {
      setState(() {
          playerHand.remove(card);
          discardPileTop = card;
          selectedCards.clear();
        });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You only have ${HandSize} cards - You can\'t discard.')),
      );

    }
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

  void _goOut() {
    if (HandSize < 15) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CONGRATULATIONS! On to the next round!')),
        );
        HandSize++;
        _restartGame();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GAME OVER! ;-)')),
      );
    }


    /*
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
    */
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
    return card.rank == 0 || card.rank == HandSize || ( HandSize == 14 && card.rank == 1 ) || ( HandSize == 15 && card.rank == 2 );
  }
  

  Widget _buildDraggableCard(PlayingCard card, int index) {
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
          childWhenDragging: Opacity(opacity: 1.0, child: Container()),
          onDragStarted: () => _selectCardForDiscard(card),
          child: SizedBox(
            height: kCardHeight,
            width: kCardHeight * 0.7,
            child: Stack(
              children: [
                // 🔽 Your actual card
                PlayingCardWidget(
                  card: card,
                  onTap: () => _toggleCardSelection(card),
                  isSelected: selectedCards.contains(card),
                ),

                // 🔼 Top line
                Positioned(
                  top: 0,
                  left: (kCardHeight * 0.7) * 0.05, // 5% left margin
                  child: Container(
                    width: (kCardHeight * 0.7) * 0.9, // 90% width
                    height: 4,
                    color: (_showWildcards && isWildcard(card)) ? colorWildHL : colorBG,
                  ),
                ),

                // 🔼 Bottom line
                Positioned(
                  bottom: 0,
                  left: (kCardHeight * 0.7) * 0.05,
                  child: Container(
                    width: (kCardHeight * 0.7) * 0.9,
                    height: 4,
                    color: (_showWildcards && isWildcard(card)) ? colorWildHL : colorBG,
                  ),
                ),
              ],
            ),
          )


        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Flutter Rummy')),
      backgroundColor: colorBG, // 👈 sets full-screen background
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
                    GestureDetector(
                      onDoubleTap: _restartGame,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                          textStyle: TextStyle(fontSize: 10),
                        ),
                        onPressed: null, // disables single-tap
                        child: Text('Restart'),
                      ),
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
                              width: 4,
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
                // Go Out Button
                Tooltip(
                  message: 'You must have $HandSize cards to Go Out',
                  child: ElevatedButton(
                    onPressed: playerHand.length == HandSize ? _goOut : null,
                    child: Text('Go Out'),
                  ),
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

            // Provide a gap
            SizedBox(height: 10),

            // =======================================================
            // Your hand display goes below
            // Scales cards to max width
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final cardCount = playerHand.length;
                  final cardWidth = kCardHeight * 0.7;
                  final idealSpacing = cardWidth;// + 8; // 8px padding
                  final totalIdealWidth = idealSpacing * cardCount;

                  // Calculate spacing
                  final spacing = totalIdealWidth <= totalWidth
                      ? idealSpacing
                      : (totalWidth - cardWidth) / (cardCount - 1);

                  // Clamp spacing to avoid excessive overlap
                  final clampedSpacing = spacing.clamp(0.0, idealSpacing);

                  // Calculate total hand width
                  final handWidth = cardWidth + clampedSpacing * (cardCount - 1);
                  final startOffset = (totalWidth - handWidth) / 2;

                  return SizedBox(
                    width: totalWidth,
                    height: kCardHeight,
                    child: Stack(
                      children: List.generate(cardCount, (index) {
                        final card = playerHand[index];
                        final offset = startOffset + clampedSpacing * index;

                        return Positioned(
                          left: offset,
                          child: _buildDraggableCard(card, index),
                        );
                      }),
                    ),

                  );
                },
              ),
            )

            //   SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}