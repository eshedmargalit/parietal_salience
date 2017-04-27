function compare_centered_raw(dataset, trial_num)
	figure('units','normalized','outerposition',[.1 .1 .8 .8])
	subplot(211);
	dataset.trials{trial_num}.plot_fixations('raw')
	title('Raw');

	subplot(212);
	dataset.trials{trial_num}.plot_fixations('centered')
	title('Centered');
end
