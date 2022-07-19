%% clear everything and shuffle random number generator

rng('default')
rng('shuffle')

clear all;
close all;
clc;
sca;

% cd('/Users/sophie/Nextcloud/PROJECT_WMtime/WMTime2_Scripts/WMTime_Seq/');

normalscreen = 0; % setting this to 0 allows to draw in smaller window

%% PARAMETERS

SB_ID = [num2str(0),'A'];

P = [] ; % struct containing all parameters
T = []; % struct containing all the data

% DIRECTORIES
P.Expdir = pwd;
P.outdir = [P.Expdir filesep 'OUTDIR_WMTime' filesep];
if ~isdir(P.outdir)
    mkdir(P.outdir)
    disp('created output directory');
end

P.sbname = SB_ID;

% the sequences
P.mindur = .3;  % shortest sequence duration in seconds
P.n_items = 3;  % maximum number of items per sequence
P.n_seqs = 3;   % number of different sequences
P.ratio = 1.5;  % ratio between two adjacent durations
P.repetitions = 1; % how many repetitions per sequence type (i.e. blocks)
P.ISI = 3:.1:6;% intervals to use from last response to beginning of next trial
P.maxreptime = 5; % in s, the time we wait for a response; to be added to the sum of sequence duration

P.retention = 3; % retention interval in seconds, after encoding until start of response

% Audio Parameters
P.mastervolume = .2; % overall volume
P.nrchannels = 2; % 2 channels = left and right
P.audiofreq = 44100;
P.sugLat = 0; % this might have to be adjusted if we use a windows computer.

% Tones
P.tonedur = .050; % tone duration in s
P.tonefade = 10; %  at the beginning and end of tone in ms
P.tonefreq = 1000; % tone duration

% KEYS
KbName('UnifyKeyNames');
P.keys = [];
P.keys.esc = KbName('ESCAPE');

P.keys.main = KbName('space');

keys = fieldnames(P.keys);
P.keys.all = [];
for i = 1:numel(keys)
    P.keys.all = [P.keys.all P.keys.(keys{i})];
end

% VISUAL

P.Background   = 150; %background

P.textsize = 36;
P.textstyle = 0;
P.textfont = 'Arial Unicode MS';
% Colors
P.colors_black = [0,0,0]; % add black
P.colors_white = [255,255,255];
P.colors_red = [255,0,0];
P.colors_green = [0,255,0];
P.colors_grey = [128, 128, 128];

%% initialize PsychPortAudio
beep OFF
try
    PsychPortAudio('Close'); % just in case it was still open
catch
end

InitializePsychSound(1);
PsychPortAudio('Verbosity',5);

pamaster = PsychPortAudio('Open', [], 1+8, 4, P.audiofreq, P.nrchannels, [], P.sugLat);

% start master
PsychPortAudio('Start', pamaster, 0, 0, 1);

% adjust volume
PsychPortAudio('Volume', pamaster, P.mastervolume);

% open slave devices
pa_tones = PsychPortAudio('OpenSlave', pamaster, 1);
%% ----------------------------
% Initialize Screen
%  ----------------------------

global w whichScreen

% open the display
Screen('Preference', 'SkipSyncTests',0);
disp('ATTENTION: skipped synchtests!')

whichScreen = 0;
scsz = get(0,'screensize');

% the smaller window is useful for debugging
if normalscreen
    [w, rect] = Screen(whichScreen,'OpenWindow');
else
    [w, rect] = Screen(whichScreen, 'OpenWindow',0,[0 0 500 300]);
end
 

% get Parameters of the display
P.rect         = rect;
P.ScreenWidth  = rect(RectRight);
P.ScreenHeight = rect(RectBottom);
P.CenterX      = P.ScreenWidth/2;
P.CenterY      = P.ScreenHeight/2;
P.White        = uint8(WhiteIndex(w));
P.Black        = uint8(BlackIndex(w));
P.Gray         = double(uint8((P.Black + P.White) / 2));
P.ifi          = Screen('GetFlipInterval', w);

Screen('Preference', 'TextRenderer', 1);
Screen('Preference', 'TextAntiAliasing', 1);
Screen('Preference', 'TextAlphaBlending', 0);

Screen('FillRect',w, P.Background);

