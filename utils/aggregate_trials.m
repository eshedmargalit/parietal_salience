function trials = aggregate_trials(datasets, mode)
% AGGREGATE_TRIALS concatenates all trials of a given mode
% Inputs
%	datasets - a cell array of DataSet objects
%	mode - a str indicating the trial types to use
%		+ '' or 'all'
%		+ 'control'
%		+ 'inactivation'
% Outputs
%	trials - a column vector of Trial objects

	trials = [];
	for d = 1:length(datasets)
		ds = datasets{d};
		trials = [trials; ds.get_trials(mode)];
	end

end
