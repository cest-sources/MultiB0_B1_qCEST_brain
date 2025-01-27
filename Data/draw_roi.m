%% Load nii files for GM, WM and B0B1 mask

grey_matter = readnifti('grey_matter.nii');
white_matter = readnifti('white_matter.nii');
B0B1_mask = readnifti('B0B1_mask.nii');
%% combine GM and WM with B0B1_mask
slice = 2; % select one slice for drawing ROII

grey_matter_mask = grey_matter(:,:,slice) .* B0B1_mask(:,:,slice);
white_matter_mask = white_matter(:,:,slice) .* B0B1_mask(:,:,slice);

grey_matter_log = grey_matter_mask > 0.9; % create logical mask for wm and gm
white_matter_log = white_matter_mask > 0.9;

slice = 2; % select one slice for drawing ROII

figure; imagesc(grey_matter_log),axis image, set(gca,'xtick',[],'ytick',[]);
figure; imagesc(white_matter_log),axis image, set(gca,'xtick',[],'ytick',[]);

%% Draw ROI in GM and WM

% ROI for GM
figure;
imagesc(grey_matter_log); axis image, set(gca,'xtick',[],'ytick',[]); title('Draw ROI in GM') % image for draw ROI in gm
circ_grey_matter = drawcircle(); % draw roi in gm
ROI_grey_matter = createMask(circ_grey_matter); % create logical mask with ROI
BW_edges_grey_matter = bwboundaries(ROI_grey_matter); % get boundaries for plotting

% ROI for WM
figure;
imagesc(white_matter_log); axis image, set(gca,'xtick',[],'ytick',[]); title('Draw ROI in WM') % image for draw ROI in gm
circ_white_matter = drawcircle(); % draw roi in gm
ROI_white_matter = createMask(circ_white_matter); % create logical mask with ROI
BW_edges_white_matter = bwboundaries(ROI_white_matter); % get boundaries for plotting

%% Plot ROI in GM and WM

grey_matter_ROI = grey_matter(:,:,slice) + ROI_grey_matter; % combine image for GM with ROI
white_matter_ROI = white_matter(:,:,slice) + ROI_white_matter; % combine image for WM with ROI

% Plot GM and WM with corresponding ROIs
figure; imagesc(grey_matter_ROI), axis image, set(gca,'xtick',[],'ytick',[]); title('ROI in GM')
figure; imagesc(white_matter_ROI), axis image, set(gca,'xtick',[],'ytick',[]); title('ROI in WM')
