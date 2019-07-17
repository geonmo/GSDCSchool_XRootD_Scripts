# Chapter 2. 2개 이상의 디스크를 사용할 경우


## 이 챕터의 목표
   * 공인IP를 사용하는 XRootD 서버를 구축할 수 있다.
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
oss.space data /mnt/disk01
oss.space data /mnt/disk02

all.export /data
oss.localroot /data
set xrdr=group0X-mn
all.manager $(xrdr) 3121
all.role server

cms.space min 200m 500m
```

## 실습 준비 
   * 해당 실습을 하기 앞서 가상의 디스크를 준비합니다.
      * 아래 코드는 solution 디렉토리에 같은 내용으로 스크립트가 작성되어 있습니다.
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



## 실습 
1. 각 조별 인원들을 본인이 담당한 서버에 접속합니다. 
1. xrootd 서비스를 시작합니다.

## 실습 Self Check

#### 공통 Step
1. xrootd-fuse와 xrootd-client 패키지를 설치합니다.
```bash
yum install -y xrootd-fuse xrootd-client
```
#### XRootD 서버측 점검
1. 각 XRootD 서버(group0X-wn) 담당자들은 본인의 서버에서 자신의 xrootd 서버에 접근이 가능한지 확인합니다.
   * 본인의 서버에서 /data파일에 만들어둔 파일이 보이면 성공입니다.
```bash
xrdfs group0X-wn0Y ls /data
```
혹은 아래와 같이 접속 후 내용을 확인하셔도 됩니다.
```bash
xrdfs group0X-wn0Y 
cd /data
ls 
```
#### XRootD Redirector측 점검
1. 마찬가지로 redirector로 접근하여 모든 하위 XRootD 서버들의 파일이 보이는지를 점검합니다.
```bash
xrdfs group0X-mn ls /data
```
2. XRootD 서버에서도 Redirector쪽에 잘 접근이 되는지 위 명령어를 그대로 입력하여 테스트를 해봅시다.

#### XRootDFS 테스트
1. 위 테스트가 끝나면 모든 머신에서 다음과 같이 xrootdfs를 마운트 합니다.
```bash
sudo mkdir /xrootdfs
sudo xrootdfs -o rdr=xroot://group0X-mn:1094//data,uid=xrootd
```
2. 그 후 디렉토리를 확인하여 모든 서버들의 정보가 올바로 표시되는지 확인합니다.
```bash
ls /xrootdfs
```


## 주의사항
   * Solution 디렉토리에 답안이 준비되어 있으나 실습 단계에서는 보고 따라 쳐주시기 바랍니다.
   * 설정 파일의 주석은 샵 기호(\#)로 할 수 있습니다.
   * 혹시 설정에 아무런 문제가 없는데 작동이 되지 않는다면 패키지가 불안정하게 설치되었을 가능성도 있습니다. 
      * yum reinstall를 통해 xrootd 와 xrootd-libs 등을 재설치하시면 문제가 해결됩니다.
   * 팀원 분들과 긴밀히 상의하시면서 작성하시기 바랍니다. 
   * 아래 실습 따라하기는 위 내용에 대한 답안을 포함하고 있습니다. 되도록 위 내용만 가지고 풀어보시기 바랍니다.
------------
## 실습 따라하기
<details><summary>안내 보기</summary>

<p>
  
1. 아래의 명령어로 yum 저장소(/etc/yum.repos.d)에 추가할 수 있습니다.
   * 내용 중 홈페이지 내용 중 _[Yum Repositories]_ - _[Stable]_ 항목의 *xrootd-stable-slc7.repo* 글자 위에서 마우스 오른쪽을 클릭하고 **링크 주소 복사**를 누르시면 URL을 복사할 수 있습니다. 
```bash
sudo wget http://xrootd.org/binaries/xrootd-stable-slc7.repo -P /etc/yum.repos.d/
```
2. 다음 명령어로 패키지를 설치합니다.
```bash
sudo yum install -y xrootd
```
3. 다음 명령어로 _xrootd_ 그룹의 gid와 _xrootd_ 사용자의 uid와 gid를 변경합니다.
```bash
sudo groupmod -g 1094 xrootd
sudo usermod -u 1094 -g 1094 xrootd
```
4. 방화벽 프로그램을 이용하여 1094/tcp, 3121/tcp를 영구적으로 추가하고 이를 현재 시스템에 적용합니다.
```bash
sudo systemctl restart firewalld
sudo firewall-cmd --permanent --add-port=1094/tcp
sudo firewall-cmd --permanent --add-port=3121/tcp
sudo firewall-cmd --reload
```
5. /etc/xrootd 디렉토리로 이동하여 xrootd-myconf.cfg 파일을 만듭니다. 
   * xrootd-clustered.cfg 파일을 참고할 수 있습니다만, 해당 파일 자체는 권한 설정의 문제로 작동을 하지 않습니다.
```bash
cd /etc/xrootd
vim xrootd-myconf.cfg
```
6. /data 디렉토리를 만듭니다.
```bash
sudo mkdir /data
```
7. /data 디렉토리의 사용자와 그룹을 변경합니다.
   * -R 옵션은 하부 디렉토리를 전부 바꿀 때 사용합니다. /data에 하부 디렉토리가 없기 때문에 의미는 없습니다.
```bash
sudo chown -R xrootd.xrootd /data
```
8. myconf 설정 파일용 cmsd, xrootd 서비스를 시작합니다. 또한, 이후 부팅시에도 서비스가 시작되도록 활성화합니다.
```bash
sudo systemctl start cmsd@myconf.service
sudo systemctl enable cmsd@myconf.service
sudo systemctl start xrootd@myconf.service
sudo systemctl enable xrootd@myconf.service

```
</p>
</details>



