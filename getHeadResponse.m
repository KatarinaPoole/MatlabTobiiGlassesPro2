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
    currAccRoll,currAccPitch] = getHeadResponse(calib,calibTime,LocAz,LocEle)
global tobiiTalk keepAlive


currRow = 1;
currGyRow = 1;
currAccRow = 1;
clicks = 0;
currTs = 0;
% Due to integration need starting angle of 0
currXAngle = 0;
currYAngle = 0;
currZAngle = 0;
tobiiData = {};
Acc = 0;
Gy = 0;

% Get first row
etime = tic;
fwrite(tobiiTalk,keepAlive)
tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
% firstTs = str2double(tobiiData{currRow,1}(7:strfind(tobiiData{currRow},',')-1)); %gets the Ts
if isempty(tobiiData{1,1})
    error('Cannot connect to Tobii')
end
currRow = currRow + 1;

disp('Recording')
% Gets data from glasses until the subject clicks  - make sure to amend so
% it uses the Ts
if isempty(calibTime)
    clickTime = tic;
    while clicks(1) == 0
        fwrite(tobiiTalk,keepAlive)
        tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
        if isempty(tobiiData{1,1})
            error('Cannot connect to Tobii')
        end
        [~,~,clicks] = GetMouse(0);
        currRow = currRow + 1;
        eclickTime = toc(clickTime);
    end
    while ((currTs-firstTs)*1e-6) <= eclickTime
        fwrite(tobiiTalk,keepAlive)
        tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
        currTs = str2double(tobiiData{currRow,1}(7:strfind(tobiiData{currRow},',')-1));
        currRow = currRow + 1;
        
    end
    disp(eclickTime)
else
    % Gets data from glasses for time specified by calibTime
    %     tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
    %     while ((currTs-firstTs)*1e-6) <= calibTime %put in otherwise its stops reading too early
    %         fwrite(tobiiTalk,keepAlive)
    %         tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
    %         currTs = str2double(tobiiData{currRow,1}(7:strfind(tobiiData{currRow},',')-1));
    %         currRow = currRow + 1;
    %     end
    % end
    
    % Writing new function to get Ts of Gy and use that as the firstTs and
    % currTs. Still not getting the full time though :/
    tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
    while isempty(strfind(tobiiData(currRow-1,1),',"gy":')) == 1
        fwrite(tobiiTalk,keepAlive)
        tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
        %         tobiiData{currRow,1} = strvcat(num2str(fread(tobiiTalk)));
        currRow = currRow + 1;
    end
    %     if isempty(strfind(tobiiData(currRow-1,1),',"gy":')) == 0
    firstTs = str2double(tobiiData{currRow-1,1}(7:strfind(tobiiData{currRow-1},',')-1)); % this isn't working correctly first Ts is before GyTs
    currTs = firstTs;
    %     end
    while ((currTs-firstTs)*1e-6) <= calibTime %put in otherwise its stops reading too early
        fwrite(tobiiTalk,keepAlive)
        tobiiData{currRow,1} = fscanf(tobiiTalk,'%s');
        %         tobiiData{currRow,1} = strjoin(string(char(fread(tobiiTalk))));
        if isempty(strfind(tobiiData(currRow-1,1),',"gy":')) == 0
            currTs = str2double(tobiiData{currRow,1}(7:strfind(tobiiData{currRow},',')-1));
        end
        currRow = currRow + 1;
    end
    
end



toc(etime)


% Pulls out data from the JSON Cell array
for currRow = 1:length(tobiiData)
    if contains(tobiiData{currRow},'gy') %pulls out the GY JSON lines
        if tobiiData{currRow}(end)=='}'
            GyTs(currGyRow) = str2double(tobiiData{currRow}...which is in microseconds
                (7:strfind(tobiiData{currRow},',')-1)); %gets the Ts
            currGy = strsplit(tobiiData{currRow},','); %splits the Gy Data
            if length(currGy)==5
                Gy(currGyRow,1) = str2double(currGy{3}(strfind(currGy{3},'[')+1:end)); %x Gy
                Gy(currGyRow,2) = str2double(currGy{4}); %y Gy
                Gy(currGyRow,3) = str2double(currGy{5}(1:end-2)); %z Gy
                currGyRow = currGyRow + 1;
            end
        end
    elseif contains(tobiiData{currRow},'ac')
        if tobiiData{currRow}(end)=='}'
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
end

dt = mode(diff(GyTs))*1e-6; % Gyroscope sampling rate around 0.0108


%Getting big differences in Ts which could be affecting the length etc.
% Write code to go through and fix it.
GyHz = mode(diff(GyTs));
AccHz = mode(diff(AccTs));
recTs = calibTime/(GyHz*1e-6)
newGy = NaN(5,500000); %should be enough, if not can adjust
newGy(1,1) = firstTs;
for ii = 2:length(newGy)
    newGy(1,ii) = newGy(1,ii-1)+GyHz;
    find(GyTs == newGy(1,ii));
end

% Smoooooooothing
oldAcc = Acc;
oldGy = Gy;
for i = 1:size(oldAcc,2)
    Acc(:,i) = smooth(oldAcc(:,i),0.02,'moving'); %smoothing on Acc data is it is noisy
end
for i = 1:size(oldGy,2)
    Gy(:,i) = smooth(oldGy(:,i),0.02,'moving'); %smoothing on Acc data is it is noisy
end
% Resamples data as Acc and Gy have slightly differing sample rates
p = max([length(Gy) length(Acc)]);
q = min([length(Gy) length(Acc)]);
Acc = resample(Acc,q,p); %will always want to resample Acc

% Calculates the pitch and roll from Acc data
for i = 1:length(Acc)-1
    currAccPitch(i) = (atan2(Acc(i,2), Acc(i,3)) * 180/pi)+96-calib.Pitch;%added a random offest
    currAccRoll(i) = (atan2(-Acc(i,1), sqrt(Acc(i,2)*Acc(i,2) + Acc(i,3)*Acc(i,3))) * 180/pi)-calib.Roll;
end

% Calculates actual angle using Gyroscope and Acc Data (Complimentary
% Filter)
% Note no filter on Yaw (since cannot be done) but could potentially
% calibrate out the drift
for idx = 1:length(Gy)-2
    currXAngle(idx+1) = ((0.98*(currXAngle(idx)+(Gy(idx+1,1)*dt)))+(0.02*currAccPitch(idx+1)));
    currYAngle(idx+1) = (currYAngle(idx) + (Gy(idx+1,2)*dt)); %-calib.Y;
    currZAngle(idx+1) = ((0.98*(currZAngle(idx) + (Gy(idx+1,3)*dt)))+(0.02*currAccRoll(idx+1)));
end

% Plots to visualise the tracking and effects of the complimentary filter
figure%('Name',sprintf('%s',num2str(LocAz),' degress in Azimuth and ',num2str(LocEle),...
    %'degrees in Elevation'))
t = 0:dt:((length(currXAngle)-1)*dt);

plot(t,currXAngle); hold on
plot(t,currYAngle);
plot(t,currZAngle);
plot(t,currAccRoll);
plot(t,currAccPitch);
% plot(t,Gy(2:end,1)); plot(t,Gy(2:end,2)); plot(t,Gy(2:end,3));
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
