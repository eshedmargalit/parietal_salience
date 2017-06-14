function temperature_histogram(dataset)
	t1 = dataset.trial_info.Temperature1;
	t2 = dataset.trial_info.Temperature2;
	t = [t1 t2];

	%x_edges = linspace(-35000,40,10);
	%y_edges = linspace(-35000,40,10);

	x_edges = linspace(0,40,100);
	y_edges = linspace(0,40,100);
	h = hist2d(t, x_edges, y_edges);
	Plot2dHist(h,x_edges,y_edges,'Temp1','Temp2','');
end
