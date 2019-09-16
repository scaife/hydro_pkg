function out = compileFlowAndPrecipData(flow_hysep, ppt)

stormevents = flow_hysep.stormflow > 0;
s1 = find(diff(stormevents)==1)+1;
s2 = find(diff(stormevents)==-1);
storm_num = zeros(size(flow_hysep,1),1); 
for i = 1:numel(s1) 
    storm_num(s1(i):s2(i))=i;
end

ppt.Properties.VariableNames = {'date_time','rainfall'};
out = [flow_hysep(:,:), ppt(1:end-1,2), array2table(storm_num)];