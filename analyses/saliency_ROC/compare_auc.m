function aucs = compare_auc(trials)
% COMPARE_AUC compares area under ROC curve for the trials provided

	%dims = [36, 64];
	%dims = [18, 32];
	dims = [9, 16];

	n = length(trials);

	base = '~/moorelab/parietal_inactivation/data/QuitoImagesExp';
	base_vgg = '~/moorelab/samnet/VGG_preds';
	base_rn = '~/moorelab/samnet/ResNet_preds';

	aucs = zeros(n,3);
	h = waitbar(0,'');
	for i = 1:n
		
		pct = i/n;
		pstr = sprintf('Computing AUCs. %.2f percent done!',pct);
		h = waitbar(pct,h,pstr);

		t = trials{i};

		gbvs_str = sprintf('%s%d/saliency_maps/gbvs_A%d.jpg',...
			base, t.exp_num, t.figure_number);
		sam_vgg_str = sprintf('%s/predictions%d/A%d.jpg',...
			base_vgg, t.exp_num, t.figure_number);
		sam_rn_str = sprintf('%s/predictions%d/A%d.jpg',...
			base_rn, t.exp_num, t.figure_number);

		[gbvs_roc, gbvs_auc] = saliency_roc(gbvs_str,...
			t.get_fixations('all'), dims);

		[sam_vgg_roc, sam_vgg_auc] = saliency_roc(sam_vgg_str,...
			t.get_fixations('all'), dims);

		[sam_rn_roc, sam_rn_auc] = saliency_roc(sam_rn_str,...
			t.get_fixations('all'), dims);

		aucs(i,1) = gbvs_auc;
		aucs(i,2) = sam_vgg_auc;
		aucs(i,3) = sam_rn_auc;
	end
	close(h);
end
