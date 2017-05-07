function make_fixation_maps(datasets)
% MAKE_FIXATION_MAPS saves fixation maps for the indicated dataset

	for i = 1:length(datasets)
		dataset = datasets{i};
		exp_num = dataset.exp_num;

		% define the output folder 
		out_base = sprintf('data/QuitoImagesExp%d/fixation_maps',exp_num);
		control_dir = sprintf('%s/control',out_base);
		inactivation_dir = sprintf('%s/inactivation',out_base);

		% create the output directories, suppress warnings temporarily
		prev_state = warning('query'); warning('off');
		mkdir(out_base);
		mkdir(control_dir);
		mkdir(inactivation_dir);
		warning(prev_state);

		fprintf('Creating fixation maps for experiment %d\n',exp_num);

		% get trials for the dataset
		control_trials = dataset.get_trials('control');
		inactivation_trials = dataset.get_trials('inactivation');

		for i = 1:length(control_trials)
			trial = control_trials{i};
			fm = trial.get_fixation_map();
			fig_num = trial.figure_number;

			outname = sprintf('%s/A%d.jpg',control_dir,fig_num);
			imwrite(fm',outname);
		end

		for i = 1:length(inactivation_trials)
			trial = inactivation_trials{i};
			fm = trial.get_fixation_map();
			fig_num = trial.figure_number;

			outname = sprintf('%s/A%d.jpg',inactivation_dir,fig_num);
			imwrite(fm',outname);
		end

		fprintf('\n\n');
	end
end
