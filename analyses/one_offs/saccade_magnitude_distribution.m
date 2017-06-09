function [dist, edges] = saccade_magnitude_distribution(trials, n_bins)
% SACCADE_MAGNITUDE_DISTRIBUTION quick and dirty script to generate distribution
%	of saccade distances given a block of trials
% Inputs
%	trials - a cell vector of Trial objects to consider
%	n_bins - how many bins to use (10-50 should be good)
%
% Outputs
%	dist - the counts of saccades in each distance-defined bin
%	edges - the edges of the bins used in forming 'dist'
%
% Notes
%	You can do something like 'area(edges(1:end-1),dist);' to visualize the
%	resultant distribution
% Author
%	Eshed Margalit
%	Stanford University
%	June 9, 2017

	magvec = [];

	for tidx = 1:length(trials)
		t = trials{tidx};

		saccades = t.saccades;
		for sidx = 1:t.n_saccades
			magvec = [magvec; saccades{sidx}.distance];
		end

	end


	[dist, edges] = histcounts(magvec, n_bins);

end
