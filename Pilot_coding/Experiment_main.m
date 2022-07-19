%% clear everthing and shuffle random generator  

rng('shuffle');
clc;    
sca;
clear;
normalscreen = 0  ;
clear PsychPortAudio;    
           
clear PsychHID;     
 
audiodevices = PsychPortAudio('GetDevices');
audiodevicenames = {audiodevices.DeviceName};
[logicalaudio, locationaudio] = ismember({'HDA Intel PCH: ALC3204 Analog (hw:0,0)'}, audiodevicenames);
audiodeviceindex = audiodevices(locationaudio(logicalaudio)).DeviceIndex;   
%%
[~,~,keyinfo]= GetKeyboardIndices();
[~,c] = size(keyinfo);
for keydevice = 1:c
 %     if ismember({'Dell Dell USB Keyboard'},keyinfo{keydevice}.product)
    if ismember({'AT Translated Set 2 keyboard'},keyinfo{keydevice}.product)
        keyinfo{keydevice}.product;
        i_keyboard = keyinfo{keydevice}.index;
    end
end 
P.i_keyboard = i_keyboard;
%% parameter

P.ISI = 2:.1:6;
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
P.Keys.left = KbName('LeftArrow');
P.Keys.right = KbName('RightArrow');
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
P.maxreptime = 3;

%% Prepare materials
P.trialrepeat = 20;

P.oneitem = [0.52,1.04;0.52,0.52;1.04,1.04;2.08,2.08;1.04,2.08];
P.twoitems_1= [1.04,2.08,3.12,1; 2.08,1.04,3.12,1];
P.twoitems_2= [1.04,2.08,3.12,2; 2.08,1.04,3.12,2];

P.produce_index = [0;1;2];  

P.Sequence1 = Make_Sequence(P.oneitem,P.trialrepeat);
P.sequence2 = Make_Sequence(P.twoitems_1,3*P.trialrepeat);
P.sequence3 = Make_Sequence(P.twoitems_2,3*P.trialrepeat);
P.pro_index = Make_Sequence(P.produce_index , 2*P.trialrepeat);
P.pro_index_2 = P.pro_index;
while P.pro_index_2(1) ~= 0
    P.pro_index_2 = P.pro_index_2 (randperm(size(P.pro_index,1)),:);
end
P.pro_index_3 = P.pro_index;
while P.pro_index_3(1) ~= 0
    P.pro_index_3 = P.pro_index_3 (randperm(size(P.pro_index,1)),:);
end

P.Sequence2 = [P.sequence2 P.pro_index_2];
P.Sequence3 = [P.sequence3 P.pro_index_3];

%% path setting
P.Expdir = pwd;
P.outdir = [P.Expdir filesep 'results_test' filesep];
if ~isfolder(P.outdir)
    mkdir(P.outdir);
    disp('created output directory');
end
%% obtain some information of experiment
% Obtain some information of experiment
prompt = {'Subject Number',   'Gender[1 = m, 2 = f]','Age'};
title = 'Exp infor'; 
definput = {'Subject Number','Gender[1 = m, 2 = f]','Age'}; 
P.part_info = inputdlg(prompt, title, [1,50],definput);
%% initialize screen

% for writing code with another monitor
Screen('Preference', 'SkipSyncTests',0);
whichScreen = 0;
scsz = get(0,'screensize');
% the smaller window is useful for debugging

if normalscreen
    [w, rect] = Screen(whichScreen,'OpenWindow');
else
    [w, rect] = Screen(whichScreen, 'OpenWindow',0,[0 0 500 300]);
end

% [w, rect] = Screen(whichScreen,'OpenWindow',0,[0,0,500,800]); % seting size
% [w, rect] = Screen(whichScreen,'OpenWindow',0, [0,0,1920,1080]);
[screenXpixels, screenYpixels] = Screen(whichScreen,'WindowSize', w);   
 
% get Parameters of the display
P.rect = rect;
[P.xcenter, P.ycenter] = RectCenter(P.rect);
P.ifi          = Screen('GetFlipInterval', w);
P.frame = round(1 / P.ifi);  % frame rate per sec, or round(FrameRate(w))
P.slack = P.ifi/2;

Screen('Preference', 'TextRenderer', 1);
% Screen('Preference', 'TextEncodingLocale', 'UTF-8');
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
HideCursor;

 
%% initializze PsyPortAudio     
tone = MakeBeep(P.tonefreq, P.tonedur, P.audiofreq);
tone = Fade_me(tone,P.audiofreq,P.tonefade,P.tonefade);
P.tone(2,:) = tone(1, :); % for left and right, two channels  
InitializePsychSound(1);
PsychPortAudio('Verbosity',5);%Set level of verbosity for error/warning/status messages.
P.paudio = PsychPortAudio('Open',audiodeviceindex,1,4,P.audiofreq, P.nrchannels,P.sugLat);
PsychPortAudio('Volume', P.paudio);  
PsychPortAudio('FillBuffer',P.paudio, P.tone);

