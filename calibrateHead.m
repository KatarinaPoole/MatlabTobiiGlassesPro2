% Calibrate Head Tracking in Tobii for the Psychophsyics Booth
global vE
vE.avGUIHandles = [];
vE.fixation.Ele = -15;
vE.fixation.Az = 0;
instrreset;
% Initialisation
initialiseLEDs;
pause(2);
% Variables
locations = readtable('CalibrationLocations.txt');
noLocs = size(locations,1);
currRow = 1;
clicks = 0;
noReps = 8;
fixationAz = 0;
fixationEle = -15;

% Init calib parameters
calib.Pitch = 0;
calib.Roll = 0;
calib.X = 0;
calib.Z = 0;
calib.Y = 0;

% %Get first response and new calibration parameters
% try
%     load(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'_temp_Head_Calibration.mat'))
% catch
disp('Please put the glasses on a flat surface and press any key when ready')
KbStrokeWait;
LEDcontrol(fixationAz,fixationEle,'on')
[~,~,currAngle,currAccRoll,currAccPitch] = getHeadwithPython(calib,10,0);
t = 1:length(currAngle.X);
calib.Pitch = mean(currAccPitch);
calib.Roll = mean(currAccRoll);
fitvars = polyfit(t,currAngle.Y,1);
calib.Y = fitvars(1); % botch way of canceling out the drift
disp('Drift calibrated.')
% save(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'_temp_Head_Calibration.mat'),'calib')
% end

% Get participant name
partName = vE.thisSub(end-1:end);

% To avoid just getting one tobii cell need to presend a keep alive message
disp('Response calibration time, press any key when ready and click the mouse when sitting and looking at the centre light')
KbStrokeWait;
calibResponses = zeros(4,noReps,noLocs);
currCount = 1;
system('python stayingalive.py'); %Take about a second so may only need this at the begininng of most responses
for currRep = 1:noReps
    % Randomise the locations
    LocOrder = randperm(noLocs);
    for currLoc = 1:noLocs
        % Light centre light
        LEDcontrol('Location','on','white',fixationAz,fixationEle);
        GetClicks();
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

save(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'calibResponses.mat'),'calibResponses','calib','vE')

LEDcontrol('Location','on','green',fixationAz,fixationEle);
analyseHeadCalib(sprintf('%s','C:\Psychophysics\HeadCalibrations\',date,'calibResponses.mat'),partName)
LEDcontrol('Location','off')
% Then make adjustments based on reponse and actual location
%
% for currLoc = 1:noLocs
%     meanResps = mean(calibResponses(:,:,currLoc),2);
%     meanResps(2) = -meanResps(2); %put in just for now, get rid after next calib
%
% end
%

% % Insert angle to X Y coordinates with geoTrans here when have time
% Also write a way to monitor the calibration process to see if subject is
% doing what you want them to do











%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Debug Tools %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% system('python livestream_data_live.py') % to check python functions
%
% % A quick way to check Tobii is all connected
% tobiiTalk = udp('[fe80::76fe:48ff:fe19:fbaf]',49152); %the address and port
% keepAlive = jsonencode(struct('op','start','type','live.data.unicast',...
%     'key','staying_alive_staying_alive'));
% fopen(tobiiTalk);
% pause(2);
% fwrite(tobiiTalk,keepAlive)
% checkonTobii = fscanf(tobiiTalk,'%s');
% if ~isempty(checkonTobii)
%     disp('Tobii connected')
% else
%     error('Tobii not connected, check firewall or if connected to VPN') %check if on VPN (could potential affect it)
% end
% fclose(tobiiTalk); clear checkonTobii
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%