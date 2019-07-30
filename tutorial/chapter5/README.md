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
   
## 실습 따라하기 
   * [파일시스템 따라하기](http://xrootd.org/doc/python/xrootd-python-0.1.0/examples/filesystem.html)
```bash
from XRootD import client
from XRootD.client.flags import DirListFlags, OpenFlags, MkDirFlags, QueryCode

myclient = client.FileSystem('root://group09-mn:1094')
```
2. [파일 따라하기](http://xrootd.org/doc/python/xrootd-python-0.1.0/examples/file.html)



## 토의
  
   
## 주의사항
 
