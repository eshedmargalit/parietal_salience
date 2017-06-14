function sal_vs_fix_wrapper(datasets, direction, mode)

	n_fix = 3;
	blue = [.161, .310, .427];
	red = [.667, .224, .224];

	colors4 = [red; red; blue; blue];
	colors2 = [red; blue];

	switch mode
	case 'aggregate'
		control_trials = aggregate_trials(datasets,'control');
		inactivation_trials = aggregate_trials(datasets,'inactivation');

		trialvec = {control_trials; inactivation_trials};
		plot_salience_vs_fixnum(trialvec, n_fix, direction, colors2);
	case 'pair_aggregate'
		n_d = length(datasets);

		all_pairs = [];
		for i = 1:n_d
			ds = datasets{i};
			control_trials = ds.get_trials('control');
			inactivation_trials = ds.get_trials('inactivation');


			if (size(inactivation_trials,1) > 0)
				pairs = get_trial_pairs(control_trials,...
					inactivation_trials);
				all_pairs = [all_pairs; pairs];
			end
		end
		control_trials = all_pairs(:,1);
		inactivation_trials = all_pairs(:,2);

		trialvec = {control_trials; inactivation_trials};
		plot_salience_vs_fixnum(trialvec, n_fix, direction, colors2);
	end
end
