classdef DataSet 

	properties
		trials %cell array of all trials in an experiment
		n_trials %number of trials above

		trial_info
		fixation_info
		blink_tbl
	end

	methods
		% Constructor
		function obj = DataSet(trials, trial_info,...
			fixation_info, blink_tbl)

			obj.trials = trials;
			obj.n_trials = length(trials);
			obj.trial_info = trial_info;
			obj.fixation_info = fixation_info;
			obj.blink_tbl = blink_tbl;
		end

		% get some subset of trials
		function retval = get_trials(self, varargin)

			if length(varargin) > 1
				error('Too many arguments. 1 argument expected');
			end

			cond = varargin{1};

			if strcmp(cond,'') 
				retval = self.trials;
			else
				retval = {};
				for i = 1:self.n_trials
					t = self.trials{i};
					if strcmp(cond, t.condition)
						retval = [retval; {t}];
					end
				end
			end
		end
	end
end