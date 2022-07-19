%% clear everthing and shuffle random generator  
clear;
rng('shuffle');
normalscreen = 1;
clear PsychPortAudio;              
clear PsychHID;     
%% get index of audiodevices 
audiodevices = PsychPortAudio('GetDevices');
audiodevicenames = {audiodevices.DeviceName};
[logicalaudio, locationaudio] = ismember({'HDA Intel PCH: ALC3204 Analog (hw:0,0)'}, audiodevicenames);
P.audiodeviceindex = audiodevices(locationaudio(logicalaudio)).DeviceIndex;   
%% get index of keyboard
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
P.ISI = 2:.1:3;
% VISUAL
P.Background   = 150; %background
P.textsize = 40;   
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
P.practice.listen = 'écouter \n\n\n + \n\n';
P.practice.remember = 'attendre \n\n\n + \n\n';
P.practice.produce = 'produire \n\n\n + \n\n';
P.maxreptime = 3;

%% Prepare materials
P.trialrepeat = 20;

P.oneitem = [0.52,1.04,0;0.52,0.52,0;1.04,1.04,0;2.08,2.08,0;1.04,2.08,0];
P.twoitems_1= [1.04,2.08,3.12; 2.08,1.04,3.12];
P.twoitems_2= [1.04,2.08,3.12; 2.08,1.04,3.12];

P.produce_index = [0;1;2];  

P.Sequence1 = Make_Sequence(P.oneitem,P.trialrepeat);
P.sequence2 = Make_Sequence(P.twoitems_1,3*P.trialrepeat);
P.sequence3 = Make_Sequence(P.twoitems_2,3*P.trialrepeat);
P.pro_index = Make_Sequence(P.produce_index , 2*P.trialrepeat);
P.pro_index_2 = P.pro_index(randperm(size(P.pro_index,1)),:);
P.pro_index_3 = P.pro_index(randperm(size(P.pro_index,1)),:);

% while P.pro_index_2(1) ~= 0
%     P.pro_index_2 = P.pro_index_2 (randperm(size(P.pro_index,1)),:);
% end
% P.pro_index_3 = P.pro_index;
% while P.pro_index_3(1) ~= 0
%     P.pro_index_3 = P.pro_index_3 (randperm(size(P.pro_index,1)),:);
% end

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
P.paudio = PsychPortAudio('Open',P.audiodeviceindex,1,4,P.audiofreq, P.nrchannels,P.sugLat);
PsychPortAudio('Volume', P.paudio);  
PsychPortAudio('FillBuffer',P.paudio, P.tone);

%% Block id 
% Block_id = [2,3];
%     Block_id = [1,3,2];
Block_id = 3;

%% Experiment design
try
    for block_id = Block_id
        if block_id == 1
            P.Sequence_practice = [0.75,1.5,0;0.75,0.75,0;1.5,1.5,0;3,3,0;1.5,3,0];
            retro = 3;
            cue = 1;
            Sequence = P.Sequence1;
            trial_count = 10;     
%             trial_count = size(Sequence,1); % TEST trial_count = trialcounter
        elseif block_id == 2
            P.Sequence_practice = [1.5,3,4.5,1;3,1.5,4.5,2;1.5,3,4.5,1;3,1.5,4.5,0];
            retro = 1;
            Sequence = P.Sequence2;
            trial_count = 11;   
        elseif block_id == 3
            P.Sequence_practice = [1.5,3,4.5,1;3,1.5,4.5,2;1.5,3,4.5,1;3,1.5,4.5,0];
            retro = 0;
            Sequence = P.Sequence3;
