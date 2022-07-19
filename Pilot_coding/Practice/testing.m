%% clear everthing and shuffle random generator  
  
rng('default')
rng('shuffle')
clc;
    
sca;
clear;
normalscreen = 1;
clear PsychPortAudio; 
    

clear PsychHID;
audiodevices = PsychPortAudio('GetDevices');
audiodevicenames = {audiodevices.DeviceName};
[logicalaudio, locationaudio] = ismember({'HDA Intel PCH: ALC3204 Analog (hw:0,0)'}, audiodevicenames);
audiodeviceindex = audiodevices(locationaudio(logicalaudio)).DeviceIndex;

%% parameter

P.ISI = 3:.1:6;
% VISUAL
P.Background   = 150; %background
P.textsize = 36;
P.textstyle = 0;
P.textfont = 'Arial Unicode MS';
% Colors
P.Color.black = [0,0,0]; % add black
P.Color.white = [255,255,255];
P.Color.yellow = [255,255,0];
P.Color.red = [255,0,0];
P.Color.green = [0,255,0];
P.Color.grey = [128, 128, 128];
% keys
KbName('UnifyKeyNames');
P.Keys.esc = KbName('escape');
P.Keys.enter = KbName('return');
P.Keys.spa = KbName('space');
P.left = KbName('LeftArrow');
P.right = KbName('RightArrow');
% Audio
P.mastervolume = .2;
P.nrchannels = 2;
P.audiofreq = 44100;
P.sugLat = 0; %‘suggestedLatency’ optional requested latency% reqlatencyclass’ Allows to select how aggressive PsychPortAudio should be about minimizing sound latency and getting good deterministic timing
% tones
P.tonedur = .050;
P.tonefade = 10;
P.tonefreq = 1000;
% content
P.cross = '+';
P.practice.listen = 'listening \n\n\n + \n\n';
P.practice.remember = 'remebering \n\n\n + \n\n';
P.practice.produce = 'producing \n\n\n + \n\n';
P.maxreptime = 1;
%% path setting
P.Expdir = pwd;
P.outdir = [P.Expdir filesep 'results_test' filesep];
if ~isfolder(P.outdir)
    mkdir(P.outdir);
    disp('created output directory');
end
%% obtain some information of experiment
% Obtain some information of experiment
% prompt = {'Subject Number','Gender[1 = m, 2 = f]','Age'};
% title = 'Exp infor'; 
% definput = {'Subject Number','Gender[1 = m, 2 = f]','Age'}; 
% P.part_info = inputdlg(prompt, title, [1,50],definput);

%% initialize screen

% for writing code with another monitor
Screen('Preference', 'SkipSyncTests',1);
disp('ATTENTION: skipped synchtests!')
whichScreen = 0;
scsz = get(0,'screensize');
[w, rect] = Screen(whichScreen,'OpenWindow',0,[0 0 800 500]);
[screenXpixels, screenYpixels] = Screen(whichScreen,'WindowSize', w);

% get Parameters of the display
P.rect = rect;
[P.xcenter, P.ycenter] = RectCenter(P.rect);
P.ifi          = Screen('GetFlipInterval', w);

Screen('Preference', 'TextRenderer', 1);
% Screen('Preference', 'TextEncodingLocale', 'UTF8');
Screen('Preference', 'TextAntiAliasing', 1);
Screen('Preference', 'TextAlphaBlending', 0);

Screen('FillRect',w, P.Background);
% color setting for screen is one number.
P.White        = uint8(WhiteIndex(w));
P.Black        = uint8(BlackIndex(w));
P.Gray         = double(uint8((P.Black + P.White) / 2));
P.ScreenWidth  = rect(RectRight);
P.ScreenHeight = rect(RectBottom);

Screen('TextFont',w,P.textfont);
Screen('TextSize',w,P.textsize);
Screen('TextStyle',w,P.textstyle);

Screen('Flip', w);
%% test plot_error
feedback = [-0.5,-0.15];
screenXpixels = P.ScreenWidth;
screenYpixels = P.ScreenHeight;
x_step = screenXpixels/50;
y_step = screenYpixels/10;
lwidth = P.xcenter-x_step*1;
rwidth = P.xcenter+x_step*1;

estimation_relative = feedback; % and signed
numb_rect = length(estimation_relative);

% when very good perf, make a green bar and display BRAVO!
if sum(abs(estimation_relative) < 0.1)/numb_rect == 1
    DrawFormattedText(w, 'BRAVO!!', 'center', 300, P.Color.green);
    Screen('FillRect', w, P.Color.green, [P.xcenter-x_step*6, P.ycenter-y_step*4,P.xcenter+x_step*6, P.ycenter+y_step*4]);
    Screen('Flip', w);
    
else
    % set rectangles X coordinates
    xl_rect = NaN(1,7);
    xy_rect = NaN(1,7);
    
    if numb_rect == 1
        xl_rect = [lwidth nan nan nan nan nan nan];
        xy_rect = [rwidth nan nan nan nan nan nan];
    elseif numb_rect == 2
        xl_rect=[lwidth+x_step*2 lwidth-x_step*2 nan nan nan nan nan];
        xy_rect=[rwidth+x_step*2 rwidth-x_step*2 nan nan nan nan nan];
%     elseif numb_rect == 3
%         x_rect=[lwidth+x_step*2.5 lwidth lwidth-x_step*2.5 nan nan nan nan];
%         X_rect=[rwidth+x_step*2.5 rwidth rwidth-x_step*2.5 nan nan nan nan];
%     elseif numb_rect == 4
%         x_rect=[lwidth+x_step*3.8 lwidth+x_step*1.3 lwidth-x_step*1.3 lwidth-x_step*3.8 nan nan nan];
%         X_rect=[rwidth+x_step*3.8 rwidth+x_step*1.3 rwidth-x_step*1.3 rwidth-x_step*3.8 nan nan nan];
%     elseif numb_rect == 5
%         x_rect=[lwidth+x_step*5.1 lwidth+x_step*2.5 lwidth lwidth-x_step*2.5 lwidth-x_step*5.1 nan nan];
%         X_rect=[rwidth+x_step*5.1 rwidth+x_step*2.5 rwidth rwidth-x_step*2.5 rwidth-x_step*5.1 nan nan];
    end
    
    % set rectangles Y coordinates
    y_rect = NaN(1,7);
    Y_rect = NaN(1,7);
    
    for i = 1:numb_rect
        if estimation_relative(i) < 0
            y_rect(i) = P.ycenter + y_step*estimation_relative(i)*-1;
            Y_rect(i) = P.ycenter;
        else
            y_rect(i) = P.ycenter;
            Y_rect(i) = P.ycenter + y_step*estimation_relative(i)*-1;
        end
    end
    allRects =  [xl_rect; y_rect; xy_rect; Y_rect];
     
    allColors = NaN(3,7);
    for k = 1:numb_rect
        if abs(estimation_relative(k)) <= 0.1
            allColors(:,k) = P.Color.red;
        elseif abs(estimation_relative(k)) > 0.9
            allColors(:,k) = P.Color.red;
        else
            allColors(:,k) = P.Color.black;
        end        
        Screen('FillRect', w, allColors, allRects);
        Screen('FillRect', w, P.Color.white, [P.xcenter-x_step*10, P.ycenter-1,P.xcenter+x_step*10, P.ycenter+1]);
        Screen('Flip', w);
    end
end
 
% KbWait;

WaitSecs(1)
%% initializze PsyPortAudio