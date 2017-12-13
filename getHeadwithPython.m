% New get Head using python (because apparently Matlab UDP is shite
profile on
tic
tobiiData = python('livestream_data.py','1');
toc
tic
newtobiiData = strsplit(tobiiData)';
celltobiiData = {};
for i = 1:length(newtobiiData)
    if i == 1
        celltobiiData{i,1} = newtobiiData{i,1}(2:end-4);
    else
        celltobiiData{i,1} = newtobiiData{i,1}(1:end-4);
    end
end
toc
profile off
profile viewer