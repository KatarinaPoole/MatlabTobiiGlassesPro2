function commandTobii(commandType)
persistent pa_id ca_id rec_id response
% Assortment of Tobii Api commands. Commands available: Initialise,
% Calibrate, Start Recording, Stop Recording
%(look at SDK for api
%commands or chuck in browser <http://[fe80::76fe:48ff:fe19:fbaf]/services>
% function startTobii(participant)

%initialise params
% participant = 'KatTest';
base_url =  'http://[fe80::76fe:48ff:fe19:fbaf]/api/';
options = weboptions('MediaType','application/json'); %to convert data to json

switch commandType
    case 'Initialise'
        %Want to create a new project
        expName = 'MatlabTestExp'; %change this to be input arg
        apiCmd = 'projects';
        data = struct('sys_ec_preset',struct('name',expName,'xid','19'));
        url = sprintf('%s',base_url,apiCmd);
        response = webwrite(url,data,options);
        pr_id = response.pr_id; %need this to get the random nanme it generates
        
        %create participant
        apiCmd = sprintf('%s','participants');
        data = struct('pa_project',pr_id);
        url = sprintf('%s',base_url,apiCmd);
        response = webwrite(url,data,options);
        pa_id = response.pa_id;
        
    case 'Calibrate'
        % Calibration
        %create a new calibration and makes new calibration until theres a correct one
        %apparently need to send a keep alivem essage but seems to calibrate ok?
        %but should probably write that in at some point
        calibGood = 0;
        while calibGood == 0 %checks if participant is calibrated if not will create a new calibration
            %need to figure out a way to just update the claibraton its working on
            %but not sure if i can do that because I get HTTP error if I do.
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
        
    case 'Start Recording'
        % Recording
        %create new recording
        apiCmd = 'recordings';
        data = struct('rec_participant',pa_id);
        url = sprintf('%s',base_url,apiCmd);
        response = webwrite(url,data,options);
        rec_id = response.rec_id;
        
        %start recording
        apiCmd = sprintf('%s','recordings/',rec_id,'/start');
        data = struct('rec_participant',rec_id);
        url = sprintf('%s',base_url,apiCmd);
        response = webwrite(url,data,options);
        
        %get status of recording to check its recording
        if strcmp(response.rec_state,'recording')
            disp('Recording')
        else
            disp('Recording failed')
        end
        
        
    case 'Stop Recording'
        %stop recording
        apiCmd = sprintf('%s','recordings/',rec_id,'/stop');
        data = struct('rec_participant',rec_id);
        url = sprintf('%s',base_url,apiCmd);
        response = webwrite(url,data,options);
        disp('Recording stopped')
end
end