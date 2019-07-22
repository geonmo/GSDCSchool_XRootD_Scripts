# Chapter 3. NAS를 포함하여 구축하기


## 이 챕터의 목표
   * NAS가 포함된 XRootD 스토리지 시스템을 구축할 수 있다.

## 실습 개요
이번 실습을 통해 다음 조건을 만족하는 4개의 서버를 이용하여 XRootD 스토리지를 구축하는 방법을 익힙니다. 
   * 클라이언트(사용자)는 리다이렉트 서버 뿐만 아니라 각 디스크 서버들에 직접 접근이 가능해야 합니다.       
   * 클라이언트(사용자)는 리다이렉트 서버 뿐만 아니라 디스크 노드들의 호스트 이름(DNS 혹은 hosts 파일)를 알고 있어야 합니다.
   * 디스크 노드들은 데이터를 저장하기 위해 1개 이상의 디스크와 NAS 디렉토리를 가지고 있습니다.
 이번 Tutorial부터 모든 부분에 대해서 설명하지 않습니다. 반복적인 부분에 대해서 궁금하시면 이전 Tutorial 내용을 참고하시기 바랍니다.

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

## 출력
# file: 72E02F5D3ECC000000000a00140b000000000C6%
user.XrdFrm.Pfn="/data/o.dat"
```
xrootd의 멀티 디스크







## 실습 준비 
1. 해당 실습을 하기 앞서 가상의 디스크를 준비합니다.
   * solution 디렉토리에 있는 스크립트(**[make_blkdev.sh](https://github.com/geonmo/GSDCSchool_XRootD_Scripts/tree/master/solution/chapter2)**) 파일을 실행하십시오.
      * 한줄씩 직접 입력하고 싶은 분들을 위해 명령어를 보여드립니다.
```bash
sudo mkdir /blockdev
cd /blockdev
## 1GB짜리 2개의 파일 생성
sudo dd if=/dev/zero of=dev01.img bs=1G count=1
sudo dd if=/dev/zero of=dev02.img bs=1G count=1

## 각 파일을 loopback 장치로 등록
sudo losetup /dev/loop0 /blockdev/dev01.img
sudo losetup /dev/loop1 /blockdev/dev02.img

## xfs 파일시스템 구성 (윈도우의 포맷과 동일)
sudo mkfs.xfs /dev/loop0
sudo mkfs.xfs /dev/loop1

## 마운트할 디렉토리 생성
sudo mkdir -p /mnt/disk01
sudo mkdir -p /mnt/disk02

## 장치 파일들을 디렉토리에 마운트
sudo mount -t xfs /dev/loop0 /mnt/disk01
sudo mount -t xfs /dev/loop1 /mnt/disk02

```
2. 아래 명령어로 **/mnt/disk01**과 **/mnt/disk02**가 제대로 마운트가 되었는지 확인이 가능합니다.
```bash
df
```


## 주요 설정 파일 내용
   * group0X-mn : 변경 없음
```bash
all.export /data
set xrdr=group0X-mn
all.manager $(xrdr) 3121
all.role manager
```
   * group0X-wn
```bash
## 서버 루트 파일시스템을 이용
## disk1 위에 파일시스템을 구축하려면 
## oss.localroot /mnt/disk01 (data 디렉토리를 추가해야 함)
oss.localroot /
oss.space public /mnt/disk01
oss.space public /mnt/disk02

