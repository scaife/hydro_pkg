function [eventDataSummary] = stormDefinition(ppt, varargin)

    % inputs
    % 
    %   1. ppt: n x 2 table (datetime, ppt) 
    %   2. varargin 
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

    if size(varargin,2)>0 && ~isempty(varargin{1}); MINRAINFALL = varargin{1}; 
    else; MINRAINFALL = 1; end
    if size(varargin,2)>1 && ~isempty(varargin{2}); MININTERSTORM = varargin{2}; 
    else; MININTERSTORM = 12; end
    if size(varargin,2)>2 && ~isempty(varargin{3}); MINGROSSP = varargin{3}; 
    else; MINGROSSP = 5; end
    if size(varargin,2)>3 && ~isempty(varargin{4}); MINMAXINTENSITY = varargin{4}; 
    else; MINMAXINTENSITY = 1.5; end
    if size(varargin,2)>4 && ~isempty(varargin{5}); MAXSTORMLENGTH = varargin{5}; 
    else; MAXSTORMLENGTH = 9999; end
    if size(varargin,2)>5; ADDITIONALDATA = varargin{6}; 
    else; ADDITIONALDATA = []; end

    p=ppt{:,2};
    ts=ppt{:,1};

    % set last observation to zero - generates error otherwise
    if p(end)>0; p(end) = 0; end   

    pIsRainingIndex = p>MINRAINFALL; 
    pIO = findStartEndIdx(pIsRainingIndex); % row # NOT index
    
    % 1: check if they're separated by interstorm period. if not they're,
    % then they're the same storm.
    ed=pIO(1:end-1,2); 
    st=pIO(2:end,1);
    interstormLengths=st-ed; 
    
    interstormIdx=interstormLengths<MININTERSTORM;
    pIO_new=nan(sum(~interstormIdx),2);
    i=1;j=1;
    while j<=sum(~interstormIdx)
        pIO_new(j,1)=pIO(i,1);
        while interstormIdx(i)==1
            i=i+1;
        end
        pIO_new(j,2)=pIO(i,2);
        j=j+1;
        i=i+1; 
    end
    interstorm=[pIO_new(1,1); pIO_new(2:end,1)-pIO_new(1:end-1,2)];
    
    % 2: Summarize Gross P, Max Int, and Dates
    numOfStorms_0=numel(pIO_new(:,1));
    grossp=nan(numOfStorms_0,1);
    maxIntensity=nan(numOfStorms_0,1);
    for i=1:numOfStorms_0
        st=pIO_new(i,1);
        ed=pIO_new(i,2);

        grossp(i,1)=sum(p(st:ed));
        maxIntensity(i,1)=max(p(st:ed));
            
    end
    date_st=ts(pIO_new(:,1)); 
    date_ed=ts(pIO_new(:,2));
    
    stormL = pIO_new(:,2)-pIO_new(:,1)+1;
    ii=all([grossp>MINGROSSP,...
        maxIntensity>MINMAXINTENSITY,...
        stormL<MAXSTORMLENGTH],2);
    event=table(date_st,date_ed,grossp,maxIntensity,interstorm,stormL);
    eventDataSummary=event(ii,:);
    
    if ~isempty(ADDITIONALDATA)
        varNames=ADDITIONALDATA.Properties.VariableNames;
        [~,c]=size(ADDITIONALDATA);
        out=nan(numOfStorms_0,c);
        for i=1:numOfStorms_0
            st=pIO_new(i,1);
            ed=pIO_new(i,2);
            out(i,:)=nansum(ADDITIONALDATA{st:ed,:}); 
        end
        moreData = array2table(out);
        moreData.Properties.VariableNames=varNames;
        eventDataSummary=[event(ii,:),moreData(ii,:)];
    end 
end

function idx1 = findStartEndIdx(pStormsIndex)
    ii=double(pStormsIndex);
    i_s=strfind(ii',[0 1])+1;
    i_e=strfind(ii',[1 0]);
    idx1=[i_s', i_e'];
    
    % check - sum of 1's in i_s == i_e
end


