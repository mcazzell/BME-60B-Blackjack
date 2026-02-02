clear all; clc;
% clear workspace and command window

%% Enable or disable beer mode
% CHECKER: Validates y/n input
while true
    funChoice = input('Enable Fun Mode (beer mechanic)? (y/n): ','s');
   % this asks if the user wants the beer mechanic enabled
    if strcmpi(funChoice, 'y') || strcmpi(funChoice, 'n')
      %checks if the user inputs yes or no
        break;
        %will take either input and stop after
    else
        disp('Enter valid input');
        %checks if the input is y or n
    end
end

funMode = strcmpi(funChoice,'y');
%essentially saying fun mode is enabled if input == y

%% Initialize Players and the dealer
% Establishes global variable for num of players
global numPlayers;

% asks how many players 
% as well as Validates positive integer input
while true
    numPlayers = input('How many players? ');
    %gets the global variable value and replaces it with user input
    if isnumeric(numPlayers) && isscalar(numPlayers) && ...
            numPlayers > 0 && floor(numPlayers) == numPlayers
        break;
% these 4 parameters test the input:
% isnumeric checks if input is a number and not a string or character
% isscalar checks if the unput is a single number and not multiple like "1 3"
% "> 0" checks if the input is a positive integer
% floor checks if the input is a whole number, and rounds down


    else
        disp('Enter valid input');
%if one of the 4 parameters are not true, it asks for valid input
    end
end

% initialize player balance and beer stats
for i = 1:numPlayers
    players(i).balance = 100; % Give the players starting money: $100
    players(i).beers = 0;     % number of beers consumed
    players(i).drunkRisk = 0; % Chance of losing because too much beer
end 
% initializing dealer balance, 
dealer.balance = 1000; 

%% Begin Game Loop
%initialize the logic for keepPlaying
keepPlaying = true;

