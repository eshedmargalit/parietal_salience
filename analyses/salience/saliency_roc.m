function [curve, auc] = saliency_roc(sm_fname, fixations, scaled_dims, n_thresh)
% SALIENCY_ROC computes area under curve for saliency map predictions
% Inputs
%	sm_fname - str containing the location of a precomputed saliency map
%	fixations - a cell array of fixations to consider 
%	scaled_dims - the resolution over which to consider fixations. This
%		should theoretically correspond to the extent of fixation 
%		jitters
% Outputs
%	curve - the ROC curve itself
%	auc - area under the ROC curve
%
% Eshed Margalit
% May 5, 2017
	
	%% Load the SM
	sm = imread(sm_fname);
	[ypix, xpix] = size(sm);

	%% Downsample both the SM and the fixmap
	sm_resized = imresize(sm, scaled_dims);

	[xs, ys] = get_fixation_positions(fixations);
	rangey = linspace(0,ypix,scaled_dims(1));
	rangex = linspace(0,xpix,scaled_dims(2));
	fix_counts = hist3([ys,xs],{rangey,rangex});
	no_fix = (fix_counts == 0);

	%% Pick reasonable thresholds, given the saliency maps
	thresholds = generate_thresholds(sm_resized, n_thresh);

	%% Construct ROC curve
	curve = zeros(n_thresh,2);
	n_trues = sum(fix_counts(:));
	falses = (fix_counts == 0);
	n_falses = sum(falses(:));

	if n_falses == 0
		n_falses = 1e-6;
	end

	for i = 1:length(thresholds)
		thresh = thresholds(i);
		passed = sm_resized >= thresh;

		true_positives = sum(passed(:).* fix_counts(:));
		true_positive_rate = true_positives / n_trues;

		false_positives = sum(passed(:).* no_fix(:));
		false_positive_rate = false_positives / n_falses;

		curve(i,:) = [false_positive_rate, true_positive_rate];
	end

	auc = trapz(curve(:,1),curve(:,2));
end

function thresholds = generate_thresholds(sm_resized, n_thresh)

	thresholds = [];
	vals = sm_resized(:);

	[~, thresholds] = histcounts(vals,n_thresh);
	thresholds = fliplr(thresholds); % strongest first
end
