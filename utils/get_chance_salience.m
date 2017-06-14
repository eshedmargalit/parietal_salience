function chance_salience = get_chance_salience(trials, method)
%GET_CHANCE_SALIENCE computes the average salience one would expect by chance
% if fixations are randomly assigned to salience maps
%
% Inputs
%	trials - a cell vector of Trial objects to consider
%	method - either 'gbvs' or 'ik'
%
% Outputs
%	chance_salience - the average salience expected by random assignment of
%		fixations to salience maps
%
% Author
%	Eshed Margalit
%	Stanford University
%	June 9, 2017



	n_t = length(trials);
	order = randperm(n_t);

	saliencies = zeros(n_t,1); 

	for i = 1:n_t

		% get the salience map to use
		randidx = order(i);
		fname = trials{randidx}.fname;

		delims = {'.','/'};
		parts = split(fname,delims);

		salmap_fname = sprintf('/Users/eshed/moorelab/parietal_inactivation/%s/%s/saliency_maps/%s_%s.jpg',parts{1},...
			parts{2},method,parts{4});
		salmap = imread(salmap_fname);


		% get the list of fixations
		fixations = trials{i}.fixations;

		% for each fixation
		trial_sals = zeros(trials{i}.n_fixations,1);
		for j = 1:trials{i}.n_fixations
			f = fixations{j};
			x = floor(f.x);
			y = floor(f.y);

			% rectify
			x = max(1,x);
			y = max(1,y);

			trial_sals(j) = salmap(y,x);
		end
		saliencies(i) = mean(trial_sals);
	end

	chance_salience = mean(saliencies);
end
