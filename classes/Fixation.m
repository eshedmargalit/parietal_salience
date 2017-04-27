classdef Fixation
	properties
		start_time
		end_time
		duration
		x
		y
		pupil
		dx
		dy
	end

	methods
		% Constructor
		function obj = Fixation(fix_row,x0,y0)
			obj.start_time = fix_row.FixationStart;
			obj.end_time = fix_row.FixationEnd;
			obj.duration = fix_row.FixationLength;
			obj.x = fix_row.XPosition;
			obj.y = fix_row.YPosition;
			obj.pupil = fix_row.Pupil;

			obj.dx = obj.x - x0;
			obj.dy = obj.y - y0;
		end
	end
end