%% Block id 
%     Block_id = [1,2,3];
%     Block_id = [1,3,2];
Block_id = 3;

%% Experiment design
try
    for block_num = 1:3
        block_id = Block_id(block_num);
        if block_id == 1
            %% Block_1 
            DrawFormattedText(w,'Block-1 \n\n\n Press Anykey \n\n', 'center', 'center',P.Color.white);
            Screen('Flip', w);
            KbStrokeWait;
            WaitSecs(1); 
            %% training
            DrawFormattedText(w,'Practice will start \n\n\n Press Anykey \n\n', 'center', 'center',P.Color.white);
            Screen('Flip', w);
            KbStrokeWait;
            WaitSecs(1); 
            P.Sequence_practice_1 = P.Sequence1(1:5,:);
            i_training_1 = 1;
            while i_training_1 == 1 
                for i_practice1 = 1:2
                    sequence = P.Sequence_practice_1(i_practice1,1);
                    retention = P.Sequence_practice_1(i_practice1,2);
                    trialcounter = i_practice1;
                    Repeat_main(trialcounter,3,1,sequence,retention,P,w,P.practice.listen,P.practice.remember,P.practice.produce);
                end
                DrawFormattedText(w,'Do you need more training? \n\n\n Yes: press LeftArrow \n\n\n No: Press RightArrow \n\n', 'center', 'center',P.Color.white);
                Screen('Flip', w);
                while 1     % waiting response
                    [~, ~, key_Code] = KbCheck;  
                    if key_Code(P.Keys.left)
                        i_training_1 = 1;
                        break
                    elseif key_Code(P.Keys.right) 
                        i_training_1 = 0;
                        break
                    end      
                end
            end
            %% main experiment_1
            DrawFormattedText(w,'Experiment-block-1 will start \n\n\n Press AnyKey \n\n', 'center', 'center',P.Color.white);
            Screen('Flip', w);
            KbStrokeWait;
            WaitSecs(1);
            %% main experiment check which block experiment   
            i_block = block_id;
            Sequence = P.Sequence1;
            trial_count = 10;     
%             trial_count = size(Sequence,1); % TEST trial_count = trialcounter
            trial_data_1 = table; 
            for i_round = 1:2
                if i_round == 1
                    for i_trial = 1:trial_count 
                        trialcounter = i_trial;
                        %% testing to have a rest
                        if rem(trialcounter/6, 1) == 0
                            Rest(w,P,30);
                        end
                        %% 1 main trials
                        ISI = P.ISI(randperm(size(P.ISI,1)));
                        sequence = Sequence(i_trial,1);
                        retention = Sequence(i_trial,2); 
                        [one_trial] = Repeat_main(trialcounter,3,1,sequence,retention,P,w,'+','+','+');
                        Trial = struct2table(one_trial,'AsArray', true);
                        trial_data_1 = [trial_data_1;Trial];    
                        WaitSecs(ISI);    
                    end  
                end
                if i_round == 2
                    re_index_1 = find(trial_data_1.got_clicks - 2 ~= 0);    
                    if re_index_1 ~= 0
                        for index2 = 1:length(re_index_1)
                            trial_count2 =  re_index_1(index2);
                            ISI = P.ISI(randperm(size(P.ISI,1)));
                            sequence = trial_data_1.sequence(index2,:);
                            retention = trial_data_1.retention(index2);     
                            [one_trial2] = Repeat_main(trial_count2,3,1,sequence,retention,P,w,'+','+','+'); 
                            Trial2 = struct2table(one_trial2,'AsArray', true);
                            trial_data_1 = [trial_data_1;Trial2];
                            P.result_1 = trial_data_1;
                            WaitSecs(ISI); 
                        end
                    end
                end
            end
            %% Save data
            name = strcat(P.outdir ,'subject_',P.part_info{1},'_block_', num2str(i_block), '_', date, '.csv');
            writetable(trial_data_1,name);   
            Rest(w,P,60);
