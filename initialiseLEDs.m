% Initialise LEDs and tests all are working 

% Plug in cables from LED
% Cable 1 -> pin 5 top row
% Cable 3 -> pin 3 top row
% Cable 4 -> pin 6 top row

global ardLED LED
ardLED = serial('COM4','BaudRate',115200); % might be able to keep this open with Tobii glasses or may not
% Assign LED txt file has the location and the associated shift register
% pins (beginning at 1 rather than 0)
LED.info = readtable('assignLEDs.txt','HeaderLines',0,'ReadVariableNames',1);
    fopen(ardLED); %when opening the connection is causes the led to go white


%uninitialise
%     fclose(ardLED);

%     instrreset %need this at the beginning or the end if it doesn't close the connection properly