Screen('TextFont',w,P.textfont);
Screen('TextSize',w,P.textsize);
Screen('TextStyle',w,P.textstyle);

Screen('Flip', w);
%% import training sequen
P.Sequence = xlsread('D:/Experiments/yunyun/TIME MEMORY/SequenceT.xlsx',1,'A1:J8');
P.ntrials = size(P.Sequence,1)
P.DurTable= P.Sequence(:,4:end) /1000

%% play tones
 
[nx, ny, bbox] = DrawFormattedText(w,double(['The training will start right now? \n\n\n'...
    'Press any key.. \n\n']), 'center', 'center',P.colors_white);
Screen('Flip', w);
KbStrokeWait;
WaitSecs(1);
 
[nx, ny, bbox] = DrawFormattedText(w,double(['+']), 'center', 'center',P.colors_black);
Screen('Flip', w);
 
try    
    for i_block = 1:P.repetitions
        
        clear DurTable
        % randomize the order of trials (do that per block)
        DurTable = P.DurTable;
        s = randperm(size(DurTable,1));
        DurTable = DurTable(s,:);
        % write the DurTable for the block to T
        T.DurTable{i_block} = DurTable;
        
        ntrials = size(DurTable,1); % how many trials are there?
        starttrial = (i_block-1)*ntrials; % this allows to count trials over blocks

        % loop over trials within one block
        %T.TimeStamps.tonestart= zeros(ntrials,8)
        for i_trial = 1:ntrials

            % note some stuff in T
            trialcounter = starttrial + i_trial;
            T.Trial(trialcounter).block = i_block;
            T.Trial(trialcounter).trial = i_trial;
            T.Trial(trialcounter).trial_all = i_block;
            
            sequence = DurTable(i_trial,:);
            T.Trial(trialcounter).sequence = sequence;
            
            % how many items to be played?
            n_items = sum(~isnan(sequence));
            T.Trial(trialcounter).n_items = n_items;
            
            % randomly select an ISI
            ISI = P.ISI(randperm(size(P.ISI,1)));
            T.Trial(trialcounter).ISI = ISI;
            
            % make the tone
            tone = [];
            tone = MakeBeep(P.tonefreq, P.tonedur, P.audiofreq);
            %tone = fade_me(tone,P.audiofreq,P.tonefade,P.tonefade); % let tones fade in
            tone(2,:) = tone(1,:);
            
            % load the tone to a buffer
            tonebuffer = PsychPortAudio('FillBuffer',pa_tones, tone);
            
            
            %% now comes the encoding sequence
            disp(['Trial ' num2str(trialcounter) ': ' num2str(sequence)]);
            
            % change the fixation cross color
            [nx, ny, bbox] = DrawFormattedText(w,double(['+']), 'center', 'center',P.colors_red);
            % the onset of the fixation cross defines the start of the trial
       
            if i_trial == 1
                trialstart = Screen('Flip', w);
            else
                trialstart = Screen('Flip', w,trialstop + ISI);
            end
            
            T.TimeStamps.trialstart(trialcounter) = trialstart;
            tonestart = trialstart;
     
            
            % play tones
            % first one is played immediately
            realtonestart=zeros(1,8);
            realtonestart(1) = PsychPortAudio('Start', pa_tones,1,tonestart,1);
            [startTime endPositionSecs xruns estStopTime] = PsychPortAudio('Stop', pa_tones, 1);
         
            % the other ones follow at the designated duration
            for i_item = 1:n_items
                tonestart = realtonestart(i_item) + sequence(i_item);
                realtonestart(i_item+1) = PsychPortAudio('Start', pa_tones,1,tonestart,1);
                [startTime endPositionSecs xruns estStopTime] = PsychPortAudio('Stop', pa_tones, 1);
            end
            
            % write down the tone onsets
            %T.TimeStamps.tonestart(trialcounter,1:n_items+1) = realtonestart;
            T.TimeStamps.tonestart(trialcounter,:) = realtonestart;
            
            % change color of fixation cross to indicate that
            % the sequence is over
            [nx, ny, bbox] = DrawFormattedText(w,double(['+']), 'center', 'center',P.colors_white);
            T.TimeStamps.encoding_over(trialcounter) = Screen('Flip', w);
            
            disp('***************');
            
            %% ---------------------------------------------------------------------
            % Retention Interval
            % ---------------------------------------------------------------------
            
            while GetSecs < T.TimeStamps.encoding_over(trialcounter) + P.retention
            end
            [nx, ny, bbox] = DrawFormattedText(w,double(['+']), 'center', 'center',P.colors_green);
            T.TimeStamps.retention_over(trialcounter) = Screen('Flip', w);
            
            
            %% ---------------------------------------------------------------------
            % Collect response
            % ---------------------------------------------------------------------
            
            % preallocate in case no key is pressed
            repstring = 'pas de reponse';
            T.Trial(trialcounter).reptimes = NaN(n_items+1,1);
            T.Trial(trialcounter).produced = NaN(n_items,1);
            T.Trial(trialcounter).feedback = NaN(n_items,1);
            
            % compute the maximal time we wait for a response
            max_reptime = nansum(sequence) + P.maxreptime;
            
            % how many clicks do we expect?
            max_clicks = n_items + 1;
            got_clicks = 0;
            
            % wait for a certain time to get responses
            while GetSecs > T.TimeStamps.retention_over(trialcounter) &&  ...
                    GetSecs < T.TimeStamps.retention_over(trialcounter) + max_reptime
                
                [ keyIsDown, seconds, keyCode ] = KbCheck;
                
                if keyIsDown
                    if not(any(keyCode(P.keys.all)))
                        continue
                    end
                    
                    % count the clicks
                    got_clicks = got_clicks+1;
                    
                    % RT: from probe offset to klick
                    T.Trial(trialcounter).reptimes(got_clicks) = seconds;
                    
                    if got_clicks == max_clicks
                        break;
                    end
                    
                    KbReleaseWait; % needs to wait until the key is released
                    
                end
            end
            
            T.Trial(trialcounter).got_clicks = got_clicks;
            T.Trial(trialcounter).max_clicks = max_clicks;
            
            %% compute the reproduced durations for feedback
            
            if got_clicks ~= max_clicks % wrong number of clicks
                
                T.Trial(trialcounter).wrongclicks = 1;
                T.Trial(trialcounter).feedback = NaN;
                
                % display error to participant
                [nx, ny, bbox] = DrawFormattedText(w,double(['mauvais nombre de réponses']), 'center', 'center',P.colors_white);
                T.TimeStamps.feedback(trialcounter) = Screen('Flip', w);
                
            else % good number of clicks
                
                T.Trial(trialcounter).wrongclicks = 0;
                
                feedback = NaN(1,n_items) % prepare
                %feedback = zeros(1,P.n_items); % prepare

                for i_item = 1:n_items
                    
                    % compute the produced duration as the difference between
                    % each click and the previous one
                    T.Trial(trialcounter).produced(i_item) = ...
                        T.Trial(trialcounter).reptimes(i_item+1)- T.Trial(trialcounter).reptimes(i_item);
                    
                    % compute feedback as (produced dur - real dur)
                    % that leaves the feedback in seconds, rather than relative
                    % measure
                    T.Trial(trialcounter).feedback(i_item) = ...     
                        T.Trial(trialcounter).produced(i_item) - sequence(i_item);
                    
                    feedback(i_item) = T.Trial(trialcounter).feedback(i_item);
                end
                
                % display feedback to participant
                [nx, ny, bbox] = DrawFormattedText(w,double(['Absolute errors (s): \n\n\n' num2str(feedback)]), 'center', 'center',P.colors_white);
                T.TimeStamps.feedback(trialcounter) = Screen(  'Flip', w);
                
                disp(['Absolute errors (s): ' num2str(feedback)]);
                %cfg.waitToShowFeedback
                disp(1)
                Plot_feedback(w, P,  feedback);
                disp(1)
            end

            %% back to fixation cross
            % switch color of fix cross
            [nx, ny, bbox] = DrawFormattedText(w,double(['+']), 'center', 'center',P.colors_black);
            trialstop = Screen('Flip', w,T.TimeStamps.feedback(trialcounter)+1);
            T.TimeStamps.trialstop(trialcounter) = trialstop;
             disp('***************');
             disp('***************');
        end
    end
end
       
 