all.export /data
set xrdr=group0X-mn
all.manager $(xrdr) 3121
all.role server
cms.space min 200m 500m
```

## 실습 
1. 각 조별 인원들을 본인이 담당한 서버에 접속합니다.    
1. /xrootdfs 디렉토리가 마운트되어 있다면 마운트를 해제합니다. 
   * 만약, 디렉토리가 사용 중으로 해제가 안된다면 -l 옵션으로 마운트를 해제하시기 바랍니다.
1. XRootD 디스크 노드의 xrootd와 cmsd 서비스를 중지합니다.
1. /mnt/disk01과 /mnt/disk02에 쓰기가 가능한지 확인합니다. 
   * xrootd 사용자는 해당 디렉토리에 반드시 쓰기가 가능해야 합니다.
1. /etc/xrootd/xrootd-myconf.cfg 파일을 같은 디렉토리의 xrootd-multidisk.cfg로 복사합니다.
1. xrootd-multidisk.cfg 내용을 위 내용을 참고하여 수정합니다.   
1. xrootd와 cmsd 서비스를 시작합니다.
1. 기존 myconf 서비스를 비활성화하고 multidisk 서비스 활성화합니다.
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
   * 디스크 2개를 사용한 방식은 Chapter 1에서 사용된 방식과 동일하게 파일이 관리되고 있습니까?
   * 다르다면 어떻게 관리되고 있는지 설명할 수 있습니까?
   * localroot 디스크가 손상이 된다면 데이터들은 어떻게 될까요?

## 주의사항
   * 설정 파일의 주석은 샵 기호(\#)로 할 수 있습니다.   
   * MN 서버의 xrootd, cmsd 서비스를 너무 일찍 끄면 WN에 마운트되어 있는 /xrootdfs 디렉토리가 마운트 해제가 되지 않습니다. 되도록 MN의 서비스를 가장 마지막에 끄도록 합니다.
   * (선택사항) MN 서버 담당자는 해당 테스트를 실습하기 위해 다음 절차를 따르십시오.
      * 포트를 변경한 xrootd, cmsd 서비스를 추가로 띄워야 합니다. 즉, MN 서버는 xrootd, cmsd 서비스가 2개씩 띄워야 합니다.
      * WN의 xrootd-multidisk.cfg 파일을 원하는 다른 이름( 예] multidisk-mn)으로 복사한 후 아래 키워드를 추가합니다.
         * 새로 띄워진 서비스는 새로운 WN로서 MN에 접속을 시도할 것입니다.
 ```bash
### xrootd 포트번호 변경
xrd.port 1096
```
 
------------
## 실습 따라하기
<details><summary>안내 보기</summary>

<p>
  
1. /xrootdfs 디렉토리의 마운트를 해제합니다.
```bash
sudo umount /xrootdfs
```
만약 마운트 해제가 잘 안된다면
```bash
sudo umount -l /xrootdfs
```
로 해제를 합니다. 

2. xrootd, cmsd 서비스를 해제합니다.
```bash
sudo systemctl stop xrootd@myconf
sudo systemctl stop cmsd@myconf
```
3. /mnt/disk01과 /mnt/disk02의 소유자를 변경합니다.
```bash
chown -R xrootd.xrootd /mnt/disk01
chown -R xrootd.xrootd /mnt/disk02
```
xrootd의 쓰기 권한을 직접 점검하고 싶다면 다음과 같이 shell을 변경한 후 직접 접근합니다.
```bash
## xrootd 유저의 쉘을 /bin/bash로 변경
sudo chsh xrootd
/bin/bash
sudo passwd xrootd 
<xrootd 암호 설정>

## xrootd 사용자로 변경 후 쓰기 확인
su - xrootd
cd /mnt/disk01
touch a
rm a
exit

## xrootd 사용자를 접속 불가로 변경
suod chsh xrootd
/sbin/nologin
```
4. /etc/xrootd 디렉토리로 이동하여 xrootd-multidisk.cfg 파일을 만듭니다. 
```bash
cd /etc/xrootd
sudo cp xrootd-myconf.cfg xrootd-multidisk.cfg
```
5. 내용을 수정한 후 서비스를 기존 서비스를 중지한 후 multidisk 설정으로 서비스를 시작합니다.
```bash
sudo vim xrootd-multidisk.cfg
sudo systemctl start cmsd@multidisk.service
sudo systemctl start xrootd@multidisk.service
```
6. 기존 myconf 서비스를 해지하고 multidisk 서비스를 활성화합니다.
```bash
sudo systemctl disable cmsd@myconf.service
sudo systemctl disable xrootd@myconf.service
sudo systemctl enable cmsd@multidisk.service
sudo systemctl enable xrootd@multidisk.service
```
</p>
</details>



