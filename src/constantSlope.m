function [sepdisch] = constantSlope(discharge, varargin)
% Hewlett and Hibbert 1967 - Constant Slope Baseflow Separation Method
% 
% Inputs:
% 1) discharge (mm/timestep) -> nx2
% 2) timestep_hrs (hrs)
% 
% Output: 
% 1) sepdisch -> nx4: [date,baseflow, stormflow, totalflow]
% 

if size(varargin,2)>0; timestep_hrs = varargin{1}; 
else; timestep_hrs = 1; end
if size(varargin,2)>1; stormLengthThreshold = varargin{2}; 
else; stormLengthThreshold = 1; end

% variables 
% tm=round(discharge(:,1)*10^7); 
% q=discharge(:,2); 
% varNames = discharge.Properties.VariableNames; 
tm = discharge{:,1}; 
q = discharge{:,2}; 

slope_Ls = 0.0055; %L/s/ha/hr - Buttle et al., 2019
slope_mm = slope_Ls*1e-4*3600*timestep_hrs; %mm/x-hrs^2

qdiff=diff(q);
qdiffrise=find(qdiff>slope_mm);
qdiffrisediff=find(diff(qdiffrise)~=1);
rlimbstart=qdiffrise(qdiffrisediff+1); % where r_limb start
%rlimb is one short in length q

bf=q;
sf=zeros(length(q),1);

i=1;
while i<length(rlimbstart)-1
    j=1;
    rowst=rlimbstart(i);
    q_0 = q(rowst);
    
    % check if initial flow is zero
    if q_0==0; q_t=0.001; else; q_t=q_0; end
    
    q_nextXdays = q(rowst+1:rowst+stormLengthThreshold); 
    b_nextXdays = slope_mm*[1:stormLengthThreshold]'+q_0;
    
    if all(q_nextXdays>q_0) && all(b_nextXdays<q_nextXdays)
        intrsct=0;
        while intrsct==0
            if all(~isnan(q(rowst:rowst+j))) % check for NaN
                
                % hydrograph subset
                x1=[rowst+j-1 rowst+j];
                y1=[q(rowst+j-1) q(rowst+j)];

                % extending baseflow separator
                x2=[rowst rowst+j];
                y2=[q_0 slope_mm*j+q_0];

                bf(rowst+j-1)=slope_mm*(j-1)+q_0;
                sf(rowst+j-1)=q(rowst+j-1)-bf(rowst+j-1);
            else 
                intrsct = 1;
            end
            
            j=j+1;
            if (rowst+j)>length(tm);break;end
            if j>2
                [xi,yi] = polyxpoly(x1, y1, x2, y2);
                if ~isempty(xi);intrsct=1;else; continue;end
            else
                continue
            end
        end
        k=find(rlimbstart>=(rowst+j));
        if isempty(k);i=i+1;break;else; i=k(1);end
    else
        i=i+1;
    end   
end

qhysep = array2table([bf,sf,q]); 
qhysep.Properties.VariableNames = {'baseflow','stormflow','totalflow'};
dt = table(tm);
dt.Properties.VariableNames = {'date_time'};
sepdisch=[dt,qhysep];