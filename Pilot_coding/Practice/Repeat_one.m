function [one_trial] = Repeat_one(trialcounter,sequence,retention,index,P,w,Str_listen,Str_remember,Str_repro)
    
    one_trial = {1,13};
    one_trial{1,1} = sequence;
    one_trial{1,2} = retention;
    one_trial{1,3} = index;    
    n_items = 2;
    disp(['Trial ' num2str(trialcounter) ':   (' num2str(sequence) ')     ' num2str(retention)]);
    %% fixation point
    for z = 1:round(1/P.ifi) % round get the round number , 1 for showing time
        Screen('DrawDots', w, [P.xcenter, P.ycenter], 10, P.Color.black, [], 1);
        one_trial{1,4} = Screen('Flip',w); %trialstart
    end                
    %% listening
    DrawFormattedText(w,Str_listen, 'center', 'center',P.Color.red);
 
    tonestart = Screen('Flip',w);
    realtonestart = zeros(1,2);
    realtonestart(1) = PsychPortAudio('Start', P.paudio,1,tonestart,1);
    PsychPortAudio('Stop', P.paudio, 1);
    for i_item = 1:n_items
        tonestart = realtonestart(i_item) + sequence(i_item);   
        realtonestart(i_item+1) = PsychPortAudio('Start', P.paudio,1,tonestart,1);
        PsychPortAudio('Stop', P.paudio, 1);
    end
    one_trial{1,5} = realtonestart;%realtonestart
    Screen('fillRect',w, P.Background);
    Screen('Flip',w);
    WaitSecs(0.1);
    %% Retention interval
    DrawFormattedText(w,Str_remember, 'center', 'center',P.Color.yellow);
    encoding_over = Screen('Flip', w);
    one_trial{1,6} = encoding_over; %encoding_over  
    disp('************************************************************************');
        while GetSecs <  encoding_over + retention+0.1
        end       
    Screen('fillRect',w,P.Background);
    Screen('Flip',w);
    WaitSecs(0.1);
   
    %% Reproduce interval
    DrawFormattedText(w,Str_repro, 'center', 'center',P.Color.green);
    retention_over = Screen('Flip', w);% retention_over
    one_trial{1,7} =  retention_over;
    Produced_id = NaN(1+1,1);
    Produced = NaN(1,1);
    Error = NaN(1,1);            
    max_reptime =  sum(sequence) + P.maxreptime;
    % how many clicks do we expect?
    got_clicks = 0;
    %% wait for a certain time to get responses  
    while GetSecs - retention_over < max_reptime 
        [keyIsDown, seconds, keyCode] = KbCheck;
        if keyIsDown
            if  keyCode(P.Keys.right)
                break
            elseif keyCode(P.Keys.spa)
                got_clicks = got_clicks+1;
                % RT: from probe offset to klick record click time point
                Produced_id(got_clicks) = seconds;
            end
            KbReleaseWait; % needs to wait until the key is release
        end
    end       
    one_trial{1,10} = got_clicks;% got_clicks
    disp(got_clicks)
%% compute the reproduced durations for feedback
    if got_clicks  ~= 2 % wrong number of clicks
        % display error to participant
        DrawFormattedText(w,'Wrong clics', 'center', 'center',P.Color.white);
        one_trial{1,8}  = Screen('Flip', w); %timepoint show feedback
        WaitSecs(0.5);
        one_trial{1,11} = nan;
        one_trial{1,12}  = nan;
        one_trial{1,13}  = nan;   
    else % right number of clicks
            
        % recording produced dur
         
        Produced= Produced_id(2)- Produced_id(1);
        Error = Produced - sequence(index);
    
        Plot_feedback(w, P,  Error);
        one_trial{1,8}  = Screen('Flip', w); %timepoint show feedback   
        disp(Error);
        one_trial{1,11} = Produced_id;
        one_trial{1,12}  = Produced;
        one_trial{1,13}  =  Error;
    end
    
     %% go back to blank screen
    Screen('Flip', w);
    trialstop = GetSecs;
    one_trial{1,9} = trialstop; % trialstop
    disp('***************************************************************************');
    disp('***************************************************************************');
    
end 
     