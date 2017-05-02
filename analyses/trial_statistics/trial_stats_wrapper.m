function trial_stats_wrapper(datasets, mode, direction)

	cont_str = sprintf('control%s',direction);
	inac_str = sprintf('inactivation%s',direction);

	switch mode
	case 'aggregate'
		% Warning: this mode of aggregation is statistically invalid, it
		% blindly combines within- and between-experiments variance

		control_trials = aggregate_trials(datasets,'control');
		inactivation_trials = aggregate_trials(datasets,'inactivation');

		control_stats = trial_stats(control_trials, direction, cont_str); 
		inactivation_stats = trial_stats(inactivation_trials,...
			direction, inac_str); 

		plot_trial_stats(control_stats, inactivation_stats);
	case 'aggregate_summaries'
		% aggregates the means of each dataset and constructs 
		% dummy "stats" structs so that 
		% plot_trial_stats is happy with the format
		control_stats = aggregate_stat_summaries(datasets,...
			'control', direction, cont_str);
		inactivation_stats = aggregate_stat_summaries(datasets,...
			'inactivation', direction, inac_str);

		plot_trial_stats(control_stats, inactivation_stats);
	otherwise
		% standard case, plot separately for each dataset,
		% error is taken over Trials within that dataset
		n_d = length(datasets);

		for i = 1:n_d
			ds = datasets{i};
			control_trials = ds.get_trials('control');
			inactivation_trials = ds.get_trials('inactivation');

			if (size(inactivation_trials,1) == 0)
				continue;
			end

			control_stats = trial_stats(control_trials,direction,...
				cont_str);
			inactivation_stats = trial_stats(inactivation_trials,...
				direction, inac_str);

			plot_trial_stats(control_stats, inactivation_stats);
		end
	end
end
