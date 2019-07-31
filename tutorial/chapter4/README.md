# Chapter 4. 접근이 안되는 XRootD 서버를 사용한 스토리지 


## 이 챕터의 목표
   * XRootD 클라이언트가 XRootD 리다이렉트와만 통신이 가능하고 서버들과는 통신이 불가능할 때 데이터를 접근하는 방법을 배웁니다.

## 실습 개요
이번 실습을 통해 다음 조건을 만족하는 4개의 서버를 이용하여 XRootD 스토리지를 구축하는 방법을 익힙니다. 
   * 클라이언트(사용자)는 리다이렉트 서버에만 접근이 가능합니다. 디스크 서버들에 직접 접근이 불가능합니다.       
   * 클라이언트(사용자)는 리다이렉트 서버의 호스트 이름만 알고 있습니다.
   * 디스크 노드들은 데이터를 저장하기 위해 1개의 디스크를 가지고 있습니다.

**이번 Tutorial부터 모든 부분에 대해서 설명하지 않습니다. 반복적인 부분에 대해서 궁금하시면 이전 Tutorial 내용을 참고하시기 바랍니다.**

## 서버 설명
각 서버들은 다음과 같은 역할로 설정될 것입니다.
   *  group0X-mn : MN 서버는 XRootD의 Redirector로 활용합니다. 외부 클라이언트를 위해서는 Standalone XRootD Server로 대응합니다.
   *  group0X-wn01,02 : XRootD의 Server로 활용합니다.
   *  group0X-wn03 : XRootD 클라이언트로 활용합니다.
