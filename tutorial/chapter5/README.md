# Chapter 5. Python Binding


## 이 챕터의 목표
   * Python 상에서 XRootD 사용방법을 익힙니다.

## 실습 개요
   * Python Binding 기능을 통해 XRootD 서버에 파일을 넣거나 뺄 수 있습니다.
   * 파일을 읽어서 데이터를 처리해볼 수 있습니다.
## 사전 지식
   * 주피터 등과 같은 웹 상에서 분석 프로그램을 사용하는 경우가 증가하고 있습니다.
   * 주피터는 웹에서 Python 쉘을 사용하기 때문에 XRootD 명령어를 사용하기 위해 Python Binding을 써야 합니다.

## 실습 준비
   * 이 실습은 구성된 XRootD를 통해 각 유저분들이 직접 데이터를 사용해보는 실습입니다. 
   * Chapter1 상태를 기본으로 합니다.
   * 기존 설정으로 복원 후 사용하시기 바랍니다.
   * 다음 명령어로 xrootd-python bind 패키지를 설치합니다.
```bash
sudo yum install -y xrootd-python
```
   * Python Bind는 xrootd proxy 서버를 대상으로 하기 때문에 아래 설정으로 group-mn 서버에서 xrootd-proxy.cfg 파일을 생성하고 서비스를 올려줍니다.
```bash
all.export /data
set xrdr=group0X-mn
xrd.port 1096
pss.origin = group0X-mn:1094
ofs.osslib libXrdPss.so
```
   * 1096/tcp 포트를 오픈해줍니다.
```bash
sudo firewall-cmd --permanent --add-port=1096/tcp
sudo firewall-cmd --reload
```
   * 테스트를 위한 텍스트 파일을 다운로드 받습니다. 명령어 자체는 아래와 같습니다.
```bash
wget http://www.gutenberg.org/cache/epub/31547/pg31547.txt
wget http://www.gutenberg.org/cache/epub/41481/pg41481.txt
wget http://www.gutenberg.org/cache/epub/28617/pg28617.txt
wget http://www.gutenberg.org/cache/epub/29607/pg29607.txt
```

## 실습 따라하기 
   * [파일시스템 따라하기](http://xrootd.org/doc/python/xrootd-python-0.1.0/examples/filesystem.html)
      * 아래 내용으로 bind_test.py 이름으로 저장한 후 실행권한을 줍니다. ( chmod +x bind_test.py )
```bash
#!/usr/bin/env python
#-*- coding:utf-8 -*-
from XRootD import client
from XRootD.client.flags import DirListFlags, OpenFlags, MkDirFlags, QueryCode

import glob

## group0X-mn xrootd proxy서버에 접속합니다.
myclient = client.FileSystem('root://group0X-mn:1096')

## /data 디렉토리 내용을 확인합니다.
status, listing = myclient.dirlist('/data', DirListFlags.STAT)

print listing.parent
for entry in listing:
  print "{0} {1:>10} {2}".format(entry.statinfo.modtimestr, entry.statinfo.size, entry.name)

## /data/novel 디렉토리를 만듭니다.
myclient.mkdir("/data/novel", MkDirFlags.MAKEPATH)


## 파일 이름을 패턴으로 검색합니다.
filelist = glob.glob("*.txt")
print filelist

## 파일들을 복사합니다.
process = client.CopyProcess()
for novel in filelist:
        infile = '/home/gsdc/%s'%(novel)
        ofile = 'root://group0X-mn:1096//data/novel/%s'%(novel)
        process.add_job( infile, ofile )
process.prepare()
process.run()
```
2. [파일 따라하기](http://xrootd.org/doc/python/xrootd-python-0.1.0/examples/file.html)
   * 위 내용을 참고하여 [파일 따라하기]를 진행해보시기 바랍니다.
```bash
from XRootD import client
from XRootD.client.flags import OpenFlags

with client.File() as f:
  f.open('root://group09-mn:1096//data/novel/pg31547.txt', OpenFlags.READ)
    for line in f:
    print '%r' % line
```

## 토의
  
   
## 주의사항
   * utf-8 인코딩 설정을 하지 않으면 한글 주석을 사용하실 수 없습니다.
   * add_job 함수 내에서는 string을 통한 이름 지정이 되지 않습니다. 위 2줄을 참고 바랍니다.
   * 혹시 아래 에러가 발생한다면 서버 이름을 확인해주세요.
```
[gsdc@group09-wn03 ~]$ ./bind_test.py 
Traceback (most recent call last):
  File "./bind_test.py", line 14, in <module>
    print listing.parent
AttributeError: 'NoneType' object has no attribute 'parent'
```
