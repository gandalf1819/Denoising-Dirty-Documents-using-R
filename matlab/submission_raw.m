%SUBMISSION_RAW Do nothing to the images.
%   The purpose of this submission is simply to test out the framework I
%   have setup for processing the images and writing the output CSV file.
%   In addition, the results of this submission will shed light on how
%   dirty the documents really are.
%
%   Score on test data: 0.20030
%
%   Time to run: 28.3 seconds
%
%   MRE 6/4/15
clear; clc; close all;

%% Get files
parentdir = 'test';
d = dir(parentdir);
imgfiles = {d(~[d.isdir]).name};
imgfiles = imgfiles(:);
[~,order] = sort(cellfun(@(x) str2num(x(1:end-4)),imgfiles));
imgfiles = imgfiles(order);

%% For each file, read the image and save to CSV
basename = regexp(mfilename,'(?<=submission_)\w+','match'); %use the last part of this script name as the CSV filename
filename = strcat(basename{1},'.csv'); %creates the filename raw.csv
for ii=1:length(imgfiles) %iterate over the test images
    fprintf('%d/%d\t%s\n',ii,length(imgfiles),imgfiles{ii});
    I = imread(fullfile(parentdir,imgfiles{ii})); %read the current image
    if ii==1 %do not append
        im2csv(I,imgfiles{ii}(1:end-4),filename);
    else %append to file
        im2csv(I,imgfiles{ii}(1:end-4),filename,'-append');
    end
end

