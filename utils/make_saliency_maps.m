directory = 'QuitoImagesExp2/All2';
listing = dir(fullfile(sprintf('%s/*.jpg',directory)));
files = {listing.name};
n_files = length(files);

for i = 1:n_files
	fname = sprintf('%s/%s',directory,files{i});
	im = imread(fname);
	saliency_map = gbvs(im);

	base = files{i};
	base = base(1:end-4);
	outname = sprintf('QuitoImagesExp2/Saliency_Map_Files/%s.mat',base);
	im_outname = sprintf('QuitoImagesExp2/Saliency_Maps/%s.jpg',base);


	save(outname,'im','saliency_map');
	overlay = heatmap_overlay(im,saliency_map.master_map_resized);
	imwrite(overlay,im_outname);
end

