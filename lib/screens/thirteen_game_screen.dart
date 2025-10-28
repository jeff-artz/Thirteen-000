import 'package:flutter/material.dart';
import '../models/playing_card.dart';
import '../models/player.dart';
import '../utils/deck_utils.dart';
import '../widgets/card_widget.dart';
import '../constants.dart';

class thirteenGameScreen extends StatefulWidget {
  @override
  _thirteenGameScreenState createState() => _thirteenGameScreenState();
}

class _thirteenGameScreenState extends State<thirteenGameScreen> {
  final double cardWidth = kCardHeight * 0.65;
  late List<PlayingCard> deck;
  //List<PlayingCard> playerHand = [];
  //List<PlayingCard> player2Hand = [];
  List<PlayingCard> selectedCards = [];
  List<PlayingCard> discardPile = [];
  
  // Temporary hardcoded list of Players
  List<Player> players = [
    Player(id: 'p1', name: 'Jeff', hand: []),
    Player(id: 'p2', name: 'Liz', hand: []),
  ];

  bool _showWildcards = true; // or false by default

  @override
  void initState() {
    super.initState();
    deck = generateDeck(NumDecks,HandSize);
    _dealInitialHand();
  }

  void _dealInitialHand() {
    // Clear the player hands
    for (final player in players) {
      player.hand.clear();
    }
    // Clear the discard pile
    discardPile.clear();
    // Deal cards to the players
    for (int ncard = 0; ncard < HandSize; ncard++) {
        for (int nplayer = 0; nplayer < NumPlayers; nplayer++) {
          final card = deck.removeLast();
          players[nplayer].hand.add(card);
        }
      }
    // Deal one card to the discard pile
    discardPile.add(deck.removeLast());
  }

