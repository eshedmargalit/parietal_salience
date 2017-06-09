function plot_scatter(statmat, order)
% PLOT_STATS plots statistics structs
% Inputs
%	statmat - cell array of statistics structures (n)
% Outputs
%	None


	% Pick colors if not provided 
	fields = fieldnames(statmat{1,1});	
	n_fields = length(fields);
	n_stats = size(statmat,2);

	for i = 1:n_fields
		field = fields{i};
		if strcmp(field,'label') % skip if it's not a statistic field
			continue;
		end

		% collect all statistic structures for this field
		[xs, ys, colors] = gather_points(statmat, field);

		% Plot custom scatter plot
		% cleft, cright, ileft, iright
		scat(xs,ys,colors,order);
	end
end


function scat(xs,ys,colors,order)
% each x, y is a struct
	n = length(xs);
	assert(n == length(ys));

	figure; hold on;

	xmns = zeros(n,1);
	ymns = zeros(n,1);
	xsems = zeros(n,1);
	ysems = zeros(n,1);
	
	for i = 1:n
		xmns(i) = xs{i}.mn;
		ymns(i) = ys{i}.mn;
		xsems(i) = xs{i}.sem;
		ysems(i) = ys{i}.sem;
	end

	% make plot
	errorbar(xmns,ymns,ysems,'.k','CapSize',0);
	errorbar(xmns,ymns,xsems,'horizontal','.k','CapSize',0);
	scatter(xmns,ymns,150,colors,'filled','MarkerEdgeColor','k');
	title(xs{1}.title);
	xlabel(sprintf('%s CONTROL',xs{1}.ylabel));
	ylabel(sprintf('%s INACTIVATION',xs{1}.ylabel));

	lims = [xlim ylim];
	xlim([min(lims), max(lims)]);
	ylim(xlim);

	% unity line
	refline(1,0);

	% legend
	h = zeros(2,1);
	%h(1) = plot(NaN,NaN,'o','MarkerEdgeColor',colors(1,:),...
	h(1) = plot(NaN,NaN,'o','MarkerEdgeColor','k',...
		'MarkerFaceColor',colors(1,:));
	h(2) = plot(NaN,NaN,'o','MarkerEdgeColor','k',...
		'MarkerFaceColor',colors(end,:));

	switch order
	case 'prev'
		legend(h,'After Left Saccade','After Right Saccade');
	case 'next'
		legend(h,'Before Left Saccade','Before Right Saccade');
	end

		
	
end

function [xs, ys, colors] = gather_points(statmat, field)

	n = size(statmat,1); %n_datasets
	xs = cell(n*2,1);
	ys = cell(n*2,1);
	colors = zeros(n*2,3);

	start_cols = [1 3];
	colormat = [174 207 223; 147 116 138]./255;
	for i = 1:2
		for j = 1:n
			idx = (i-1) * n + j;
			xs{idx} = statmat{j,start_cols(1)+i-1}.(field); 
			ys{idx} = statmat{j,start_cols(2)+i-1}.(field); 
			colors(idx,:) = colormat(i,:);
		end
	end


end
