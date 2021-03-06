function summaries = aggregate_stat_summaries(datasets, mode, direction, order, label)
% AGGREGATE_STAT_SUMMARIES create pseudo-statistics structs from datasets
% Inputs
%	datasets - a cell array of datasets to aggregate over
%	mode - the kind of trials to use (e.g., 'all', 'control', 'inactivation')
%	direction - which fixations to use (e.g.,  'left', 'right')
%	order - which saccade to use as reference (e.g., 'next' or 'prev')
%	salmethod - 'gbvs' or 'ik'
%	salscaling - 'raw' or 'scaled'
%	label - a str describing the combination of the above settings, e.g., 'control-left'
% Outputs
%	summaries - a struct with fields raw, mn, md, sd, sem, title, and ylabel
	% from trial_stats, get the properties that matter

	[props, titles, ylabels] = parse_desired_stats();

	n = length(datasets);
	summaries = struct();

	% iterate over each property
	for p = 1:length(props)

		% Read property name, initialize raw vector
		str = props{p};
		summaries.(str).raw = zeros(n,1);

		empty_sets = []; % keeps track of datasets for which the given trial type does not exist
		% iterate over each dataset
		for d = 1:n
			% extract relevant trials
			ds = datasets{d};
			trials = ds.get_trials(mode);
			if size(trials,1) == 0 % no trials of that condition
				empty_sets = [empty_sets; d];
			end

			% iterate over trials
			tmp = zeros(length(trials),1);
			for t = 1:length(trials)
				trial = trials{t};
				tstats = trial.get_stats(direction, order, salmethod, salscaling);
				tmp(t) = tstats.(str);
			end

			summaries.(str).raw(d) = nanmean(tmp);
		end

		% remove any datasets for which there were no data
		summaries.(str).raw(empty_sets) = [];

		% compute statistics, as expected
		summaries.(str).mn = mean(summaries.(str).raw);
		summaries.(str).md = median(summaries.(str).raw);
		summaries.(str).sd = std(summaries.(str).raw);
		summaries.(str).sem = std(summaries.(str).raw) ./...
			sqrt(n);
		summaries.(str).title = titles{p};
		summaries.(str).ylabel = ylabels{p};
		summaries.label = label;
	end
end
