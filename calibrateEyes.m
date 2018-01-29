% Function to calibrate eye (i.e get the agle limits of the scene camera
% and associate the gp3 with angles)
clear all; close all
instrreset;

% Intialisation
initialiseLEDs;
pause(2);
calibrateTobii('Test')

% Variables
locations = readtable('EyeCalibrationLocations.txt');
noLocs = size(locations,1);
currRow = 1;
clicks = 0;
noReps = 3;

%Get first response and new calibration parameters
try
    load(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'_temp_Head_Calibration.mat'))
catch
    disp('Please put the glasses on a flat surface and press any key when ready')
    KbStrokeWait;
    LEDcontrol(0,0,'on')
    [~,~,currAngle,currAccRoll,currAccPitch] = getHeadwithPython(calib,5);
    t = 1:length(currAngle.X);
    calib.Pitch = mean(currAccPitch);
    calib.Roll = mean(currAccRoll);
    fitvars = polyfit(t,currAngle.Y,1);
    calib.Y = fitvars(1); % botch way of canceling out the drift
    disp('Applying the calib')
    save(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'_temp_Head_Calibration.mat'),'calib')
end


disp('Response calibration time, press any key when ready and click the mouse when sitting and looking at the centre light')
KbStrokeWait;
disp('Head facing red light and eyes on the white light')

% Light up required headposition
LEDcontrol('Location','on','red',0,0)
calibEyeResponses = cell(noReps,noLocs,4);
count = 1;
for currRep = 1:noReps
    LocOrder = randperm(noLocs);
    for currLoc = 1:noLocs
        % Light centre light
        LEDcontrol('Location','off');
        LEDcontrol('Location','on','white',0,0);
        GetClicks();
        if count == 1
            system('python stayingalive.py'); %Take about a second so may only need this at the begininng of most responses
        end
        LEDcontrol('Location','off');
        LEDcontrol('Location','on','red',0,0);
        % Light up target light
        pause(0.1)
        LEDcontrol('Location','on','white',locations.Azimuth(LocOrder(currLoc)),...
            locations.Elevation(LocOrder(currLoc)));
        [Gp3,Gp3Ts,responseFBAz,responseFBEle,currAngle] = getHeadandEyeswithPython(calib,'clicks');
        LEDcontrol('Location','off');
        calibEyeResponses{currRep,LocOrder(currLoc),1:4} = {locations.Azimuth(LocOrder(currLoc));...
            locations.Elevation(LocOrder(currLoc));Gp3;Gp3Ts};
        count = count + 1;
    end
end
save(sprintf('%s','C:\Psychophysics\EyeCalibrations\',date,'calibEyeResponsesTake2.mat'),'calibEyeResponses')

%Post processing of Gp3 data
for i = 1:length(Gp3)
    if Gp3(i,4) ~= 0
        Gp3(i,1:3) = NaN;
    end
end

% Need to somehow get livestream of the scene camera, clashes with pygst
% and Gstreamer (psychtoolbox) - this needs fixing!

% or get it offline, but means it will be difficult to tailor it to other
% participants, but this may not be necessary (though with different
% heights it probably will but could do some post adjustment by doing other
% calibration


% Will need to check multiple head positions so have certian light for head
% position and acertina light for where the eye should be.
% Need to identify the limit of the scene camera as well