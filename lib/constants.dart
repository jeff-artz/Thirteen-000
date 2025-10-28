// constants.dart
import 'package:flutter/material.dart';
import '../models/player.dart';

// Interface defaults
const double kCardHeight = 140.0;
double heightWCBar = 5;
// Interface Colors (Change to themes maybe?)
const colorBG = Color(0xFF006400);   // Background Color
const colorText = Colors.white;      // Text Color
const colorWildHL = Colors.orange;   // Wild Highlight Color

// Initial Game Play options
int HandSize = 3;
int NumDecks = 2;
int currentPlayerIndex = 0; // First player is #0 (Base 0)
bool showCards = true;
bool canDrawCard = true;

// MultiPlayer Setup
int NumPlayers = 2;         // Minimum of 2 players, 1 local, 1 AI or Web
List<Player> players = [];

// Card Names
const cardName = [
  'Joker', // 0
  'Ace',   // 1
  '2',     // 2
  '3',     // 3
  '4',     // 4
  '5',     // 5
  '6',     // 6
  '7',     // 7
  '8',     // 8
  '9',     // 9
  '10',    // 10
  'Jack',  // 11
  'Queen', // 12
  'King',  // 13
  'Ace',   // 14
  '2'      // 15
];

// Round Dropdown List Values
final List<Map<String, dynamic>> handSizeOptions = [
  {'label': '3', 'value': 3},
  {'label': '4', 'value': 4},
  {'label': '5', 'value': 5},
  {'label': '6', 'value': 6},
  {'label': '7', 'value': 7},
  {'label': '8', 'value': 8},
  {'label': '9', 'value': 9},
  {'label': '10', 'value': 10},
  {'label': '11 (J)', 'value': 11},
  {'label': '12 (Q)', 'value': 12},
  {'label': '13 (K)', 'value': 13},
  {'label': '14 (A)', 'value': 14},
  {'label': '15 (2)', 'value': 15},
];

  // Part of Meld checking
  int getWildcardValueForRound(int roundNumber) {
    // Round 3 → 3s are wild, Round 2 → 4s, ..., Round 13 → Kings
    // Round 14 → Aces, Round 15 → 2s
    return roundNumber == 13 ? 2 : roundNumber + 2;
  }
  bool isCardWild(int cardRank, int roundNumber) {
    final wildcardValue = getWildcardValueForRound(roundNumber);
    return cardRank == 0 || cardRank == wildcardValue;
  }