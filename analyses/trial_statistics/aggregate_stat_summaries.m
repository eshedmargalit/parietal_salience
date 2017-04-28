function summaries = aggregate_stat_summaries(datasets, mode)
	% the summaries struct needs to include: raw, mn, md, sd, sem, title, ylabel 

	% from trial_stats, get the properties that matter
	[~, props, titles, ylabels] = trial_stats([]);

	n = length(datasets);

	summaries = struct();
	for p = 1:length(props)
		str = props{p};
		summaries.(str).raw = zeros(n,1);

		empty_sets = [];
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
				tmp(t) = trial.(str);
			end

			summaries.(str).raw(d) = mean(tmp);
		end

		% remove any datasets for which there were no data
		summaries.(str).raw(empty_sets) = [];

		summaries.(str).mn = mean(summaries.(str).raw);
		summaries.(str).md = median(summaries.(str).raw);
		summaries.(str).sd = std(summaries.(str).raw);
		summaries.(str).sem = std(summaries.(str).raw) ./...
			sqrt(n);
		summaries.(str).title = titles{p};
		summaries.(str).ylabel = ylabels{p};
	end
end
