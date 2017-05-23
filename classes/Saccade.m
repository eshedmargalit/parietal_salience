classdef Saccade < handle
	properties
		duration
		distance
		direction
		xs
		ys
		prev_fixation
		next_fixation
		global_position
	end

	methods
		% Constructor
		function obj = Saccade(fixation1,fixation2)
			
			% duration
			t_start = fixation1.end_time;
			t_end = fixation2.start_time;
			obj.duration = t_end - t_start;

			% assign fixations
			obj.prev_fixation = fixation1;
			obj.next_fixation = fixation2;

			% distance
			x1 = fixation1.x;
			x2 = fixation2.x;
			y1 = fixation1.y;
			y2 = fixation2.y;

			obj.xs = [x1 x2];
			obj.ys = [y1 y2];

			obj.distance = sqrt((x2-x1)^2 + (y2-y1)^2);

			% direction
			if x1 <= x2
				obj.direction = 'right';
			else
				obj.direction = 'left';
			end

			% position
			if x2 < (1920/2)
				obj.global_position = 'left';
			else
				obj.global_position = 'right';
			end
		end
	end
end
