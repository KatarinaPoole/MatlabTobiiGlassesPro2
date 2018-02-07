function stopTobiiandLEDs
% Stop recording
global vE 
base_url =  'http://[fe80::76fe:48ff:fe19:fbaf]/api/';
options = weboptions('MediaType','application/json'); %to convert data to json
rec_id = vE.tobiiInfo.rec_id;
%stop recording
apiCmd = sprintf('%s','recordings/',rec_id,'/stop');
data = struct('rec_participant',rec_id);
url = sprintf('%s',base_url,apiCmd);
webwrite(url,data,options);
fclose(ardLED);
disp('Tobii recording stopped and COM with LEDs closed')
end

