function [out] = hourly2daily(in_data, varargin)

% This function will convert hourly data to daily
% 
% Inputs
%   1. in_data: n x 1 datetime
%   2. data_in: n x m table
%   3. method (optional): 'average' (default) or 'sum' - ignores nan's be
%   default
% 
% example: 
%   hourly2daily(time, hourly_dataset)
% 
% Author: Charles Scaife
% Last Update: July 24, 2019

if size(varargin,2)>0; method = varargin{1}; 
else; method = 1; end

varNames = in_data.Properties.VariableNames; 
dates_in = in_data{:,1}; 
data_in = in_data{:,2:end}; 

% find min and max dates
x1=dateshift(min(dates_in),'start','day'); 
x2=dateshift(max(dates_in),'end','day'); 
dates_out=transpose(x1:days(1):x2);

% size of data_out 
[~,c]=size(data_in);
[r,~]=size(dates_out);
data_out = nan(r,c);

for i=1:r
    d1=dates_out(i);
    d2=dates_out(i)+1;
    
    idx=(dates_in>=d1) & (dates_in<d2);
    if isempty(idx); continue; end
    
    if strcmpi(method, 'mean')
        data_out(i,:)=nanmean(data_in(idx,:),1);
    elseif strcmpi(method, 'sum')
        data_out(i,:)=sum(data_in(idx,:),1);
    else 
        data_out(i,:)=nanmean(data_in(idx,:),1);
    end
end

out = [array2table(dates_out), array2table(data_out)];
out.Properties.VariableNames = varNames; 
