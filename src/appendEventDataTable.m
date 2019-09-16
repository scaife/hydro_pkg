function output=appendEventDataTable(eventdatain, datain, varargin)

    % inputs
    % 
    %   1. eventdatain: output from combineRainfallAndRunoff
    %   2. datain: data to be summarized 
    %   3. varargin
    %       {1} = other vars as table
    %       {2} = methods as strings
    % 
    % outputs
    % 
    %   1. output: n x X table
    %       Col 1: storm start as datetime
    %       Col 2: storm end as datetime
    % 
    % notes: 
    %   1. N/A
    % 
    % Author: Charles Scaife
    % Date: Sept. 6, 2019
    
	if size(varargin,2)>0 && ~isempty(varargin{1}); METHODS = varargin{2}; 
	else; METHODS = 'mean'; end
    
    
    numOfDatasets=size(datain,2); 
    
    for i=1:numOfDatasets
        
        
    end
    
    
   