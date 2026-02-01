%% Initialize Cards
    % clear and clc cuz duh + create deck
clear; clc;
mainDeck = makeShuffledDeck();

%% Initialize Players+Dealer

% ask how many players 
numPlayers = input('How many players? ');

% initialize players
for i = 1:numPlayers
    players(i).balance = 100; % starting money
    players(i).bet = 0; % current bet
    players(i).hand = table(); % empty hand
    players(i).isBust = false; % bust status
    players(i).outcome = ""; % determined after total s
end 

% initializing dealer 
dealer.hand = table();
dealer.isBust = false; 
dealer.balance = 1000; 

% Deal initial 2 cards
for i = 1:2 % loops this twice to deal 2 cards
    for n = 1:numPlayers
        [mainDeck, players(n).hand] = dealCard(mainDeck, players(n).hand);
        % deals 1 card to each player
    end
    [mainDeck, dealer.hand] = dealCard(mainDeck, dealer.hand);
    % deals a card to the dealer
end

%% Begin Game



%% Dealer Decision Making
    % Very simple function, if hand >=17 stopp hitting
    % we can make this interesting with a randint modifier :)

%% Make Players Function, Give initial $, Deal Starting hands
    % Plan: Each character is a table
    % A column for their cards (which is a nested table)
    % A column for thier bets (run bet function to modify)

%% Deal Cards Function, Create Dealer, Hit/Stand
function [updatedDeck, updatedHand] = dealCard(currentDeck, currentHand)
    % Take the top card (row 1)
    cardDealt = currentDeck(1, :);
    
    % Append it to the player's hand table
    updatedHand = [currentHand; cardDealt];
    
    % Remove that card from the deck
    updatedDeck = currentDeck(2:end, :);
end

%% Calculate Player Hand (+Ace Consideration)
    % EZ just sum(playerHand.values) the values column
    % Make a conditional if value>21 check if there is an ace
    % If player has ace (do like a strfind in card name)
    %   Then subtract 10 from sum(playerHand.values)
    % If over 21, give player status that prevents them from 
    % getting more cards... like a bust logical or something

%% Money and Betting Function 

% Place Bet Function 
function player = placeBet(player, betAmount)

% Ensures betting amount doesn't exceed available balance
    if betAmount > player.balance
        error("Bet exceeds available balance");
    end 

% Ensures betting amount doesn't cause negative balance  
    if betAmount <= 0 
        error("Bet must be positive"); 
    end


    player.bet = betAmount; 
end 

%% Money Settle Function
function [player, dealer] = settleMoney(player, dealer, roundOutcome)

switch roundOutcome

    case "win" 
        player.balance = player.balance + player.bet * 2;
        dealer.balance = dealer.balance - player.bet;
    case "lose" 
        player.balance = player.balance - player.bet;   
        dealer.balance = dealer.balance + player.bet;
    case "push"
        % no money is exchanged
end

player.bet = 0; % bet is reset for next round
end

% plcaing bets for player(s)

for i = 1:numPlayers 
    betAmount = input(['Player ' num2str(i) , ', enter your bet: ']);
    players(i) = placeBet(players(i), betAmount); 
end

% determining outcome from hand

for i = 1:numPlayers 
    playerTotal = sum(players(i).hand.values);
    % these values need to be calcualted from card values !!!
    dealerTotal = sum(dealer.hand.values);
    % also these so work on these later lololol=

    if players(i).isBust 
        players(i).outcome = "lose"; 

    elseif dealer.isBust 
        players(i).outcome = "win"; 

    elseif playerTotal > dealerTotal 
        players(i).outcome = "win"; 

    elseif playerTotal < dealerTotal
        players(i).outcome = "lose"; 

    else 
        players(i).outcome = "push";

    end
end 


% settling monety for players function 

for i = 1:numPlayers
    [players(i), dealer] = settleMoney(players(i), dealer, players(i).outcome);
end

% print out all balances
 
for i = 1:numPlayers
    fprintf('Player %d: balance = %d, outcome = %s \n', i, players(i).balance, players(i).outcome);

end

% print ou tdealer balance 

fprintf('Dealer Balance = %d \n', dealer.balance);

%% Shuffle and Make Deck of Cards Function
function mainDeck = makeShuffledDeck()
myDeck = table(); 
% creates table "myDeck" for the cards

myVals = [2:10, repmat(10,[1,3]), 11];
% creates array of possible values (except 1)
myVals = repmat(myVals,[1,4]);
% make 4 copies of the values array
myDeck.values = myVals';
% creates column "values" in table myDeck, populates it with card values

mySuits = [repmat("Hearts",[1,13]),repmat("Diamonds", [1,13]),...
    repmat("Clubs", [1,13]), repmat("Spades", [1,13])];
% makes array of suits for the deck of cards
myDeck.suits = mySuits';
% creates column "suits" in table myDeck, populates it with suits

rankNames = ["2", "3", "4", "5", "6", "7", "8", "9", "10",...
    "Jack", "Queen", "King", "Ace"];
% Create a string array of the card value names
rankNames = repmat(rankNames, [1, 4])';
% Repeats the value names (for each suit), and transpose into column

myDeck.cardName = compose("%s of %s", rankNames, myDeck.suits);
% compose takes a string from rankNames concats with " of " and
    % concats again with the string from myDeck.suits
    % This produces the full card name (i.e., "Ace of Spades")

mainDeck = myDeck(randperm(height(myDeck)), :);
% Sets the output "mainDeck" with a shuffled version of myDeck
    % Code logic notes:
    % randperm randomizes rows 1 to 52 (# of cards)
    % : indicates columns remain unchanged (Values linked to Suits)
end

    