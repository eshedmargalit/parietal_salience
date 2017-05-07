% Eshed Margalit
% April 24, 2017
classdef Trial < handle

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
		exp_num

		%% derived props
		% fixations
		fixations
		n_fixations
		baseline_fixation % time after fixation onset and before image onset

		% saccades
		saccades
		n_saccades
	end

	methods
		% Constructor
		function obj = Trial(trial_info, fixation_table, blink_tbl,...
			im_dir, exp_num)

			% trivial initialization
			trivial_init(obj, trial_info);
			obj.im_dir = im_dir;
			obj.exp_num = exp_num;

			% classify trial type based on maximum of two temps
			assign_condition(obj);

			% store image filename
			obj.fname = sprintf('%s/A%d.jpg',obj.im_dir,...
				obj.figure_number);

			%% Parse fixation table
			parse_fixation_table(obj,fixation_table,blink_tbl);	
			compute_saccades(obj);

			obj.n_fixations = length(obj.fixations);
			obj.n_saccades = obj.n_fixations - 1;

			% assign saccades to fixations
			assign_fixations_saccades(obj);
		end

		function stats = get_stats(self, direction)
			% direction can be '', 'left', or 'right'

			fixations = self.get_fixations(direction);

			stats = struct();
			stats.n_fixations = length(fixations);

			durations = zeros(stats.n_fixations,1);
			pupil_sizes = zeros(stats.n_fixations,1);
			saliences = zeros(stats.n_fixations,1);

			for i = 1:stats.n_fixations
				durations(i) = fixations{i}.duration;
				pupil_sizes(i) = fixations{i}.pupil;
				saliences(i) = fixations{i}.salience;
			end

			% Fixation durations
			stats.fixation_durations = struct();
			stats.fixation_durations.mn = mean(durations); 
			stats.fixation_durations.sd = std(durations);
			stats.fixation_durations.sem = stats.fixation_durations.sd...
				./ sqrt(stats.n_fixations);

			% Pupil sizes
			stats.pupil_sizes = struct();
			stats.pupil_sizes.mn = mean(pupil_sizes);
			stats.pupil_sizes.sd = std(pupil_sizes);
			stats.pupil_sizes.sem = stats.pupil_sizes.sd...
				./ sqrt(stats.n_fixations);

			% Saliences
			stats.saliences = struct();
			stats.saliences.mn = mean(saliences);
			stats.saliences.sd = std(saliences);
			stats.saliences.sem = stats.saliences.sd...
				./ sqrt(stats.n_fixations);

			% For ease of access, store means separately
			stats.fixation_durations_mn = stats.fixation_durations.mn;
			stats.pupil_sizes_mn = stats.pupil_sizes.mn;
			stats.saliences_mn = stats.saliences.mn;

		end

		function retval = get_fixations(obj, varargin)
			if length(varargin) > 1
				error('Too many arguments. 1 argument expected');
			elseif length(varargin) == 0
				direction = '';
			else
				direction = varargin{1};
			end


			if strcmp(direction,'') || strcmp(direction,'all')
				retval = obj.fixations;
			else
				retval = {};
				for i = 1:obj.n_fixations
					f = obj.fixations{i};
					if isempty(f.prev_saccade)
						continue;
					end

					if strcmp(direction, f.prev_saccade.direction)
						retval = [retval; {f}];
					end
				end
			end
		end

		function retval = get_saccades(obj, varargin)
			if length(varargin) > 1
				error('Too many arguments. 1 argument expected');
			elseif length(varargin) == 0
				direction = '';
			else
				direction = varargin{1};
			end


			if strcmp(direction,'') 
				retval = obj.saccades;
			else
				retval = {};
				for i = 1:obj.n_saccades
					s = obj.saccades{i};
					if strcmp(direction, s.direction)
						retval = [retval; {s}];
					end
				end
			end
		end

		% plots image and saliency map
		function hm = get_heatmap(self)
			img = imread(self.fname);
			params = makeGBVSParams;
			params.levels = [2, 3, 5, 6, 7, 8, 9]; % from Xiaomo
			saliency_map = gbvs(img, params);
			hm = heatmap_overlay(img,saliency_map.master_map_resized);
		end

		function compute_fixation_salience(self)
			img = imread(self.fname);
			params = makeGBVSParams;
			params.levels = [2, 3, 5, 6, 7, 8, 9]; % from Xiaomo
			saliency_map = gbvs(img, params);

			% assign salience to each fix
			for f = 1:length(self.fixations)
				x = floor(self.fixations{f}.x);
				y = floor(self.fixations{f}.y);
				self.fixations{f}.salience = saliency_map.master_map_resized(y,x);
			end
		end

		function assign_condition(obj)
			max_temp = max(obj.temp1, obj.temp2);
			if max_temp < -30000 || max_temp > 30 
				obj.condition = 'control';
			else
				obj.condition = 'inactivation';
			end
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
					fx = fix.cx;
					fy = fix.cy;
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

		% plot image and raw fixation points
		function lr_test(obj)
			
			% compute heatmap overlay
			hm = obj.get_heatmap();
			imshow(hm); hold on;
			
			saccades = obj.saccades;

			for i = 1:obj.n_saccades
				sac = saccades{i};

				color = 'r';
				if strcmp(sac.direction, 'left')
					color = 'b';
				end
				
				plot([sac.xs(1), sac.xs(2)],...
					[sac.ys(1), sac.ys(2)],...
					'Color',color,...
					'LineWidth',3);
			end
		end

		function trivial_init(obj, trial_info)
			obj.temp1 = trial_info.Temperature1;
			obj.temp2 = trial_info.Temperature2;
			obj.fixation_on = trial_info.FixationOn;
			obj.fixation_in = trial_info.FixationIn;
			obj.figure_number = trial_info.FigureNum;
			obj.image_on = trial_info.ImageOn;
			obj.image_end = trial_info.ImageEnd;
		end

		function assign_fixations_saccades(obj)
			for fix_idx = 1:obj.n_fixations
				if fix_idx == 1
					obj.fixations{fix_idx}.next_saccade = ...
						obj.saccades{fix_idx};
					obj.fixations{fix_idx}.prev_saccade = ...
						[];
				elseif fix_idx == obj.n_fixations
					obj.fixations{fix_idx}.next_saccade = ...
						[];
					obj.fixations{fix_idx}.prev_saccade = ...
						obj.saccades{fix_idx-1};	
				else
					obj.fixations{fix_idx}.next_saccade = ...
						obj.saccades{fix_idx};
					obj.fixations{fix_idx}.prev_saccade = ...
						obj.saccades{fix_idx-1};	
				end
			end
		end

		function parse_fixation_table(obj,fix_tbl,blink_tbl)
			% scrub any fixation within 100ms of blink
			n_fixations = size(fix_tbl,1);
			blink_on = blink_tbl(:,3);
			blink_off = blink_tbl(:,3);
			cut_early = blink_on - 100;
			cut_late = blink_off + 100;

			blink_rows = [];
			for i = 1:n_fixations
				fix = fix_tbl(i,:);
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
			fix_tbl(blink_rows,:) = [];
			n_fixations = size(fix_tbl,1);

			% determine x0,y0: monkey's fixation point before image appears
			starts_after_fixation = fix_tbl.FixationStart >= obj.fixation_on;
			ends_before_image_onset = fix_tbl.FixationEnd <= obj.image_on;
			intersection = (starts_after_fixation .* ends_before_image_onset);
			baseline_fixation_indices = find(intersection);
			fix0 = fix_tbl(baseline_fixation_indices,:);

			x0s = fix0.XPosition;
			y0s = fix0.YPosition;

			% if any fixations meet the criteria after blink
			% removal, use the mean. If not, use the
			% first entry in the table 
			if size(fix0,1) == 0
				x0 = fix_tbl.XPosition(1);
				y0 = fix_tbl.YPosition(1);
			else
				x0 = mean(x0s);
				y0 = mean(y0s);
			end

			% Initialize all fixations
			fixations = {};

			base = '~/moorelab/parietal_inactivation/data/QuitoImagesExp';
			gbvs_str = sprintf('%s%d/saliency_maps/gbvs_A%d.jpg',...
				base, obj.exp_num, obj.figure_number);
			salmap = imread(gbvs_str);
			for i = 1:n_fixations
				fixations{i} = Fixation(fix_tbl(i,:),...
					x0,y0,salmap');
			end
			obj.fixations = fixations';

			if size(fix0,1) == 0
				obj.baseline_fixation = fix_tbl(1,:);
			else
				obj.baseline_fixation = fix0;
			end
		end

		function saccades = compute_saccades(obj)
			
			saccades = cell(length(obj.fixations)-1,1);
			for f = 2:length(obj.fixations)
				fix1 = obj.fixations{f-1};
				fix2 = obj.fixations{f};
				saccades{f-1} = Saccade(fix1,fix2);
			end
			obj.saccades = saccades;
		end
	end
end
