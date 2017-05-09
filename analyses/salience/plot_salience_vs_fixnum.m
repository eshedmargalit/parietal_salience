function plot_salience_vs_fixnum(trialsvec, n_fix, direction, varargin)
% PLOT_SALIENCE_VS_FIXNUM plots salience of fixations against the number of the
% fixation
% Inputs
%	trialsvec - a cell vector of arrays of trials to use in the averaging
%	n_fix - how many fixations to use
%	direction - which fixationst to pull. 'all', 'left', or 'right'
%
% Outputs
%	None
%
% Eshed Margalit
% May 8, 2017

	n = numel(trialsvec);

	if length(varargin) == 0
		colors = hsv(n);
	else
		colors = varargin{1};
	end


	scores = cell(n,1);
	for i = 1:n
		trials = trialsvec{i};
		%n_fix = check_n_fix(trials, n_fix, direction);

		scores{i} = agg_fixation_scores(trials, n_fix, direction);
	end

	plot_scores(scores, colors);

end

function nf = check_n_fix(trials, nf, direction)
% CHECK_N_FIX
% sees if n_fix is reasonable, if not, resets it to highest possible
	fewest = 1/eps;

	for i = 1:length(trials)
		t = trials{i};
		n = size(t.get_fixations(direction),1);
		if n < fewest
			fewest = n;
		end
	end

	if fewest < nf
		nf = fewest;
	else
		nf = nf;
	end
end

function scores = agg_fixation_scores(trials, n_fix, direction)
	scores = zeros(length(trials),n_fix);
	for i = 1:length(trials)
		fixations = trials{i}.get_fixations(direction);
		num_available = length(fixations);

		for j = 1:n_fix

			if j <= num_available
				scores(i,j) = fixations{j}.salience;
			else
				scores(i,j) = NaN;
			end
		end

	end
end

function plot_scores(scores, colors)

	n = numel(scores);
	figure; hold on;

	for i=1:n
		x = scores{i};
		n_x = size(x,2);
		mn = nanmean(x,1);
		sd = nanstd(x, [], 1);

		n_nan = sum(isnan(x));
		n_valid = size(x,1) - n_nan;
		sem = sd ./ sqrt(n_valid);

		shadedErrorBar(1:n_x, mn, sem,...
			{'color',colors(i,:)});
	end

end
