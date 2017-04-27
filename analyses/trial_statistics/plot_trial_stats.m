function plot_trial_stats(control_stats, inactivation_stats)
	

	fields = fieldnames(control_stats);	
	n_fields = length(fields);

	for i = 1:n_fields
		x1 = control_stats.(fields{i});
		x2 = inactivation_stats.(fields{i});

		fprintf('t-test for %s\n', fields{i});
		p = ttests(x1,x2);

		bare(x1,x2,p);
	end
end

function bare(x1,x2,p)
	figure; hold on;
	bar(1, x1.mn, 0.5, 'FaceColor', [.910 .302 .239],...
		'EdgeColor', [.659 .082 .024],'LineWidth',1.5);
	errorbar(1, x1.mn, x1.sem, 'k.','LineWidth',1.5);

	bar(2, x2.mn, 0.5, 'FaceColor', [.220 .290 .620],...
		'EdgeColor', [.071 .137 .447],'LineWidth',1.5);
	errorbar(2, x2.mn, x2.sem, 'k.','LineWidth',1.5);

	lower_lim = min([x1.mn, x2.mn]) * 0.95;
	upper_lim = max([x1.mn, x2.mn]) * 1.05;

	plot([1,2],[upper_lim * .98, upper_lim * .98], 'k-',...
	'LineWidth',3);

	starstr = 'n.s.';
	if p < .0001
		starstr = '***';
	elseif p < .001
		starstr = '**';
	elseif p < .05
		starstr = '*';
	end
	text(1.5, upper_lim * .99, starstr, 'FontSize', 24);


	ylim([lower_lim, upper_lim]);
	xlim([.52, 2.52]);
	set(gca,'XTick',[1 2]);
	set(gca,'XTickLabels',{'Control','Inactivation'});
	ylabel(x1.ylabel);
	title(x1.title);
end

function p = ttests(x1,x2)
	[h, p, ci, stats] = ttest2(x1.raw, x2.raw);

	fprintf('t(%d) = %.2f, p = %.2f\n\n',stats.df,stats.tstat,p);
end
