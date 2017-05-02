function trial_stats_wrapper(datasets, mode)

	switch mode
	case 'aggregate'
		% Warning: this mode of aggregation is statistically invalid, it
		% blindly combines within- and between-experiments variance

		control_trials = aggregate_trials(datasets,'control');
		inactivation_trials = aggregate_trials(datasets,'inactivation');

		control_left_stats = trial_stats(control_trials, 'left',...
			'control-left'); 
		control_right_stats = trial_stats(control_trials, 'right',...
			'control-right'); 

		inactivation_left_stats = trial_stats(inactivation_trials,...
			'left',	'inactivation-left'); 
		inactivation_right_stats = trial_stats(inactivation_trials,...
			'right', 'inactivation-right'); 

		statvec = {control_left_stats, control_right_stats,...
			inactivation_left_stats, inactivation_right_stats};

		pairs = [1 3; 2 4];
		plot_stats(statvec, pairs);
		
	case 'aggregate_summaries'
		% aggregates the means of each dataset and constructs 
		% dummy "stats" structs so that 
		% plot_trial_stats is happy with the format
		control_left_stats = aggregate_stat_summaries(datasets,...
			'control', 'left', 'control-left');
		control_right_stats = aggregate_stat_summaries(datasets,...
			'control', 'right', 'control-right');

		inactivation_left_stats = aggregate_stat_summaries(datasets,...
			'inactivation', 'left', 'inactivation-left');
		inactivation_right_stats = aggregate_stat_summaries(datasets,...
			'inactivation', 'right', 'inactivation-right');

		statvec = {control_left_stats, control_right_stats,...
			inactivation_left_stats, inactivation_right_stats};

		pairs = [1 3; 2 4];
		plot_stats(statvec, pairs);

	otherwise
		% standard case, plot separately for each dataset,
		% error is taken over Trials within that dataset
		n_d = length(datasets);

		for i = 1:n_d

			ds = datasets{i};
			control_trials = ds.get_trials('control');
			inactivation_trials = ds.get_trials('inactivation');

			if (size(inactivation_trials,1) > 0)
				control_left_stats = trial_stats(...
					control_trials,'left',...
					'control-left');
				control_right_stats = trial_stats(...
					control_trials,'right',...
					'control-right');
				inactivation_left_stats = trial_stats(...
					inactivation_trials,'left',...
					'inactivation-left');
				inactivation_right_stats = trial_stats(...
					inactivation_trials,'right',...
					'inactivation-right');

				statvec = {control_left_stats,...
				control_right_stats,...
				inactivation_left_stats,...
				inactivation_right_stats};
				pairs = [1 3; 2 4];
				plot_stats(statvec, pairs);
			else
				control_left_stats = trial_stats(...
					control_trials,'left',...
					'control-left');
				control_right_stats = trial_stats(...
					control_trials,'right',...
					'control-right');

				statvec = {control_left_stats,...
				control_right_stats};
				pairs = [1 2];
				plot_stats(statvec, pairs);
			end

		end
	end
end
