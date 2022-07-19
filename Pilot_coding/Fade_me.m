function fx = Fade_me(fx, Fs, fadein, fadeout ) 


    % calculate a lot
	fadein = 1:round(fadein*Fs/1000);
	fadein = fadein/max(fadein);
	fadeout = 1:round(fadeout*Fs/1000);
	fadeout = fadeout/max(fadeout);
	fadeout = fliplr(fadeout);
	env = [fadein ones(1, length(fx)-(length(fadein)+length(fadeout))) fadeout];
	
	% multiply the fade-envelop on the flipped wavmatrix
	
if size(fx,1) > size(fx,2)
    fx = (fx').*env;
elseif size(fx,1) < size(fx,2)
    fx = (fx).*env;
end
 