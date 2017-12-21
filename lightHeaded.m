% Little script to test the calibrate of head response from tobii with the
% LEDs
% not working that well since need to constantly livestream the data
% otherwise it misses movements and therefore the tracking isn't accurate
initialiseLEDs;
% Load up the calibration
load(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'_temp_Head_Calibration.mat'))
pause(2)
system('python stayingalive.py'); %Take about a second so may only need this at the begininng of most responses
LEDcontrol('Location','on','white',0,0)
GetClicks()
% to avoid to short of a response (so that there is no Gy data, could start
% recording from longer before?)
currAz = 0;
currEle = 0;
while 1
LEDcontrol('Location','off')
[responseFBAz,responseFBEle,currAngle,...
    currAccRoll,currAccPitch] = getHeadwithPython(calib,0.5);
currAz = currAz + responseFBAz;
currEle = currEle + responseFBEle;
LocAz = round(currAz/7.5)*7.5;
LocEle = round(currEle/7.5)*7.5;
if LocAz > 52.5 
    LocAz = 52.5;
elseif LocAz < -52.5
    LocAz = -52.5;
end
LEDcontrol('Location','on','green',LocAz,0)
end


% In order to get the eyes to work need 
% Either 8m or 94cm away









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

