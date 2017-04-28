% Eshed Margalit
% April 24, 2017
classdef Trial

	properties
		%% trivial props
		temp1
		temp2
		fixation_on
		fixation_in
		image_on
		image_end
		figure_number
		fname % the name of the 1920x1080 image
		condition % either 'control' or 'inactivation'
		im_dir % the folder in which images are kept

		%% derived props
		% fixations
		fixations
		n_fixations

		pupil_sizes
		fixation_durations

		mn_fixation_duration
		mn_pupil_size

		% saccades
		saccades
		n_saccades
	end

	methods
		% Constructor
		function obj = Trial(trial_info, fixation_table, blink_tbl,...
			im_dir)

			% trivial initialization
			obj.temp1 = trial_info.Temperature1;
			obj.temp2 = trial_info.Temperature2;
			obj.fixation_on = trial_info.FixationOn;
			obj.fixation_in = trial_info.FixationIn;
			obj.figure_number = trial_info.FigureNum;
			obj.image_on = trial_info.ImageOn;
			obj.image_end = trial_info.ImageEnd;

			obj.im_dir = im_dir;

			% classify trial type based on maximum of two temps
			max_temp = max(obj.temp1, obj.temp2);
			if max_temp < -30000 || max_temp > 30 
				obj.condition = 'control';
			else
				obj.condition = 'inactivation';
			end

			% store image filename
			obj.fname = sprintf('%s/A%d.jpg',obj.im_dir,...
				obj.figure_number);

			%% Parse fixation table
			obj.fixations = Trial.parse_fixation_table(fixation_table,...
				obj.fixation_on,obj.image_on,blink_tbl);	
			obj.saccades = Trial.compute_saccades(obj.fixations);

			obj.n_fixations = length(obj.fixations);
			obj.n_saccades = obj.n_fixations - 1;

			% Compute some statistics of fixation table
			durations = zeros(obj.n_fixations,1);
			pupil_sizes = zeros(obj.n_fixations,1);
			for i = 1:obj.n_fixations
				durations(i) = obj.fixations{i}.duration;
				pupil_sizes(i) = obj.fixations{i}.pupil;
			end

			obj.fixation_durations = struct();
			obj.fixation_durations.mn = mean(durations); 
				obj.mn_fixation_duration = mean(durations);

			obj.fixation_durations.sd = std(durations);
			obj.fixation_durations.sem = obj.fixation_durations.sd...
				./ sqrt(obj.n_fixations);

			obj.pupil_sizes = struct();
			obj.pupil_sizes.mn = mean(pupil_sizes);
				obj.mn_pupil_size = mean(pupil_sizes);
			obj.pupil_sizes.sd = std(pupil_sizes);
			obj.pupil_sizes.sem = obj.pupil_sizes.sd...
				./ sqrt(obj.n_fixations);
		end

		% plots image and saliency map
		function hm = get_heatmap(self)
			img = imread(self.fname);
			params = makeGBVSParams;
			params.levels = [2, 3, 5, 6, 7, 8, 9]; % from Xiaomo
			saliency_map = gbvs(img, params);
			hm = heatmap_overlay(img,saliency_map.master_map_resized);
		end

		% plot image and raw fixation points
		function plot_fixations(self, mode)
			
			% compute heatmap overlay
			hm = self.get_heatmap();
			imshow(hm); hold on;
			
			fixations = self.fixations;

			colors = cool(self.n_fixations);
			for i = 1:self.n_fixations
				fix = fixations{i};
				switch mode
				case 'raw'
					fx = fix.x;
					fy = fix.y;
				case 'centered'
					fx = fix.dx + 1920/2;
					fy = fix.dy + 1080/2;
				otherwise
					error('Mode must be ''centered'' or ''raw''');
				end

				if i ==1
					plot([1920/2, fx], [1080/2, fy],...
						'Color',colors(i,:),...
						'LineWidth',3);
				else
					plot([prev.x, fx], [prev.y, fy],...
						'Color',colors(i,:),...
						'LineWidth',3);
				end
				prev.x = fx;
				prev.y = fy;
			end
		end

		function plot_fixation_heatmap(self, mode)
			
			for i = 1:self.n_fixations
				fix = fixations{i};
				switch mode
				case 'raw'
					fx = fix.x;
					fy = fix.y;
				case 'centered'
					fx = fix.dx + 1920/2;
					fy = fix.dy + 1080/2;
				otherwise
					error('Mode must be ''centered'' or ''raw''');
				end

				% approach: create gaussian at each location, then sum?
			end
		end
	end


	methods (Static)
		function fixations = parse_fixation_table(tbl,fixation_on,...
			image_on,blink_tbl)
			% scrub any fixation within 100ms of blink
			n_fixations = size(tbl,1);
			blink_on = blink_tbl(:,3);
			blink_off = blink_tbl(:,3);
			cut_early = blink_on - 100;
			cut_late = blink_off + 100;

			blink_rows = [];
			for i = 1:n_fixations
				fix = tbl(i,:);
				after_cut_early = cut_early < fix.FixationStart;
				before_cut_late = cut_late > fix.FixationEnd;
				both = after_cut_early .* before_cut_late;
				if sum(both) > 0
					blink_rows = [blink_rows i];
				end
			end
			n_blinks = length(blink_rows);
			for i=1:n_blinks
				fprintf('*');
			end
			tbl(blink_rows,:) = [];
			n_fixations = size(tbl,1);

			% determine x0,y0: monkey's fixation point before image appears
			starts_after_fixation = tbl.FixationStart >= fixation_on;
			ends_before_image_onset = tbl.FixationEnd <= image_on;
			intersection = (starts_after_fixation .* ends_before_image_onset);
			baseline_fixation_indices = find(intersection);
			fix0 = tbl(baseline_fixation_indices,:);

			x0s = fix0.XPosition;
			y0s = fix0.YPosition;

			if size(fix0,1) == 0
				x0 = tbl.XPosition(1);
				y0 = tbl.YPosition(1);
			else
				x0 = mean(x0s);
				y0 = mean(y0s);
			end

			% Initialize all fixations
			fixations = {};
			for i = 1:n_fixations
				fixations{i} = Fixation(tbl(i,:),x0,y0);
			end
		end

		function saccades = compute_saccades(fixations)
			saccades = cell(length(fixations)-1,1);
			for f = 2:length(fixations)
				fix1 = fixations{f-1};
				fix2 = fixations{f};
				saccades{f-1} = Saccade(fix1,fix2);
			end
		end
	end
end
