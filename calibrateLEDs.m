% Function to assign/map LEDs to their correct shift register pin in assign
% LEDs.txt file
clear all
instrreset;
initialiseLEDs;
Type = input('Remap all LEDs? [Y/N]  ','s');
varNames = {'LocAz','LocEle','R','G','B'};
if Type == 'Y' || Type == 'y'
    currPin = 1;
elseif Type == 'N' || Type == 'n'
    currPin = table2array(LED.info(end,end));
end
while true
    LEDcontrol('Number','on',[],currPin)
    userOnOff = input('Is an LED on? [Y/N]    ','s');
    if userOnOff == 'Y' || userOnOff == 'y'
        LocAz(currPin) = input('What is the Azimuth location in signed degrees (Left is negative)?   ');
        LocEle(currPin) = input('What is the Elevation location in signed degrees (Down is negative)?    ');
        Colour{currPin} = input('What is the colour of the LED? [R/G/B]    ','s');
    else userOnOff == 'N' || userOnOff == 'n';
        userFin = input('Are you finished? [Y/N]','s');
        if userFin == 'Y' || userFin == 'y'
            LEDcontrol('Number','off',[],currPin)
            break
        elseif userFin == 'N' || userFin == 'n'
            LocAz(currPin) = NaN; LocEle(currPin) = NaN; Colour{currPin} = NaN;
        end
    end
    LEDcontrol('Number','off',[],currPin)
    currPin = currPin + 1;
end

% Delete all the NaN's
alllocations = [LocAz',LocEle'];
noNanlocations = unique([LocAz(~isnan(LocAz))' LocEle(~isnan(LocEle))'],'rows');

% Make vars for the table
for currLoc = 1:size(noNanlocations,2)
    currPins = find(noNanlocations(currLoc,1) == alllocations(:,1)&...
        noNanlocations(currLoc,2)==alllocations(:,2));
    % Make the table
    tabLocAz(currLoc) = noNanlocations(currLoc,1);
    tabLocEle(currLoc) = noNanlocations(currLoc,2);
    try
    tabR(currLoc) = currPins(find(contains(Colour(currPins),'R')));
    end
    try
    tabG(currLoc) = currPins(find(contains(Colour(currPins),'G')));
    end
    try
    tabB(currLoc) = currPins(find(contains(Colour(currPins),'B')));
    end
end

table = [tabLocAz', tabLocEle', tabR', tabG', tabB'];

% Write to text
fileID = fopen(sprintf('%s','C:\Psychophysics\assignLEDs',date,'.txt'),'w');
if Type == 'Y' || Type == 'y'
    fprintf(fileID,'%s\t %s\t %s\t %s\t %s\r\n','LocAz','LocEle','R','G','B');
end
fprintf(fileID,'%g\t %g\t %g\t %g\t %g\r\n',table');
fclose(fileID)

