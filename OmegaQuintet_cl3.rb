require 'find'
require 'pathname'
lujin=Pathname.new(File.dirname(__FILE__)).realpath 
file_name=[0]
all_files=0
Find.find(lujin) do |path|
  #puts path
  #if File::directory?(path)
  tmp_nn=path.split("/")
  org_name=tmp_nn[((tmp_nn.size.to_i)-1)].to_s
  if /.cl3$/ =~ org_name
	file_name[all_files]=org_name
	all_files+=1
  end
end

def str_magic(_str)
	re_size=_str.to_s.size.to_i
	r_wz=$cl3_file.read(re_size).to_s
	if r_wz == _str
		puts "#{_str} √"
	else
		throw "wrong file"
	end
end
def readstr
	_tmp_o=[0,0]
	_tmp_save_pos=$cl3_file.pos.to_i
	for _g in 0..99
		_tmp_o[_g]=$cl3_file.read(1).to_s
		if _tmp_o[_g] == "\x00"
			break
		end
	end
	_tmp_o=_tmp_o.join("")
	$cl3_file.seek(_tmp_save_pos)
	return _tmp_o.chomp("\x00")
end
def read_int32
	return $cl3_file.read(4).unpack($endinn).to_s.gsub("[","").gsub("]","").to_i
end
def go_wz(_wz)
	$cl3_file.seek(_wz)
end
def write_file(_floder,_file_name,_wz,_size)
	#creat floder
	mk_floder="md "+_floder.to_s
	if File::directory?(_floder)
	else
		system mk_floder
	end
	
	_tmp_file=File.open(((_floder.to_s)+"\\"+(_file_name.to_s)),"wb+")
	go_wz(_wz)
	_tmp_data=$cl3_file.read(_size)
	_tmp_file.print _tmp_data
	_tmp_file.close
	puts "save #{_file_name}"
end

for ii in 0..(all_files-1) 
	puts "open #{file_name[ii]}"
	$cl3_file=File.open(file_name[ii],"rb")
	floder_name=file_name[ii].to_s.split(".")[0]
	str_magic("CL3")
	type=$cl3_file.read(1).to_s
	if type == "L"
		$endinn="V"
	elsif type == "B"
		$endinn="N"
	end
	go_wz(16)
	wz=read_int32
	go_wz(wz)
	str_magic("FILE_COLLECTION")
	go_wz(wz+32)
	file_es,dunny,start_wz=read_int32,read_int32,read_int32
	wz_local=start_wz

	for i in 0..(file_es-1)
		go_wz(wz_local)
		n_file_name=readstr
		wz_local+=512
		go_wz(wz_local)
		index=read_int32
		file_local_wz=read_int32
		file_size=read_int32
		offsett=start_wz+file_local_wz
		
		#file-head
		go_wz(offsett)
		litte_head=$cl3_file.read(3).to_s
		if litte_head == "DDS"
			tmp_file_name=n_file_name.split(".")
			tmp_file_name[((tmp_file_name.size.to_i)-1)]="dds"
			n_file_name=tmp_file_name.join(".")
		end
		
		write_file(floder_name,n_file_name,offsett,file_size)
		wz_local+=48
	end
	$cl3_file.close
end
