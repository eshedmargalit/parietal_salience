function plot_m_seqs(seqvec, varargin)
% PLOT_M_SEQS plots the m sequences for control and inactivation sequence structs


	n = numel(seqvec);
	%h = cell(n*2,1); % each sequence needs a mean handle and a raw handle
	h = cell(n,1); 

	if length(varargin) == 0
		colors = hsv(n);
		markers = {'-<','-o','-<','-o'};
		markers = markers(1:n);
		strs = {'Control-Left','Control-Right',...
			'Inactivation-Left','Inactivation-Right'};
		strs = strs(1:n);
	else
		colors = varargin{1};
		markers = varargin{2};
		strs = varargin{3};
	end

	hold on;
	legend_entries = [];
	for i=1:n
		seq = seqvec{i};

		%% Shaded bars

		h{i} = shadedErrorBar(seq.binned_distances,...
			seq.binned_durations.mn,...
			seq.binned_durations.sem,...
			{markers{i},'color',colors(i,:)},1);

		p = h{i}.patch;
		legend_entries(i) = h{i}.mainLine;

		% scatterplots in background
		%h{n+i} = scatter(seq.distances.raw,...
			%seq.durations.raw,...
			%1,...
			%markers{i}(end),...
			%'MarkerEdgeColor', colors(i,:),...
			%'MarkerEdgeAlpha', 0.05);

		ylim([0 175]);
		xlim([0 800]);
	end
	legend(legend_entries,strs);

	xlabel('Saccade Distance (px)');
	ylabel('Saccade Duration (ms)');
end
