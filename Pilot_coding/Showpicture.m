function Showpicture(screen_name, pic_name)

    pic_load = imread(pic_name);
    pic_show = Screen('MakeTexture', screen_name, pic_load);
    Screen('DrawTexture',screen_name, pic_show);
    Screen('Flip',screen_name);
     
    KbStrokeWait;
   
end
