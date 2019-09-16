function output = aggregateHydroDataByStorm(data_in)
    vNames = data_in.Properties.VariableNames;
    numOfStorms = numel(unique(data_in.storm_num));
    
    data_temp = nan(numOfStorms,size(data_in,2)-2);
    date_time = NaT(numOfStorms,1);
    storm_num = 1:numOfStorms;
    
    for i = 1:numOfStorms-1
        ii = find(data_in.storm_num==i);
        date_time(i) = data_in{ii(1),1}; 
        data_temp(i,:) = sum(data_in{ii,2:end-1},1);
    end
    
    output = [array2table(date_time), ...
        array2table(data_temp), ...
        array2table(storm_num')];
    output.Properties.VariableNames = vNames; 
end