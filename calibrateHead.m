% Calibrate Head Tracking in Tobii for the Psychophsyics Booth
clear all
% Initialisation
% initialiseLEDs;

% system('python livestream_data.py clicks') % to check python functions

% A quick way to check Tobii is all connected
tobiiTalk = udp('[fe80::76fe:48ff:fe19:fbaf]',49152); %the address and port
keepAlive = jsonencode(struct('op','start','type','live.data.unicast',...
    'key','staying_alive_staying_alive'));
fopen(tobiiTalk);
fwrite(tobiiTalk,keepAlive)
checkonTobii = fscanf(tobiiTalk,'%s');
if ~isempty(checkonTobii)
    disp('Tobii connected')
else
    error('Tobii not connected, unconnect to VPN') %check if on VPN (could potential affect it)
end
fclose(tobiiTalk); clear checkonTobii

% Variables
noReps = 3; %change to increase or decrease reliability
locations = readtable('CalibrationLocations.txt');
noLocs = size(locations,1);
currRow = 1;
clicks = 0;

% Init calib parameters
calib.Pitch = 0;
calib.Roll = 0;
calib.X = 0;
calib.Z = 0;
calib.Y = 0;

%Get first response and new calibration parameters
if isempty(dir('C:\Psychophysics\HeadCalibrations\*.mat')) %change this if loop
    LEDcontrol(0,0,'on')
    [~,~,currAngle,currAccRoll,currAccPitch] = getHeadwithPython(calib,5,[],[]);
    t = 1:length(currAngle.X);
    calib.Pitch = mean(currAccPitch);
    calib.Roll = mean(currAccRoll);
    fitvars = polyfit(t,currAngle.Y,1);
    calib.Y = fitvars(1); % botch way of canceling out the drift
    disp('Applying the calib')
    save(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'_temp_Head_Calibration.mat'),'calib')
else
    load(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'_temp_Head_Calibration.mat'))
end

disp('Checking calibration')
% Check calibration
% [~,~,currAngle,currAccRoll,currAccPitch] = getHeadwithPython(calib,10,[],[]);

% Run throuh all the calibration locations and get reponse angles for each
% of them
% figure('Name','One repeat responses');
% %Just one repeat (put in code for more repeats)
% for currLoc = 1:noLocs
%     disp(sprintf('%s','Please look to the location of ',...
%         num2str(locations.Azimuth(currLoc)),' in azimuth and ',...
%         num2str(locations.Elevation(currLoc)),' in elevation and press key when ready'))
%     KbStrokeWait;
%     % Will record reponse until they click at the end of their response
%     [responseFBAz,responseFBEle,currAngle] = getHeadwithPython(calib,...
%         'clicks',locations.Azimuth(currLoc),locations.Elevation(currLoc));
%     t = 1:length(currAngle.X);
%     subplot(ceil(sqrt(noLocs))-1,ceil(sqrt(noLocs)),currLoc); hold on
%     plot(t,currAngle.X); hold on
%     plot(t,currAngle.Y); hold on
%     plot([1 t(end)],[responseFBAz responseFBAz]); hold on
%     plot([1 t(end)],[responseFBEle responseFBEle]); hold on
%     xlabel('Time (s)')
%     ylabel('Angle (degrees)')
%     title(sprintf('%s','Location in Az (',num2str(locations.Azimuth(currLoc)),...
%         ') and location in Ele ',num2str(locations.Elevation(currLoc))));
% end
% legend('X Angle','Y Angle','Response Az','Response Ele')

disp('Time for all the repeats')
KbStrokeWait;
calibResponses = zeros(4,noReps,noLocs);
for currRep = 1:noReps
    for currLoc = 1:noLocs
        disp(sprintf('%s','Please look to the location of ',...
            num2str(locations.Azimuth(currLoc)),' in azimuth and ',...
            num2str(locations.Elevation(currLoc)),' in elevation and press key when ready'))
        KbStrokeWait;
        [responseFBAz,responseFBEle,currAngle] = getHeadwithPython(calib,...
            'clicks',locations.Azimuth(currLoc),locations.Elevation(currLoc));
        calibResponses(:,currRep,currLoc) = [locations.Azimuth(currLoc),...
            responseFBAz,locations.Elevation(currLoc),responseFBEle];
    end
end
save(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'calibResponses.mat'),'calibResponses')

% Then make adjustments based on reponse and actual location

for currLoc = 1:noLocs
    meanResps = mean(calibResponses(:,:,currLoc),2);
    meanResps(2) = -meanResps(2); %put in just for now, get rid after next calib
    
end


% % Insert angle to X Y coordinates with geoTrans here when have time 
% Also write a way to monitor the calibration process to see if subject is
% doing what you want them to do