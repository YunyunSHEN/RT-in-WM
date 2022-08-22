function Plot_feedback(w, P, feedback)
% I.A. Mangione, T.W. Kononowicz

screenXpixels = P.ScreenWidth;
screenYpixels = P.ScreenHeight;
x_step = screenXpixels/50;
y_step = screenYpixels/10;
lwidth = P.xcenter-x_step*1;
rwidth = P.xcenter+x_step*1;

estimation_relative = feedback(~isnan(feedback)); % and signed
numb_rect = length(estimation_relative);

% when very good perf, make a green bar and display BRAVO!
if sum(abs(estimation_relative) < 0.1)/numb_rect == 1
    DrawFormattedText(w, 'BRAVO!!', 'center', 'center', P.Color.black);
%     Screen('FillRect', w, P.Color.green, [P.xcenter-x_step*6, P.ycenter-y_step*4,P.xcenter+x_step*6, P.ycenter+y_step*4]);
    Screen('Flip', w);
    
else
    % set rectangles X coordinates
    xl_rect = NaN(1,7);
    xy_rect = NaN(1,7);
    
    if numb_rect == 1
        xl_rect = [lwidth nan nan nan nan nan nan];
        xy_rect = [rwidth nan nan nan nan nan nan];
    elseif numb_rect == 2
        xl_rect=[lwidth-x_step*2 lwidth+x_step*2 nan nan nan nan nan];
        xy_rect=[rwidth-x_step*2 rwidth+x_step*2 nan nan nan nan nan];
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
            allColors(:,k) = P.Color.black;
        elseif abs(estimation_relative(k)) > 0.9
            allColors(:,k) = P.Color.black;
        else
            allColors(:,k) = P.Color.black;
        end        
        Screen('FillRect', w, allColors, allRects);
        Screen('FillRect', w, P.Color.black, [P.xcenter-x_step*10, P.ycenter-1,P.xcenter+x_step*10, P.ycenter+1]);
        Screen('Flip', w);
    end
end
WaitSecs(1);