function ok = putvartofile( fname, var, top )% PUTVARTOFILE  Serialize a variable to a file%% ok = putvartofile( fname, var, top )% 05-Jun-04 -- created;  adapted from addstringtofile.m (RFM)% set default argumentsdefarg('top',1);% serialize variablevarstr=serialize(var,inputname(2));% create new fileif ~exist(fname,'file'),	fnew=fopen(fname,'w');	fprintf(fnew,'%s\n',varstr);	fclose(fnew);	returnend% open filestmpname=[ fname '.tmp' ];fnew=fopen(tmpname,'w');fold=fopen(fname,'r');% add string to topif top,	fprintf(fnew,'%s\n',varstr);end% copy filewhile ~feof(fold),	str=fgetl(fold);	fprintf(fnew,'%s\n',str);end% add string to bottomif ~top,	fprintf(fnew,'%s\n',varstr);end% close files and replace old with newfclose(fold);fclose(fnew);movefile(tmpname,fname);return