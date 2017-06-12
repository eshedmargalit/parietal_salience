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

	%% Pre-processing
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

		[scores{i}, distances{i}, indices{i}] = ...
			agg_fixation_scores(trials, n_fix, direction);
	end

	%% Plotting raw traces
	%x_axis = distances;
	%xaxstr = 'Cumulative Saccade Distance (px)';

	x_axis = indices;
	xaxstr = 'Saccade Index';

	plot_scores(x_axis, xaxstr, scores, colors);

	%% Permutation testing and plotting
	permutation_testing(x_axis, xaxstr, scores);

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

function [scores, distances, indices] = agg_fixation_scores(trials, n_fix, direction)
	scores = zeros(length(trials),n_fix);
	distances = zeros(length(trials),n_fix);
	indices = zeros(length(trials),n_fix);
	for i = 1:length(trials)
		fixations = trials{i}.get_fixations(direction,'prev');
		num_available = length(fixations);

		for j = 1:n_fix

			if j <= num_available
				scores(i,j) = fixations{j}.percent_chance_salience;
				distances(i,j) = fixations{j}.cumulative_distance;
				indices(i,j) = j;
			else
				scores(i,j) = NaN;
				distances(i,j) = NaN; 
				indices(i,j) = NaN;
			end
		end

	end
end

function plot_scores(x_axis, xaxstr, scores, colors)

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

		% average x_axis
		x = x_axis{i};
		mnx = nanmean(x,1);

		shadedErrorBar(mnx, mn, sem,...
			{'color',colors(i,:)});
	end
	title(sprintf('Salience vs. %s',xaxstr));
	ylabel('Salience (% Chance)');
	xlabel(xaxstr);

end

function permutation_testing(x_axis, xaxstr, scores)

	figure();
	control_scores = scores{1};
	inactivation_scores = scores{2};

	% Compute and plot shuffled difference
	%%%%%%%%%%%%%
	all_scores = [control_scores; inactivation_scores];
	n = size(all_scores,1);
	n_half = n/2;

	fake_indices = randperm(n);
	new_control_indices = fake_indices(1:n_half);
	new_inactivation_indices = fake_indices((n_half+1):end);

	new_control_scores = all_scores(new_control_indices,:);
	new_inactivation_scores = all_scores(new_inactivation_indices,:);

	new_diff = new_control_scores - new_inactivation_scores;

	n = size(new_diff, 2);
	mn = nanmean(new_diff, 1);
	sd = nanstd(new_diff, [], 1);

	n_nan = sum(isnan(new_diff));
	n_valid = size(new_diff,1) - n_nan;
	sem = sd ./ sqrt(n_valid);

	x = x_axis{1};
	mnx = nanmean(x,1);

	shadedErrorBar(mnx, mn, sem,...
		{'color','k'});
	hold on;


	% Compute and plot true difference
	%%%%%%%%%%%%%%%%%

	diff = control_scores - inactivation_scores;

	n = size(diff, 2);
	mn = nanmean(diff, 1);
	sd = nanstd(diff, [], 1);

	n_nan = sum(isnan(diff));
	n_valid = size(diff,1) - n_nan;
	sem = sd ./ sqrt(n_valid);

	x = x_axis{1};
	mnx = nanmean(x,1);

	shadedErrorBar(mnx, mn, sem,...
		{'color','r'});

	title(sprintf('Difference in Salience vs. %s',xaxstr));
	ylabel('Difference in % Chance Salience (Control - Inactivation)');
	xlabel(xaxstr);
end
