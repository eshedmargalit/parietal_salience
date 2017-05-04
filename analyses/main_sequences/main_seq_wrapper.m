function main_seq_wrapper(datasets, mode, varargin)

	blue = [.161, .310, .427];
	red = [.667, .224, .224];

	colors4 = [red; red; blue; blue];
	colors2 = [red; blue];
	markers4 = {'-<','-o','-<','-o'};
	markers2 = {'-<','-o'};
	strs4 = {'Control-Left','Control-Right',...
		'Inactivation-Left','Inactivation-Right'};
	strs2 = strs4(1:2);

	if ~isempty(varargin)
		n_bins = varargin{1};
	else
		n_bins = 15;
	end

	if strcmp(mode, 'aggregate')
		control_trials = aggregate_trials(datasets,'control');
		inactivation_trials = aggregate_trials(datasets,'inactivation');

		control_seq_left = main_seq(control_trials, ...
			'left', n_bins); 
		inactivation_seq_left = main_seq(inactivation_trials, ...
			'left', n_bins); 

		control_seq_right = main_seq(control_trials, ...
			'right', n_bins); 
		inactivation_seq_right = main_seq(inactivation_trials, ...
			'right', n_bins); 

		seqvec = {control_seq_left,...
			control_seq_right,...
			inactivation_seq_left,...
			inactivation_seq_right};

		plot_main_seqs(seqvec, colors4, markers4, strs4);
	else
		n_d = length(datasets);

		for i = 1:n_d
			ds = datasets{i};
			%figure('units','normalized','outerposition',...
			%	[.1+randn() .1+randn() .5 .5]) % uncomment...
			%	% to randomize location of figure plots

			figure(i);
			title(ds.name);
			control_trials = ds.get_trials('control');
			inactivation_trials = ds.get_trials('inactivation');

			if (size(inactivation_trials,1) > 0)
				control_seq_left = main_seq(control_trials, ...
					'left', n_bins); 
				inactivation_seq_left = main_seq(inactivation_trials, ...
					'left', n_bins); 

				control_seq_right = main_seq(control_trials, ...
					'right', n_bins); 
				inactivation_seq_right = main_seq(inactivation_trials, ...
					'right', n_bins); 

				seqvec = {control_seq_left,...
					control_seq_right,...
					inactivation_seq_left,...
					inactivation_seq_right};

				plot_main_seqs(seqvec, colors4, markers4, strs4);
			else
				control_seq_left = main_seq(control_trials, ...
					'left', n_bins); 

				control_seq_right = main_seq(control_trials, ...
					'right', n_bins); 

				seqvec = {control_seq_left,...
					control_seq_right};

				plot_main_seqs(seqvec, colors2, markers2, strs2);
			end
		end
	end
end
