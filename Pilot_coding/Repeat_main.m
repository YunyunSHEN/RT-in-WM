function [one_trial] = Repeat_main(trialcounter,retro,cue,sequence,retention,P,w,Str_listen,Str_remember,Str_repro)
 
    one_trial.trial = trialcounter;
    one_trial.sequence = sequence;
    one_trial.retention = retention;
    one_trial.attention = retro;
    one_trial.cue = cue;
    n_items = length(sequence);
    one_trial.n_items = n_items;      
    disp(['Trial ' num2str(trialcounter) ':   (' num2str(sequence) ')    ' num2str(retention) '    '  num2str(cue)]);
    %% fixation point

    DrawFormattedText(w,'+','center','center',P.Color.white);
    one_trial.trialstart = Screen('Flip',w);
    WaitSecs(0.4);

    y = -1*0.23+2*0.65*rand(5,5);
    x = randi(25);
    WaitSecs(y(x));

    Screen('fillRect',w, P.Background);
    Screen('Flip',w);
    WaitSecs(0.3);
%         for z = 1:round(1/P.ifi) % round get the round number , 1 for showing time
%             Screen('DrawDots', w, [P.xcenter, P.ycenter], 10, P.Color.black, [], 1);
%             one_trial.trialstart = Screen('Flip',w); %trialstart
%         end 
    %% Attention cue
    if retro == 0
        %% Show index to produce
        if cue == 0
            DrawFormattedText(w,'TOUT', 'center', 'center',P.Color.black);
            Screen('Flip', w);
            WaitSecs(0.5);
%             Screen('DrawText',w,'All',P.xcenter,P.ycenter,P.Color.black);
%             on_set = Screen('Flip', w);
%             Screen('Flip', w,on_set+0.3-P.slack);
        elseif cue == 1
            i_reproduce = cue;
            DrawFormattedText(w,num2str(i_reproduce), 'center', 'center',P.Color.black);
            Screen('Flip', w);
            WaitSecs(0.5);
%             Screen('DrawText',w,num2str(i_reproduce),P.xcenter,P.ycenter,P.Color.black);
%             on_set = Screen('Flip', w);
%             Screen('Flip', w,on_set+0.3-P.slack);
        elseif cue == 2
             i_reproduce = cue;
            DrawFormattedText(w,num2str(i_reproduce), 'center', 'center',P.Color.black);
            Screen('Flip', w);
            WaitSecs(0.5);
%             Screen('DrawText',w,num2str(i_reproduce),P.xcenter,P.ycenter,P.Color.black);
%             on_set = Screen('Flip', w);
%             Screen('Flip', w,on_set+0.3-P.slack);
        end
    end
    %% listening
    DrawFormattedText(w,Str_listen, 'center', 'center',P.Color.red);
%     Screen('DrawText',w,Str_listen,P.xcenter,P.ycenter,P.Color.red);
    tonestart = Screen('Flip',w);
    realtonestart = zeros(1,n_items+1);
    realtonestart(1) = PsychPortAudio('Start', P.paudio,1,tonestart,1);
    PsychPortAudio('Stop', P.paudio, 1);
    for i_item = 1:n_items
        tonestart = realtonestart(i_item) + sequence(i_item);   
        realtonestart(i_item+1) = PsychPortAudio('Start', P.paudio,1,tonestart,1);
        PsychPortAudio('Stop', P.paudio, 1);
    end
    one_trial.realtonestart = realtonestart;%realtonestart
    Screen('fillRect',w, P.Background);
    Screen('Flip',w);
    WaitSecs(0.1);
    %% Retention interval
%     for z = 1:round(retention-0.2/P.ifi)% round get the round number , 1 for showing time
%         disp(z)
%         DrawFormattedText(w,Str_remember, 'center', 'center',P.Color.yellow);
%         one_trial.encoding_over = Screen('Flip', w);
%     end 
%     one_trial.encoding_over

    DrawFormattedText(w,Str_remember, 'center', 'center',P.Color.yellow);
%     Screen('DrawText',w,Str_remember,P.xcenter,P.ycenter,P.Color.yellow);
    encoding_over = Screen('Flip', w);
    WaitSecs(retention);
    one_trial.encoding_over = encoding_over; %encoding_over  
    Screen('fillRect',w,P.Background);
%     Screen('Flip',w,encoding_over + retention - P.slack);
    Screen('Flip',w);
    WaitSecs(0.1);
    %% Retro cue
    if retro == 1
        %% Show index to produce any interval
        if cue == 0
            DrawFormattedText(w,'TOUT', 'center', 'center',P.Color.black);
            Screen('Flip', w);
            WaitSecs(0.5);
