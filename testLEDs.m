% Test script that goes through and makes sure all colours and LEDs work
instrreset
initialiseLEDs;
pause(2);
% Check all and in each Colour
for currLoc = 1:height(LED.info)
    LEDcontrol('Location','on','red',LED.info.LocAz(currLoc),...
        LED.info.LocEle(currLoc));
end
pause(10);
LEDcontrol('Location','off')
for currLoc = 1:height(LED.info)
    LEDcontrol('Location','on','green',LED.info.LocAz(currLoc),...
        LED.info.LocEle(currLoc));
end
pause(10);
LEDcontrol('Location','off')
LEDcontrol('Location','off')
for currLoc = 1:height(LED.info)
    LEDcontrol('Location','on','blue',LED.info.LocAz(currLoc),...
        LED.info.LocEle(currLoc));
end
pause(10);
LEDcontrol('Location','off')

% Christmas Lights - interestingly stops after a while. Something to do
% with the buffer?
colours = {'red','green','blue','yellow','cyan','purple','white'};
onoff = {'on','off'};
count = 1;
while true
    LEDcontrol('Location','on',colours{randi(7,1)},...
        LED.info.LocAz(randi(length(LED.info.LocAz),1)),...
        LED.info.LocEle(randi(length(LED.info.LocEle),1)))
    pause(0.1);
    LEDcontrol('Location','off')
    count = count + 1;
    if count == 200
        break
    end
end


% A way to test? Need to fix why after a while itll lag, soemthign to do
% with the output buffer?? (Currently put code in to flush it when turned
% off, but need to close and open to get it working again - so thats an
% easy fix
fclose(ardLED);
fopen(ardLED);
pause(2);
count = 1;
% while 1
    for currCol = 1:length(colours)
        for currLoc = 1:length(LED.info.LocAz)
            LEDcontrol('Location','on',colours{currCol},...
                LED.info.LocAz(currLoc),...
                LED.info.LocEle(currLoc))
        end
%         count = count + 1;
%         if count == 5
%             break
%         end
        pause(0.3);
        LEDcontrol('Location','off')
    end
% end