function plotStormData(data_in, varargin) 
    if size(varargin,2)>0; date_filt=varargin{1}; else; date_filt=[]; end
    if size(varargin,2)>1; dateOfSplit=varargin{2}; else; dateOfSplit=[]; end
    
    doy = day(data_in.date_time,'dayofyear');
    if date_filt(1) < date_filt(2)
        ii = all([doy >= date_filt(1), doy <= date_filt(2)],2); 
    elseif date_filt(1) > date_filt(2)
        ii = any([doy >= date_filt(1),doy <= date_filt(2)],2);
    else 
        ii = true(size(doy));
    end
    
    f = figure; hold on
    f.Position(3:4) = [322 254];
    if ~isempty(dateOfSplit)
        ii_pre = all([data_in.date_time<=dateOfSplit(1),ii],2);
        ii_post = all([data_in.date_time>dateOfSplit(2),ii],2);
        h_post= plot(data_in.rainfall(ii_post), ...
            data_in.stormflow(ii_post), ...
            '.r', 'markersize',15);
        h_pre = plot(data_in.rainfall(ii_pre), ...
            data_in.stormflow(ii_pre), ...
            '.b', 'markersize',15);
        legend([h_post, h_pre], ...
            'post-','pre-', ...
            'Location','northwest')
    else 
        h = plot(data_in.rainfall(ii), data_in.stormflow(ii), ...
            '.k', 'markersize',15);
        legend(h,'control','Location','northwest')
    end
    figsettings(f,'P_s_t_o_r_m (mm)','Q_s_t_o_r_m_f_l_o_w','',14)
end