%             Screen('DrawText',w,'All',P.xcenter,P.ycenter,P.Color.black);
%             on_set = Screen('Flip', w);
%             Screen('Flip', w,on_set+0.3-P.slack);
        elseif cue == 1
            i_reproduce = cue;
            DrawFormattedText(w,num2str(i_reproduce), 'center', 'center',P.Color.black);
            Screen('Flip', w);
            WaitSecs(0.5);
%             Screen('DrawText',w,num2str(i_reproduce),P.xcenter,P.ycenter,P.Color.black);
%             on_set = Screen('Flip', w);
%             Screen('Flip', w,on_set+0.3-P.slack);
        elseif cue == 2
             i_reproduce = cue;
            DrawFormattedText(w,num2str(i_reproduce), 'center', 'center',P.Color.black);
            Screen('Flip', w);
            WaitSecs(0.5);
%             Screen('DrawText',w,num2str(i_reproduce),P.xcenter,P.ycenter,P.Color.black);
%             on_set = Screen('Flip', w);
%             Screen('Flip', w,on_set+0.3-P.slack);
        end
    end
%% Reproduce interval
    DrawFormattedText(w,Str_repro, 'center', 'center',P.Color.green);
%     Screen('DrawText',w,Str_repro,P.xcenter,P.ycenter,P.Color.green);
    retention_over = Screen('Flip', w);% retention_over
    one_trial.retention_over =  retention_over;
%     if cue ~= 0
%         one_trial.Produced_id = NaN(2,1);
%     elseif cue == 0 
%         one_trial.Produced_id = NaN(n_items+1,1);
%         one_trial.Produced = NaN(n_items,1);
%         one_trial.Error = NaN(n_items,1); 
%     end 
one_trial.Produced_id = NaN(n_items+1,1);
one_trial.Produced = NaN(n_items,1);
one_trial.Error = NaN(n_items,1); 

    max_reptime =  sum(sequence) + P.maxreptime;
    % how many clicks do we expect?
    got_clicks = 0;
    %% wait for a certain time to get responses  
    keyOfInterest = zeros(1,256);
    keyOfInterest(KbName({'LeftArrow','escape','RightArrow'})) = 1;
    PsychHID('KbQueueCreate',P.i_keyboard,keyOfInterest);
    PsychHID('KbQueueStart',P.i_keyboard);  

    while GetSecs - retention_over < max_reptime   
        [keyIsDown, firstPress] = PsychHID('KbQueueCheck',P.i_keyboard);
        if keyIsDown  
           pressedKey = find(firstPress);    
           pressed_timestemp = firstPress(pressedKey);
           if pressedKey == P.Keys.esc               
               return
           elseif pressedKey == P.Keys.right      
               break
           elseif pressedKey == P.Keys.left
               got_clicks = got_clicks+1;
                % RT: from probe offset to klick record click time point
               one_trial.Produced_id(got_clicks) = pressed_timestemp;  
           end           
        end 
    end

    PsychHID('KbQueueStop',P.i_keyboard); 
    PsychHID('KbQueueRelease',P.i_keyboard); 
    one_trial.got_clicks = got_clicks;% got_clicks

%% compute the reproduced durations for feedback
    if cue ~= 0
        check_number = 1;
    elseif cue == 0
        check_number = n_items;
    end
    if got_clicks  - check_number ~= 1 % wrong number of clicks
        % display error to participant
        DrawFormattedText(w,'Clics incorrects', 'center', 'center',P.Color.white);
%         Screen('DrawText',w,'Wrong clics',P.xcenter,P.ycenter,P.Color.white);
        one_trial.feedback  = Screen('Flip', w); %timepoint show feedback
        one_trial.Produced(1) = 0;
        one_trial.Error(1) = 0;
        WaitSecs(0.5);
    else % right number of clicks
        if check_number == n_items
            for i_item = 1:check_number  %compute the produced dur
                one_trial.Produced(i_item) = one_trial.Produced_id(i_item+1)- one_trial.Produced_id(i_item);
                one_trial.Error(i_item) = one_trial.Produced(i_item) - one_trial.sequence(i_item);
            end
        elseif check_number == 1
            one_trial.Produced(cue) = one_trial.Produced_id(2)- one_trial.Produced_id(1);
            one_trial.Error(cue) = one_trial.Produced(cue) - one_trial.sequence(cue);
        end
        Plot_feedback(w, P,  one_trial.Error);
        one_trial.feedback  = Screen('Flip', w); %timepoint show feedback   
    end
     %% go back to fixation; point
    % fixation the onset of the fixation crosss defines the start of trial 
    Screen('Flip', w);
    trialstop = GetSecs;
    one_trial.trailstop = trialstop; % trialstop
    disp('***************************************************************************');
 
end 
