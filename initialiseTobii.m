function initialiseTobii(partName,expName)
global vE
% Initialisation for the Eye/Head Tracker
base_url =  'http://[fe80::76fe:48ff:fe19:fbaf]/api/';
options = weboptions('MediaType','application/json'); %to convert data to json
system('python stayingalive.py');
            
% Create a new project
apiCmd = 'projects';
data = struct('sys_ec_preset',struct('name',expName,'xid',partName));
url = sprintf('%s',base_url,apiCmd);
response = webwrite(url,data,options);
pr_id = response.pr_id; %need this to get the random nanme it generates
vE.tobiiInfo.pr_id = pr_id;

%create participant
apiCmd = sprintf('%s','participants');
data = struct('pa_project',pr_id);
url = sprintf('%s',base_url,apiCmd);
response = webwrite(url,data,options);
pa_id = response.pa_id;
vE.tobiiInfo.pa_id = pa_id;

% Calibration
%create a new calibration and makes new calibration until theres a correct one
calibGood = 0;
while calibGood == 0 %checks if participant is calibrated if not will create a new calibration
    system('python stayingalive.py');
    apiCmd = 'calibrations';
    data = struct('ca_participant',pa_id,'ca_type','default');
    url = sprintf('%s',base_url,apiCmd);
    response = webwrite(url,data,options); %send create new calib request
    fprintf('%s%s\n','ca_id: ',response.ca_id,...
        'ca_participant: ',response.ca_participant,...
        'ca_project: ',response.ca_project)
    ca_id = response.ca_id;
    apiCmd = sprintf('%s','calibrations/',ca_id,'/start');
    data = struct('ca_id',ca_id);
    url = sprintf('%s',base_url,apiCmd);
    disp('For correct eye data, calibration using the card with the black circle is necessary.') 
    disp('Please have the participant stand approximately a meter away and looking at the card.') 
    disp('Press any key to start calibration.')
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
        disp('Calibration was unsuccessful, trying again...')
        calibGood = 0;
    end
end

disp('Press any key when ready to continue')
pause

% Recording
%create new recording
apiCmd = 'recordings';
data = struct('rec_participant',pa_id);
url = sprintf('%s',base_url,apiCmd);
response = webwrite(url,data,options);
rec_id = response.rec_id;
vE.tobiiInfo.rec_id = rec_id;

%start recording
apiCmd = sprintf('%s','recordings/',rec_id,'/start');
data = struct('rec_participant',rec_id);
url = sprintf('%s',base_url,apiCmd);
response = webwrite(url,data,options);

% Initialise drift and geotrans calibration parameters
fileName = dir(sprintf('%s','C:\Psychophysics\HeadCalibrations\',partName,'\','*.mat'));
load(sprintf('%s','C:\Psychophysics\HeadCalibrations\',partName,'\',fileName(end).name));
vE.tobiiCalibrations.tformTobii = tformTobii;
vE.tobiiCalibrations.calib = calib;

end