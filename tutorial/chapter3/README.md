# Chapter 3. NAS를 포함하여 구축하기


## 이 챕터의 목표
   * NAS가 포함된 XRootD 스토리지 시스템을 구축할 수 있다.

## 실습 개요
이번 실습을 통해 다음 조건을 만족하는 4개의 서버를 이용하여 XRootD 스토리지를 구축하는 방법을 익힙니다. 
   * 클라이언트(사용자)는 리다이렉트 서버 뿐만 아니라 각 디스크 서버들에 직접 접근이 가능해야 합니다.       
   * 클라이언트(사용자)는 리다이렉트 서버 뿐만 아니라 디스크 노드들의 호스트 이름(DNS 혹은 hosts 파일)를 알고 있어야 합니다.
   * 디스크 노드들은 데이터를 저장하기 위해 1개 이상의 디스크와 NAS 디렉토리를 가지고 있습니다.



**이번 Tutorial부터 모든 부분에 대해서 설명하지 않습니다. 반복적인 부분에 대해서 궁금하시면 이전 Tutorial 내용을 참고하시기 바랍니다.**

## 서버 설명
각 서버들은 다음과 같은 역할로 설정될 것입니다.
   *  group0X-mn : MN 서버는 XRootD의 Redirector로 활용합니다.
   *  group0X-wn01,02 : XRootD의 Server로 활용합니다.
   *  group0X-wn03 : NAS Server로 활용합니다.
![xrootd_chapter3_figure](https://user-images.githubusercontent.com/4969463/61511638-5bfe7400-aa32-11e9-8201-86aa081ffd21.png)

## 사전 지식 설명
#### FileSystem과 user_xattr
chapter2에서 각 wn의 disk01과 disk02는 디스크를 xfs 파일시스템으로 만든 것을 기억하실 겁니다.

리눅스에서 많이 사용되는 ext4와 xfs 파일시스템에는 user_attr이라는 재미있는 기능이 포함되어 있습니다. 

먼저 이 기능을 어떻게 사용하는지 보여드리겠습니다.

```bash
## /mnt/disk01 디렉토리는 xfs 파일시스템으로 포맷되었습니다.
cd /mnt/disk01
## game.img 파일을 생성합니다. 
sudo dd if=/dev/urandom of=game.img bs=10M count=1

## 해당 파일은 10M 크기로 작성되었습니다.
ls -lh game.img

## game.img 파일에다가 user attribute를 추가합니다. 반드시 user. 로 시작해야 합니다.
sudo setfattr -n user.game_title -v "starcraft2" game.img

## 그리고 다음 명령어로 해당 내용을 확인할 수 있습니다.
getfattr -d game.img

## 출력 ##
# file: game.img
user.game_title="starcraft2"
```
이 기능을 이용하여 chapter2에서 복사했던 파일의 내용을 확인해봅시다.

```bash
## sudo -i로 root로 아이디를 변경합니다.
sudo -i
cd /mnt/disk01/public/00

## xrdcp로 복사한 파일을 확인합니다. 혹시 파일이 없으면 파일을 여러 개를 집어넣어 확인해봅시다.
ls -l

## 해당 파일의 attribute를 확인합니다.
getfattr -d 72E02F5D3ECC000000000a00140b000000000C6% 

## 출력 ##
# file: 72E02F5D3ECC000000000a00140b000000000C6%
user.XrdFrm.Pfn="/data/o.dat"
```
xrootd의 멀티 디스크 구조에서는 파일 구조를 담은 디스크 파손시 복구를 위해 해당 파일의 경로를 user_xattr을 이용하여 저장하게 됩니다.

불행히도 해당 기능은 몇몇 파일시스템에서만 지원이 되며 

nfs나 xrootdfs 같은 NAS에서는 대개 지원되지 않습니다. (표준안은 제출되었습니다.)

해당 기능을 아래와 같이 테스트해 볼 수 있습니다.
```bash
## On NFS, it is not working.
[geonmo@ui10 ~]$ setfattr -n hello -v world noXattrOnNAS.txt 
setfattr: noXattrOnNAS.txt: Operation not supported

## On XRootDFS, no changed for user_xattr.
[geonmo@ui10 xrootd]$ setfattr -n hello -v world noXattrOnXRootDFS.txt 
[geonmo@ui10 xrootd]$ getfattr -d noXattrOnXRootDFS.txt 
[geonmo@ui10 xrootd]$ 
```
저장될 공간 중 일부가 xattr 기능을 지원하지 않는다면 해당 디스크 공간에 쓰기를 시도할 때 에러가 발생합니다.

이러한 문제를 피하기 위해 xattr 기능을 꺼두면 됩니다. 단, PFN 위치 저장이 불가능해집니다.



## 실습 준비
   * Chapter2 종료 후 환경을 기준으로 시작합니다.

## 주요 설정 파일 내용
   * group0X-mn : 변경 없음
   * group0X-wn0{1,2}
```bash
oss.localroot /
oss.space public /mnt/disk01
oss.space public /mnt/disk02
oss.space public /mnt/nas

all.export /data noxattrs
set xrdr=group09-mn
all.manager $(xrdr) 3121
all.role server
cms.space min 200m 500m
```
* group0X-wn03
```bash
### 주석들 제외하면 아래와 같음. all.role을 지정하지 않으면 server로 설정됨.
all.export /
oss.localroot /mnt/disk01
all.adminpath /var/spool/xrootd
all.pidpath /var/run/xrootd
xrd.port 1095
continue /etc/xrootd/config.d/
```

## 실습 

### group0X-mn은 변경사항 없습니다.

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
1. /cms/nas 디렉토리에 group0X-wn03:1095와 gropu0X-wn03:1096을 xrootdfs 명령어 혹은 fstab을 수정하여 마운트합니다.
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
3. /xrootd_group0X-wn0Y 디렉토리는 2GB정도로 표시되어야 합니다. 다음 명령어로 확인할 수 있습니다.
```bash
df -h
```

## 토의
   * 디스크와 NAS를 섞어 쓸 경우 문제점이 무엇인가요?
   * 만약 네트워크 파일시스템을 섞어 쓸 경우 어떤 식으로 구성하면 이러한 문제를 해결할 수 있을까요? 
   
## (선택사항) oss.space 대신 oss.cache 를 이용하여 디스크를 구성하면 어떠한 차이가 발생하는지 확인해봅시다.
   
## 주의사항
   *    

```bash
### xrootd 포트번호 변경
xrd.port 1096
```
 
------------
## 실습 따라하기 : Chapter3부터는 제공되지 않습니다.
