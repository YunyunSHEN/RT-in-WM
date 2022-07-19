KbName('UnifyKeyNames');
[~,~,keyinfo]= GetKeyboardIndices();
[r,c] = size(keyinfo);
for keydevice = 1:c
    if ismember({'Dell Dell USB Keyboard'},keyinfo{keydevice}.product)
        index = keyinfo{keydevice}.index;
    end   
 end

P.Keys.esc = KbName('escape');
P.Keys.enter = KbName('return');
P.Keys.spa = KbName('space');
P.Keys.left = KbName('LeftArrow');
P.Keys.right = KbName('RightArrow');
 
keyOfInterest = zeros(1,256);
keyOfInterest(KbName({'space','RightArrow'})) = 1;   
PsychHID('KbQueueCreate',index,keyOfInterest);    
PsychHID('KbQueueStart',index);    
got_clicks = 0;
t0 = GetSecs; 
exp_term = 0;
while GetSecs - t0 <= 10   
    [keyIsDown, firstPress] = PsychHID('KbQueueCheck',index);
    if keyIsDown     
       pressedKey = find(firstPress);    
       pressed_timestemp = firstPress(pressedKey);
       if pressedKey == P.Keys.right
           break
       elseif pressedKey == P.Keys.spa
           disp(3)   
           got_clicks = got_clicks+1;
            % RT: from probe offset to klick record click time point
           disp(pressed_timestemp)
           time_stemp(got_clicks) = pressed_timestemp;  
       end           
    end 
end
disp(time_stemp)   
PsychHID('KbQueueStop',index);  
PsychHID('KbQueueRelease', index);     
                            
           
% sca;       
% clear;
% 
% P.tonedur = .050;
% P.tonefade = 10;
% P.tonefreq = 1000;
% P.nrchannels = 2;
% P.audiofreq = 44100;
% 
% normalscreen = 0;
% clear PsychPortAudio;
% clear PsychHID;
% 
% % audiodevices = PsychPortAudio('GetDevices');
% % audiodevicenames = {audiodevices.DeviceName};
% % [logicalaudio, locationaudio] = ismember({'HDA Intel PCH: ALC3204 Analog (hw:0,0)'}, audiodevicenames);
% % audiodeviceindex = audiodevices(locationaudio(logicalaudio)).DeviceIndex;
% 
% tone = MakeBeep(P.tonefreq, P.tonedur, P.audiofreq);
% tone = Fade_me(tone,P.audiofreq,P.tonefade,P.tonefade);
% tone(2,:) = tone(1, :); % for left and right, two channels
% InitializePsychSound(1);
% 
% 
% PsychPortAudio('Verbosity',5);%Set level of verbosity for error/warning/status messages.
% 
% %pahandle = PsychPortAudio(‘Open’ [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0])
% % paudio = PsychPortAudio('Open',[],1+8,4,P.audiofreq, P.nrchannels, [],[]);
% paudio = PsychPortAudio('Open', [], [], 0, P.audiofreq, P.nrchannels);
% playtime = GetSecs;
% % PsychPortAudio('Start', paudio,0,0,1);
% PsychPortAudio('Volume', paudio); %PsychPortAudio(;Volume’, pahandle [, masterVolume][, channelVolumes])
% 
% P.pa_tones = PsychPortAudio('OpenSlave', paudio, 1);
% 
% PsychPortAudio('FillBuffer',P.pa_tones, tone);
% 
% tonestart = GetSecs;
% realtonestart(1) = PsychPortAudio('Start', P.pa_tones,1,tonestart,1);
% PsychPortAudio('Stop', P.pa_tones, 1);
% PsychPortAudio('Close');