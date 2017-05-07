function [xs, ys] = get_fixation_positions(fixations)

	n_fix = numel(fixations);
	xs = zeros(n_fix,1);
	ys = zeros(n_fix,1);

	for i = 1:n_fix
		fix = fixations{i};
		xs(i) = fix.x;
		ys(i) = fix.y;
	end

end
