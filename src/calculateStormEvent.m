function [eventData, rainEvents] = saff_stormevent(precip, flow)

%% Variables
% precip:   n x 2 [datevector, values]
% flow:     n x 2 [datevector, values], will handle more than 2 col.

%% Rain Event Criteria
% 1. >= 5mm total event rainfall
% 2. peak hourly intensity of 1.5 mm/hr
% 3. events separated by >12 hrs

hrsbetween=12;
intensitythreshold=1.5;
eventthreshold=5; 

% [idx_re] = findREStartEndIdx(precip(:,2));
[rainEvents, idx_re] = calculateRainEvents(precip, eventthreshold);

c1 = rainEvents{:,4}>=intensitythreshold;
c2 = rainEvents{:,5}>hrsbetween;

idx = all([c1, c2],2);
rainEvents=rainEvents(idx,:);
idx_re=idx_re(idx,:);

%% Flow Event Criteria
%
% Start:
% 1. change in flow > 0.05mm/hr
%
% End: 
% 2. flow returns to initial value
% 3. new rain event starts
% 4. no longer than 96 hours


% NEED TO KEEP RAIN EVENTS WITHOUT FLOW RESPONSE
[flowEvents] = calculateFlowEvents(flow, precip, idx_re);
idx = flowEvents.stormL<=96;

eventData = flowEvents(idx,:);
%% 
% for i=1:size(events(:,1))
%     st=events(:,1); 
%     ed=events(:,2); 
%     
%     grossp=sum(

% [grossp, qstorm, stormdates]