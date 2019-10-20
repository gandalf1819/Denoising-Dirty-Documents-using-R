function im2csv(I,varargin)
%IM2CSV Convert image to comma-separated value file.
%   IM2CSV(I) transforms an image I into a comma-separated value file
%   (temp.csv, by default). The encoding protocol is based on submission
%   requirements for the Kaggle competition called Denoising Dirty
%   Documents:
%       id,value
%       1_1_1,1
%       1_2_1,0
%       1_3_1,1
%       ...
%   where each id specifies the image_row_column of a pixel with the
%   corresponding intensity value between 0 and 1. The default image id is
%   1.
%
%   IM2CSV(I,...,ID) uses the scalar ID to identify the image.
%
%   IM2CSV(I,...,FILENAME) writes the transformed image data to the 
%   specified FILENAME. The file is created if it does not already exist.
%   FILENAME must have the extension '.csv'.
%
%   IM2CSV(I,...,'-APPEND') appends the data instead of overwriting the 
%   file. This is useful when some data is already written in the file
%   (including the header, for example).
%
%   See the following link for submission file protocol:
%   https://www.kaggle.com/c/denoising-dirty-documents/submissions
%
%   MRE 6/4/15

%% Default parameters
filename = 'temp.csv'; %default filename
permission = 'w'; %default is to overwrite the file
id = '1'; %default image identifier

%% Parse inputs
I = im2double(I);
if size(I,3)>1
    error('Input image must be grayscale.');
end
mask = cellfun(@isempty,regexp(varargin,'[^\d]+')); %do any of the inputs specify an image id
if any(mask)
    id = varargin{mask};
end
mask = ~cellfun(@isempty,strfind(varargin,'.csv')); %are any of the inputs a CSV filename
if any(mask)
    filename = varargin{mask};
end
mask = strcmpi(varargin,'-append'); %should the data be appended or not
if any(mask)
    permission = 'a';
end

%% Write data to CSV file
fid = fopen(filename,permission);
s = dir(filename);
if s.bytes==0 %the file is empty and needs a header
    fprintf(fid,'id,value\r\n');
end

[col,row] = meshgrid(1:size(I,2),1:size(I,1)); %setup row and column index arrays
I = I(:);
row = row(:);
col = col(:);

data = [row,col,I]'; %the array need to be transposed to print properly (help fprintf)
fprintf(fid,strcat(id,'_%d_%d,%0.3f\r\n'),data);

fclose(fid);

end

