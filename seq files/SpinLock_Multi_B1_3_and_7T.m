%% Multi_B0_B1_10SL_DC50
% this file requires pulseq-cest sim commit
% 94484e494e4897287ab0c78160bf654106feeff7 or later, as previously weff sign  error lead to artifacts
% see also https://github.com/kherz/pulseq-cest/pull/6
%
%
% Creates a sequence file for an APTw protocol with conventional offresonant SL pulses, 50% DC and tsat of 2 s
% This is a pulseq spin-lock pulse train following the paper of Roellofs et al.
% citation:
% Roeloffs, V., Meyer, C., Bachert, P., and Zaiss, M. (2014) 
% Towards quantification of pulsed spinlock and CEST at clinical MR scanners: 
% an analytical interleaved saturation–relaxation (ISAR) approach, 
% NMR Biomed., 28, 40– 53, doi: 10.1002/nbm.3192. 

% Moritz Zaiss 2021
% moritz.zaiss@tuebingen.mpg.de

%%  Further sequence definitions part 2
author = 'Moritz Zaiss','Lukas Kamm','Moritz Fabian','Jan-Ruediger Schuere';

%% get id of generation file
if contains(mfilename, 'LiveEditorEvaluationHelperESectionEval')
    [~, seqid] = fileparts(matlab.desktop.editor.getActiveFilename);
else
    [~, seqid] = fileparts(which(mfilename));
end

%% scanner limits
% see pulseq doc for more ino
seq = SequenceSBB(getScannerLimits());
gamma_hz  =seq.sys.gamma*1e-6;                  % for H [Hz/uT]

%% sequence definitions
% everything in defs gets written as definition in .seq-file
defs.n_pulses      = [10]                                                       ; % number of pulses
defs.tp            = 100e-3                                                     ; % pulse duration [s]
defs.td            = 100e-3                                                     ; % interpulse delay [s]
defs.Trec          = 3.5                                                        ; % approx [s] % Trec und Trec M0 sind doppelt
defs.Trec_M0       = 3.5                                                        ; % approx [s]
defs.M0_offset     = -300                                                       ; % m0 offset [ppm]
defs.DCsat         = defs.tp/(defs.tp+defs.td)                                  ; % duty cycle
defs.offsets1       = [-100 -75 -50 -30 -20 -10 -6:0.25:6 10 20 30 50 75 100]          ; % offsets1 for low B1
defs.offsets2       = [-100 -75 -50 -30 -20 -10 -6:0.5:6 10 20 30 50 75 100]           ; % offsets2 for high B1
%defs.offsets1       = [-1 -0.5 0]           ; % offsets1 for low B1
%defs.offsets2       = [-1 -0.5 0]           ; % offsets2 for high B1

defs.offsets_ppm    = [defs.M0_offset defs.offsets1]                            ; % offset1 vector [ppm] + M0                
defs.num_meas      = numel(defs.offsets_ppm)                                    ; % number of repetition
defs.Tsat          = defs.n_pulses.*(defs.tp+ defs.td)-defs.td                  ;
defs.FREQ		   = 127.7292;   %298.0348                                                    ;% Approximately 3 T
defs.B0            = defs.FREQ/(gamma_hz)                                       ;% Calculate B0     
defs.seq_id_string = seqid                                                      ;% unique seq id
defs.B1_array      = [0.3 0.6 0.9 1.5 2 2.7 4]     %0.3                               ;%[uT]
%defs.B1_array      = [0.3]     %0.3 
defs.B1pa          = defs.B1_array                                              ;% Multiple B1 levels.
defs.spoiling      = 1                                                            ;% 0=no spoiling, 1=before readout, Gradient in x,y,z

seq_filename = strcat(defs.seq_id_string,'.seq'); % filename

%% Gradient spoiler parameters

spoilRiseTime = 1e-3;
spoilDuration = 4500e-6 + spoilRiseTime; % [s]

%% Pseudo ADC , da sonst Probleme mit zurücksetzen der seq file ?! sletsam

% pseudo adc, not played out
pseudoADC = mr.makeAdc(1,'Duration', 1e-3);

%% check SL parameters

% SL pulses are played out during the interpulse delay. We need to make
% sure that they fit in the DC here
slPrepPulseTime = 1e-3; %Gaps between pulses [s]
slPauseTime = 250e-6;

additionalSLPrepTime = 2*slPrepPulseTime+2*slPauseTime;
td = defs.td - additionalSLPrepTime; % DC is between block bulses SL is in between
if td < 100e-6
    error('DC too high for SL prepatration pulses!');
end

% these rf times getting added in the run function of pulseq! If we want
% the timing to be exact we have to take care of this
if(slPauseTime-seq.sys.rfDeadTime-seq.sys.rfRingdownTime) <= 0
    error('slPauseTime is too short for hardware limits');
