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
   * Chapter1 상태를 기본으로 합니다만, mn을 통해 wn01, wn02가 통신이 가능하다면 어떠한 환경이라도 상관 없습니다.
   
## 주요 설정 파일 내용
   * group0X-mn 
   * (1) 내부 네트워크용 설정파일
```bash
### 아래 IP 주소는 꼭 확인을 해주시기 바랍니다.
set xrdr=10.0.20.10  
all.role manager
all.export /data
xrd.port 1094
all.manager $(xrdr):3122

### nodnr: DNS 이름 풀이를 하지 않습니다. MN 혹은 WN들이 DNS에 등록되어 있지 않다면 반드시 nodnr를 지정해야 합니다.
### split use eth0: 공인IP와 사설IP를 동시에 쓸 경우 어느 네트워크 장치를 통해 XRootD 서비스를 실행할지를 선택해야 합니다.
#### 자세한 설명은 XRootD 설명을 보십시오. 
xrd.network nokeepalive nodnr norpipa routes split use eth0 
```
   * (2) 외부 접속용 설정파일 : 앞 챕터의 wn03(standalone 설정과 같습니다.)
```bash
### 주석들 제외하면 아래와 같음. all.role을 지정하지 않으면 server로 설정됨.
all.export / readonly
oss.localroot /xrootdfs
xrd.port 1095  
```

   * group0X-wn0{1,2}
```bash
all.export /data 
set xrdr=10.0.20.10
all.manager $(xrdr) 3121
all.role server
cms.space min 200m 500m
### nodnr: DNS 이름 풀이를 하지 않습니다. MN 혹은 WN들이 DNS에 등록되어 있지 않다면 반드시 nodnr를 지정해야 합니다.
### split use eth0: 공인IP와 사설IP를 동시에 쓸 경우 어느 네트워크 장치를 통해 XRootD 서비스를 실행할지를 선택해야 합니다.
#### 자세한 설명은 XRootD 설명을 보십시오. 
xrd.network nokeepalive nodnr norpipa routes split use eth0 

```
* group0X-wn03 : 클라이언트는 설정 내용이 없습니다.

## 실습 

### group0X-mn
1. 기존 서비스들(xrootd, cmsd)을 종료합니다. 


### group0X-wn03 
1. 기존 마운트된 파일시스템들과 서비스들을 종료합니다.


### gropu0X-wn0{1,2}
1. 기존 xrootdfs가 마운트되어 있다면 모두 해제합니다.
1. xrootd, cmsd 서비스를 중지합니다.


## 실습 Self Check


#### xrdfs 테스트
1. wn03에서 mn을 통해 xrdfs가 작동하면 성공적으로 서비스를 실행한 것입니다.


## 토의
  
   
## 주의사항
 
------------
## 실습 따라하기 : Chapter3부터는 제공되지 않습니다.
