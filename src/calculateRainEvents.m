function [event, stormidx] = calculateRainEvents(precipDatesAndValues, ...
    totalThresh)
    
    stormidx=findREStartEndIdx(precipDatesAndValues(:,2));
    
    % remove rain events < 5mm 
    total=nan(size(stormidx,1),1);
    temp = precipDatesAndValues(:,2); 
    for i = 1:size(stormidx,1)
        st=stormidx(i,1);
        ed=stormidx(i,2);
        
        total(i,1)=sum(precipDatesAndValues(st:ed,2),1);
        totalGreaterThan = total(i,1)>totalThresh;
        if ~totalGreaterThan
            temp(st:ed)=0;
        end
    end
    
    stormidx=findREStartEndIdx(temp);
    date_st=nan(size(stormidx,1),1);
    date_ed=nan(size(stormidx,1),1);
    total=nan(size(stormidx,1),1);
    maxInt=nan(size(stormidx,1),1);
    
    for i = 1:size(stormidx,1)
        st=stormidx(i,1);
        ed=stormidx(i,2);
        
        total(i,1)=sum(precipDatesAndValues(st:ed,2),1);
        maxInt(i,1)=max(precipDatesAndValues(st:ed,2));
        date_st(i,1)=precipDatesAndValues(st,1);
        date_ed(i,1)=precipDatesAndValues(ed,1);
    end
    
    interstorm1=stormidx(1)-1; 
    interstorm=[interstorm1; stormidx(2:end,1)-stormidx(1:end-1,2)];
    
    event=table(date_st,date_ed,total,maxInt,interstorm);
end

function idx1 = findREStartEndIdx(precipValues)

    % if last observatio is rain day an error is generated
    if precipValues(end)>0
        precipValues(end) = 0;
    end    

    ii=double(precipValues > 0);
    i_s=strfind(ii',[0 1])+1;
    i_e=strfind(ii',[1 0]);
        
    idx1=[i_s', i_e'];
end
