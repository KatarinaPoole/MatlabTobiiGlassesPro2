% Calibrate Head Tracking in Tobii for the Psychophsyics Booth
clear all
% Initialisation
global tobiiTalk keepAlive
% initialiseLEDs;
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
noReps = 8; %change to increase or decrease reliability
locations = readtable('CalibrationLocations.txt');
noLocs = size(locations,1);

% Init calib parameters
calib.Pitch = 0;
calib.Roll = 0;
calib.X = 0;
calib.Z = 0;
calib.Y = 0;

%Get first response and new calibration parameters
if isempty(dir('C:\Psychophysics\HeadCalibrations\*.mat')) %change this if loop
    LEDcontrol(0,0,'on')
    [~,~,currXAngle,currYAngle,currZAngle,currAccRoll,currAccPitch] = getHeadResponse(calib,10);
    
    t = 1:length(currXAngle);
    calib.Pitch = mean(currAccPitch);
    calib.Roll = mean(currAccRoll);
    % calib.X = mean(currXAngle);
    % calib.Z = mean(currZAngle);
    fitvars = polyfit(t,currYAngle,1);
    % calib.Y = fitvars(1);
    disp('Applying the calib')
    save(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'_Head_Calibration.mat'),'calib')
else
    load(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'_Head_Calibration.mat'))
end
LEDcontrol(0,0,'off')

disp('Ready to check calibration?')
KbStrokeWait;
% Check calibration
[~,~,currXAngle,currYAngle,currZAngle,currAccRoll,currAccPitch] =...
    getHeadResponse(calib,[]);

% Run throuh all the calibration locations and get reponse angles for each
% of them
figure
calibResponses = zeros(noLocs,noReps,2);

%Just one repeat
for currLoc = 1:noLocs
        fprintf('%s','Please look to the location of ',...
            num2str(locations.Azimuth(currLoc)),' in azimuth and ',...
            num2str(locations.Elevation(currLoc)),' in elevation')
        [responseFBAz,responseFBEle,currXAngle,currYAngle] = getHeadResponse(calib,[]);
        calibResponses(currLoc,noReps,:) = [reponseFBAz,responseFBEl];
        
        KbStrokeWait;
end
% 
% for currRep = 1:noReps
%     for currLoc = 1:noLocs
%         fprintf('%s','Please look to the location of ',...
%             num2str(locations.Azimuth(currLoc)),' in azimuth and ',...
%             num2str(locations.Elevation(currLoc)),' in elevation')
%         [responseFBAz,responseFBEle,currXAngle,currYAngle] = getHeadResponse(calib,[]);
%         calibResponses(currLoc,noReps,:) = [reponseFBAz,responseFBEl];
%         
%         KbStrokeWait;
%     end
% end
% % Insert angle to X Y coordinates with geoTrans here when have time (
fclose(tobiiTalk);