clear; clc;

mainDeck = makeShuffledDeck();
players = makePlayers();

function myPlayers = makePlayers()
myPlayers = table();
%think player name, balance, hand

names=[];
nPlayers=input("How many players at the table? ");

for i = 1:nPlayers
    names{i} = string(input("Player " + i + " name: ","s"));
    %curly bracket = cell, fixes things somehow???
end

myPlayers.name = names';
myPlayers.money = repmat(10,[nPlayers,1]);


%Start dealing cards
for i = 1:nPlayers
    myPlayers.hand(i) = mainDeck.cardName(1)
    %update playing deck
    mainDeck(1, :) = [];
end

end

function mainDeck = makeShuffledDeck()

J = 10;
Q = 10;
K = 10;
royals = [J, Q, K];
    % Is it possible to have these display as the J/Q/K?

myVals = [2:10, royals, 11];
% creates array of possible values (except 1)
myVals = repmat(myVals,[1,4]);
% make 4 copies of the values array
mySuits = [repmat("Hearts",[1,13]),repmat("Diamonds", [1,13]),...
    repmat("Clubs", [1,13]), repmat("Spades", [1,13])];
% makes array of suits for the deck of cards

myDeck = table(); 
% creates table "myDeck" for the cards
myDeck.values = myVals';
% creates column "values" in table myDeck, populates it with card values
myDeck.suits = mySuits';
% creates column "suits" in table myDeck, populates it with suits


% PLAN: write a name for each card i.e., Ace of Spades, 2 of Hearts
% There is def a in-built function that can like repeat a string




shuffledDeck = myDeck(randperm(height(myDeck)), :);
% creates new table "shuffledDeck" with a shuffled version of myDeck
    % Code logic notes:
    % randperm randomizes rows 1 to 52 (# of cards)
    % : indicates columns remain unchanged (Values linked to Suits)
    % the initial myDeck(...) indicates this table
mainDeck = shuffledDeck;
% sets the output to the shuffledDeck

end