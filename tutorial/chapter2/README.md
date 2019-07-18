# Chapter 2. 2개 이상의 디스크를 사용할 경우


## 이 챕터의 목표
   * 2개 이상의 디스크(DAS or SAN)로 구성된 환경에서 XRootD 서버를 설치할 수 있다.

## 실습 개요
이번 실습을 통해 공인 IP를 사용하고 있는 것으로 가정한 4개의 서버들에 디스크가 여러 개가 할당될 경우 이를 함께 묶어서 사용하는 방법에 대해서 알아봅니다.

## 서버 설명
각 서버들은 다음과 같은 역할로 설정될 것입니다.
   *  group0X-mn : MN 서버는 XRootD의 Redirector로 활용합니다.
   *  group0X-wn : WN 서버들은 XRootD의 Server로 활용합니다.

## 주요 설정 파일 내용
   * group0X-mn
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
set xrdr=group09-mn
all.manager $(xrdr) 3121
all.role server
cms.space min 200m 500m
```

## 실습 준비 
1. 해당 실습을 하기 앞서 가상의 디스크를 준비합니다.
   * 아래 코드는 solution 디렉토리에 같은 내용으로 스크립트(**[make_blkdev.sh](https://github.com/geonmo/GSDCSchool_XRootD_Scripts/tree/master/solution/chapter2)**)가 작성되어 있습니다.
```bash
sudo mkdir /blockdev
cd /blockdev
sudo dd if=/dev/zero of=dev01.img bs=1G count=1
sudo dd if=/dev/zero of=dev02.img bs=1G count=1
sudo losetup /dev/loop0 /blockdev/dev01.img
sudo losetup /dev/loop1 /blockdev/dev02.img

sudo mkfs.xfs /dev/loop0
sudo mkfs.xfs /dev/loop1

sudo mkdir -p /mnt/disk01
sudo mkdir -p /mnt/disk02

sudo mount -t xfs /dev/loop0 /mnt/disk01
sudo mount -t xfs /dev/loop1 /mnt/disk02

```
2. 아래 명령어로 제대로 마운트(###)가 되었는지 확인이 가능합니다.
```bash
[gsdc@group09-wn01 GSDCSchool_XRootD_Scripts]$ df
Filesystem          1K-blocks    Used Available Use% Mounted on
/dev/mapper/sl-root   8869888 2902064   5967824  33% /
devtmpfs              8182756       0   8182756   0% /dev
tmpfs                 8197964       0   8197964   0% /dev/shm
tmpfs                 8197964   16768   8181196   1% /run
tmpfs                 8197964       0   8197964   0% /sys/fs/cgroup
tmpfs                 8197964      20   8197944   1% /tmp
/dev/vda1              508588  223440    285148  44% /boot
/dev/vdb             20961264      48  20961216   1% /mnt
tmpfs                 1639596       0   1639596   0% /run/user/1001
/dev/loop0            1038336   32928   1005408   4% /mnt/disk01   ###
/dev/loop1            1038336   32928   1005408   4% /mnt/disk02   ###
[gsdc@group09-wn01 GSDCSchool_XRootD_Scripts]$ 
```


## 실습 
1. 각 조별 인원들을 본인이 담당한 서버에 접속합니다.    
1. /xrootdfs 디렉토리의 마운트를 해제합니다. 
   * 만약, 다른 디스크 서버들이 먼저 해제하거나 사용 중으로 해제가 안된다면 -l 옵션으로 마운트를 해제하시기 바랍니다.
1. XRootD 디스크 노드의 xrootd와 cmsd 서비스를 중지합니다.
1. /mnt/disk01과 /mnt/disk02에 쓰기가 가능한지 확인합니다. 
   * xrootd 사용자는 해당 디렉토리에 반드시 쓰기가 가능해야 합니다.
1. /etc/xrootd/xrootd-myconf.cfg 파일을 같은 디렉토리의 xrootd-multidisk.cfg로 복사합니다.
1. xrootd-multidisk.cfg 내용을 위 내용을 참고하여 수정합니다.   
1. xrootd와 cmsd 서비스를 시작합니다.
1. 기존 myconf 서비스를 비활성화하고 multidisk 서비스 활성화합니다.
## 실습 Self Check


#### XRootDFS 테스트
1. 위 테스트가 끝나면 모든 머신에서 다음과 같이 xrootdfs를 마운트 합니다.
```bash
sudo mkdir /xrootdfs_group0X-wn0Y
sudo xrootdfs -o rdr=xroot://group0X-wn0Y:1094//data,uid=xrootd /xrdfs_group0X-wn0Y
sudo xrootdfs -o rdr=xroot://group0X-mn:1094//data,uid=xrootd /xrootdfs
```
2. 그 후 디렉토리를 확인하여 모든 서버들의 정보가 올바로 표시되는지 확인합니다.
```bash
ls /xrootdfs
```


## 주의사항
   * 설정 파일의 주석은 샵 기호(\#)로 할 수 있습니다.   
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
만약에 xrootd의 쓰기 권한을 실제로 점검하고 싶다면 다음과 같이 shell을 변경한 후 직접 접근합니다.
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



