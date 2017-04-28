function compare_centered_raw(trial)
	
	if nargin < 1
		error('Usage: compare_centered_raw(trial)');
	end

	figure('units','normalized','outerposition',[.1 .1 .8 .8])
	subplot(211);
	trial.plot_fixations('raw')
	title('Raw');

	subplot(212);
	trial.plot_fixations('centered')
	title('Centered');
end
