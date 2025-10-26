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
  List<PlayingCard> discardPile = [];

  bool _showWildcards = true; // or false by default

  @override
  void initState() {
    super.initState();
    deck = generateDeck();
    _dealInitialHand();
  }

  void _dealInitialHand() {
    int dealCount = HandSize;
    discardPile.clear;
    playerHand = deck.take(dealCount).toList();
    deck.removeRange(0, dealCount);
    discardPile.add(deck.removeLast());
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
    if (discardPile.isNotEmpty){
       if (deck.isNotEmpty && playerHand.length < HandSize + 1) {
         setState(() {
          playerHand.add(discardPile.last!);
          discardPile.removeLast();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('a You already have ${HandSize + 1} cards!  You can\'t pick up any more cards.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('b You already have ${HandSize + 1} cards!  You can\'t pick up any more cards.')),
      );

    }
  }
  

  void _restartGame() {
    setState(() {
      deck = generateDeck(); // fresh deck
      discardPile.clear;
      _dealInitialHand(); // re-deal hand
    });
  }

   // 
  void _selectCardForDiscard(PlayingCard card) {
    setState(() {
      selectedCards = [card];
    });
  }

  void _discardCard(PlayingCard card) {
    if (playerHand.length == HandSize + 1) {
      setState(() {
          playerHand.remove(card);
          discardPile.add(card);
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
  

  Widget _buildDraggableCard(PlayingCard card, int index, double kCardHeight) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🃏 Card with fixed height
                  SizedBox(
                    height: kCardHeight,
                    child: PlayingCardWidget(
                      card: card,
                      onTap: () => _toggleCardSelection(card),
                      isSelected: selectedCards.contains(card),
                    ),
                  ),
                ],
              ),
            )


          ),
          childWhenDragging: Opacity(opacity: 1.0, child: Container()),
          onDragStarted: () => _selectCardForDiscard(card),
/*
          child: SizedBox(
            height: kCardHeight,
            width: kCardHeight * 0.7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🃏 Your actual card
                SizedBox(
                  height: kCardHeight,
                  child: PlayingCardWidget(
                    card: card,
                    onTap: () => _toggleCardSelection(card),
                    isSelected: selectedCards.contains(card),
                  ),
                ),

                // 🔽 Bottom line below the card
                Container(
                  width: (kCardHeight * 0.7) * 0.9,
                  height: 5, // ⬅️ updated height
                  color: (_showWildcards && isWildcard(card)) ? colorWildHL : colorBG,
                ),
              ],
            ),
          )
*/
          child: SizedBox(
            width: kCardHeight * 0.7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🃏 Your actual card
                SizedBox(
                  height: kCardHeight,
                  child: PlayingCardWidget(
                    card: card,
                    onTap: () => _toggleCardSelection(card),
                    isSelected: selectedCards.contains(card),
                  ),
                ),
                Container(
                  width: (kCardHeight * 0.7) * 0.9,
                  height: 5,
                  color: (_showWildcards && isWildcard(card)) ? colorWildHL : colorBG,
                ),
              ],
            ),
          )



        );
      },
    );
  }

  // DRAW THE SCREEN NOW
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final kCardHeight = screenHeight / 3;
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
                // Discard Pile Display
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
                              //color: candidateData.isNotEmpty ? Colors.green : Colors.transparent,
                              color: candidateData.isNotEmpty
                                  ? Colors.green
                                  : (discardPile.isNotEmpty && _showWildcards && isWildcard(discardPile.last))
                                      ? colorWildHL
                                      : Colors.transparent,
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: discardPile.isNotEmpty
                              ? Image.asset(discardPile.last!.imagePath, fit: BoxFit.contain)
                              : Image.asset(
                                'assets/cards/empty_discard_pile.png',
                                height: kCardHeight,
                              ),
                        ),
                      );
                  },
                ),
                //------------------------------
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, // optional for left alignment
                  children: [
                    // 🟢 Go Out Button with Tooltip
                    Tooltip(
                      message: 'You must have $HandSize cards to Go Out',
                      child: ElevatedButton(
                        onPressed: playerHand.length == HandSize ? _goOut : null,
                        child: const Text('Go Out'),
                      ),
                    ),

                    const SizedBox(height: 8), // spacing between button and checkbox

                    // 🟡 Checkbox + Label stacked vertically
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
                        const Text('Highlight Wildcards'),
                      ],
                    ),
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
                          child: _buildDraggableCard(card, index, kCardHeight),
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