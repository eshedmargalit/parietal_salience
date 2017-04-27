function dataset = init(trial_info, fixation_info, trial_type, blink_tbl, im_dir)
%INIT filters fixation info table by experiment number and reward, return DataSet Object
%
% Inputs
%	trial_info - the trial table to be filtered 
%	fixation_info - the fixation table to be filtered 
%	trial_type - the experiment number to keep
%	im_dir - the directory in which the images for this experiment were kept
%
% Outputs
%	dataset - a DataSet instance containing all trials
%
% Eshed Margalit
% April 24, 2017

	% dictate what the "correct" reward should be
	switch trial_type
	case 2
		reward = 1;
	case 3
		reward = 2;
	otherwise
		error('Experiment number not recognized.');
	end

	% determine which rows are both the right experiment and appropriately rewarded
	exp_valid_rows = trial_info.TrialType == trial_type;
	reward_valid_rows = trial_info.Reward == reward;
	trial_rows = find(exp_valid_rows .* reward_valid_rows);
	n_valid_trials = length(trial_rows);

	% filter trials to only good trials
	filtered_trial_info = trial_info(trial_rows,:);	

	% use trial_rows to extract correct subsection of fixation_info
	trials = cell(n_valid_trials,1);

	nofix = []; %keeps track of trials for which no fixation data are present
	for row_idx = 1:n_valid_trials
		row = trial_rows(row_idx);
		good = find(fixation_info.TrialNumber == row);

		% subtable "belongs" to a trial
		subtable = fixation_info(good,:);
		if (size(subtable,1) == 0)
			nofix = [nofix; row_idx];
			continue;
		end
		trials{row_idx} = Trial(filtered_trial_info(row_idx,:),...
			subtable,blink_tbl,im_dir);
	end

	% remove trials for which no fixation data were available
	if size(nofix,1) > 0
		warning(sprintf(['Fixation data were unavailable for'...
			' %d trials (%.2f%%)!\n'], size(nofix,1),...
			size(nofix,1)/n_valid_trials * 100));
		trials(nofix) = [];
	end

	dataset = DataSet(trials,trial_info,fixation_info,blink_tbl);
end
