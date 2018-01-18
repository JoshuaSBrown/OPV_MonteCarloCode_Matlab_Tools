function make_video2(video_dirs,extension,aviname,fps,NameImagFilesCore)
      resnames=dir(fullfile(video_dirs,['*.' extension]));
      aviobj=VideoWriter(aviname);
      aviobj.FrameRate=fps;
      open(aviobj);
      
      %[FileName, ~]=strsplit(resnames.name,'Frame');
      FileName = NameImagFilesCore;%strcat(FileName{1},'Frame');
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