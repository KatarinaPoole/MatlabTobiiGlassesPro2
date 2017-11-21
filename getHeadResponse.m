% Initialisation parameters below if just using this as standalone script.
% Bear in mind that the address will be different on a different pair of
% glasses

% tobiiTalk = udp('[fe80::76fe:48ff:fe19:fbaf]',49152); %sets up udp object
% keepAlive = jsonencode(struct('op','start','type','live.data.unicast',...
%     'key','staying_alive_staying_alive')); %needs to be sent at interval of 20000
% % for the glasses to keep sending data
% fopen(tobiiTalk);
% fwrite(tobiiTalk,keepAlive)
% checkonTobii = fscanf(tobiiTalk,'%s'); %code to ensure Tobii is connected
% % before running the whole function
% if ~isempty(checkonTobii)
%     disp('Tobii connected')
% else
%     error('Tobii not connected')
% end
% tobiiData = {}; %prep a cell array to read the JSON dat
% dt = 0.0107; %Gyroscope sampling rate

%% Function to get the head response angle in azimuth and elevation
function [responseFBAz,responseFBEle,currXAngle,currYAngle,currZAngle,...
    currAccRoll,currAccPitch] = getHeadResponse(calib,calibTime)
global tobiiTalk keepAlive dt tobiiData

currRow = 1;
currGyRow = 1;
currAccRow = 1;
clicks = 0;
currTs = 0;
% Due to integration need starting angle of 0
currXAngle = 0;
currYAngle = 0;
currZAngle = 0;

% Issue with getting data (only seems to scn for like 7.8 seconds (this
% could be due to keep alive not working correctly or perhaps its not able
% to hold that much data?
% try different things
etime = tic;
fwrite(tobiiTalk,keepAlive)
tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
firstTs = str2double(tobiiData{currRow,1}(7:strfind(tobiiData{currRow},',')-1)); %gets the Ts

if isempty(tobiiData{1,1})
    error('Cannot connect to Tobii')
end
currRow = currRow + 1;

profile on

% Gets data from glasses until the subject clicks
if isempty(calibTime)
    clickTime = tic;
    while clicks(1) == 0
        fwrite(tobiiTalk,keepAlive)
        tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
        if isempty(tobiiData{1,1})
            error('Cannot connect to Tobii')
        end
        [~,~,clicks] = GetMouse(1);
        currRow = currRow + 1;
        eclickTime = toc(clickTime)
    end
    while ((currTs-firstTs)*1e-6) <= eclickTime
        fwrite(tobiiTalk,keepAlive)
        tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
        currTs = str2double(tobiiData{currRow,1}(7:strfind(tobiiData{currRow},',')-1));
        currRow = currRow + 1;
        
    end
else
    % Gets data from glasses for time specified by calibTime
    fwrite(tobiiTalk,keepAlive)
    tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
    while ((currTs-firstTs)*1e-6) <= calibTime %put in otherwise its stops reading too early
        fwrite(tobiiTalk,keepAlive)
        tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
        currTs = str2double(tobiiData{currRow,1}(7:strfind(tobiiData{currRow},',')-1));
        currRow = currRow + 1;
    end
end
toc(etime)
profile off
profile viewer
% Pulls out data from the JSON Cell array
for currRow = 1:length(tobiiData)
    if contains(tobiiData{currRow},'gy') %pulls out the GY JSON lines
        GyTs(currGyRow) = str2double(tobiiData{currRow}...which is in microseconds
            (7:strfind(tobiiData{currRow},',')-1)); %gets the Ts
        currGy = strsplit(tobiiData{currRow},','); %splits the Gy Data
        if length(currGy)==5
            Gy(currGyRow,1) = str2double(currGy{3}(strfind(currGy{3},'[')+1:end)); %x Gy
            Gy(currGyRow,2) = str2double(currGy{4}); %y Gy
            Gy(currGyRow,3) = str2double(currGy{5}(1:end-2)); %z Gy
            currGyRow = currGyRow + 1;
        end
    elseif contains(tobiiData{currRow},'ac')
        AccTs(currAccRow) = str2double(tobiiData{currRow}...
            (7:strfind(tobiiData{currRow},',')-1)); %gets the Ts
        currAcc = strsplit(tobiiData{currRow},','); %splits the Acc Data
        %put a line in here to check the s
        if length(currAcc)==5 %to ignore any lost data
            Acc(currAccRow,1) = str2double(currAcc{3}(strfind(currAcc{3},'[')+1:end)); %x Acc
            Acc(currAccRow,2) = str2double(currAcc{4}); %y Acc
            Acc(currAccRow,3) = str2double(currAcc{5}(1:end-2)); %z Acc
            currAccRow = currAccRow + 1;
        end
    end
end

% Resamples data as Acc and Gy have slightly differing sample rates
p = max([length(Gy) length(Acc)]);
q = min([length(Gy) length(Acc)]);
if length(Gy) == q
    Acc = resample(Acc,q,p);
elseif length(Acc)==q
    Gy = resample(Gy,q,p);
end

% Shave off the beginning (should change this) due to resampling artifacts
% and wierd Gyro artificats
% Acc = Acc(10:end,:);
% Gy = Gy(10:end,:);

% Calculates the pitch and roll from Acc data
for i = 1:length(Acc)-1
    currAccPitch(i) = ((atan2(Acc(i,2), Acc(i,3)) * 180/pi)+96)-calib.Pitch;%added a random offest
    currAccRoll(i) = (atan2(-Acc(i,1), sqrt(Acc(i,2)*Acc(i,2) + Acc(i,3)*Acc(i,3))) * 180/pi) -calib.Roll;
end

% Put in a low pass filter for Acc data here as it is quite noisy

% Calculates actual angle using Gyroscope and Acc Data (Complimentary
% Filter)
% Note no filter on Yaw (since cannot be done) but could potentially
% calibrate out the drift
for i = 1:length(Gy)-2
    currXAngle(i+1) = ((0.98*(currXAngle(i)+(Gy(i+1,1)*dt)))+(0.02*currAccPitch(i+1)));
    currYAngle(i+1) = (currYAngle(i) + (Gy(i+1,2)*dt)); %-calib.Y;
    currZAngle(i+1) = ((0.98*(currZAngle(i) + (Gy(i+1,3)*dt)))+(0.02*currAccRoll(i+1)));
end

% Plots to visualise the tracking and effects of the complimentary filter
figure('Name','Get Response Function Fig')
t = 0:dt:((length(currXAngle)-1)*dt);

plot(t,currXAngle); hold on
plot(t,currYAngle);
plot(t,currZAngle);
plot(t,currAccRoll);
plot(t,currAccPitch);
legend('X Pitch','Y Yaw','Z Roll','Roll','Pitch'); hold on
title('Tobii MEMs Data with Complimentary Filter')
xlabel('Time(s)')
ylabel('Angle (degrees)')
hold off

% Gets a mean response angle looking at last few data points
% Yaw = currYAngle, left is positive.
responseFBAz = mean(currYAngle(end-5:end));
% Ele = currXAngle
responseFBEle = mean(currXAngle(end-5:end));

end
