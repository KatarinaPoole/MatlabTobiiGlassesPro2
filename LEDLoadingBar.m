function LEDLoadingBar(time)
%LEDLOADINGBAR Loading bar made of LEDs
%   Loading bar of LEDS to indicate the amount of time left of a break for
%   experiment in seconds
% initialiseLEDs;
global LED

LocAz = [LED.info.LocAz(find(LED.info.LocAz));0];
LocEle = zeros(length(LocAz),1);
LocAz = sort(LocAz);

% Turn all Az LEDs on
for i = 1:length(LocAz)
    LEDcontrol('Location','on','blue',LocAz(i),LocEle(i))
end

% Turn off Az LEDs one by one
for i = length(LocAz):-1:1
    LEDcontrol('Location','off','blue',LocAz(i),LocEle(i))
    pause(time/length(LocAz))
end

end