while keepPlaying == true %if the variable is true, the loop continues
    mainDeck = makeShuffledDeck(); %calls the deck
    
    % Reset round variables
    activePlayers = 0; % Count how many people can actually play and ...
    % and are not too intoxicated or broke
    
    for i = 1:numPlayers
        players(i).bet = 0; % initalizes player bet
        players(i).hand = table(); % initalizes individual player hand
        players(i).isBust = false; % initalizes individual player continuing
        players(i).outcome = ""; % initalizes individual  player outcome
        players(i).beers = 0;     % initalizes individual player beer count
        players(i).drunkRisk = 0; % initalizes individual player drunkRisk
    end
    dealer.hand = table(); %initalizes the dealer hand
    dealer.isBust = false; %begins as the dealer hasnt busted yet
    
    %% Placing bets
    fprintf('\n--- NEW ROUND ---\n'); %User Interface Stuff
    for i = 1:numPlayers %creates a loop that goes for each player
        if players(i).balance > 0 %checks to see if player is broke or not
            % CHECKER: Validates bet 
            validBet = false;
            while ~validBet %ensures that player has enough money
                betAmount = input(['Player ', num2str(i), ', your balance is ', ...
                    num2str(players(i).balance), ', enter your bet: ']);
            %UI stuff for player balance and asks for bet    
            
                % Check if numeric, positive, and player has enough money
                if isnumeric(betAmount) && isscalar(betAmount) && ...
                        betAmount > 0 && betAmount <= players(i).balance
                    validBet = true;
  % isnumeric checks if the player input is a number
  % isscalar checks if the player input is a single number
  % "> 0" checks if the input is a positive integer
  %Checks if the player has enough money to place a bet

                else
                    disp('Enter valid input (number less than or equal to balance).');
                   %if the player has bet too much money past their balance
                   %they are asked to enter a valid amount
                end
            end
            % Deducts bet immediately from players balance
            players(i) = placeBet(players(i), betAmount);
            %includes the player who placed a bet as an active player
            activePlayers = activePlayers + 1;
        else
            %if everything else is not true, the game assumes the player is
            %broke and cant ply
            fprintf('Player %d is broke and cannot bet this round.\n', i);
            players(i).bet = 0;
            players(i).outcome = "Sat Out"; % Mark them as not playing
        end
    end
    
    %Fidxed: If everyone is broke, the game ends.
    if activePlayers == 0 %checks if any active players
        fprintf('\nAll players are broke! The House Wins.\n');
        break; % Breaks the main while loop
    end
    
    %% Pregame beers (Fun Mode)
    if funMode %if fun mode is true
        for i = 1:numPlayers 
            % Fixed Idea: Ensure they have money AFTER their bet to buy beer.
            % Note: Since placeBet now deducts money immediately, 'players(i).balance'
            % represents the actual available funds.
            
            %I balanced the beer to 3 dollars because previously, 6 dollars
            %led me to think that the house was winning too much money
            if players(i).bet > 0 && players(i).balance >= 3
                %checks if the players bet at all, and if any player can
                %afford beer
                fprintf('\n*Player %d Pregame Beer Round* (Fun Mode enabled)\n', i);
                %user interface stuff
                while players(i).balance >= 3
                    fprintf('Money Remaining: $%d | Current Beer Risk: %.0f%%\n', ...
                        players(i).balance, players(i).drunkRisk*100);
                    % $%d is a placeholder for the balance, and this:
                    % %.0f%%\n' is a placeholder for the drunk risk
                    % percentage, and %.0f makes sure that ther are no
                    % numbers past the decimal point


                    % Checks and validates y/n
                    while true 
                        beerChoice = input('Buy a beer for $3? (y/n, pregame only): ','s');
                        %asks user to input yes or no to beer
                        if strcmpi(beerChoice,'y') || strcmpi(beerChoice,'n')
                    %strcmpi makes the input case insensitive, like Y or y
                    %And checks if both Y or N are inputed
                            break;
                        else
                         %if the input is not Y or N, it asks for valid
                         %input
                            disp('Enter valid input');
                        end
                    end
                    
                    if strcmpi(beerChoice,'y') %checks if player wants beer
                        %Deducts money from the players balance for beer
                        %and adds to the risk of the beer consumed. 
                        players(i).balance = players(i).balance - 3;
                        players(i).beers = players(i).beers + 1;
                        players(i).drunkRisk = min(players(i).beers*0.08,0.5);
                  %calculates the risk of too much beer; ex; 3 beers is 3 *
                  %0.008 = 24% risk amd gets player drunk risk. 
                        fprintf('Beer #%d consumed. Risk now: %.0f%%\n', ...
                            players(i).beers, players(i).drunkRisk*100);
                       %prints out the # of beers consumed and prints risk
                       %of losing to too much beer
                        
                        if rand < players(i).drunkRisk
             %rand makes a decimal number between 0 and 1
             %and the higher your number is, the more likely your are to
             %risk rand < risk
             %if this is true you drank too much beer and lose
                            fprintf('You drank to much and left the table!\n');
                            players(i).isBust = true; %sets logic for bust
                            players(i).outcome = "lose"; % Sets outcome immediately
                            break;
                        end
                    else
                        break;
                    end
                end
            end
        end
    end
    

    %% loop to Deal initial 2 cards for each player and the dealer at the end
    for i = 1:2 
        for n = 1:numPlayers
            % Only deal if they bet and aren't already busted from beer
            if players(n).bet > 0 && ~players(n).isBust
                %checks if player bet at all, and if the player hasnt
                %busted
                if funMode && i==1
                    %checks if beer enabled, and pulls cards from that
                    %biased deck
                    [mainDeck, players(n).hand] = dealCardBiased(mainDeck, players(n).hand, players(n).beers);
                else
                 %if there is no beer, the player gets a hand from the
                 %mainDeck
                    [mainDeck, players(n).hand] = dealCard(mainDeck, players(n).hand);
                end
            end
        end
        %the sober dealer pulls out of the main deck
        [mainDeck, dealer.hand] = dealCard(mainDeck, dealer.hand);
    end
    
    %% Player Turn Loops after pregaming
    for i = 1:numPlayers
        % Only runs turn if they have a bet and aren't busted
        if players(i).bet > 0 && ~players(i).isBust
            fprintf('\n*Player %d Turn*\n', i);
            [players(i), mainDeck] = playerTurn(players(i), mainDeck);
            %gets a card from the main deck
        end
    end
    
    %% Dealer AI lol
    % Only runs dealer if at least one player hasn't busted/sat out after
    % their turns
    anyoneAlive = false;
    for i=1:numPlayers
        if ~players(i).isBust && players(i).bet > 0
            %checks if the players are eligible to play
            anyoneAlive = true;
        end
    end

    if anyoneAlive %when this is true the dealer begins
        fprintf('\n*Dealer Turn*\n');
        disp(dealer.hand(:, {'cardName'}));
        dealerTotal = calculateTotal(dealer.hand);
        fprintf('Dealer Total: %d\n', dealerTotal);
        
        while calculateTotal(dealer.hand) < 17
            %once the dealer has 2 cards, if those cards are less than 17,
            %the dealCard function is called and the dealer is dealt a card
            fprintf('Dealer hits...\n');
            [mainDeck, dealer.hand] = dealCard(mainDeck, dealer.hand);
            disp(dealer.hand(:, {'cardName'}));
            fprintf('Dealer Total: %d\n', calculateTotal(dealer.hand));
        end
        
        dealerTotal = calculateTotal(dealer.hand);
        %calculates the dealers hand value after picking another card
        if dealerTotal > 21
            %if the dealer has a hand greater than 21 house loses
            fprintf('Dealer Busted!\n');
            dealer.isBust = true;
        else
            %if the dealer has a hand between 21 and 17, the dealer stands
            %out of safety
            fprintf('Dealer stands.\n');
        end
    end
    
    %% Win/Lose/Push Stuff
    for i = 1:numPlayers %essentially checks each player
        %If player didn't bet (already marked "Sat Out" or Bust from beer)
        if players(i).bet == 0
             continue; 
        end
        
        % If a player has alread already busted with a beer or Hit they lose. 
        if players(i).isBust
            players(i).outcome = "lose";
            continue;
        end
        %variable in the loop is created to compare the players hand total
        %and the dealer hand total
        playerTotal = calculateTotal(players(i).hand);
        dealerTotal = calculateTotal(dealer.hand);
        
        if dealer.isBust %if the dealer busted, anyone "standing" will win
            players(i).outcome = "win"; 
        elseif playerTotal > dealerTotal 
            %if the player standing has a higher stand than the standing
            %dealer, they win
            players(i).outcome = "win"; 
        elseif playerTotal < dealerTotal
            players(i).outcome = "lose"; 
            %if the dealer standing has a higher stand than the player,
            %dealer wins
        else 
            players(i).outcome = "push";
            %if the values are equal, the player is given back their bet
        end
    end 
    
    %% Distributing Moeney
    fprintf('\n--- ROUND RESULTS ---\n');
    %UI Stuff
    for i = 1:numPlayers
        [players(i), dealer] = settleMoney(players(i), dealer, players(i).outcome);
        fprintf('Player %d: balance = %d, outcome = %s \n', i,...
            players(i).balance, players(i).outcome);
        %prints out the players balance and their outcome
    end
    fprintf('Dealer Balance = %d\n', dealer.balance);
    %prints dealer balance last
    
    %% Game Loop Reset
    % checks for Y or N if the player wants to continue
    while true
        choice = input('\nPlay another round? (y/n): ', 's');
        if strcmpi(choice, 'y') || strcmpi(choice, 'n')
            break;
            %uses either capital Y or y for input
        else
            disp('Enter valid input');
            % if Y or N not inputed, asks for valid input
        end
    end
    
    if ~strcmpi(choice, 'y')
        %if the answer is n, the logic that continues the main loop is set
        %to false, ending the loop
        keepPlaying = false;
        fprintf('Thanks for playing at the Anteater Casino and Bar!\n');
    end
