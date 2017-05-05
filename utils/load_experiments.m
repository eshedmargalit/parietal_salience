function datasets = load_experiments(varargin)
% LOAD_EXPERIMENTS creates a cell array of dataset objects
% Inputs
%	varargin - optional; indicated which experiments to load
% Outputs
%	datasets - a cell array of DataSet objects

	
	% Parse varargin
	if isempty(varargin)
		experiment_numbers = 2:11;
		force_recompute = 0;
	else
		experiment_numbers = varargin{1};
		force_recompute = varargin{2};
	end

	% Define constants
	TrialType = 3;

	% Initialize empty cell column vector
	datasets = cell(length(experiment_numbers),1);
	fprintf('Loading experiments. * indicates removal of a blink.\n');

	% Loop over all experiments
	for i=1:length(experiment_numbers)
		exp_num = experiment_numbers(i);

		ds_str = sprintf('data/processed_datasets/experiment%d.mat',...
			exp_num);

		if exist(ds_str)
			fprintf('DataSet already exists for experiment %d.\n',...
				exp_num);
			if force_recompute
				fprintf('Recomputing anyway, override enabled.\n');
			else
				dataset = load(ds_str);
				dataset = dataset.dataset;
				datasets{i} = dataset;
				continue;
			end
		end

		name = sprintf('Experiment %d',exp_num);
		fprintf('\nExperiment %d...\n', exp_num);

		% Load the experiment table 
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

		% Indicate where the images for this experiment live
		im_dir = sprintf('data/QuitoImagesExp%d/All%d',...
			exp_num, exp_num);

		% Call init() to process trials and fixations
		dataset = init(trial_info,fixation_info,TrialType,...
			blink_tbl,im_dir,name,exp_num);
		datasets{i} = dataset;
		save(ds_str,'dataset');
	end
	fprintf('\n');
end
