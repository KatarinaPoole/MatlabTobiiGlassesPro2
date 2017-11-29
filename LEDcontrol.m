% Arduino LED control in terms of location angle
function LEDcontrol (LocAz,LocEle,onoff,LEDcolour)
global ardLED LED
if exist('ardLED','var')
    pause(1.8) % need it in so it write ones the comm is opened properly
    switch onoff
        case 'on'
            switch LEDcolour
                case 'red'
                currPin = LED.info.R(LED.info.LocAz == LocAz &...
                    LED.info.LocEle == LocEle,1);
                case 'green'
                    currPin = LED.info.G(LED.info.LocAz == LocAz &...
                    LED.info.LocEle == LocEle,1);
                case 'blue'
                    currPin = LED.info.B(LED.info.LocAz == LocAz &...
                    LED.info.LocEle == LocEle,1);
                case 'yellow' %yellow is more green because the green is is so bright
                    currPin = [LED.info.R(LED.info.LocAz == LocAz &...
                    LED.info.LocEle == LocEle,1) LED.info.G(LED.info.LocAz...
                    == LocAz & LED.info.LocEle == LocEle,1)];
                case 'cyan'
                    currPin = [LED.info.G(LED.info.LocAz == LocAz &...
                    LED.info.LocEle == LocEle,1) LED.info.B(LED.info.LocAz...
                    == LocAz & LED.info.LocEle == LocEle,1)];
                case 'purple'
                    currPin = [LED.info.R(LED.info.LocAz == LocAz &...
                    LED.info.LocEle == LocEle,1) LED.info.B(LED.info.LocAz...
                    == LocAz & LED.info.LocEle == LocEle,1)];
            end
            for i = 1:length(currPin)
                fwrite(ardLED,uint8(currPin(i)));
            end
        case 'off'
            fwrite(ardLED, uint8(0));
    end
end