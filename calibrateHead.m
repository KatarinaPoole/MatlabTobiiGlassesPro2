%Calibrate Head Tracking in Tobii for the Psychophsyics Booth
clear all
%Initialisation
global tobiiTalk keepAlive dt
tobiiTalk = udp('[fe80::76fe:48ff:fe19:fbaf]',49152); %the address and port
keepAlive = jsonencode(struct('op','start','type','live.data.unicast',...
    'key','staying_alive_staying_alive'));
dt = 0.0107; %this needs to be set by the gyroscope sampling rate as if
fopen(tobiiTalk);
fwrite(tobiiTalk,keepAlive)
checkonTobii = fscanf(tobiiTalk,'%s');
if ~isempty(checkonTobii)
    disp('Tobii connected')
else
    error('Tobii not connected') %check if on VPN (could potential affect it)
end
tobiiData = {};
calib.Pitch = -96;
calib.Roll = 0;
calib.X = 0;
calib.Z = 0;
calib.Y = 0;
[~,~,currXAngle,currYAngle,currZAngle,currAccRoll,currAccPitch] =...
    getHeadResponse(calib,[]);
noReps = 8; %change to increase or decrease reliability

%Need to put in functionality for the arduino in order to light the lights
%required 

%want to pull out a constatn for each angle that can jsut be applied to the
%response

%rest glasses on flat surface to get appropriate offset for accelerometer)
[~,~,currXAngle,currYAngle,currZAngle,currAccRoll,currAccPitch] = getHeadResponse(calib,10);
t = 1:length(currXAngle);
calib.Pitch = mean(currAccPitch);
calib.Roll = mean(currAccRoll);
calib.X = mean(currXAngle);
calib.Z = mean(currZAngle);
%to minimise the drift finding out the drift when stable and then finding
%the gradient and when calculating angle we make sure to take in the drift
fitvars = polyfit(t,currYAngle,1);
calib.Y = fitvars(1); 
disp('Applying the calib')
% KbStrokeWait;
save(sprintf('%s',date,'_Head_Calibration.mat'),'calib')

[~,~,currXAngle,currYAngle,currZAngle,currAccRoll,currAccPitch] =...
    getHeadResponse(calib,10);

%Centre point (try and use this point to minimise yaw drift) will need to
%count in head to 5 and then click.

[~,~,currXAngle,currYAngle,currZAngle,currAccRoll,currAccPitch] =...
    getHeadResponse(calib,[]);



%maybe then run the calibraton with the calib params added
%maybe plot some sort of calibration graph



%when have time make sure the angles canalso be converted to x,y data via
%fitgeotrans

fclose(tobiiTalk);