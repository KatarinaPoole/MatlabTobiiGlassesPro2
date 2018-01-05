% Analyse the head calibration responses and will apply the appropriate
% calibration

% Make a plot of actual responses with should be responses.

load('C:\Psychophysics\HeadCalibrations\KP21-Dec-2017calibResponses.mat')

% plot of actual locations
locAzi = reshape(calibResponses(1,1,:),1,size(calibResponses,3));
locEle = reshape(calibResponses(3,1,:),1,size(calibResponses,3));
scatter(locAzi,locEle,50,'filled','black'); hold on
grid on; grid minor; xlabel('Azimuth degrees'); ylabel('Elevation degrees');
title('Head Tracking Calibration')
axis([-52.5, 52.5, -45, 45])
set(gca,'xtick',[-52.5:7.5:52.5]);
set(gca,'ytick',[-45:7.5:45]);



for currLoc = 1:size(calibResponses,3)
    for currRep = 1:size(calibResponses,2)
        x = reshape(calibResponses(2,currRep,:),1,size(calibResponses,3));
        y = reshape(calibResponses(4,currRep,:),1,size(calibResponses,3));
        scatter(x,y,25,'filled'); hold on
        Azi(currRep,:) = x;
        Ele(currRep,:) = y;
    end
end
meanAzi = mean(Azi);
meanEle = mean(Ele);
scatter(meanAzi,meanEle,50,'filled','red');

% Calculate and apply the offset
offsetAzi = mean(locAzi - meanAzi);
offsetEle = mean(locEle - meanEle);
newAzi = meanAzi + offsetAzi;
newEle = meanEle + offsetEle;
scatter(newAzi,newEle,50,'filled','green');

% Then want to calculate the geometric correct (i.e. the stretch)
% Want to get the different from actual and the mean (lets try after offset
% and also do before offset) - because this might get rid of the need for
% the offset

% Do this with new rig where we know the angles are correct!

diffAzi = newAzi - locAzi;
diffEle = newEle - locEle;

for i = 1:length(locAzi)
    scalingAzi(i) = locAzi(i)/newAzi(i);
    if scalingAzi(i) == 0
        scalingAzi(i) = 1;
    end
end

figure
scatter(locAzi,scalingAzi)

% Essentially want to make the mean dots match the black dots
