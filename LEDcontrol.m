% Arduino LED control in terms of location angle
function LEDcontrol (LocAz,LocEle,parameter)
global ardLED LED
currLED = LED.info.Pin(find(LED.info.LocAz == LocAz & LED.info.LocEle == LocEle),1);

switch parameter
    case 'on'
        for i = 1:length(currLED)
            writeDigitalPin(ardLED,currLED{i},1)
        end
    case 'off'
        for i = 1:length(currLED)
            writeDigitalPin(ardLED,currLED{i},0)
        end
end