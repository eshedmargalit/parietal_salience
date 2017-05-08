function trial_stats_wrapper(datasets, mode)
% TRIAL_STATS_WRAPPER
% Inputs
%	datasets - a cell array of DataSet objects
%	mode - a str indicating the trial types to use
%		+ '' or 'all'
%		+ 'control'
%		+ 'inactivation'
% Outputs
%	None

	% define colors for 2-stat and 4-stat cases
	blue = [.161, .310, .427];
	red = [.667, .224, .224];

	colors4 = [red; red; blue; blue];
	colors2 = [red; blue];

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

		pairs = [1 3; 2 4; 1 2; 3 4];
		plot_stats(statvec, pairs, 0, colors4);
		
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

		pairs = [1 3; 2 4; 1 2; 3 4];
		%pairs = [1 3; 2 4];
		plot_stats(statvec, pairs, 0, colors4);

	case 'pair'
		n_d = length(datasets);

		for i = 1:n_d

			ds = datasets{i};
			control_trials = ds.get_trials('control');
			inactivation_trials = ds.get_trials('inactivation');


			if (size(inactivation_trials,1) > 0)
				pairs = get_trial_pairs(control_trials,...
					inactivation_trials);

				control_trials = pairs(:,1);
				inactivation_trials = pairs(:,2);

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
				pairs = [1 3; 2 4; 1 2; 3 4];
				plot_stats(statvec, pairs, 1, colors4);
			else
				continue;
			end
		end
		
	case 'pair_aggregate'
		n_d = length(datasets);

		all_pairs=[];
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
		pairs = [1 3; 2 4; 1 2; 3 4];
		plot_stats(statvec, pairs, 1, colors4);
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
				plot_stats(statvec, pairs, 0, colors4);
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
				plot_stats(statvec, pairs, 0, colors2);
			end
		end
	end
end
