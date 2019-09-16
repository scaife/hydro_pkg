function [eventData] = combineRainfallAndRunoffEvents(ppt, q_in, rainevents, varargin) 


    % inputs
    % 
    %   1. ppt: n x 2 table (datetime, ppt) 
    %   2. qhysep: n x 4 table (datetime, baseflow, stormflow, totalflow)
    %   3. rainevents: n x 3 (start and end dates, interstorm period);
    %   3. varargin 
    %       {1} = minimum rainfall to initiate storm (input units)
    %       {2} = minimum inter rainstorm period in timestep
    %       {3} = min total event precip
    %       {4} = min max-intensity
    %       {5} = max storm length
    %       {6} = sum up provided table (must be same length) 
    % 
    % outputs
    % 
    %   1. eventDataSummary: n x X table
    %       Col 1: storm start as datetime
    %       Col 2: storm end as datetime
    % 
    % notes: 
    %   1. remove snow events? if so, set ppt to zero outside of
    %   this routine and those events will be skipped.
    %   2. this routine WILL produce some storm that generate NO flow. this 
    %   is intended! 
    % 
    % Author: Charles Scaife
    % Date: Aug. 28th, 2019

    % update storm end date to consider when stormflow ENDS
    % aggregate data

%     if size(varargin,2)>0 && ~isempty(varargin{1}); MINRAINFALL = varargin{1}; 
%     else; MINRAINFALL = 1; end
%     if size(varargin,2)>1 && ~isempty(varargin{2}); MININTERSTORM = varargin{2}; 
%     else; MININTERSTORM = 12; end
%     if size(varargin,2)>2 && ~isempty(varargin{3}); MINGROSSP = varargin{3}; 
%     else; MINGROSSP = 5; end
%     if size(varargin,2)>3 && ~isempty(varargin{4}); MINMAXINTENSITY = varargin{4}; 
%     else; MINMAXINTENSITY = 1.5; end
%     if size(varargin,2)>4 && ~isempty(varargin{5}); MAXSTORMLENGTH = varargin{5}; 
%     else; MAXSTORMLENGTH = 9999; end
%     if size(varargin,2)>5; ADDITIONALDATA = varargin{6}; 
%     else; ADDITIONALDATA = []; end
    
    p=ppt{:,2};
    q=q_in{:,2:end};
    ts=ppt{:,1};
    re=rainevents{:,1:2};
    interst=rainevents.interstorm;
    varNames=q_in.Properties.VariableNames(2:4);
    
    eventDates = NaT(size(re));
    numOfRainEvents=size(re,1);
    i=1;
    while i<numOfRainEvents
        st=re(i,1); 
        ed=re(i,2);
        nxtst=re(i+1,1); 
        eventDates(i,1)=st; 
        
        j=find(ts==ed);
        while q(j,2)>0 && ts(j)<nxtst
            j=j+1; 
        end
        
        eventDates(i,2)=ts(j);
        i=i+1;
    end
    eventDates(i,1:2)=re(end,1:2); % need to fix this
    date_st=eventDates(:,1); 
    date_ed=eventDates(:,2); 
    interstorm=[interst(1); hours(date_st(2:end)-date_ed(1:end-1))];
    
    % 2: Summarize Gross P, Max Int, and Dates
    grossp=nan(numOfRainEvents,1);
    maxIntensity=nan(numOfRainEvents,1);
    stormL=nan(numOfRainEvents,1);
    qdata_t=nan(numOfRainEvents,3);
    for i=1:numOfRainEvents
        st=find(ts==date_st(i));
        ed=find(ts==date_ed(i));

        grossp(i,1)=sum(p(st:ed));
        maxIntensity(i,1)=max(p(st:ed));
        stormL(i,1)=ed-st+1;
        qdata_t(i,1:3)=nansum(q(st:ed,:),1);
    end
    qData = array2table(qdata_t);
    qData.Properties.VariableNames=varNames;
    eventData=[table(date_st,date_ed),...
        qData, ...
        table(grossp,maxIntensity,interstorm,stormL)];
    
    
    
