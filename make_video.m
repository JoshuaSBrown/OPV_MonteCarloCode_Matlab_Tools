function make_video(video_dirs,extension,aviname,fps)
      resnames=dir(fullfile(video_dirs,['*.' extension]));
      aviobj=VideoWriter(aviname);
      aviobj.FrameRate=fps;
      open(aviobj);
      
      [FileName, ~]=strsplit(resnames(1).name,'Frame');
      FileName = strcat(FileName{1},'Frame');
      for i=1:length(resnames)
          img=imread(fullfile(video_dirs,strcat(FileName,num2str(i),'.jpg')));
          F=im2frame(img);
          if sum(F.cdata(:))==0
              error('black');
          end
          writeVideo(aviobj,F);
      end
      close(aviobj);
end