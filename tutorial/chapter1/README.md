# Chapter1. 완전 개방형 단일 디스크 기반 XRootD 스토리지


## 이 챕터의 목표
   * XRootD 서버를 설치할 수 있다.
   * XRootD 서버를 위한 방화벽을 설정할 수 있다.
   * 공인IP를 사용하는 XRootD 서버를 구축할 수 있다.

## 실습 개요
이번 실습을 통해 공인 IP를 사용하고 있는 것으로 가정한 4개의 서버를 이용하여 외부와 직접 통신을 할 수 있는
XRootD 서버를 구축합니다. 

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
all.export /data
set xrdr=group0X-mn
all.manager $(xrdr) 3121
all.role server
cms.space min 200m 500m
```

## 실습 
1. 각 조별 인원들을 본인이 담당한 서버에 접속합니다. 
1. XRootD의 패키지를 설치할 수 있는 YUM 저장소는 [XRootD 홈페이지](http://xrootd.org/dload.html)를 방문하시면 구할 수 있습니다.
   * 실제 업무에서는 EPEL 저장소를 사용하시면 됩니다만, 이 실습에서는 직접 YUM 저장소를 설치하여야 합니다.
1. 맡은 서버에 xrootd 패키지를 설치합니다.
1. xrootd 그룹의 gid number와 xrootd 사용자 계정의 uid와 기본 gid를 1094로 변경합니다.
1. xrootd 사용자의 uid와 gid가 바뀌었으므로 /var/log/xrootd와 /var/run/xrootd 디렉토리의 소유자도 xrootd로 변경합니다
1. 방화벽(firewalld) 서비스를 재시작하고 port 1094/tcp와 3121/tcp를 허용합니다.
1. XRootD 설정 파일을 작성합니다. 
   * 파일 내용은 위 설정 내용을 참고 바랍니다.
1. XRootD 설정 파일을 올바른 위치로 복사합니다. 
   * 파일명이 서비스 이름이 되기 때문에 주의하여 입력하시기 바랍니다.
1. XRootD가 사용할 데이터 디렉토리 공간 /data를 만듭니다.
   * *이 예제에서는 추가적인 디스크를 사용하지 않습니다.*
   * *Redirector는 해당 디렉토리를 만들어주지 않아도 상관 없습니다.*
1. 제대로 마운트 되었음을 확인하기 위하여 다음과 같이 파일을 미리 만들어둡니다.
```bash
sudo touch /data/${hostname}_tutorial_chapter1
```
11. 해당 디렉토리를 xrootd 유저가 사용할 수 있도록 사용자 권한을 부여합니다.
12. cmsd 서비스를 시작합니다.
13. xrootd 서비스를 시작합니다.
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
sudo xrootdfs -o rdr=xroot://group0X-mn:1094//data,uid=xrootd /xrootd
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



