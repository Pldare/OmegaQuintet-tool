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
	return $cl3_file.read(4).unpack("V").to_s.gsub("[","").gsub("]","").to_i
end
def go_wz(_wz)
	$cl3_file.seek(_wz)
end
def write_file(_file_name,_wz,_size)
	_tmp_file=File.open(_file_name,"wb")
	go_wz(_wz)
	_tmp_data=$cl3_file.read(_size)
	_tmp_file.print _tmp_data
	_tmp_file.close
	puts "save #{_file_name}"
end
$cl3_file=File.open(ARGV[0],"rb")
str_magic("CL3L")
go_wz(56)
str_magic("FILE_COLLECTION")
go_wz(88)
file_es,dunny,start_wz=read_int32,read_int32,read_int32
wz_local=start_wz

for i in 0..(file_es-1)
	go_wz(wz_local)
	file_name=readstr
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
		tmp_file_name=file_name.split(".")
		tmp_file_name[((tmp_file_name.size.to_i)-1)]="dds"
		file_name=tmp_file_name.join(".")
	end
	
	write_file(file_name,offsett,file_size)
	wz_local+=48
end
$cl3_file.close
