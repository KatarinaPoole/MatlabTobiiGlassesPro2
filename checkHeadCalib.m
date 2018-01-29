% Check calibration is good for the participant - put in a part which
% just plots the reposne versu the actual locatin
function checkHeadCalib(partName)
clear all; close all
instrreset;
% Initialisation
initialiseLEDs;
pause(2);
% Variables
locations = readtable('CalibrationLocations.txt');
noLocs = size(locations,1);
currRow = 1;
clicks = 0;
noReps = 3;

files = dir(sprintf('%s','C:\Psychophysics\HeadCalibrations\',partName));
load(sprintf('%s','C:\Psychophysics\HeadCalibrations\',partName,'\',files(end).name))



% To avoid just getting one tobii cell need to presend a keep alive message
disp('Response calibration time, press any key when ready and click the mouse when sitting and looking at the centre light')
KbStrokeWait;
calibResponses = zeros(4,noReps,noLocs);
currCount = 1;
for currRep = 1:noReps
    % Randomise the locations
    LocOrder = randperm(noLocs);
    for currLoc = 1:noLocs
        % Light centre light
        LEDcontrol('Location','on','white',0,0);
        GetClicks();
        if currCount == 1
            system('python stayingalive.py'); %Take about a second so may only need this at the begininng of most responses
        end
        LEDcontrol('Location','off');
        % Light up target light
        pause(0.1)
        LEDcontrol('Location','on','white',locations.Azimuth(LocOrder(currLoc)),...
            locations.Elevation(LocOrder(currLoc)));
        [responseFBAz,responseFBEle] = getHeadwithPython(calib,...
            'clicks',0);
        fprintf('%s %s %s %s %s\n','Subject response location was at ',num2str(responseFBAz),...
            ' degrees in Azimuth and ',num2str(responseFBEle),' degrees in Elevation.')
        LEDcontrol('Location','off');
        calibResponses(:,currRep,LocOrder(currLoc)) = [locations.Azimuth(LocOrder(currLoc)),...
            responseFBAz,locations.Elevation(LocOrder(currLoc)),responseFBEle];
        currCount = currCount +1;
    end
end

end