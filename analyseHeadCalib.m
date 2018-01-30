% Analyse the head calibration responses and will apply the appropriate
% calibration
function analyseHeadCalib(fileName,partName)

load(fileName)

% plot of actual locations
locAzi = reshape(calibResponses(1,1,:),1,size(calibResponses,3));
locEle = reshape(calibResponses(3,1,:),1,size(calibResponses,3));
h1 = scatter(locAzi,locEle,50,'filled','black'); hold on
grid on; grid minor; xlabel('Azimuth degrees'); ylabel('Elevation degrees');
title('Head Tracking Calibration')
axis([ -97.5, 97.5, -22.5, 52.5])
set(gca,'xtick',[-97.5:7.5:97.5]);
set(gca,'ytick',[-22.5:7.5:52.5]);
for currRep = 1:size(calibResponses,2)
    x = reshape(calibResponses(2,currRep,:),1,size(calibResponses,3));
    y = reshape(calibResponses(4,currRep,:),1,size(calibResponses,3));
    h2 = scatter(x,y,15,'filled','blue'); hold on
    Azi(currRep,:) = x;
    Ele(currRep,:) = y;
end
meanAzi = mean(Azi);
meanEle = mean(Ele);
h3 = scatter(meanAzi,meanEle,50,'filled','red');

% Geometric correction
movingPoints = [meanAzi' meanEle'];
fixedPoints = [locAzi' locEle'];
tformTobii = fitgeotrans(movingPoints,fixedPoints,'affine');
newLoc = transformPointsForward(tformTobii,movingPoints);
h4 = scatter(newLoc(:,1),newLoc(:,2),50,'filled','green');

legend([h1 h2 h3 h4],{'Actual Locations','Actual Reponses','Average Actual Resp','Geometric Correction on Av'})

try
    save(sprintf('%s','C:\Psychophysics\HeadCalibrations\',partName,'\',...
        partName,'HeadCalibParams',date,'.mat'),'partName','tformTobii')
catch
    disp('Creating participant calibration folder')
    mkdir(sprintf('%s','C:\Psychophysics\HeadCalibrations\',partName))
    save(sprintf('%s','C:\Psychophysics\HeadCalibrations\',partName,'\',...
        partName,'HeadCalibParams',date,'.mat'),'partName','tformTobii')
end
end

