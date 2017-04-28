function trial_stats_wrapper(datasets, mode)

	if strcmp(mode, 'aggregate')
		control_trials = aggregate_trials(datasets,'control');
		inactivation_trials = aggregate_trials(datasets,'inactivation');

		control_stats = trial_stats(control_trials); 
		inactivation_stats = trial_stats(inactivation_trials); 

		plot_trial_stats(control_stats, inactivation_stats);
	else
		n_d = length(datasets);

		for i = 1:n_d
			ds = datasets{i};
			control_trials = ds.get_trials('control');
			inactivation_trials = ds.get_trials('inactivation');

			control_stats = trial_stats(control_trials);
			inactivation_stats = trial_stats(inactivation_trials);

			plot_trial_stats(control_stats, inactivation_stats);
		end
	end
end
