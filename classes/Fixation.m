classdef Fixation < handle
	properties
		% meta
		start_time
		end_time
		duration
		pupil
		salience

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
		function obj = Fixation(fix_row,x0,y0,salmap)
			obj.start_time = fix_row.FixationStart;
			obj.end_time = fix_row.FixationEnd;
			obj.duration = fix_row.FixationLength;
			obj.pupil = fix_row.Pupil;

			obj.x = fix_row.XPosition;
			obj.y = fix_row.YPosition;

			sal_x = floor(obj.x) + 1;
			sal_y = floor(obj.y) + 1; % +1 because matlab is 1-indexed

			if (sal_x <= 0 || sal_y <= 0)
				obj.salience = 0;
			else
				obj.salience = double(salmap(sal_x,sal_y));
			end

			obj.dx = obj.x - x0;
			obj.dy = obj.y - y0;

			obj.cx = obj.dx + 1920/2;
			obj.cy = obj.dy + 1080/2;
		end
	end
end