%             DrawFormattedText(w,'Having a rest \n\n\n Start experiment Press AnyKey \n\n', 'center', 'center',P.Color.white);
%             Screen('Flip'  ,w);
%             KbStrokeWait;          
        elseif block_id == 2
            %% Block 2 retro 1
            DrawFormattedText(w,'Entrainement-Bloc-2 va commencer \n\n\n Appuyez sur la flèche droite \n\n', 'center', 'center',P.Color.white);
            Screen('Flip', w);
            KbStrokeWait;
            WaitSecs(1);          
            %% Practice experiment  
            P.Sequence_practice_2 = P.Sequence2(1:5,:);
            i_training_2 = 2;
            while i_training_2 == 2 
                for i_practice2 = 1:5
                    sequence = P.Sequence_practice_2(i_practice2,1:2);
                    retention = P.Sequence_practice_2(i_practice2,3);
                    trialcounter = i_practice2;
                    cue = P.Sequence_practice_2(i_practice2,5);
                    Repeat_main(trialcounter,1,cue,sequence,retention,P,w,'listen +','Retention +','Reproduce +');
                end
                    DrawFormattedText(w,'Avez-vous encore besoin de vous entrainer \n\n\n Oui: Appuyez sur la flèche gauche \n\n\n Non: Appuyez sur la flèche droite \n\n', 'center', 'center',P.Color.white);
                    Screen('Flip', w);
                    while 1     % waiting response
                        [~, ~, key_Code] = KbCheck;  
                        if key_Code(P.Keys.left)
                            i_training_2 = 2;
                            break
                        elseif key_Code(P.Keys.right) 
                            i_training_2 = 0;
                            break
                        end      
                    end
             end
        %% 2 main experiment retro 1
            DrawFormattedText(w,'Experience-bloc-2 va commencer \n\n\n Appuyez sur la flèche droite \n\n', 'center', 'center',P.Color.white);
            Screen('Flip', w);
            KbStrokeWait;
            WaitSecs(1);
        %% 2 main experiment check    
            i_block = block_id;
            Sequence = P.Sequence2;
            trial_count = 60;     
%             trial_count = size(Sequence,1); % TEST trial_count = trialcounter
            trial_data_2 = table; 
            for i_round = 1:2
                if i_round == 1
                    for i_trial = 1:trial_count 
                        trialcounter = i_trial;
                        %% testing to have a rest
                        if rem(trialcounter/61, 1) == 0
                            Rest(w,P,5);
                        end
                        %% main trials
                        ISI = P.ISI(randperm(size(P.ISI,1)));
                        sequence = Sequence(i_trial,1:2);
                        retention = Sequence(i_trial,3); 
                        cue = Sequence(i_trial,5);
                        [one_trial] = Repeat_main(trialcounter,1,cue,sequence,retention,P,w,'+','+','+');
                        Trial_2 = struct2table(one_trial,'AsArray', true);
                        trial_data_2 = [trial_data_2;Trial_2];    
                        WaitSecs(ISI);    
                    end  
                end  
                if i_round == 2
                    if trial_data_2.cue == 0
                        re_index = find(trial_data_2.got_clicks -3 ~= 0);  
                    else
                        re_index = find(trial_data_2.got_clicks -2 ~= 0); 
                    end
    
                    if re_index ~= 0
                        for index2 = 1:length(re_index)
                            trial_count2 =  re_index(index2);
                            ISI = P.ISI(randperm(size(P.ISI,1)));
                            sequence = trial_data_2.sequence(index2,:);
                            retention = trial_data_2.retention(index2);   
                            cue = trial_data_2.cue(index2);   
                            [one_trial2] = Repeat_main(trial_count2,1,cue,sequence,retention,P,w,'+','+','+'); 
                            Trial2 = struct2table(one_trial2_2,'AsArray', true);
                            trial_data_2 = [trial_data_2;Trial2];
                            P.result_2 = trial_data_22;
                            WaitSecs(ISI); 
                        end
                    end
                end
            end
            %% Save data
            name = strcat(P.outdir ,'subject_',P.part_info{1},'_block_', num2str(i_block), '_', date, '.csv');
            writetable(trial_data_22,name);  
            DrawFormattedText(w,'La pause \n\n\n Appuyez sur la flèche droite \n\n', 'center', 'center',P.Color.white);
            Screen('Flip',w);
            KbStrokeWait;   
            %% Block_3 attention 0
            elseif block_id == 3
            DrawFormattedText(w,'Entrainement-bloc-3 va commencer \n\n\n Appuyez sur la flèche droite \n\n', 'center', 'center',P.Color.white);
            Screen('Flip', w);
            KbStrokeWait;
            WaitSecs(1);  
            %% training experiment
            P.Sequence_practice_3 = P.Sequence3(1:5,:);
            i_training_3 = 3;
            while i_training_3 == 3
                for i_practice3 = 1:5
                    sequence = P.Sequence_practice_3(i_practice3,1:2);
                    retention = P.Sequence_practice_3(i_practice3,3);
                    trialcounter = i_practice3;
                    cue = P.Sequence_practice_3(i_practice3,5);
                    Repeat_main(trialcounter,0,cue,sequence,retention,P,w,'listen +','Retention +','Reproduce +');
                end
                    DrawFormattedText(w,'Avez-vous encore besoin de vous entrainer \n\n\n Oui: Appuyez sur la flèche gauche \n\n\n Non: Appuyez sur la flèche droite \n\n', 'center', 'center',P.Color.white);
                    Screen('Flip', w);
                    while 1     % waiting response
                        [~, ~, key_Code] = KbCheck;  
                        if key_Code(P.Keys.left)
                            i_training_3 = 3;
                            break;
                        elseif key_Code(P.Keys.right) 
                            i_training_3 = 0;
                            break
                        end      
                    end
            end  
            %% 3 main experiment block_3
            DrawFormattedText(w,'Experimence-block-3 va commencer \n\n\n Appuyez sur la flèche droite \n\n', 'center', 'center',P.Color.white);
            Screen('Flip', w);
            KbStrokeWait;
            WaitSecs(1);
            %% 3 main experiment
            i_block = block_id;
            Sequence = P.Sequence3;
