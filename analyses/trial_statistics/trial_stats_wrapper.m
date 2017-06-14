function trial_stats_wrapper(datasets, mode, order, direction_scope, salmethod, salscaling)
% TRIAL_STATS_WRAPPER
% Inputs
%	datasets - a cell array of DataSet objects
%	mode - a string indicating how to do the stats
%		- aggregate concatenates all trials
%		- aggregate_summaries treats datasets as independent observations
%		- pair does paired stats for each dataset with both control and inactivation 
%		- pair_aggregate does paired stats for each dataset with both control and inactivation but concatenates all such pairs
%		- pair_scatter creates scatterplots instead of bar plots for datasets with pairs
%	order
%		- 'next' indicates to use next saccade as reference
%		- 'prev' indicates to use prev saccade as reference
%	salmethod - 'gbvs' or 'ik'
%	salscaling - 'raw' or 'scaled'
% Outputs
%	None

	% define colors for 2-stat and 4-stat cases
	blue = [.161, .310, .427];
	red = [.667, .224, .224];

	colors4 = [red; red; blue; blue];
	colors2 = [red; blue];

	switch direction_scope
	case 'local'
		left = 'left';
		right = 'right';
	case 'global'
		left = 'global_left';
		right = 'global_right';
	end

	switch mode
	case 'aggregate'
		% Warning: this mode of aggregation is statistically invalid, it
		% blindly combines within- and between-experiments variance

		control_trials = aggregate_trials(datasets,'control');
		inactivation_trials = aggregate_trials(datasets,'inactivation');

		control_left_stats = trial_stats(control_trials, left,order,...
			salmethod, salscaling,'control-left'); 
		control_right_stats = trial_stats(control_trials, right,order,...
			salmethod, salscaling,'control-right'); 

		inactivation_left_stats = trial_stats(inactivation_trials,...
			salmethod, salscaling,left,order,'inactivation-left'); 
		inactivation_right_stats = trial_stats(inactivation_trials,...
			salmethod, salscaling,right,order, 'inactivation-right'); 

		statvec = {control_left_stats, control_right_stats,...
			inactivation_left_stats, inactivation_right_stats};

		pairs = [1 3; 2 4; 1 2; 3 4];
		plot_stats(statvec, pairs, 0, colors4);
		
	case 'aggregate_summaries'
		% aggregates the means of each dataset and constructs 
		% dummy "stats" structs so that 
		% plot_trial_stats is happy with the format
		control_left_stats = aggregate_stat_summaries(datasets,...
			'control', left, order, salmethod, salscaling,'control-left');
		control_right_stats = aggregate_stat_summaries(datasets,...
			'control', right, order, salmethod, salscaling,'control-right');

		inactivation_left_stats = aggregate_stat_summaries(datasets,...
			'inactivation', left, order, salmethod, salscaling,'inactivation-left');
		inactivation_right_stats = aggregate_stat_summaries(datasets,...
			'inactivation', right, order, salmethod, salscaling,'inactivation-right');

		statvec = {control_left_stats, control_right_stats,...
			inactivation_left_stats, inactivation_right_stats};

		pairs = [1 3; 2 4; 1 2; 3 4];
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
					control_trials,left,order,...
					salmethod, salscaling,'control-left');
				control_right_stats = trial_stats(...
					control_trials,right,order,...
					salmethod, salscaling,'control-right');
				inactivation_left_stats = trial_stats(...
					inactivation_trials,left,order,...
					salmethod, salscaling,'inactivation-left');
				inactivation_right_stats = trial_stats(...
					inactivation_trials,right,order,...
					salmethod, salscaling,'inactivation-right');

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
			control_trials,left,order,...
			salmethod, salscaling,'control-left');
		control_right_stats = trial_stats(...
			control_trials,right,order,...
			salmethod, salscaling,'control-right');
		inactivation_left_stats = trial_stats(...
			inactivation_trials,left,order,...
			salmethod, salscaling,'inactivation-left');
		inactivation_right_stats = trial_stats(...
			inactivation_trials,right,order,...
			salmethod, salscaling,'inactivation-right');

		statvec = {control_left_stats,...
		control_right_stats,...
		inactivation_left_stats,...
		inactivation_right_stats};
		pairs = [1 3; 2 4; 1 2; 3 4];
		plot_stats(statvec, pairs, 1, colors4);
	case 'pair_scatter'
		n_d = length(datasets);
		% produce n x 2 matrix, each row a dataset, each column a condition

		statmat = cell(n_d,4);
		skips = []; %track datasets to ignore

		for i = 1:n_d
			ds = datasets{i};

			control_trials = ds.get_trials('control');
			inactivation_trials = ds.get_trials('inactivation');

			% skip datasets without inactivation
			if (size(inactivation_trials,1) == 0)
				skips = [skips i];
				continue;
			end

			% get statistics for left/right fixations
			control_left_stats = trial_stats(...
				control_trials,left,order,...
				salmethod, salscaling,'control-left');
			control_right_stats = trial_stats(...
				control_trials,right,order,...
				salmethod, salscaling,'control-right');
			inactivation_left_stats = trial_stats(...
				inactivation_trials,left,order,...
				salmethod, salscaling,'inactivation-left');
			inactivation_right_stats = trial_stats(...
				inactivation_trials,right,order,...
				salmethod, salscaling,'inactivation-right');

			% add to statmat
			statmat{i,1} = control_left_stats;
			statmat{i,2} = control_right_stats;
			statmat{i,3} = inactivation_left_stats;
			statmat{i,4} = inactivation_right_stats;
		end

		statmat(skips,:) = [];
		plot_scatter(statmat, order);


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
					control_trials,left,order,...
					salmethod, salscaling,'control-left');
				control_right_stats = trial_stats(...
					control_trials,right,order,...
					salmethod, salscaling,'control-right');
				inactivation_left_stats = trial_stats(...
					inactivation_trials,left,order,...
					salmethod, salscaling,'inactivation-left');
				inactivation_right_stats = trial_stats(...
					inactivation_trials,right,order,...
					salmethod, salscaling,'inactivation-right');

				statvec = {control_left_stats,...
				control_right_stats,...
				inactivation_left_stats,...
				inactivation_right_stats};
				pairs = [1 3; 2 4];
				plot_stats(statvec, pairs, 0, colors4);
			else
				control_left_stats = trial_stats(...
					control_trials,left,order,...
					salmethod, salscaling,'control-left');
				control_right_stats = trial_stats(...
					control_trials,right,order,...
					salmethod, salscaling,'control-right');

				statvec = {control_left_stats,...
				control_right_stats};
				pairs = [1 2];
				plot_stats(statvec, pairs, 0, colors2);
			end
		end
	end
end
