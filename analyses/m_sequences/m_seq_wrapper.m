function m_seq_wrapper(datasets, mode, varargin)

	if ~isempty(varargin)
		n_bins = varargin{1};
	else
		n_bins = 15;
	end

	if strcmp(mode, 'aggregate')
		control_trials = aggregate_trials(datasets,'control');
		inactivation_trials = aggregate_trials(datasets,'inactivation');
		control_seq = m_seq(control_trials, n_bins); 
		inactivation_seq = m_seq(inactivation_trials, n_bins); 

		plot_m_seqs(control_seq, inactivation_seq);
	else
		n_d = length(datasets);

		for i = 1:n_d
			ds = datasets{i};
			control_trials = ds.get_trials('control');
			inactivation_trials = ds.get_trials('inactivation');

			control_seq = m_seq(control_trials, n_bins); 
			inactivation_seq = m_seq(inactivation_trials, n_bins); 

			plot_m_seqs(control_seq, inactivation_seq);
			pause(2);
			close all;
		end
	end
end
