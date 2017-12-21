function calibrateTobii(projectName)
%CALIBRATETOBII Function to call Tobii's inbuild calibration for Gaze
%   Make sure to have the target card to calibrate against

% Initial params
base_url =  'http://[fe80::76fe:48ff:fe19:fbaf]/api/';
options = weboptions('MediaType','application/json'); %to convert data to json

% Need set up exp and project to do the calibration
% Create a new project
apiCmd = 'projects';
data = struct('sys_ec_preset',struct('name',projectName,'xid','19'));
url = sprintf('%s',base_url,apiCmd);
response = webwrite(url,data,options);
pr_id = response.pr_id; %need this to get the random nanme it generates

% Create participant
apiCmd = sprintf('%s','participants');
data = struct('pa_project',pr_id);
url = sprintf('%s',base_url,apiCmd);
response = webwrite(url,data,options);
pa_id = response.pa_id;

system('python stayingalive.py') % Sends KA message just incase
% Calibratin
calibGood = 0;
while calibGood == 0 
    apiCmd = 'calibrations';
    data = struct('ca_participant',pa_id,'ca_type','default');
    url = sprintf('%s',base_url,apiCmd);
    response = webwrite(url,data,options); %send create new calib request
    fprintf('%s','ca_id: ',response.ca_id,...
        ' ca_participant: ',response.ca_participant,...
        ' ca_project: ',response.ca_project)
    ca_id = response.ca_id;
    apiCmd = sprintf('%s','calibrations/',ca_id,'/start');
    data = struct('ca_id',ca_id);
    url = sprintf('%s',base_url,apiCmd);
    disp('Press any key to start calibration')
    pause
    webwrite(url,data,options); %sends start new calib request
    pause(3)
    apiCmd = sprintf('%s','calibrations/',ca_id);
    url = sprintf('%s',base_url,apiCmd);
    response = webread(url); %gets status of the calibration
    while strcmp(response.ca_state,'calibrating')
        pause(1)
        response = webread(url);
        disp('Calibrating')
    end
    if strcmp(response.ca_state,'calibrated')
        disp('Calibration was successful')
        calibGood = 1;
    else
        disp('Calibration was unsuccessful, please try again')
        calibGood = 0;
    end
end
end

