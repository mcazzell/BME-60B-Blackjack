function numPlayers = getNumPlayers()
% Prompts user to enter number of players (excluding dealer)
% Ensures valid numeric input

validInput = false;

while ~validInput
    numPlayers = input('Enter number of players (1–5): ');
    
    if isnumeric(numPlayers) && numPlayers >= 1 && numPlayers <= 5 && mod(numPlayers,1)==0
        validInput = true;
    else
        disp('Invalid input. Please enter an integer between 1 and 5.');
    end
end
end
