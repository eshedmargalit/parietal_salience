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

		[scores{i}, distances{i}] = agg_fixation_scores(trials, n_fix, direction);
	end

	plot_scores(distances, scores, colors);

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

function [scores, distances] = agg_fixation_scores(trials, n_fix, direction)
	scores = zeros(length(trials),n_fix);
	distances = zeros(length(trials),n_fix);
	for i = 1:length(trials)
		fixations = trials{i}.get_fixations(direction,'prev');
		num_available = length(fixations);

		for j = 1:n_fix

			if j <= num_available
				scores(i,j) = fixations{j}.salience;
				distances(i,j) = fixations{j}.cumulative_distance;
			else
				scores(i,j) = NaN;
				distances(i,j) = NaN; 
			end
		end

	end
end

function plot_scores(distances, scores, colors)

	n = numel(scores);
	figure; hold on;

	for i=1:n
		y = scores{i};
		n_y = size(y,2);
		mn = nanmean(y,1);
		sd = nanstd(y, [], 1);

		n_nan = sum(isnan(y));
		n_valid = size(y,1) - n_nan;
		sem = sd ./ sqrt(n_valid);

		% average distances
		x = distances{i};
		mnx = nanmean(x,1);

		shadedErrorBar(mnx, mn, sem,...
			{'color',colors(i,:)});
	end
	title('Salience vs. Cumulative Saccade Distance');
	ylabel('Salience');
	xlabel('Cumulative Saccade Distance (px)');

end
