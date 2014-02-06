﻿package {	import flash.display.*;	import flash.events.*;	import flash.text.*;	import flash.utils.Timer;		public class Blackjack extends MovieClip {		// game objects		private var cash:int; // keep track of money		private var bet:int; // this bet		private var deck:Array; // starts with all card values		private var playerHand:Array; // player's card values		private var dealerHand:Array; // dealer's card values		private var dealerCard:Cards; // reference to face-down card		private var cards:Array; // all cards, for clean-up				// timer for future events		private var timedEvents:Timer;		private var timedEventsList:Array;				// set up buttons and deal first card		public function startBlackjack() {						// initial cash			cash = 100;			showCash();			cards = new Array();						// start game			createDeck();						// set up timed events list			timedEventsList = new Array();						// remove all buttons			removeChild(addBetButton);			removeChild(dealButton);			removeChild(hitButton);			removeChild(stayButton);			removeChild(continueButton);						// start first hand			startHand();		}				// create a shuffled deck		private function createDeck() {			// create six ordered decks in an array			// using strings to represent card values			var suits:Array = ["c","d","s","h"];			var temp = new Array();			for (var i:int=0;i<6;i++) {				for(var suit:int=0;suit<4;suit++) {					for(var num:int=1;num<14;num++) {						temp.push(suits[suit]+num);					}				}			}					// pick random cards until deck has been shuffled			deck = new Array();			while (temp.length > 0) {				var r:int = Math.floor(Math.random()*temp.length);				deck.push(temp[r]);				temp.splice(r,1);			}		}		// init hand arrays and bet		private function startHand() {						// empty player and dealer hands			playerHand = new Array();			dealerHand = new Array();			playerValueDisplay.text = "";			dealerValueDisplay.text = "";						// start off each hand with smallest bet and deal card hidden			bet = 5;			showBet();						// show buttons			addChild(addBetButton);			addChild(dealButton);			resultDisplay.text = "Add to your bet if you wish then press Deal Cards.";		}		// allow the player to increase her bet up to $25		private function addToBet(e:MouseEvent) {			bet += 5;			if (bet > 25) bet = 25; // limit bet			showBet();		}				// start checking every second for an event to play out		private function startTimedEvents() {			timedEvents = new Timer(1000);			timedEvents.addEventListener(TimerEvent.TIMER, playTimedEvents);			timedEvents.start();		}				// done with events for now		private function stopTimedEvents() {			timedEvents.stop();			timedEvents.removeEventListener(TimerEvent.TIMER, playTimedEvents);			timedEvents = null;		}		// see if there is a new event in the list and do it		private function playTimedEvents(e:TimerEvent) {			var thisEvent = timedEventsList.shift();			if (thisEvent == "deal card to dealer") {				dealCard("dealer");			} else if (thisEvent == "deal card to player") {				dealCard("player");				showPlayerHandValue();			} else if (thisEvent == "end deal") {				if (!checkForBlackjack()) {					waitForHitOrStay();				}			} else if (thisEvent == "show dealer card") {				showDealerCard();			} else if (thisEvent == "dealer move") {				dealerMove();			}		}				// add an event to the list to be played out soon		private function addTimedEvent(eventString) {			timedEventsList.push(eventString);		}				// deal inital cards in hard		private function dealCards(e:MouseEvent) {						// take bet away from player			cash -= bet;			showCash();						// add events to deal first cards			addTimedEvent("deal card to dealer");			addTimedEvent("deal card to player");			addTimedEvent("deal card to dealer");			addTimedEvent("deal card to player");			addTimedEvent("end deal");			startTimedEvents();					// switch buttons			removeChild(addBetButton);			removeChild(dealButton);		}		// take one card from the deck and give it to the player or dealer		private function dealCard(toWho) {						// get the next card from the deck			var newCardVal:String = deck.pop();						if (toWho == "player") {				// if it goes to the player, then show it and update hand value				playerHand.push(newCardVal);				showCard(newCardVal,"player");							} else {				// if it goes to the dealer, then show it, but only update hand value later				dealerHand.push(newCardVal);				showCard(newCardVal,"dealer");			}		}		// add a card object to the display		private function showCard(cardVal, whichHand) {						// get a new card			var newCard:Cards = new Cards();			newCard.gotoAndStop(cardVal);						// set the position of the new card			if (whichHand == "dealer") {				newCard.y = 100;				if (dealerHand.length == 1) {					// show back for first dealer card					newCard.gotoAndStop("back");					dealerCard = newCard;				}				var whichCard:int = dealerHand.length;							} else if (whichHand == "player") {				newCard.y = 200;				whichCard = playerHand.length;			}			newCard.x = 70*whichCard;						// add the card			addChild(newCard);			cards.push(newCard);		}				// time for player to make a decision		private function waitForHitOrStay() {			addChild(hitButton);			addChild(stayButton);			timedEvents.stop();		}				// player draws another card		private function hit(e:MouseEvent=null) {			dealCard("player");			showPlayerHandValue();					// if player gets 21 or more, go to dealer			if (handValue(playerHand) >= 21) stay();		}		// player done, so show dealer's first card and continue		private function stay(e:MouseEvent=null) {			removeChild(hitButton);			removeChild(stayButton);			addTimedEvent("show dealer card");			addTimedEvent("dealer move");			startTimedEvents();		}		// player stays, so time to show dealer card and hand value so far		private function showDealerCard() {			dealerCard.gotoAndStop(dealerHand[0]);			showDealerHandValue();		}		// dealer gets a card		private function dealerMove() {			if (handValue(dealerHand) < 17) {				// dealer still doesn't have 17, so must continue to draw				dealCard("dealer");				showDealerHandValue();				addTimedEvent("dealer move");							} else {				// dealer is done				decideWinner();				stopTimedEvents();				showCash();				addChild(continueButton);			}		}		// calculate hand value		private function handValue(hand) {			var total:int = 0;			var ace:Boolean = false;					for(var i:int=0;i<hand.length;i++) {				// add value of card				var val:int = parseInt(hand[i].substr(1,2));						// jack, queen, and king = 10				if (val > 10) val = 10;				total += val;						// remember if an ace is found				if (val == 1) ace = true;			}					// ace can = 11 if it doesn't bust player			if ((ace) && (total <= 11)) total += 10;					return total;		}		// check to see whether either has blackjack		private function checkForBlackjack():Boolean {					// if player has blackjack			if ((playerHand.length == 2) && (handValue(playerHand) == 21)) {				// award 150 percent winnings				cash += bet*2.5;				resultDisplay.text = "Blackjack!";				stopTimedEvents();				showCash();				addChild(continueButton);				return true;			} else {				return false;			}		}		// see who won, or if there is a tie		private function decideWinner() {			var playerValue:int = handValue(playerHand);			var dealerValue:int = handValue(dealerHand);			if (playerValue > 21) {				resultDisplay.text = "You Busted!";			} else if (dealerValue > 21) {				cash += bet*2;				resultDisplay.text = "Dealer Busts. You Win!";			} else if (dealerValue > playerValue) {				resultDisplay.text = "You Lose!";			} else if (dealerValue == playerValue) {				cash += bet;				resultDisplay.text = "Tie!";			} else if (dealerValue < playerValue) {				cash += bet*2;				resultDisplay.text = "You Win!";			}		}		// start next hand		function newDeal(e:MouseEvent) {			removeChild(continueButton);			resetCards();					// if deck has less than 26 cards, reshuffle			if (deck.length < 26) {				createDeck();			} else {				startHand();			}		}		private function showPlayerHandValue() {			playerValueDisplay.text = handValue(playerHand);		}		private function showDealerHandValue() {			dealerValueDisplay.text = handValue(dealerHand);		}		// display cash with $		private function showCash() {			cashDisplay.text = "Cash: $"+cash;		}		// display bet with $		private function showBet() {			betDisplay.text = "Bet: $"+bet;		}		// remove cards from table		function resetCards() {			while(cards.length > 0) {				removeChild(cards.pop());			}		}	}}