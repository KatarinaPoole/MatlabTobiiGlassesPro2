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
