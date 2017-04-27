function plot_m_seqs(control, inactivation)
% PLOT_M_SEQS plots the m sequences for control and inactivation sequence structs

	if nargin < 2
		error('Please supply control and inactivation sequence structs');
	end
	
	%% Shaded bars
	figure; hold on;
	h1 = shadedErrorBar(control.binned_distances,...
		control.binned_durations.mn,...
		control.binned_durations.sem,...
		{'r-'},1);

	h2 = shadedErrorBar(inactivation.binned_distances,...
		inactivation.binned_durations.mn,...
		inactivation.binned_durations.sem,...
		{'b-'},1);

	h1p = h1.patch;
	h2p = h2.patch;


	% scatterplots in background
	h3 = scatter(control.distances.raw,...
		control.durations.raw,...
		1,...
		'MarkerEdgeColor', 'r',...
		'MarkerEdgeAlpha', 0.05);

	h4 = scatter(inactivation.distances.raw,...
		inactivation.durations.raw,...
		1,...
		'MarkerEdgeColor', 'b',...
		'MarkerEdgeAlpha', 0.05);

	ylim([0 200]);
	xlim([0 800]);

	legend([h1p,h2p,h3,h4],{'Control','Inactivation','Control Raw',...
		'Inactivation Raw'});

	xlabel('Saccade Distance (px)');
	ylabel('Saccade Duration (ms)');

end