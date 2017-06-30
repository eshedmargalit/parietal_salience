classdef Fixation < handle
	properties
		% meta
		start_time
		end_time
		duration
		pupil

		% salience
		gbvs_salience
		ik_salience
		sam_salience
		gbvs_percent_chance_salience
		ik_percent_chance_salience
		sam_percent_chance_salience

		% positional
		x
		y
		dx % difference from raw
		dy
		cx % distances from center
		cy

		% saccadic
		next_saccade;
		prev_saccade;
		cumulative_distance;
	end

	methods
		% Constructor
		function obj = Fixation(fix_row,x0,y0,salmap,ik_salmap,sam_salmap)
			obj.start_time = fix_row.FixationStart;
			obj.end_time = fix_row.FixationEnd;
			obj.duration = fix_row.FixationLength;
			obj.pupil = fix_row.Pupil;

			obj.x = fix_row.XPosition;
			obj.y = fix_row.YPosition;

			sal_x = floor(obj.x) + 1;
			sal_y = floor(obj.y) + 1; % +1 because matlab is 1-indexed

			if (sal_x <= 0 || sal_y <= 0)
				obj.gbvs_salience = 0;
				obj.ik_salience = 0;
				obj.sam_salience = 0;
			else
				obj.gbvs_salience = double(salmap(sal_x,sal_y));
				obj.ik_salience = double(ik_salmap(sal_x,sal_y));
				obj.sam_salience = double(sam_salmap(sal_x,sal_y));
			end

			obj.dx = obj.x - x0;
			obj.dy = obj.y - y0;

			obj.cx = obj.dx + 1920/2;
			obj.cy = obj.dy + 1080/2;
		end

		%% Gets salience, depending on which method and scaled or not
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function sal = get_salience(self, method, scaling)

			switch scaling
			case 'raw'
				switch lower(method)
				case 'gbvs'
					sal = self.gbvs_salience;
				case 'ik'
					sal = self.ik_salience;
				case 'sam'
					sal = self.sam_salience;
				otherwise
					error(sprintf('%s not recognized. Try ''gbvs'',''sam'', or ''ik''', method));
				end
			case 'scaled'
				switch lower(method)
				case 'gbvs'
					sal = self.gbvs_percent_chance_salience;
				case 'ik'
					sal = self.ik_percent_chance_salience;
				case 'sam'
					sal = self.sam_percent_chance_salience;
				otherwise
					error(sprintf('%s not recognized. Try ''gbvs'',''sam'', or ''ik''', method));
				end
			case 'duration_weighted'
				switch lower(method)
				case 'gbvs'
					sal = self.gbvs_percent_chance_salience * self.duration;
				case 'ik'
					sal = self.ik_percent_chance_salience * self.duration;
				case 'sam'
					sal = self.sam_percent_chance_salience * self.duration;
				end
			otherwise
				error(sprintf('%s not recognized. Try ''raw'', ''scaled'', or ''duration_weighted''', scaling));
			end
		end
	end
end
