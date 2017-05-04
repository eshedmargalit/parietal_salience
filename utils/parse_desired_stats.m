function [props, titles, ylabels] = parse_desired_stats(varargin)
% PARSE_DESIRED_STATS reads a text file to quickly determine which Trial stats
% we care about
% Inputs
%	varargin - if anything, this should be a filename

	if length(varargin) > 0
		fname = varargin{1};
	else
		fname = '~/moorelab/parietal_inactivation/docs/trial_stats.txt';
	end

	fid = fopen(fname);

	l0 = fgets(fid);
	n_lines = str2num(l0);

	props = cell(n_lines,1);
	titles = cell(n_lines,1);
	ylabels = cell(n_lines,1);

	for i = 1:n_lines
		line = fgets(fid);
		parts = split(line,',');

		switch numel(parts)
		case 2
			prop = parts{1};
			title = parts{2};
			ylabel = title;
		case 3
			prop = parts{1};
			title = parts{2};
			ylabel = parts{3};
		otherwise
			error('Malformatted.');
		end

		props{i} = prop;
		titles{i} = title;
		ylabels{i} = ylabel;
	end

	fclose(fid);
end
	
