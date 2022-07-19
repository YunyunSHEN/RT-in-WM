P.Color.black = [0,0,0]; % add black
P.Color.white = [255,255,255];
P.Color.yellow = [255,255,0];
P.Color.red = [255,0,0];
P.Color.green = [0,255,0];
P.Color.grey = [128, 128, 128];

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

% DrawFormattedText(w,'Do you need more training? \n\n\n Yes: press Space \n\n\n No: Press RightArrow \n\n', 'center', 'center',P.Color.white);
% Screen('Flip', w);

DrawFormattedText(w,'Experiment will start \n\n\n Press Anykey \n\n', 'center', 'center',P.Color.white);
Screen('Flip', w);