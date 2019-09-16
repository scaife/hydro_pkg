function [sepdisch] = constantSlopeHourly(discharge)
% Hewlett and Hibbert 1967 - Constant Slope Baseflow Separation Method
%
% !!!! ONLY HANDLES HOURLY DATA FOR NOW
% 
% Input:
% 1) discharge (mm/hr) -> nx2 
% 
% Output: 
% 1) sepdisch -> nx4: [date,baseflow, stormflow, total]
% 

tm=round(discharge(:,1)*10^7); 
q=discharge(:,2); 

slope_cfs = 0.05; %cfs/mi2/hr
slope_mmh = slope_cfs/(5280^2)*3600*304.8; %mm/hr/hr

qdiff=diff(q);
qdiffrise=find(qdiff>0.001); % certain number of timesteps
qdiffrisediff=find(diff(qdiffrise)~=1);
rlimbstart=qdiffrise(qdiffrisediff+1); % where r_limb start
%rlimb is one short in length q

bf=q(1:end-1);
sf=zeros(length(q)-1,1);

i=1;
stormLenghtThreshold=3; %hours
while i<length(rlimbstart)-1
    j=1;
    rowst=rlimbstart(i);
    if all(q(rowst+1:rowst+stormLenghtThreshold)>q(rowst))
        intrsct=0;
        while intrsct==0
            x1=[tm(rowst+j-1) tm(rowst+j)]; %growing hydrograph
            y1=[q(rowst+j-1) q(rowst+j)];

            x2=[tm(rowst) tm(rowst+j)]; %extending separator
            y2=[q(rowst) q(rowst)*slope_mmh*j+q(rowst)];

            bf(rowst+j-1)=q(rowst)*slope_mmh*(j-1)+q(rowst);
            sf(rowst+j-1)=q(rowst+j-1)-bf(rowst+j-1);

            j=j+1;
            if (rowst+j)>length(tm);break;end
            if j>2;
                [xi,yi] = polyxpoly(x1, y1, x2, y2);
                if ~isempty(xi);intrsct=1;else continue;end
            else
                continue
            end
        end
        k=find(rlimbstart>=(rowst+j));
        if isempty(k);i=i+1;break;else i=k(1);end;
    else
        i=i+1;
    end   
end
sepdisch=[tm(1:end-1)./10^7,bf,sf,q(1:end-1)];