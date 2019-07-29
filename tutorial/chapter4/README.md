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
   *  group0X-mn : MN 서버는 XRootD의 Redirector로 활용합니다.
   *  group0X-wn01,02 : XRootD의 Server로 활용합니다.
   *  group0X-wn03 : XRootD 클라이언트로 활용합니다.

## 사전 지식

## 실습 준비
   * Chapter1 상태를 기본으로 합니다만, mn을 통해 wn01, wn02가 통신이 가능하다면 어떠한 환경이라도 상관 없습니다.
   
## 주요 설정 파일 내용
   * group0X-mn 
```bash
all.role manager

xrd.port 1094
all.manager $(xrdr):3122
xrd.network nokeepalive nodnr norpipa routes split use eth0 
```
   * group0X-wn0{1,2}
```bash
all.export /data 
set xrdr=group09-mn
all.manager $(xrdr) 3121
all.role server
cms.space min 200m 500m
xrd.network nokeepalive nodnr norpipa routes split use eth0 

```
* group0X-wn03 : 클라이언트는 설정 내용이 없습니다. 모든 xrootd, cmsd 서비스를 종료하세요.

## 실습 

### group0X-mn
1. 기존 서비스들(xrootd, cmsd)을 종료합니다. 

### group0X-wn03 (Standalone 모드로 실행합니다. cmsd 서비스가 필요 없습니다.)
1. 기존 xrootdfs가 마운트되어 있다면 모두 해제합니다.
1. 기존 서비스를 모두 멈춥니다. (xrootd, cmsd)
1. /mnt/disk01과 /mnt/disk02의 모든 파일을 삭제합니다. ( rm -rf /mnt/disk01 ; rm -rf /mnt/disk02 )
1. 두 디렉토리에 /data 디렉토리를 만들고 사용자와 그룹을 xrootd로 변경합니다.
1. /etc/xrootd/xrootd-standalone.cfg 파일을 xrootd-nas01.cfg와 xrootd-nas02.cfg로 복사합니다.
1. xrootd-nas01.cfg의 all.export /tmp 를 all.export /로 변경합니다.
1. xrootd-nas01.cfg 파일에 oss.localroot /mnt/disk01을 추가합니다.
1. xrootd-nas01.cfg 파일에 xrd.port 1095를 추가합니다.
1. xrootd-nas02.cfg의 all.export /tmp 를 all.export /로 변경합니다.
1. xrootd-nas02.cfg 파일에 oss.localroot /mnt/disk02을 추가합니다.
1. xrootd-nas02.cfg 파일에 xrd.port 1096를 추가합니다.
1. xrootd@nas01 서비스와 xrootd@nas02 서비스를 시작합니다.
1. xrdfs 명령어를 통해 서비스가 제대로 작동하는지 확인합니다.
1. 방화벽에서 외부에서 1095/tcp, 1096/tcp 포트 접근을 허용합니다.
1. gropu09-wn01, 02에서 xrdfs로 접근이 가능한지를 점검합니다.

### gropu0X-wn0{1,2}
1. 기존 xrootdfs가 마운트되어 있다면 모두 해제합니다.
1. xrootd, cmsd 서비스를 중지합니다.
1. /cms/nas 디렉토리에 group0X-wn03:1095(on wn01)와 gropu0X-wn03:1096(on wn02)을 xrootdfs 명령어 혹은 fstab을 수정하여 마운트합니다.
1. 기존 xrootd-multidisk.cfg 파일을 xrootd-mix.cfg로 복사합니다.
1. xrootd-mix.cfg에 oss.space public /mnt/nas를 추가합니다.
1. xrootd-mix.cfg에 all.export /data 를 all.export /data noxattrs로 변경합니다. (noxattrs 추가)
1. xrootd@mix 서비스를 시작합니다.

## 실습 Self Check


#### XRootDFS 테스트
1. 다음과 같이 xrootdfs를 마운트 합니다.
```bash
sudo mkdir /xrootdfs_group0X-wn0Y
sudo xrootdfs -o rdr=xroot://group0X-wn0Y:1094//data,uid=xrootd /xrdfs_group0X-wn0Y
sudo xrootdfs -o rdr=xroot://group0X-mn:1094//data,uid=xrootd /xrootdfs
```
2. 그 후 디렉토리를 확인하여 모든 서버들의 정보가 올바로 표시되는지 확인합니다.
```bash
ls /xrootd_group0X-wn0Y
ls /xrootdfs
```
3. /xrootd_group0X-wn0Y 디렉토리는 3GB로 표시되어야 합니다.(디스크 2GB + XRootDFS 1GB) 다음 명령어로 확인할 수 있습니다.
```bash
df -h
```

## 토의
   * 디스크와 NAS를 섞어 쓸 경우 문제점이 무엇인가요?
   * 만약 네트워크 파일시스템을 섞어 쓸 경우 어떤 식으로 구성하면 이러한 문제를 해결할 수 있을까요? 
   
## (선택사항) oss.space 대신 oss.cache 를 이용하여 디스크를 구성하면 어떠한 차이가 발생하는지 확인해봅시다.
   
## 주의사항
   * Chapter1에서도 설명하였지만 /var/run/xrootd, /var/log/xrootd의 권한(혹은 소유주)가 xrootd인지를 확인하시기 바랍니다.
   * 부득이하게 XRootDFS로만 실습을 하였습니다. xattr 옵션이 켜진 상태로 nfs상에서 테스트를 진행하면 0바이트 파일이 생성이 되고 실제로는 disk 디렉토리에만 파일이 저장됩니다.

```bash
### xrootd 포트번호 변경
xrd.port 1096
```
 
------------
## 실습 따라하기 : Chapter3부터는 제공되지 않습니다.
