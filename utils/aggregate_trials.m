function trials = aggregate_trials(datasets, mode)

	trials = [];
	for d = 1:length(datasets)
		ds = datasets{d};
		trials = [trials; ds.get_trials(mode)];
	end

end
