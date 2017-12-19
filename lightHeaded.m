% Little script to test the calibrate of head response from tobii with the
% LEDs
% Currently not working as hard to get a small sample of the response with
% Gy in so find a way to livestream the data from python?
initialiseLEDs;
% Load up the calibration
load(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'_temp_Head_Calibration.mat'))
pause(2)

% to avoid to short of a response (so that there is no Gy data, could start
% recording from longer before?)
while 1
LEDcontrol('Location','on','white',0,0)
GetClicks()
[responseFBAz,responseFBEle,currAngle,...
    currAccRoll,currAccPitch] = getHeadwithPython(calib,'clicks');
LocAz = round(responseFBAz/7.5)*7.5;
LocEle = round(responseFBEle/7.5)*7.5;
if LocAz > 52.5 
    LocAz = 52.5;
elseif LocAz < -52.5
    LocAz = -52.5;
end
LEDcontrol('Location','off')
LEDcontrol('Location','on','green',LocAz,0)
pause(1)
LEDcontrol('Location','off')
end










%
%
% LEDcontrol('Location','on','blue',0,15)
% disp('Click when ready')
% GetClicks()
% LEDcontrol('Location','off')
% currAz = 0;
% currEle = 0;
% LEDcontrol('Location','on','white',0,0)
% LocAz = 0;
% LocEle = 0;
% while 1
%     % Get the head reponse
%     [responseFBAz,responseFBEle,currAngle,...
%         currAccRoll,currAccPitch] = getHeadwithPython(calib,0,'live');
%     currAz = currAz + responseFBAz;
%     currEle = currEle + responseFBEle;
%     if LocAz ~= round(currAz/7.5)*7.5
%         LocAz = round(currAz/7.5)*7.5;
%         LocEle = round(currEle/7.5)*7.5;
%         LEDcontrol('Location','off')
%         LEDcontrol('Location','on','white',LocAz,0)
%     end
% end
%
%
% system('python livestream_data_live.py')

