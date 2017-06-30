% Quick script to generate GBVS maps for each experiment
experiments = 2:11;

for e = 1:length(experiments)
	exp_num = experiments(e);

	% define the input and output directory strings
	in_dir = sprintf('data/QuitoImagesExp%d/All%d',exp_num,exp_num);
	sam_in_dir = sprintf('/Users/eshed/moorelab/samnet/ResNet_preds/predictions%d',...
		exp_num);
	out_dir = sprintf('data/QuitoImagesExp%d/saliency_maps',exp_num);

	% create the output directory
	mkdir(out_dir);

	fprintf('Creating saliency maps for %s\n',in_dir);
	fprintf('Copying saliency maps for %s\n',sam_in_dir);

	% Read all images in the experiment directory
	listing = dir(fullfile(sprintf('%s/*.jpg',in_dir)));
	sam_listing = dir(fullfile(sprintf('%s/*.jpg',sam_in_dir)));

	files = {listing.name};
	n_files = length(files);

	sam_files = {sam_listing.name};
	sam_n_files = length(sam_files);

	%% Compute saliency map for each image
	%for i = 1:n_files
		%fprintf('%d...',i);
		%fname = sprintf('%s/%s',in_dir,files{i});

		%im = imread(fname);

		%%% Computation of GBVS map
		%params = makeGBVSParams;
		%params.levels = [2, 3, 5, 6, 7, 8, 9]; % from Xiaomo
		%saliency_map = gbvs(im, params);

		%% Computation of IK map
		%ik_params = makeGBVSParams;
		%ik_params.useIttiKochInsteadOfGBVS = 1;
		%ik_params.ittiCenterLevels = [2 5 6 7];
		%ik_params.ittiDeltaLevels = [1 2];
		%ik_saliency_map = gbvs(im, ik_params);

		%% Write file
		%base = files{i};
		%base = base(1:end-4);

		%gbvs_im_outname = sprintf('%s/gbvs_%s.jpg',out_dir,base);
		%ik_im_outname = sprintf('%s/ik_%s.jpg',out_dir,base);

		%imwrite(saliency_map.master_map_resized,gbvs_im_outname);
		%imwrite(ik_saliency_map.master_map_resized,ik_im_outname);
	%end

	% copy sam saliency maps
	for i = 1:sam_n_files
		fprintf('%d...',i);
		fname = sprintf('%s/%s',sam_in_dir,sam_files{i});

		base = sam_files{i};
		base = base(1:end-4);
		outname = sprintf('%s/sam_%s.jpg',out_dir,base);

		copyfile(fname,outname);
	end
	fprintf('\n\n');
end
