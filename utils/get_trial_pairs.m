function pairs = get_trial_pairs(tvec1, tvec2)
% GET_TRIAL_PAIRS examines image associated with each trial and finds paired trials
% Inputs
%	tvec1 - vector of Trial objects
%	tvec2 - vector of Trial objects
% Outputs
% Eshed Margalit
% May 3, 2017

	pairs = cell(1,2);
	idx = 1;

	for i = 1:length(tvec1)
		for j = 1:length(tvec2)
			t1 = tvec1{i};
			t2 = tvec2{j};

			fname1 = t1.fname;
			fname2 = t2.fname;

			if strcmp(fname1, fname2)
				pairs{idx,1} = t1;
				pairs{idx,2} = t2;
				idx = idx + 1;
			end
		end
	end
end
