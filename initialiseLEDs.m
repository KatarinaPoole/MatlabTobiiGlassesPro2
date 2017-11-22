% Initialise LEDs and tests all are working
global ardLED
ardLED = arduino;
LEDinfo = readtable('assignLEDs.txt','HeaderLines',0,'ReadVariableNames',1);
LEDorder = [1:1:height(LEDinfo) height(LEDinfo):-1:1];

% Forward and backwards Loop
for i = [1:1:height(LEDinfo) height(LEDinfo):-1:1]
    writeDigitalPin(ardLED,LEDinfo.Pin{i},1)
    pause(0.6)
    writeDigitalPin(ardLED,LEDinfo.Pin{i},0)
    pause(0.2)
end

% RGB fun
writeDigitalPin(ardLED,LEDinfo.Pin{3},1)
writeDigitalPin(ardLED,LEDinfo.Pin{4},1)
pause(1)

%Random Loop
for ii = randi([1, height(LEDinfo)],1,length(LEDorder))
    writeDigitalPin(ardLED,LEDinfo.Pin{ii},1)
    pause(0.1)
    writeDigitalPin(ardLED,LEDinfo.Pin{ii},0)
end

% Fast Forward and backwards Loop
for i = [1:1:height(LEDinfo) height(LEDinfo):-1:1]
    writeDigitalPin(ardLED,LEDinfo.Pin{i},1)
    pause(0.05)
    writeDigitalPin(ardLED,LEDinfo.Pin{i},0)
end

% Loop to run to turn everything off
for i = 1:height(LEDinfo)
    writeDigitalPin(ardLED,LEDinfo.Pin{i},0)
end