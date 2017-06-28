function [control_trials, inactivation_trials] = pair_aggregate_trials(datasets)
% PAIR_AGGREGATE_TRIALS concatenates all trials that have control/inactivation pairs 
% Inputs
%	datasets - a cell array of DataSet objects
%
% Outputs
%	trials - a column vector of Trial objects

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

end