end
slPauseTime = slPauseTime-seq.sys.rfDeadTime-seq.sys.rfRingdownTime;   % Aktuell wird nur das ausgeführt und SL Pause ist auf 0.25 ms festgelegt?!

%minFa = 0.38    ; % this is the limit for prep pulses to be played out     % Muss der für 7T angepasst werden ?!
minFa = 0    ; % this is the limit for prep pulses to be played out     % Muss der für 7T angepasst werden ?!

%% loop for different B1

for nb1=1:numel(defs.B1_array)

currentB1=defs.B1_array(nb1);
% init sequence
   seq = mr.Sequence();

% Adaption of Frequency Offsets 
    if currentB1>2.99
       disp('B2 values have to be in ascending order!')
       defs.offsets_ppm= [defs.M0_offset defs.offsets2]
    end


    %% loop through zspec offsets
    offsets_Hz = defs.offsets_ppm*defs.FREQ;        % [Hz]
    gamma_rad = gamma_hz*2*pi;        	            % [rad/uT]

    % loop through offsets and set pulses and delays
    for currentOffset = offsets_Hz
        if currentOffset == defs.M0_offset*defs.FREQ
            if defs.Trec_M0 > 0
                seq.addBlock(mr.makeDelay(defs.Trec_M0));
            end
        else
            if defs.Trec > 0
                seq.addBlock(mr.makeDelay(defs.Trec)); % recovery time
            end
        end
    
    fa_sat          = currentB1*gamma_rad*defs.tp; % flip angle of sat pulse
    faSL            = atan((gamma_hz*currentB1)/(currentOffset));   % thats the angle theta of the effective system
    preSL           = mr.makeBlockPulse(faSL,'Duration',slPrepPulseTime, 'Phase', -pi/2,'system',seq.sys);
    satPulse        = mr.makeBlockPulse(fa_sat, 'Duration', defs.tp,'freqOffset', currentOffset, 'system', seq.sys);
    accumPhase      = currentOffset*360*defs.tp*pi/180; % scanner needs the correct phase at the end of the sturation pulse
    postSL          = mr.makeBlockPulse(faSL,'Duration',slPrepPulseTime, 'Phase', accumPhase+pi/2,'system',seq.sys);
        
        for np = 1:defs.n_pulses
              
            if fa_sat == 0 % pulses with amplitude/FA 0 have to be replaced by delay
                seq.addBlock(mr.makeDelay(defs.tp));
                seq.addBlock(mr.makeDelay(additionalSLPrepTime));
            else
                if abs(faSL) > minFa/180*pi
                    seq.addBlock(preSL);
                    seq.addBlock(mr.makeDelay(slPauseTime));
                else
                    seq.addBlock(mr.makeDelay(mr.calcDuration(preSL)+slPauseTime));
                end
                seq.addBlock(satPulse);
                if abs(faSL) > minFa/180*pi
                    seq.addBlock(mr.makeDelay(slPauseTime));
                    seq.addBlock(postSL);
                else
                    seq.addBlock(mr.makeDelay(mr.calcDuration(postSL)+slPauseTime));
                end
            end
        
            if np < defs.n_pulses % delay between pulses
            
                seq.addBlock(mr.makeDelay(td)); % add delay
            
            end
        end

        if defs.spoiling % spoiling before readout
            %seq.addSpoilerGradients()
            [gxSpoil, gySpoil, gzSpoil] = makeSpoilerGradients(seq.sys, spoilDuration, spoilRiseTime);
            seq.addBlock(gxSpoil, gySpoil, gzSpoil);

        end
        %seq.addPseudoADCBlock(); % readout trigger event
        seq.addBlock(pseudoADC); % readout trigger event
    end

    
   %% write definitions
    defs.seq_id_string = strcat(seqid,'_B1_',num2str(currentB1,3),'uT');
    defs.B1pa = currentB1;
    seq_filename = strcat(defs.seq_id_string,'.seq'); % filename
    def_fields = fieldnames(defs);
    for n_id = 1:numel(def_fields)
        seq.setDefinition(def_fields{n_id}, defs.(def_fields{n_id}));
    end
    seq.write(seq_filename);
   
end


%% plot
%saveSaturationPhasePlot(seq_filename);

%% call standard sim
%M_z = simulate_pulseqcest(seq_filename,'../../sim-library/WM_3T_default_7pool_bmsim.yaml');

%% plot
%plotSimulationResults(M_z,defs.offsets_ppm, defs.M0_offset);
%writematrix(M_z', ['M_z_' seq_filename '.txt']);

M_z = simulate_pulseqcest('W:\radiologie\mr-physik-data\Mitarbeiter\Schuere\test\3_SpinLock_05.seq','W:\radiologie\mr-physik-data\Mitarbeiter\Schuere\test\WM_3T_default_7pool_bmsim.yaml');