end
%% Neded functions
% player hit/stand Turn function 
function [players, mainDeck] = playerTurn(players, mainDeck)
    isStanding = false;
    while ~players.isBust && ~isStanding
        %checks if the player busted and is still standing
        currentTotal = calculateTotal(players.hand);
        %calculates total hand value
        disp(players.hand(:, {'cardName'}));
        fprintf('Current Total: %d\n', currentTotal);
        %prints hand total
        
        if currentTotal > 21
            %if the hand total is greater than 21 player busts out
            fprintf('BUST!\n');
            players.isBust = true;
            break;
            %ends the loop for the player if they busted.
        end
        
        % Hit/Stand 
        validMove = false;
        while ~validMove %if the player has a valid input, they either hit or stand
            choice = input('Would you like to (h)it or (s)tand? ', 's');
            if strcmpi(choice, 'h') || strcmpi(choice, 's')
                validMove = true;
            else
                disp('Enter valid input');
                %if h or s is not inputed, the user is prompted to enter
                %the correct input
            end
        end
        
        if strcmpi(choice, 'h')
            [mainDeck, players.hand] = dealCard(mainDeck, players.hand);
            %if they hit, they draw a card
        else
            isStanding = true;
            %if they didnt hit, they are standing
        end
    end
end
%% Bet Function 

