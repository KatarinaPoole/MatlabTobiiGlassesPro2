%% Function to get the head response angle in azimuth and elevation
function [responseFBAz,responseFBEle,currAngle,...
    currAccRoll,currAccPitch,error] = getHeadwithPython(calib,responseType,trialNo)
global vE
error = 0;
% profile on

% Runs python code that grabs the livestream data (second argument is
% calibTime or 'clicks'
if responseType ~= 'clicks'
    pythonInp1 = 'time';
    pythonInp2 = num2str(responseType);
else
    pythonInp1 = 'clicks';
    pythonInp2 = '0';
end

tic
disp('Recording')
%     system('python stayingalive.py') %Take about a second so may only need this at the begininng of most responses

rawtobiiData = python('livestream_data.py',pythonInp1, pythonInp2);
toc

if trialNo ~= 0
    sendEventTobii(trialNo,'ResponseEnd')
end


% Sorting out the incoming data
tic
rawtobiiData = strsplit(rawtobiiData)';
tobiiData = {};
for i = 1:length(rawtobiiData)
    if i == 1
        tobiiData{i,1} = rawtobiiData{i,1}(4:end-4);
    else
        tobiiData{i,1} = rawtobiiData{i,1}(3:end-4);
    end
end

% Set up variables
currGyRow = 1; currAccRow = 1;
currAngle.X = 0; currAngle.Y = 0; currAngle.Z = 0;

% Pull Data from the JSON Cell array
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

% Get the sampling rates (should pick a value at some point to standardise
% it but currently just using the mode
try
    GyHz = mode(diff(GyTs));
    dt = GyHz*1e-6; % get the sample rate in seconds for the integration
    
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
    if length(Acc) >= length(Gy)
        Acc = resample(Acc,q,p); %will always want to resample Acc as we are downsampling to GyHz
    else
        Acc = resample(Acc,p,q); % yet to avoid errors due to pulling uneven amount of Gy and Acc data put this in
    end
    oldAcc = Acc;
    oldGy = Gy;
    % And then chop off the end of the biggest one to avoid indexing problems
    % or do this before the resampling
    
    % Calculates the pitch and roll from Acc data
    for i = 1:length(Acc)-1
        currAccPitch(i) = (atan2(Acc(i,2), Acc(i,3)) * 180/pi)+96-calib.Pitch;%added a random offest
        currAccRoll(i) = (atan2(-Acc(i,1), sqrt(Acc(i,2)*Acc(i,2) + Acc(i,3)*Acc(i,3))) * 180/pi)-calib.Roll;
    end
    
    % Calculates actual angle using Gyroscope and Acc Data (Complimentary
    % Filter)
    %Added plus 15 to chop off the wierd begininng of the gy data
    adjustGy = 10;
    for idx = 1:length(Gy)-2-adjustGy % Takes off the beginning
        currAngle.X(idx+1) = ((0.97*(currAngle.X(idx)+(Gy(idx+1+adjustGy,1)*dt)))+(0.03*currAccPitch(idx+1+adjustGy)));
        currAngle.Y(idx+1) = (currAngle.Y(idx) + (Gy(idx+1+adjustGy,2)*dt))-calib.Y; % a botch job to cancel out the drift
        currAngle.Z(idx+1) = ((0.97*(currAngle.Z(idx) + (Gy(idx+1+adjustGy,3)*dt)))+(0.03*currAccRoll(idx+1+adjustGy)));
    end
    
    % Gets a mean response angle looking at last few data points
    % Yaw = currAngle.Y, left is positive.
    responseFBAz = -mean(currAngle.Y(end-5:end)); % Need to sign flip
    % Ele = currAngle.X
    responseFBEle = -mean(currAngle.X(end-5:end)); % also need to sign flip
    
    % Due to changes in fixation will need to adjust
    responseFBEle = responseFBEle + vE.fixation.Ele;
    responseFBAz = responseFBAz + vE.fixation.Az;
    
    toc
    
    % Geometrically transforms resp based on calib response. Need to make sure
    % also apply the same geometric calib
    try
        newLoc = transformPointsForward(vE.tobiiCalibrations.tformTobii,[responseFBAz responseFBEle]);
        responseFBAz = newLoc(:,1);
        responseFBEle = newLoc(:,2);
        %     sendEventTobii(trialNo,'CalibratedHead') % A way to check recording offline
    catch
        disp('Response is uncalibrated')
        %     sendEventTobii(trialNo,'UncalibratedHead') % A way to check recording offline
    end
catch
    responseFBAz = 0;
    responseFBEle = 0;
    currAngle = 0;
    currAccRoll = 0;
    currAccPitch = 0;
    error = 1;
end
% Plots if you want it
%
% figure;%('Name',sprintf('%s',num2str(LocAz),' degress in Azimuth and ',num2str(LocEle),...
% %     'degrees in Elevation'))
% t = 0:dt:((length(currAngle.X)-1)*dt);
%
% plot(t,currAngle.X); hold on
% plot(t,currAngle.Y);
% plot(t,currAngle.Z);
% % plot(t,currAccRoll);
% % plot(t,currAccPitch);
% % plot(t,Gy(2:end,1)); plot(t,Gy(2:end,2)); plot(t,Gy(2:end,3));
% legend('X Pitch','Y Yaw','Z Roll','Roll','Pitch'); hold on
% title('Tobii MEMs Data with Complimentary Filter')
% xlabel('Time(s)')
% ylabel('Angle (degrees)')
% hold off
% profile off
% profile viewer

end