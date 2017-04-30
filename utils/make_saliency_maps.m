experiments = 2:11;

for e = 1:length(experiments)
	exp_num = experiments(e);

	in_dir = sprintf('data/QuitoImagesExp%d/All%d',exp_num,exp_num);
	out_dir = sprintf('data/QuitoImagesExp%d/saliency_maps',exp_num);
	mkdir(out_dir);

	fprintf('Creating saliency maps for %s\n',in_dir);

	listing = dir(fullfile(sprintf('%s/*.jpg',in_dir)));
	files = {listing.name};
	n_files = length(files);

	for i = 1:n_files
		fprintf('%d...',i);
		fname = sprintf('%s/%s',in_dir,files{i});
		im = imread(fname);

		params = makeGBVSParams;
		params.levels = [2, 3, 5, 6, 7, 8, 9]; % from Xiaomo
		saliency_map = gbvs(im, params);

		base = files{i};
		base = base(1:end-4);
		im_outname = sprintf('%s/gbvs_%s.jpg',out_dir,base);

		imwrite(saliency_map.master_map_resized,im_outname);
	end
	fprintf('\n\n');
end