function player = placeBet(player, betAmount)
    %bet is deducted from the balance
    player.bet = betAmount; 
    player.balance = player.balance - betAmount;
end 
%% Money Dealing Function
function [player, dealer] = settleMoney(player, dealer, roundOutcome)
    % Fix from earlier: Logic now assumes bet was already deducted
    switch roundOutcome
   %switch looks at the text from roundOutcome
        case "win" 
     %of roundOutcome = win, the bet is double and given back to the
     %player from the dealer
            player.balance = player.balance + (player.bet * 2);
            dealer.balance = dealer.balance - player.bet;
        case "lose" 
            % Money is already gone from placeBet function so the dealer
            % gets the money
            dealer.balance = dealer.balance + player.bet;
        case "push"
            % Return the original bet to the player because of the draw
            player.balance = player.balance + player.bet;
        case "Sat Out"
            % If the player Sat out, nothing happens
    end
    player.bet = 0; %resets the bet value for the next game
end

%% Calculate Hand Value

%calculates the total of the hand of the player 
function total = calculateTotal(handTable)
    if isempty(handTable)
        total = 0;
        return;
    end
    
    %sums the values column of the table
    values = handTable.values;
    total = sum(values);
    
    %Ace logic: Makes Aces 11 
    %counts number of ACes
    numAces = sum(values == 11);
    % if the total goes above 21, and the hand has aces the following
    % happens
    while total > 21 && numAces > 0 
        total = total - 10; %substracts 10 because Ace is set to val of 1
        numAces = numAces - 1; % does this for only one ace
    end
end
%% Shuffle/ Make Deck
function mainDeck = makeShuffledDeck()
    myDeck = table(); %initilizes deck
    myVals = [2:10, repmat(10,[1,3]), 11]; 
    %gets values from 2-10, 3 face cards, and ace
    myVals = repmat(myVals,[1,4]);
    %repeats this 4 times for each suite
    myDeck.values = myVals';
    %makes values column
    
    %creates suites of 13
    mySuits = [repmat("Hearts",[1,13]),repmat("Diamonds", [1,13]),...
        repmat("Clubs", [1,13]), repmat("Spades", [1,13])];
    myDeck.suits = mySuits'; % makes suits column
    rankNames = ["2", "3", "4", "5", "6", "7", "8", "9", "10",...
        "Jack", "Queen", "King", "Ace"]; %gives each card a name
    rankNames = repmat(rankNames, [1, 4])'; %does this for each suite
    myDeck.cardName = compose("%s of %s", rankNames, myDeck.suits);
    % randperm(height(myDeck)) gives a random list of numbers from 1
    % to the lenght of the deck
    % We use this list to re-order the rows of the table randomly.
    mainDeck = myDeck(randperm(height(myDeck)), :); 
end
%% Deal Cards Function
function [deck, playerHand] = dealCard(deck, playerHand)
%gets the playerHand and grabs card from the deck and adds to player hand
    card = deck(1,:);
    playerHand = [playerHand; card];
    deck(1,:) = []; %sets the taken card, and shortens the list by 1
end
%% Deal biased cards because of the beer effect
function [deck, playerHand] = dealCardBiased(deck, playerHand, beers)
%gets the current deck, the player had, and number of beers
% and it outputs a biased deck based on the # of beers
    if beers > 0 && rand < min(0.1 * beers, 0.7)
        %checks if the player drank at least one beer 
        %beers increase your chance of getting a higher card by 10%, and it
        %caps at 70%
        highIdx = find(deck.values >= 10);
        %this checks for rows with values >= 10
        pick = highIdx(randi(length(highIdx)));
        %length(highIdx) checks how many cards are higher than 9 and picks
        %between that number, picking the index of this list
    else
        pick = 1; %if not, the first card of the maindeck will be picked, 
        %ike normal
    end
    card = deck(pick,:);
    %copies the card
    playerHand = [playerHand; card];
    %adds card to the bottom of your hand
    deck(pick,:) = [];
    %deletes the row from which the card was dealt so its not picked again.
    %
end