%             trial_count = 12;   
            trial_count = size(Sequence,1); % TEST trial_count = trialcounter
        end
            %% starting
            i_block = block_id;
            DrawFormattedText(w,strcat('Bloc-', num2str(i_block), ' \n\n\n Appuyez sur la flèche droite \n\n'), 'center', 'center',P.Color.white);
            Screen('Flip', w);
            KbStrokeWait;
            WaitSecs(1); 
            %% training
            DrawFormattedText(w,strcat('Entrainement-Bloc-', num2str(i_block), '  va commencer \n\n\n Appuyez sur la flèche droite \n\n'), 'center', 'center',P.Color.white);
            Screen('Flip', w);
            KbStrokeWait;
            WaitSecs(1); 
            i_training = 1;
            while i_training == 1 
                for i_practice = 1:2
                    if block_id == 1
                        sequence = P.Sequence_practice(i_practice,1);
                        retention = P.Sequence_practice(i_practice,2); 
                    else
                        sequence = P.Sequence_practice(i_practice,1:2);
                        retention = P.Sequence_practice(i_practice,3);
                        cue = P.Sequence_practice(i_practice,4);
                    end
                    trialcounter = i_practice;
                    Repeat_main(trialcounter,retro,cue,sequence,retention,P,w,P.practice.listen,P.practice.remember,P.practice.produce);
                end
                DrawFormattedText(w,'Avez-vous encore besoin de vous entrainer? \n\n\n Oui: Appuyez sur la flèche gauche \n\n\n Non: Appuyez sur la flèche droite \n\n', 'center', 'center',P.Color.white);
                Screen('Flip', w);
                while 1     % waiting response
                    [~, ~, key_Code] = KbCheck;  
                    if key_Code(P.Keys.left)
                        i_training = 1;
                        break
                    elseif key_Code(P.Keys.right) 
                        i_training = 0;
                        break
                    end      
                end
            end
            %% main experiment
            DrawFormattedText(w,strcat('Experience-bloc-', num2str(i_block),' va commencer \n\n\n Appuyez sur la flèche droite \n\n'), 'center', 'center',P.Color.white);
            Screen('Flip', w);
            KbStrokeWait;
            WaitSecs(1);
            %% main experiment check which block experiment   
            i_block = block_id;
            trial_data = table; 
            for i_round = 1:2
                if i_round == 1
                    for i_trial = 1:trial_count 
                        %% testing to have a rest
                        trialcounter = i_trial;
                        if rem(trialcounter/61, 1) == 0
                            Rest(w,P,5);
                        end
                        %% main trials
                        ISI = P.ISI(randi([1,11],1,1));
                        if block_id == 1
                            sequence = Sequence(i_trial,1);
                            retention = Sequence(i_trial,2); 
                            cue = Sequence(i_trial,3);
                        else
                            sequence = Sequence(i_trial,1:2);
                            retention = Sequence(i_trial,3);
                            cue = Sequence(i_trial,4);
                        end
                        [one_trial] = Repeat_main(trialcounter,retro,cue,sequence,retention,P,w,'+','+','+');
                        Trial = struct2table(one_trial,'AsArray', true);
                        trial_data = [trial_data;Trial];    
                        WaitSecs(ISI);    
                    end  
                end
                if i_round == 2
                    re_index = [];
                    for i = 1:size(trial_data,1)
                        if block_id ~=1
                            check = cell2mat(trial_data.Produced(i));
                        else
                            check = trial_data.Produced(i);
                        end
                        if isequal(check(1),0)
                            re_index = [re_index,i];
                        end
                    end  
                    if isempty(re_index)
                        continue
                    else
                        for index2 = 1:length(re_index)
                            trial_count2 =  re_index(index2);
                            ISI = P.ISI(randi([1,11],1,1));
                            sequence = trial_data.sequence(index2,:);
                            retention = trial_data.retention(index2);     
                            [one_trial2] = Repeat_main(trial_count2,retro,cue,sequence,retention,P,w,'+','+','+'); 
                            Trial2 = struct2table(one_trial2,'AsArray', true);
                            trial_data = [trial_data;Trial2];
                            WaitSecs(ISI); 
                        end
                    end
                end
            end
            %% Save data
            if block_id == 1
                P.result_1 =  trial_data;
            elseif block_id == 2
                P.result_2 =  trial_data;
            elseif block_id == 3
                P.result_3 =  trial_data;
            end
            name = strcat(P.outdir ,'subject_',P.part_info{1},'_block_', num2str(i_block), '_', datestr(now,'yyyymmdd'), '.csv');
            writetable(trial_data,name);
            Rest(w,P,30);
%             DrawFormattedText(w,'Having a rest \n\n\n Start experiment Press AnyKey \n\n', 'center', 'center',P.Color.white);
%             Screen('Flip'  ,w);
%             KbStrokeWait;          
    end
    %% SAVE DATA
    save ([P.outdir filesep P.part_info{1}  '_' datestr(now,'yyyymmdd')],'P');
    DrawFormattedText(w,'Merci beaucoup', 'center', 'center',P.Color.white);
    Screen('Flip', w);
    KbStrokeWait;   
    sca;
catch exception
Errors = [P.outdir filesep P.part_info{1}  '_' datestr(now,'yyyymmdd') '_ERROR'];
save (Errors ,'P');
Screen('CloseAll');
sca;
PsychPortAudio('Close');
ShowCursor;
rethrow(exception);
end
              
                 
 
    
        
                                                                                                                                                
                                                                                                                                                       
                      
        
      
     
       
                 
              
                                      
         
  
  
 
   
    
   

      




   
  


 


 

 
   
        
      
     
     
 
   
   
 

    
       
    
       
    
      
                
          
  
   
   
   
 
