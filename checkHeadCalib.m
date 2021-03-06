% Check calibration is good for the participant - put in a part which
% just plots the reposne versu the actual locatin
function checkHeadCalib(partName)
global vE
vE.avGUIHandles = [];
vE.fixation.Ele = -7.5;
vE.fixation.Az = 0;
% Initialisation
initialiseLEDs;
pause(2);
% Variables
locations = readtable('AllLocations.txt');
noLocs = size(locations,1);
currRow = 1;
clicks = 0;
noReps = 1;
tobiiError = 0;

fileName = dir(sprintf('%s','C:\Psychophysics\HeadCalibrations\',partName,'\','*.mat'));
[~,idx] = sort([fileName.datenum]);
load(sprintf('%s','C:\Psychophysics\HeadCalibrations\',partName,'\',fileName(idx(end)).name));

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
        carryon = 1;
        while carryon == 1
            % Light centre light
            LEDcontrol('Location','on','white',vE.fixation.Az,vE.fixation.Ele);
            GetClicks();
            LEDcontrol('Location','off');
            % Light up target light
            pause(0.1)
            LEDcontrol('Location','on','white',locations.Azimuth(LocOrder(currLoc)),...
                locations.Elevation(LocOrder(currLoc)));
            [responseFBAz,responseFBEle,~,~,~,tobiiError] = getHeadwithPython(calib,...
                'clicks',0);
            fprintf('%s %s %s %s %s\n','Subject response location was at ',num2str(responseFBAz),...
                ' degrees in Azimuth and ',num2str(responseFBEle),' degrees in Elevation.')
            LEDcontrol('Location','off');
            calibResponses(:,currRep,LocOrder(currLoc)) = [locations.Azimuth(LocOrder(currLoc)),...
                responseFBAz,locations.Elevation(LocOrder(currLoc)),responseFBEle];
            if tobiiError == 0
                carryon = 0;
            end
        end
    end
end

% plotting fun
locAzi = reshape(calibResponses(1,1,:),1,size(calibResponses,3));
locEle = reshape(calibResponses(3,1,:),1,size(calibResponses,3));
h1 = scatter(locAzi,locEle,50,'filled','black'); hold on
grid on; grid minor; xlabel('Azimuth degrees'); ylabel('Elevation degrees');
title('Head Tracking Calibration')
axis([ -97.5, 97.5, -22.5, 52.5])
set(gca,'xtick',[-97.5:7.5:97.5]);
set(gca,'ytick',[-22.5:7.5:52.5]);

% plot of actual responses with hopefully the geometric correction applied
for currRep = 1:size(calibResponses,2)
    x = reshape(calibResponses(2,currRep,:),1,size(calibResponses,3));
    y = reshape(calibResponses(4,currRep,:),1,size(calibResponses,3));
    h2 = scatter(x,y,15,'filled','blue'); hold on
    Azi(currRep,:) = x;
    Ele(currRep,:) = y;
end
% meanAzi = mean(Azi);
% meanEle = mean(Ele);
% h3 = scatter(meanAzi,meanEle,50,'filled','green');
saveas(gcf,sprintf('%s','C:\Psychophysics\HeadCalibrations\',partName,'\',partName,'checkHeadCalib',date,'.fig'))
end