classdef DataSet 

	properties
		trials %cell array of all trials in an experiment
		n_trials %number of trials above

		trial_info
		fixation_info
		blink_tbl

		exp_num
		name 

		chance_salience
	end

	methods
		% Constructor
		function obj = DataSet(trials, trial_info,...
			fixation_info, blink_tbl, name, exp_num)

			obj.trials = trials;
			obj.n_trials = length(trials);
			obj.trial_info = trial_info;
			obj.fixation_info = fixation_info;
			obj.blink_tbl = blink_tbl;
			obj.name = name;
			obj.exp_num = exp_num;

			% compute chance salience
			obj.chance_salience = get_chance_salience(trials);

			% add percent_chance_salience to all trials
			for t = 1:numel(trials)
				trials{t}.set_percent_chance_salience(obj.chance_salience)
			end
		end

		% get some subset of trials
		function retval = get_trials(self, varargin)

			if length(varargin) > 1
				error('Too many arguments. 1 argument expected');
			end

			cond = varargin{1};

			if strcmp(cond,'') || strcmp(cond,'all')
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
