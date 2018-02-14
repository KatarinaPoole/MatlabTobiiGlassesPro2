% Analyse Tobii
fid = fopen('C:\Users\King Admin\Desktop\ExampleVideosandData\Dan\livedata.json');
rawdata = fscanf(fid,'%s');
rawdata = convertCharsToStrings(rawdata);
tobiiData = cellstr(strsplit(rawdata,'}'))';


% If you want to find particular data points
for i = 1:length(tobiiData)
    res(i) = ~isempty(strfind(tobiiData{i},'Response'));
end
find(res);


% Write in way that splits trial between response events


% Potentially add in a way that converts the ts to seconds (but may not be
% needed
