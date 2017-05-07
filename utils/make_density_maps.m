function make_density_maps(datasets, scaled_dims)
% MAKE_DENSITY_MAPS saves density maps for the indicated dataset

	for i = 1:length(datasets)
		dataset = datasets{i};
		exp_num = dataset.exp_num;

		% define the output folder 
		out_base = sprintf('data/QuitoImagesExp%d/density_maps',exp_num);
		control_dir = sprintf('%s/control',out_base);
		inactivation_dir = sprintf('%s/inactivation',out_base);

		% create the output directories, suppress warnings temporarily
		prev_state = warning('query'); warning('off');
		mkdir(out_base);
		mkdir(control_dir);
		mkdir(inactivation_dir);
		warning(prev_state);

		fprintf('Creating density maps for experiment %d\n',exp_num);

		% get trials for the dataset
		control_trials = dataset.get_trials('control');
		inactivation_trials = dataset.get_trials('inactivation');

		for i = 1:length(control_trials)
			trial = control_trials{i};
			dm = trial.get_density_map(scaled_dims);
			fig_num = trial.figure_number;

			outname = sprintf('%s/A%d.jpg',control_dir,fig_num);
			imwrite(dm',outname);
		end

		for i = 1:length(inactivation_trials)
			trial = inactivation_trials{i};
			dm = trial.get_density_map(scaled_dims);
			fig_num = trial.figure_number;

			outname = sprintf('%s/A%d.jpg',inactivation_dir,fig_num);
			imwrite(dm',outname);
		end

		fprintf('\n\n');
	end
end
