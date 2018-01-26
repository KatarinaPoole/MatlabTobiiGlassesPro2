% Send external sync events to Tobii
function sendEventTobii(trialNo,responseType)

% takes about 100ms so need to think about placement
url =  'http://[fe80::76fe:48ff:fe19:fbaf]/api/events';
options = weboptions('MediaType','application/json'); %to convert data to json
data = struct('ets',num2str(now),'type',responseType,'tag',sprintf('%s','Trial No.: ',num2str(trialNo)));
webwrite(url,data,options);

end