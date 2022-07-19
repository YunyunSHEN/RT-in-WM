function[] = Rest(w,P,breakDuration)
 
    breakFrames = round(1/P.ifi*breakDuration);
      
    for k = 1:breakFrames 
        dispTime = breakDuration-round(k/60); %% convert frame rate to sec and display descending order
        DrawFormattedText(w,'Faites une pause \n\n\n', 'center', 'center',P.Color.white);
%         Screen('DrawText',w,'Having a rest',P.xcenter,P.ycenter,P.Color.white);
        Screen('DrawText',w,double([int2str(dispTime)]),P.xcenter,P.ycenter+100,P.Color.white);
        Screen('Flip', w);
    end

    DrawFormattedText(w,'Continuez \n\n\n Appuyez sur la flèche droite \n\n', 'center', 'center',P.Color.white);
    Screen('Flip', w);
    KbStrokeWait;
    
end