![tutorial4](https://user-images.githubusercontent.com/4969463/62031449-5ec34b00-b222-11e9-8e70-ea07fbaf8418.png)

## 사전 지식

## 실습 준비
   * 외부 XRootD 클라이언트 역할을 수행하는 wn03은 wn01,wn02 로부터 직접 접근이 불가능해야 합니다. 
   * 가상으로 방화벽을 이용해 wn03의 접속을 막을 수 있습니다.
#### group0X-wn0{1,2}
```bash
### IP 10.0.20.13로부터 1094/tcp, 3122/tcp 차단
### 해제는 add-rich-rule 대신 remove-rich-rule을 넣으면 됩니다.
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.0.20.13/32" port port="1094" protocol="tcp" reject'
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.0.20.13/32" port port="3121" protocol="tcp" reject'
sudo firewall-cmd --reload
````

#### 체크 방법 : group0X-wn03에서 다음 명령어로 차단 여부 확인 
```bash
sudo yum install -y nmap
sudo nmap -PN 10.0.??.?? -p 1094
## 정상 연결 ##
Starting Nmap 6.40 ( http://nmap.org ) at 2019-07-29 04:36 PDT
Nmap scan report for group0X-wn0Y.gZ.gsdc.org (10.0.??.??)
Host is up (0.0018s latency).
PORT     STATE SERVICE
1094/tcp open  rootd
## 방화벽 설정 ##
Starting Nmap 6.40 ( http://nmap.org ) at 2019-07-29 04:37 PDT
Nmap scan report for group09-wn0Y.gZ.gsdc.org (10.0.??.??)
Host is up (0.0015s latency).
PORT     STATE    SERVICE
1094/tcp filtered unknown
## 서비스가 꺼져있을 때 ##
Starting Nmap 6.40 ( http://nmap.org ) at 2019-07-29 04:37 PDT
Nmap scan report for group09-wn0Y.gZ.gsdc.org (10.0.??.??)
Host is up (0.0015s latency).
PORT     STATE    SERVICE
1094/tcp closed unknown
```
## 추가 정보
   * 자세한xrootd 메뉴얼은 xrootd.org 홈페이지 docs 탭에서 확인이 가능합니다.
   * 이번 예제는 [xrd 메뉴얼](http://xrootd.org/doc/dev50/xrd_config.pdf)을 참고하시면 더욱 자세한 내용을 확인하실 수 있습니다.

## 주요 설정 파일 내용
### group0X-mn 
#### (1) 내부 네트워크용 설정파일
```bash
### 아래 IP 주소는 꼭 확인을 해주시기 바랍니다.

all.export /data
set xrdr=10.0.20.10 
xrd.port 1094
all.manager $(xrdr):3121
all.role manager
### nodnr, norpipa: DNS 이름 풀이를 하지 않습니다. MN 혹은 WN들이 DNS에 등록되어 있지 않다면 반드시 nodnr,norpipa를 지정해야 합니다.
### routes split use eth0: 공인IP와 사설IP를 동시에 쓸 경우 어느 네트워크 장치를 통해 XRootD 서비스를 실행할지를 선택해야 합니다.
### 자세한 설명은 XRootD 설명을 보십시오. 
xrd.network nodnr norpipa routes split use eth0 
```
#### (2) 외부 접속용 설정파일 : 앞 챕터의 wn03(standalone 설정과 같습니다.)
```bash
### 주석들 제외하면 아래와 같음. all.role을 지정하지 않으면 server로 설정됨.
all.export / readonly
oss.localroot /xrootdfs
xrd.port 1095  
```
   * 단, standalone 경로는 경로명이 달라지기 때문에 부득이하게 /xrootdfs 를 localroot로 지정합니다.

### group0X-wn0{1,2}
```bash
all.export /data 
set xrdr=10.0.20.10
all.manager $(xrdr) 3121
all.role server
cms.space min 200m 500m
### nodnr, norpipa: DNS 이름 풀이를 하지 않습니다. MN 혹은 WN들이 DNS에 등록되어 있지 않다면 반드시 nodnr,norpipa를 지정해야 합니다.
### routes split use eth0: 공인IP와 사설IP를 동시에 쓸 경우 어느 네트워크 장치를 통해 XRootD 서비스를 실행할지를 선택해야 합니다.
### 자세한 설명은 XRootD 설명을 보십시오. 
xrd.network nodnr norpipa routes split use eth0 
```
### group0X-wn03 : 클라이언트는 설정 내용이 없습니다.

## 실습 

### group0X-mn
1. 기존 마운트된 디렉토리들(/xrootdfs)과 서비스들(xrootd, cmsd) 종료합니다. 
1. xrootd-myconf.cfg 파일을 xrootd-chap4.cfg로 복사한 후 내용을 위 설정을 참고하여 수정합니다.
1. xrootd-standalone.cfg 파일을 참고하여 xrootd-pubic.cfg로 복사한 후 위 내용을 참고하여 수정합니다.
1. 먼저 chap4 서비스가 정상적으로 시작되는지 확인한 후 /xrootdfs 디렉토리에 xrootdfs 를 이용하여 fuse로 마운트합니다.
1. public 서비스를 위한 포트 1095/tcp 를 허용해줍니다.
1. public 서비스를 시작합니다. public은 xrootd 서비스만 올리면 됩니다.
1. group0X-wn03에서 접속 후 파일 확인이 가능한지 xrdfs, xrootdfs 명령어로 확인합니다.

### group0X-wn03 
1. 기존 마운트된 디렉토리들과 서비스들을 종료합니다.
1. mn과 wn01,02 서버들이 설정이 완료된 후 테스트를 진행합니다.
1. 1094포트를 사용하여 접근을 시도합니다. ( xrdfs group09-mn:1094 ls /data)
1. 1095포트를 사용하여 접근을 시도합니다. ( xrdfs group09-mn:1095 ls / )


### gropu0X-wn0{1,2}
1. 기존 xrootdfs가 마운트되어 있다면 모두 해제합니다.
1. 위 제공된 방화벽 설정을 적용합니다.
1. xrootd-myconf.cfg 파일을 xrootd-chap4wn.cfg로 복사한 후 내용을 위 설정을 참고하여 수정합니다.
1. 서비스들을 올립니다.
1. 개별 사이트 내에서 접근이 잘되는지 체크합니다.


## 실습 Self Check
### xrdfs 테스트
   * wn03에서 mn을 통해 xrdfs가 작동하면 성공적으로 서비스를 실행한 것입니다.
      * wn03은 기본적으로 wn01, 02와 통신을 할 수 없으므로 파일 내용 확인 및 파일 복사를 할 수 없습니다.
      * 지금처럼 xrootdfs를 통해 간접적으로 통신을 수행하면 파일을 가져올 수 있습니다.


## 토의
   * 공인IP와 사설IP 등 2개 이상의 네트워크를 이용한 스토리지 시스템의 필요성은 무엇일까요?
   * DNS 서비스 없이 스토리지 시스템을 사용할 경우는 어떠한 경우일까요?
   
   
## 주의사항
   * xrootd, cmsd 서비스가 재시작된 후 접속이 가능해질 때까지는 꽤 긴 시간이 필요합니다.
      * MN 서버 담당자가 log 파일을 잘 살펴보면 언제쯤 서비스가 시작되는지를 대략적으로 알 수 있습니다.
   * xrootdfs 마운트도 한번에 되지 않을 수가 있습니다. 
      * umount -f 로 마운트를 몇번 해제하다보면 정상적으로 작동합니다.
      
------------
## 실습 따라하기 : Chapter3부터는 제공되지 않습니다.
