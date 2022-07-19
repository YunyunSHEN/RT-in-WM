[~,~,keyinfo]= GetKeyboardIndices();
[~,c] = size(keyinfo);
for keydevice = 1:c
 %     if ismember({'Dell Dell USB Keyboard'},keyinfo{keydevice}.product)
    if ismember({'AT Translated Set 2 keyboard'},keyinfo{keydevice}.product)
        keyinfo{keydevice}.product
        i_keyboard = keyinfo{keydevice}.index;
    end  
end 
P.i_keyboard = i_keyboard; 
keyOfInterest = zeros(1,256); 
retention_over = GetSecs;
keyOfInterest(KbName({'space','escape','RightArrow'})) = 1;
PsychHID('KbQueueCreate',P.i_keyboard,keyOfInterest);
PsychHID('KbQueueStart',P.i_keyboard);    
got_clicks = 0;  
while GetSecs - retention_over < 2 
    [keyIsDown, firstPress] = PsychHID('KbQueueCheck',P.i_keyboard);
    disp(3)
    if keyIsDown  
       disp(4)
       pressedKey = find(firstPress);    
       pressed_timestemp = firstPress(pressedKey);
       if pressedKey == P.Keys.esc               
           return
       elseif pressedKey == P.Keys.right      
           break
       elseif pressedKey == P.Keys.spa
           got_clicks = got_clicks+1;
            % RT: from probe offset to klick record click time point
    
       end           
    end 
end
PsychHID('KbQueueStop',P.i_keyboard); 
PsychHID('KbQueueRelease',P.i_keyboard); 
 
disp(got_clicks)