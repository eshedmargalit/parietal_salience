function [stats, props, titles, ylabels] = trial_stats(trials, direction, order, salmethod, salscaling, label)
%TRIAL_STATS produces statistics for relevant fields of the Trial object (see preproc/Trial.m)
%
% Inputs
%	trials - a cell array of Trial objects to be summarized
%	direction - '', 'left', or 'right'
%	order - '', 'prev' or 'next'
%	salmethod - 'gbvs' or 'ik'
%	salscaling - 'raw' or 'scaled'
%	label - a label to be used on figures
%
% Outputs
%	stats - a struct of structs, each represeting a property of Trial 
%
% Eshed Margalit
% April 25, 2017

	% create list of all fields to compute statistics on
	[props, titles, ylabels] = parse_desired_stats();

	if isempty(trials) % intended use case: user just wants props
		stats = [];
		return;
	end

	stats = struct();
	n = length(trials);

	% Prepare empty 'raw' vectors for each property in props
	for s = 1:numel(props)
		str = props{s};

		stats.(str) = struct();
		stats.(str).raw = zeros(n,1);
	end

	% populate raw vectors
	for i = 1:n
		trial = trials{i};
		tstats = trial.get_stats(direction, order, salmethod, salscaling);

		for s = 1:numel(props)
			str = props{s};
			stats.(str).raw(i) = tstats.(str);
		end
	end

	% Compute summary statistics from raw vectors
	for s = 1:numel(props)
		str = props{s};

		stats.(str).mn = nanmean(stats.(str).raw);
		stats.(str).md = median(stats.(str).raw);
		stats.(str).sd = nanstd(stats.(str).raw);
		stats.(str).sem = stats.(str).sd ./ sqrt(n);
		stats.(str).title = titles{s};
		stats.(str).ylabel = ylabels{s};

		% dirty fix for ylabel inflexibility with salmethods
		if strcmp(str, 'saliences_mn')
			stats.(str).title = get_salstring(salmethod, salscaling);
			stats.(str).ylabel = get_salstring(salmethod, salscaling);
		end
	end

	% Slap a label on it
	stats.label = label;
end

function retval =  get_salstring(method, scaling)
	switch scaling
	case 'raw'
		switch lower(method)
		case 'gbvs'
			retval = 'GBVS Raw Salience';
		case 'ik'
			retval = 'Itti-Koch Raw Salience';
		case 'sam'
			retval = 'SAM Raw Salience';
		end
	case 'scaled'
		switch lower(method)
		case 'gbvs'
			retval = 'GBVS % Chance Salience';
		case 'ik'
			retval = 'Itti-Koch % Chance Salience';
		case 'sam'
			retval = 'SAM % Chance Salience';
		end
	case 'duration_weighted'
		switch lower(method)
		case 'gbvs'
			retval = 'GBVS Duration-Weighted % Chance';
		case 'ik'
			retval = 'Itti-Koch Duration-Weighted % Chance';
		case 'sam'
			retval = 'SAM Duration-Weighted % Chance';
		end
	end
end
