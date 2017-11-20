%want to get the response angle for a given trial
%init params, chuck in other code if using this as a function.
%
% tobiiTalk = udp('[fe80::76fe:48ff:fe19:fbaf]',49152); %the address and port
% keepAlive = jsonencode(struct('op','start','type','live.data.unicast',...
%     'key','staying_alive_staying_alive'));
% fopen(tobiiTalk);
% fwrite(tobiiTalk,keepAlive)
% checkonTobii = fscanf(tobiiTalk,'%s');
% if ~isempty(checkonTobii)
%     disp('Tobii connected')
% else
%     error('Tobii not connected')
% end
% tobiiData = {};
%need to have this function before a fixation point
function [responseFBAz,responseFBEle,currXAngle,currYAngle,currZAngle,...
    currAccRoll,currAccPitch] = getHeadResponse(calib,calibTime)
global tobiiTalk keepAlive dt

%Gets data from tobiiTracker until the subject clicks
currRow = 1;
currGyRow = 1;
currAccRow = 1;
clicks = 0;
tic
if isempty(calibTime)
    while clicks(1) == 0
        fwrite(tobiiTalk,keepAlive)
        tobiiData{currRow,1} = fscanf(tobiiTalk,'%s'); %will read tobii data into cell array
        if isempty(tobiiData{1,1})
            error('Cannot connect to Tobii')
        end
        [~,~,clicks] = GetMouse(1);
        currRow = currRow + 1;
    end
else
    tic
    while toc <= calibTime
        fwrite(tobiiTalk,keepAlive)
        tobiiData{currRow,1} = fscanf(tobiiTalk,'%s'); %will read tobii data into cell array
        if isempty(tobiiData{1,1})
            error('Cannot connect to Tobii')
        end
        currRow = currRow + 1;
        
    end
end
toc
%pull out data and track head movement in that trial
for currRow = 1:length(tobiiData)
    if contains(tobiiData{currRow},'gy') %pulls out the GY JSON lines
        GyTs(currGyRow) = str2double(tobiiData{currRow}...
            (7:strfind(tobiiData{currRow},',')-1)); %gets the Ts - don't need this?
        currGy = strsplit(tobiiData{currRow},','); %splits the Gy Data
        Gy(currGyRow,1) = str2double(currGy{3}(strfind(currGy{3},'[')+1:end)); %x Gy
        Gy(currGyRow,2) = str2double(currGy{4}); %y Gy
        Gy(currGyRow,3) = str2double(currGy{5}(1:end-2)); %z Gy
        currGyRow = currGyRow + 1;
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

%then want to resample Acc and Gy data(as they have different sampling
%frequencies (struggles to resample when usig irretex for some reason so
%doing hard and fast way
p = max([length(Gy) length(Acc)]);
q = min([length(Gy) length(Acc)]);
if length(Gy) == q
    Acc = resample(Acc,q,p);
elseif length(Acc)==q
    Gy = resample(Gy,q,p);
end

%then due to the effects of resample as well as the wierd gyro thing that
%happens when you start reading (in live stream) itwant to shave off the beginning

Acc = Acc(10:end,:);
Gy = Gy(10:end,:);

for i = 1:length(Acc)-1
    currAccPitch(i) = (atan2(Acc(i,2), Acc(i,3)) * 180/pi)-calib.Pitch;%added a random offest
    currAccRoll(i) = (atan2(-Acc(i,1), sqrt(Acc(i,2)*Acc(i,2) + Acc(i,3)*Acc(i,3))) * 180/pi)-calib.Roll;
end
%could put in a low pass filter here to get the Acc data to be less noisey.
%But cba right now

currXAngle = 0; %starting angle is 0 from the beginning of the recording
currYAngle = 0;
currZAngle = 0;

% theres too much it will over shoot and wont be accurate. Got this from
% extracted gyroscope data.txt (in getHead function). If the first one nans
% then the rest can nan (need to figure out why (to do with the filter?)
for i = 1:length(Gy)-2
    currXAngle(i+1) = ((0.98*(currXAngle(i)+(Gy(i+1,1)*dt)))+(0.02*currAccPitch(i+1)));
    currYAngle(i+1) = (currYAngle(i) + (Gy(i+1,2)*dt))-calib.Y; %no filtering here but can add the calib to bodge it as it cannot be done for yaw
    currZAngle(i+1) = ((0.98*(currZAngle(i) + (Gy(i+1,3)*dt)))+(0.02*currAccRoll(i+1)));
end

% currXAngle = currXAngle - calib.X;
% currZAngle = currXAngle - calib.Z;
%depending on where you want the resonse output, ideally want to take the
%last measurement just before the mouse click (but can output the whole
%respose as well if needed).
figure('Name','Get Response Function Fig')
t = 1:dt:((length(currXAngle)*dt)+1)-dt;
plot(t,currXAngle); hold on
plot(t,currYAngle); hold on
plot(t,currZAngle); hold on
plot(t,currAccRoll); hold on
plot(t,currAccPitch); hold on
legend('X Pitch','Y Yaw','Z Roll','Roll','Pitch'); hold on
title('Tobii MEMs Data with Complimentary Filter')
xlabel('Time(s)')
ylabel('Angle (degrees)')

%want to look at just the yaw which is currYAngle, left is positive.
responseFBAz = mean(currYAngle(end-5:end)); %adjust this depeding on how much want the response
%also want elevation measure which is
responseFBEle = mean(currXAngle(end-5:end)); %adjust this depeding on how much want the response
% end

end
