classdef Saccade 
	properties
		duration
		distance
	end

	methods
		% Constructor
		function obj = Saccade(fixation1,fixation2)
			
			% duration
			t_start = fixation1.end_time;
			t_end = fixation2.start_time;
			obj.duration = t_end - t_start;

			% distance
			x1 = fixation1.x;
			x2 = fixation2.x;
			y1 = fixation1.y;
			y2 = fixation2.y;

			obj.distance = sqrt((x2-x1)^2 + (y2-y1)^2);
		end
	end
end