%             trial_count = 6;     
            trial_count = size(Sequence,1); % TEST trial_count = trialcounter
            trial_data_3 = table; 
            for i_round = 1:2
                if i_round == 1
                    for i_trial = 1:trial_count
                        trialcounter = i_trial;
                        %% 3 testing to have a rest
                        if rem(trialcounter/61, 1) == 0
                            Rest(w,P,30);
                        end         
                                                              %% 3 main trials
                        ISI = P.ISI(randperm(size(P.ISI,1)));
                        sequence = Sequence(i_trial,1:2);
                        retention = Sequence(i_trial,3); 
                        cue = Sequence(i_trial,5);
                        [one_trial] = Repeat_main(trialcounter,0,cue,sequence,retention,P,w,'+','+','+');
                        Trial_3 = struct2table(one_trial,'AsArray', true);
                        trial_data_3 = [trial_data_3;Trial_3];    
                        WaitSecs(ISI);    
                    end  
                end  
                
                if i_round == 2
                    re_index3 = [];
                    for i = 1:size(trial_data_2)
                        if cell2mat(trial_data_2.Produced(i)) == 0
                            disp(trial_data_2.Produced(i));
                            disp(i);
                            re_index3 = [re_index3,i];
                        end
                    end
                    if size(re_index3) ~= 0
                        for index2 = 1:length(re_index3)
                            trial_count2 =  re_index3(index2);
                            ISI = P.ISI(randperm(size(P.ISI,1)));
                            sequence = trial_data_3.sequence(index2,:);
                            retention = trial_data_3.retention(index2);   
                            cue = trial_data_3.cue(index2);   
                            [one_trial2] = Repeat_main(trial_count2,0,cue,sequence,retention,P,w,'+','+','+'); 
                            Trial_3_2 = struct2table(one_trial2,'AsArray', true);
                            trial_data_3 = [trial_data_3;Trial_3_2];
                            P.result_3 = trial_data_33;
                            WaitSecs(ISI); 
                        end
                    end
                end
            end
            %% Save data
        name = strcat(P.outdir ,'subject_',P.part_info{1},'_block_', num2str(i_block), '_', date, '.csv');
        writetable(trial_data_33,name);
        DrawFormattedText(w,'La pause \n\n\n Appuyez sur la flèche droite \n\n', 'center', 'center',P.Color.white);
        Screen('Flip'  ,w);
        KbStrokeWait;
        stop = 1;
        end
    end
    %% SAVE DATA
    save ([P.outdir filesep P.part_info{1}  '_' datestr(now,'yyyymmdd')],'P');
    if stop ==1
        DrawFormattedText(w,'Merci beaucoup', 'center', 'center',P.Color.white);
        Screen('Flip', w);
        sca;
    end
catch exception
Errors = [P.outdir filesep P.part_info{1}  '_' datestr(now,'yyyymmdd') '_ERROR'];
save (Errors ,'P');
Screen('CloseAll');
sca;
PsychPortAudio('Close');
ShowCursor;
rethrow(exception);
end
              
                 
 
    
        
                                                                                                                                                
                                                                                                                                                       
                      
        
      
     
       
                 
              
                                      
         
  
  
 
   
    
   

      




   
  


 


 

 
   
        
      
     
     
 
   
   
 

    
       
    
       
    
      
                
          
  
   
   
   
 
