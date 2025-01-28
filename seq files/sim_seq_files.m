%% Add pulseq-CEST and pulseq-CEST-library to path

%% Load yaml file and seq files

yaml_file = 'GM_vanZijl2018_11pool_bmsim.yaml'; % name of yaml file
Yaml = yaml.ReadYaml(yaml_file); % read yaml file

sequences = dir('*SpinLock*.seq'); % struct for sequences
seq_files = {sequences(:).name}; % array of sequence names

%% pulseq-CEST simulation for all seq files

sim = cell(2,numel(seq_files)); % create sim cell array

for ii=1:numel(seq_files)
% read seq file and save offsets for Z
seq = SequenceSBB(getScannerLimits()); 
seq_file = seq_files{ii};
seq.read(seq_file) 
offsets_ppm = seq.definitions('offsets_ppm'); 
offsets = offsets_ppm(2:end)';  
Z = zeros(numel(offsets),2); % initialize array for offsets and simulated Z spectra

% simulate seq file with yaml file
Mz = simulate_pulseqcest(seq_file,yaml_file);

% save offsets and Z spectra in Z 
Z(:,1) = offsets;
Z(:,2) = Mz(2:end);

% write seq file and Z into sim cell array
sim{1,ii} = seq_file;
sim{2,ii} = Z;
end
%% Plot results of simulation

figure;
for ii=1:numel(seq_files)
    plot(sim{2,ii}(:,1), sim{2,ii}(:,2),'-') , grid on
    set(gca,'XDir','reverse'); xlabel('\Delta\omega [ppm]'); ylabel('Z(\Delta\omega)'); set(gca,'yLim',[0 1.1]); set(gca,'xLim',[-100 100])
    hold on
end
