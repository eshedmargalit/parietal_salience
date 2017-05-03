function sequence = m_seq(trials, direction, n_bins);
%M_SEQ aggregates saccades from provided trials and computes m-sequence
%
% Inputs
%	trials - a cell array of Trial objects to be summarized
%	direction - which saccades to use. Valid values are '', 'left', 'right' 
%	n_bins - how many bins to discretize durations by
%
% Outputs
%	sequence - struct with fields:
%		+ (binned) distances: statistics for saccade distances
%		+ (binned) durations: statistics for saccade durations
%
% Eshed Margalit
% April 27, 2017 | Last Modified: May 3, 2017

	% aggregate
	n = length(trials);

	dists = [];
	durs = []; 
	for i = 1:n
		saccades = trials{i}.get_saccades(direction);
		for s = 1:length(saccades)
			sac = saccades{s};

			dists = [dists; sac.distance];
			durs = [durs; sac.duration];
		end
	end

	sequence.distances.raw = dists;
	sequence.durations.raw = durs;

	% bin
	sequence.n_bins = n_bins;
	[~, edges] = histcounts(sequence.distances.raw, sequence.n_bins);

	sequence.binned_durations.mn = zeros(length(edges)-1,1);
	sequence.binned_durations.sd = zeros(length(edges)-1,1);
	sequence.binned_durations.sem = zeros(length(edges)-1,1);

	for e = 2:length(edges)
		e1 = edges(e-1);
		e2 = edges(e);

		good = find((dists >= e1) .* (dists <= e2));
		good_durs = durs(good);
		sequence.binned_durations.mn(e-1) = mean(good_durs);
		sequence.binned_durations.sd(e-1) = std(good_durs);
		sequence.binned_durations.sem(e-1) = std(good_durs) ./...
			sqrt(length(good_durs));
		sequence.binned_distances(e-1) = e1;
	end
end
