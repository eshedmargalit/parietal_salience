function plot_stats(statvec, ttest_pairs, varargin)
% statvec is a cell array of statistic objects to plot
% ttest_pairs is an nx2 matrix of stats in statvec to compare


	if length(varargin) == 0
		colors = hsv(4);
	else
		colors = varargin{1};
	end

	fields = fieldnames(statvec{1});	
	n_fields = length(fields);
	n_stats = length(statvec);

	for i = 1:n_fields
		field = fields{i};
		if strcmp(field,'label')
			continue;
		end

		% collect all statistic structures for this field
		xs = cell(n_stats,1);
		strs = cell(n_stats,1);
		for j = 1:n_stats
			xs{j} = statvec{j}.(field);
			strs{j} = statvec{j}.label;
		end

		% perform t-tests for indicated pairs
		fprintf('\n%s\n---------------\n',field);
		ps = do_ttests(xs, ttest_pairs, strs);

		bare(xs,ps,ttest_pairs,strs,colors);
	end
end


function bare(xs,ps,ttest_pairs,strs,colors)
	figure;
	hold on;

	n = length(xs);

	means = zeros(n,1);
	for i = 1:n 
		x = xs{i};
		str = strs{i};

		means(i) = x.mn;

		bar(i, x.mn, 0.5,'LineWidth',1.5,...
			'FaceColor',colors(i,:));
		errorbar(i, x.mn, x.sem, 'k.','LineWidth',1.5);

		ylabel(x.ylabel);
		title(x.title);
	end
	set(gca,'XTick',1:n);
	set(gca,'XTickLabels',strs);

	lower_lim = min(means) * 0.95;
	upper_lim = max(means) * 1.15;

	ylim([lower_lim, upper_lim]);
	xlim([.52, n+.52]);

	n_pairs = size(ttest_pairs,1);

	for i = 1:n_pairs
		idx1 = ttest_pairs(i,1);
		idx2 = ttest_pairs(i,2);

		height = upper_lim * .90 + (i * upper_lim/50);
		txt_height = height * 1.01;

		% top bar
		plot([idx1, idx2],[height, height], 'k-',...
			'LineWidth',2);

		% legs
		plot([idx1 idx1],[height-upper_lim/150, height],'k-',...
			'LineWidth',2);
		plot([idx2 idx2],[height-upper_lim/150, height],'k-',...
			'LineWidth',2);

		p = ps(i);
		starstr = 'n.s.';
		if p < .0001
			starstr = '***';
		elseif p < .001
			starstr = '**';
		elseif p < .05
			starstr = '*';
		end
		text(mean([idx1, idx2]), txt_height, starstr, 'FontSize', 24);
	end

end

function ps = do_ttests(xs, ttest_pairs, strs)
	n_pairs = size(ttest_pairs,1);
	if n_pairs == 0
		ps = [];
		return;
	end

	for i = 1:n_pairs
		idx1 = ttest_pairs(i,1);
		idx2 = ttest_pairs(i,2);

		x1 = xs{idx1};
		x2 = xs{idx2};
		
		str1 = strs{idx1};
		str2 = strs{idx2};

		fprintf('t-test between %s and %s\n',str1, str2);
		[h, ps(i), ci, stats] = ttest2(x1.raw, x2.raw);
		fprintf('t(%d) = %.2f, p = %.2f\n\n',stats.df,...
			stats.tstat,ps(i));
	end
end