  void _drawCard() {
    if (deck.isNotEmpty && players[currentPlayerIndex].hand.length < HandSize + 1) {
      setState(() {
        players[currentPlayerIndex].hand.add(deck.removeAt(0));
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
       if (deck.isNotEmpty && players[currentPlayerIndex].hand.length < HandSize + 1) {
         setState(() {
          players[currentPlayerIndex].hand.add(discardPile.last!);
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
      deck = generateDeck(NumDecks,HandSize); // fresh deck
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
    if (players[currentPlayerIndex].hand.length == HandSize + 1) {
      setState(() {
          players[currentPlayerIndex].hand.remove(card);
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
      players[currentPlayerIndex].hand.remove(draggedCard);
      players[currentPlayerIndex].hand.insert(newIndex, draggedCard);
    });
  }

  void _goOut() {
    if (HandSize < 15) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CONGRATULATIONS! On to the next round!'),
            duration: Duration(seconds: 1),
          ),
        );
        HandSize++;
        _restartGame();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GAME OVER! ;-)')),
      );
    }


  }

  // ignore: unused_element
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

  void _endTurn() {
    setState(() {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
      showCards=false;
    });
  }


  // Return the Card NAME for the value
  String describeCardValue(int value) {
    return cardName[value];
  }

  Widget buildPlayerHandLayout(List<PlayingCard> hand, double cardHeight) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final cardCount = hand.length;
          final cardWidth = cardHeight * 0.7;
          final idealSpacing = cardWidth;
          final totalIdealWidth = idealSpacing * cardCount;

          final spacing = totalIdealWidth <= totalWidth
              ? idealSpacing
              : (totalWidth - cardWidth) / (cardCount - 1);

          final clampedSpacing = spacing.clamp(0.0, idealSpacing);
          final handWidth = cardWidth + clampedSpacing * (cardCount - 1);
          final startOffset = (totalWidth - handWidth) / 2;

          return SizedBox(
            width: totalWidth,
            height: cardHeight,
            child: Stack(
              children: List.generate(cardCount, (index) {
                final card = hand[index];
                final offset = startOffset + clampedSpacing * index;

                return Positioned(
                  left: offset,
                  child: _buildDraggableCard(card, index, cardHeight),
                );
              }),
            ),
          );
        },
      ),
    );
  }


  Widget _buildDraggableCard(PlayingCard card, int index, double kCardHeight) {
    double heightWCBar = (kCardHeight * 0.05).clamp(10.0,20.0);
   // heightWCBar=10;
    return DragTarget<PlayingCard>(
      // ignore: deprecated_member_use
      onWillAccept: (incomingCard) => incomingCard != card,
      // ignore: deprecated_member_use
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
                  height: heightWCBar,
                  color: (_showWildcards && isWildcard(card)) ? colorWildHL :colorBG,
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
    final kCardHeight = screenHeight / 2.5;
    //final kCardHeight = screenHeight / 3.25;
    String selectedPlayerId = players.first.id;
    return Scaffold(
      //appBar: AppBar(title: Text('Flutter thirteen')),
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
                    SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Round'),
                        SizedBox(height: .75),
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
                    Text(
                      'Wild',
                      style: TextStyle(
                        fontSize: 15,
                        //fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                    Text(
                      '${describeCardValue(getWildcardValueForRound(HandSize - 2))}',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 30),

                // =======================================================
                // DRAW Button (Blue Card back)
                Stack(
                  children: [
                    // 🔹 Actual pile
                    GestureDetector(
                      onTap: _drawCard,
                      child: Image.asset(
                        'assets/cards/blue_back.png',
                        height: kCardHeight,
                      ),
                    ),

                    // 🔹 Dimming overlay
                    if (players[0].hand.length == HandSize + 1) 
                      Container(
                        height: kCardHeight,
                        width: kCardHeight * 0.65,
                        color: Colors.black.withOpacity(0.4),
                      ),
                  ]
                ),

                SizedBox(width: 20),
                
                // =======================================================
                // Discard Pile Display

                DragTarget<PlayingCard>(
                  onAccept: (card) => _discardCard(card),
                  builder: (context, candidateData, rejectedData) {
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: _drawFromDiscard,
                          child: Container(
                            height: kCardHeight,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: candidateData.isNotEmpty
                                    ? Colors.green
                                    : (discardPile.isNotEmpty &&
                                            _showWildcards &&
                                            isWildcard(discardPile.last))
                                        ? colorWildHL
                                        : Colors.transparent,
                                width: 6,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: discardPile.isNotEmpty
                                ? Image.asset(
                                    discardPile.last!.imagePath,
                                    fit: BoxFit.contain,
                                  )
                                : Image.asset(
                                    'assets/cards/empty_discard_pile.png',
                                    height: kCardHeight,
                                  ),
                          ),
                        ),

                        // ✅ Dimming overlay that matches the card size
                        if (players[0].hand.length == HandSize + 1)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                SizedBox(width: 30),
                //------------------------------
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, // optional for left alignment
                  children: [
                    // 🟢 Go Out Button with Tooltip
                    Tooltip(
                      message: 'You must have $HandSize cards to Go Out',
                      child: ElevatedButton(
                        onPressed: players[0].hand.length == HandSize ? _goOut : null,
                        child: const Text('Go Out'),
                      ),
                    ),

                    //const SizedBox(height: 8), // spacing between button and checkbox

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
                        const Text('Show Wildcards'),
                      ],
                    ),
                    //SizedBox(height: 4),
                    
                    /*
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showCards = !showCards;
                        });
                      },
                      child: Text(showCards ? 'Hide Cards' : 'Show Cards'),
                    ),
                    */

                    // Player Name Display
                    Text(
                      'Player ${currentPlayerIndex + 1}: ${players[currentPlayerIndex].name}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),

                    // End Turn
                    ElevatedButton(
                      onPressed: _endTurn,
                      child: Text('End Turn'),
                    ),

                  ],
                ),
              ],
            ),  

            // Provide a gap
            SizedBox(height: 5),

            // =======================================================
            // Your hand display goes below
            // Scales cards to max width
            showCards
              ? buildPlayerHandLayout(players[currentPlayerIndex].hand, kCardHeight)
              : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showCards = !showCards;
                        });
                      },
                      child: Text(
                        '${players[currentPlayerIndex].name}\'s CARDS HIDDEN - Click here to show them',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
            //SizedBox(height: 16),
            //buildPlayerHandLayout(players[0].hand, kCardHeight*.5),
            //buildPlayerHandLayout(players[1].hand, kCardHeight*.5),

            //   SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}