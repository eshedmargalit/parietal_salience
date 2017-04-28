function datasets = load_experiments(varargin)

	if length(varargin) > 1
		error('Too many arguments.');
	end

	if isempty(varargin)
		experiment_numbers = 2:11;
	else
		experiment_numbers = varargin{1};
	end

	% Constants
	TrialType = 3;

	datasets = cell(length(experiment_numbers),1);
	fprintf('Loading experiments. * indicates removal of a blink.\n');
	for i=1:length(experiment_numbers)
		exp_num = experiment_numbers(i);
		name = sprintf('Experiment %d',exp_num);
		fprintf('\nExperiment %d...\n', exp_num);

		% General loading
		load_struct = load(sprintf('data/QuitoImagesExp%d/Exp%d.mat',...
		exp_num,exp_num));

		if exp_num == 2 %special format

			fixation_info = load_struct.FixationInfo;
			trial_info = load_struct.TrialInfo;
			blink_tbl = load('data/QuitoImagesExp2/Exp2EFIXtable.mat',...
			'EBLINKAll');
			blink_tbl = blink_tbl.EBLINKAll;
		else
			fixation_info = load_struct.FixationInfo;
			trial_info = load_struct.TrialInfo;
			blink_tbl = load_struct.EBLINKAll;
		end

		im_dir = sprintf('data/QuitoImagesExp%d/All%d',...
			exp_num, exp_num);

		datasets{i} = init(trial_info,fixation_info,TrialType,...
			blink_tbl,im_dir,name);
	end
end
