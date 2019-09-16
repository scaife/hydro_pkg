function rbindex = rbflashiness(discharge)

% "The resulting index isdimensionless  and  its  value  is  independent  of
% theunits chosen to represent flow. In particular, the valueof  the  index
% is  the  same  whether  the  values  of  qaretreated as daily discharge
% volumes (m3) or as averagedaily flows (m3/s)." Baker et al., 2004

    rbindex = sum(abs(diff(discharge)))/sum(discharge);

end