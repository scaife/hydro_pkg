function out = calculateFlowEvents(flowDatesAndValues, ... 
    rainDatesAndValues, ...
    stormidx)

    dates=flowDatesAndValues(:,1);    
    flow=flowDatesAndValues(:,2); % total flow
    ppt=rainDatesAndValues(:,2);
    
    if size(flowDatesAndValues,2)==4
        hysep=true; 
        bflow=flowDatesAndValues(:,3);
        sflow=flowDatesAndValues(:,4);
    else
        hysep=false; 
    end
        
    k=1; 
    for i = 1:size(stormidx,1)-1
        k = i; % added with else statement
        
        st=stormidx(i,1);
        ed=stormidx(i,2); 
        next=stormidx(i+1,1);
        
%         lag=2;      % 1-hr delay between rainfall and streamflow response

        % flow change of rain event?
        % remember: we've already applied criteria for classifying rain
        % events! There should be at least 12 hours between storms, so lag
        % should not go above this value. 
%         flowChange=flow(ed+lag)-flow(st);

        % max change over a window
        err=0.001; % may want to tweak this
%         "Runoff events began when the stream discharge hydrograph started 
%         to rise from its initial low flow value or..."
        flowInit=flow(st); 
%         flowNext=flow(st+1); 
        flowRiseFromInit=(flow(st+1:ed)-flowInit)>err;
        flowCriteria1=sum(flowRiseFromInit); 

%         "Runoff events began when the stream discharge hydrograph ...
%         moved above a threshold of 0.05 mm h?1 following the commencement 
%         of a rainfall event."
        flowChangePostRain=diff(flow(ed-1:ed+24))>0.05;
%             "ed-1": think about special cases where there is a high 
%                       intensity storm that last less than an hour.  
        flowCriteria2=sum(flowChangePostRain)>0; 
        
%         flowChange=max(flow(st+1:ed+lag)-flow(st));
        

%         if flowChange > 0.01
        if flowCriteria1
            % ends when flow returns to initial value (within 0.001), and
            % before the start of the next rain storm.
            
            critMet=find(flowRiseFromInit==true);
            lag=critMet(1); 
            
            j=st+lag;
            flowDiff=flow(j)-flowInit;
            while ((flowDiff>err) && (j<next))
                j=j+1;
                flowDiff=flow(j)-flowInit;
%                 pptNow=ppt(j); 
            end
            edFlow=j;
            
             % compute storm length
            stormL(k,1)=edFlow-st;

            % total flow 
            totalflow(k,1)=sum(flow(st:edFlow));
            
            if hysep
                baseflow(k,1)=sum(bflow(st:edFlow)); 
                stormflow(k,1)=sum(sflow(st:edFlow));
            else 
                baseflow(k,1)=nan; 
                stormflow(k,1)=nan;
            end

            % max flow
            peakflow(k,1)=max(flow(st:edFlow));
            
            % gross p 
            grossp(k,1)=sum(ppt(st:edFlow));
            
            % max intensity
            maxIntensity(k,1)=max(ppt(st:edFlow));

            % start and end dates
            ts_start(k,1)=dates(st);
            ts_end(k,1)=dates(edFlow);

        elseif flowCriteria2 && ~flowCriteria1
            % if there is a change in flow, start with the last day of the
            % event as the end of the rain event. Then find the end of the
            % event as defined by the discharge.
            
            critMet=find(flowChangePostRain==true);
            lag=critMet(1); % print out
            
            flowInit=flow(ed+lag-1); 
            j=ed+lag; 
            
%             flowDiff=flowChange;
%             flowInit=flow(j); 
            flowDiff=flow(j)-flowInit;
%             pptNow=ppt(j); 
            while ((flowDiff>err) && (j<next))
                j=j+1;
                flowDiff=flow(j)-flowInit;
%                 pptNow=ppt(j); 
            end
            edFlow=j;
            
             % compute storm length
            stormL(k,1)=edFlow-st;

            % total flow 
            totalflow(k,1)=sum(flow(st:edFlow));
            
            if hysep
                baseflow(k,1)=sum(bflow(st:edFlow)); 
                stormflow(k,1)=sum(sflow(st:edFlow));
            else 
                baseflow(k,1)=nan; 
                stormflow(k,1)=nan;
            end

            % max flow
            peakflow(k,1)=max(flow(st:edFlow));
            
            % gross p 
            grossp(k,1)=sum(ppt(st:edFlow));
            
            % max intensity
            maxIntensity(k,1)=max(ppt(st:edFlow));

            % start and end dates
            ts_start(k,1)=dates(st);
            ts_end(k,1)=dates(edFlow);
%             k=k+1;
        else 
            % if there is no change in flow over the rain event and lag,
            % then the total flow response is summed and stormflow set to
            % zero and baseflow set to total flow.
            
            edFlow=ed; 
            % compute storm length
            stormL(k,1)=edFlow-st+1;

            % total flow 
            totalflow(k,1)=sum(flow(st:edFlow));
            
            if hysep
                baseflow(k,1)=totalflow(k,1); 
                stormflow(k,1)=0;
            else 
                baseflow(k,1)=nan; 
                stormflow(k,1)=nan;
            end

            % max flow
            peakflow(k,1)=max(flow(st:edFlow));
            
            % gross p 
            grossp(k,1)=sum(ppt(st:edFlow));
            
            % max intensity
            maxIntensity(k,1)=max(ppt(st:edFlow));

            % start and end dates
            ts_start(k,1)=dates(st);
            ts_end(k,1)=dates(edFlow);
        end
    end
    out = table(ts_start, ts_end,...
        stormL, ...
        totalflow,baseflow, stormflow,peakflow, ...
        grossp, maxIntensity);
end