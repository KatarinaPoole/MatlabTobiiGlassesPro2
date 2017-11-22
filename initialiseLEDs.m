% Initialise LEDs and tests all are working
global ardLED LED
ardLED = arduino;
LED.info = readtable('assignLEDs.txt','HeaderLines',0,'ReadVariableNames',1);
LEDorder = [1:1:height(LED.info) height(LED.info):-1:1];

% Forward and backwards Loop
for i = [1:1:height(LED.info) height(LED.info):-1:1]
    writeDigitalPin(ardLED,LED.info.Pin{i},1)
    pause(0.6)
    writeDigitalPin(ardLED,LED.info.Pin{i},0)
    pause(0.2)
end

% RGB fun
writeDigitalPin(ardLED,LED.info.Pin{3},1)
writeDigitalPin(ardLED,LED.info.Pin{4},1)
pause(1)

%Random Loop
for ii = randi([1, height(LED.info)],1,length(LEDorder))
    writeDigitalPin(ardLED,LED.info.Pin{ii},1)
    pause(0.1)
    writeDigitalPin(ardLED,LED.info.Pin{ii},0)
end
pause(1)
% Fast Forward and backwards Loop
for i = [1:1:height(LED.info) height(LED.info):-1:1]
    writeDigitalPin(ardLED,LED.info.Pin{i},1)
    pause(0.05)
    writeDigitalPin(ardLED,LED.info.Pin{i},0)
end

% Loop to run to turn everything off
for i = 1:height(LED.info)
    writeDigitalPin(ardLED,LED.info.Pin{i},0)
end