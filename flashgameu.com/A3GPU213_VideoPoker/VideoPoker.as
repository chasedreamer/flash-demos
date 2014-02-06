﻿package {	import flash.display.*;	import flash.events.*;	import flash.text.*;	import flash.utils.Timer;		public class VideoPoker extends MovieClip {		// constants				// game objects		private var cash:int; // running total		private var bet:int = 1; // bet per deal		private var deck:Array; // shuffled deck of cards		private var playerHand:Array; // list of card values in hand		private var playerCards:Array; // list of card objects		private var cardsToDraw:Array; // which cards to draw				// keep track of future events		private var timedEvents:Timer;		private var timedEventsList:Array;				// set up deck, timer, buttons and deal first cards		public function startVideoPoker() {						// initial cash			cash = 100;			showCash();						// start game			createDeck();						// set up timed events list			timedEventsList = new Array();						// remove all buttons			removeChild(dealButton);			removeChild(drawButton);			removeChild(continueButton);						// start first hand			startHand();		}				// create a shuffled deck		private function createDeck() {			// create an ordered deck in an array			// using strings to represent card values			var suits:Array = ["c","d","h","s"];			var temp:Array = new Array();			for(var suit:int=0;suit<4;suit++) {				for(var num:int=1;num<14;num++) {					temp.push(suits[suit]+num);				}			}					// pick random cards until deck has been shuffled			deck = new Array();			while (temp.length > 0) {				var r:int = Math.floor(Math.random()*temp.length);				deck.push(temp[r]);				temp.splice(r,1);			}		}		// start checking every .25 seconds for an event to play out		private function startTimedEvents() {			timedEvents = new Timer(250);			timedEvents.addEventListener(TimerEvent.TIMER, playTimedEvents);			timedEvents.start();		}				// done with events for now		private function stopTimedEvents() {			timedEvents.stop();			timedEvents.removeEventListener(TimerEvent.TIMER, playTimedEvents);			timedEvents = null;		}				// add an event to the list to be played out soon		private function addTimedEvent(eventString) {			timedEventsList.push(eventString);		}				// see if there is a new event in the list and do it		private function playTimedEvents(e:TimerEvent) {			var thisEvent = timedEventsList.shift();			if (thisEvent == "deal card") {				dealCard(); // part of initial deal			} else if (thisEvent == "end deal") {				waitForDraw(); // initial deal complete			} else if (thisEvent == "draw card") {				drawCard(); // replace a card			} else if (thisEvent == "end draw") {				drawComplete(); // all card replacement complete, all done			}		}				// init hand arrays and bet		private function startHand() {						// empty player hand			playerHand = new Array();					playerCards = new Array();			cardsToDraw = new Array();			resultDisplay.text = "Press DEAL to start.";						addChild(dealButton);		}		// deal inital cards in hard		private function dealCards(e:MouseEvent) {						// take bet away from player			cash -= bet;			showCash();						// remove the deal button			removeChild(dealButton);					// add events to deal five cards			for(var i:int=0;i<5;i++) {				addTimedEvent("deal card");			}						// end to signify end of deal			addTimedEvent("end deal");						// start event timer			startTimedEvents();		}		// take one card from the deck and give it to the player or dealer		private function dealCard() {						// get the next card from the deck			var newCardVal:String = deck.pop();						// show it and add to hand			showCard(newCardVal);			playerHand.push(newCardVal);		}		// add a card object to the display		private function showCard(cardVal) {						// get a new card and add it to the screen			var newCard:Cards = new Cards();			newCard.gotoAndStop(cardVal);			newCard.y = 200;			newCard.x = 70*playerHand.length+100;			newCard.val = cardVal; // remember my value			newCard.pos = playerHand.length; // remember my position			newCard.addEventListener(MouseEvent.CLICK, clickDrawButton);			addChild(newCard);						// add to the array of card objects			playerCards.push(newCard);		}				// time for player to make a decision		private function waitForDraw() {						// show draw button and instructions			addChild(drawButton);			resultDisplay.text = "Click to turn over cards you want to discard.";						// stop the events timer for now			stopTimedEvents();		}				// click on a card to turn it over		private function clickDrawButton(e:MouseEvent) {						// get card clicked			var thisCard:MovieClip = MovieClip(e.currentTarget);						if (thisCard.currentFrame == 2) {				// if it has been turned over (frame 2) then turn back				thisCard.gotoAndStop(thisCard.val);							} else {				// turn over by going to frame 2				thisCard.gotoAndStop(2);			}		}				// see which cards should be replaced		private function drawCards(e:MouseEvent) {						// remove draw button			removeChild(drawButton);						// loop through all 5 cards			for(var i=0;i<playerCards.length;i++) {				if (playerCards[i].currentFrame == 2) {					// card is turned over, so add to list and set up event					cardsToDraw.push(i);					addTimedEvent("draw card");				}			}						// add end of all events, add one event to check results			addTimedEvent("end draw");						// start timer again			startTimedEvents();		}				// draw the next card replacement		private function drawCard() {						// which card to replace			var cardToDraw = cardsToDraw.shift();						// get a card from the deck			var newCardVal:String = deck.pop();						// change the card value to the new one			playerHand[cardToDraw] = newCardVal;			playerCards[cardToDraw].gotoAndStop(newCardVal);					}				// all cards drawn so check results		private function drawComplete() {						// get hand value and winnings			var handVal = handValue();			var win = winnings(handVal);						// show in text			resultDisplay.text = handVal+" = $"+win;						// award any winnings			cash += win;			showCash();						// show next button			addChild(continueButton);						// stop events for now			stopTimedEvents();		}				// start next hand		function endTurn(e:MouseEvent) {						// remove button			removeChild(continueButton);						// remove the old cards			while(playerCards.length > 0) {				removeChild(playerCards.pop());			}					// reshuffle deck and deal new hand			createDeck();			startHand();		}		// display cash with $		private function showCash() {			cashDisplay.text = "Cash: $"+cash;		}		// determine what the player has		private function handValue() {					// make a copy of the player's cards and sort them			var hand:Array = playerHand.slice();			hand.sort(compareHands);					// make arrays with suits and numbers for easy access			var suits:Array = new Array();			var nums:Array = new Array();			for(var i:int=0;i<5;i++) {				suits.push(hand[i].substr(0,1));				nums.push(Number(hand[i].substr(1,2)));			}					// see whether they are in perfect order			var straight:Boolean = true;			for(i=0;i<4;i++) {				if (nums[i] + 1 != nums[i+1]) straight = false;			}					// look for 10, J, Q, K and Ace			if ((nums[0] == 1) && (nums[1] == 10) && (nums[2] == 11) && (nums[3] == 12) && (nums[4] == 13))  straight = true;					// see whether they are all the same suit			var flush:Boolean = true;			for(i=1;i<5;i++) {				if (suits[i] != suits[0]) flush = false;			}					// make array of how much of each number is in hand			var counts:Array = new Array();			for(i=0;i<14;i++) {				counts.push(0);			}			for(i=0;i<5;i++) {				counts[nums[i]]++;			}					// use counts array to find matches			var pair:Boolean = false;			var twoPair:Boolean = false;			var threeOfAKind:Boolean = false;			var fourOfAKind:Boolean = false;			for(i=1;i<14;i++) {				// pair found				if (counts[i] == 2) {					// second pair found					if (pair) {						twoPair = true;					// first pair found					} else {						pair = true;					}				// three-of-a-kind				} else if (counts[i] == 3) {					threeOfAKind = true;				// four-of-a-kind				} else if (counts[i] == 4) {					fourOfAKind = true;				}			}					// see whether any matches are jacks or higher			var jackOrHigher:Boolean = false;			for(i=1;i<14;i++) {				if (((i == 1) || (i > 10)) && (counts[i] >= 2)) {					jackOrHigher = true;				}			}					// see whether hand has both king and ace			var hasKingAndAce:Boolean = false;			if ((counts[1]==1) && (counts[13]==1)) hasKingAndAce = true;					// return the type of hand the player has			if (straight && flush && hasKingAndAce) {				return("Royal Flush");			} else if (straight && flush) {				return("Straight Flush");			} else if (fourOfAKind) {				return("Four-Of-A-Kind");			} else if (pair && threeOfAKind) {				return("Full House");			} else if (flush) {				return("Flush");			} else if (straight) {				return("Straight");			} else if (threeOfAKind) {				return("Three-Of-A-Kind");			} else if (twoPair) {				return("Two Pair");			} else if (pair && jackOrHigher) {				return("High Pair");			} else if (pair) {				return("Low Pair");			} else {				return("Nothing");			}		}				// take the type of hand and return the amount won		function winnings(handVal) {			if (handVal == "Royal Flush") return 800;			if (handVal == "Straight Flush") return 50;			if (handVal == "Four-Of-A-Kind") return 25;			if (handVal == "Full House") return 8;			if (handVal == "Flush") return 5;			if (handVal == "Straight") return 4;			if (handVal == "Three-Of-A-Kind") return 3;			if (handVal == "Two Pair") return 2;			if (handVal == "High Pair") return 1;			if (handVal == "Low Pair") return 0;			if (handVal == "Nothing") return 0;		}			// this function is used by the sort command to		// decide which cards come first		private function compareHands(a,b) {					// get number value of cards			var numa:Number = Number(a.substr(1,2));			var numb:Number = Number(b.substr(1,2));					// return -1, 0, or 1 depending on comparison			if (numa < numb) return(-1);			if (numa == numb) return (0);			if (numa > numb) return (1);		}	}}