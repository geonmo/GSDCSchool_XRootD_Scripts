# Chapter1. 단일 디스크를 이용한 XRootD 스토리지 구축


## 이 챕터의 목표
   * XRootD 서버를 설치할 수 있다.
   * XRootD 서버를 위한 방화벽을 설정할 수 있다.
   * XRootD 스토리지를 사용하여 파일을 저장하거나 마운트할 수 있다.

## 실습 개요
이번 실습을 통해 다음 조건을 만족하는 4개의 서버를 이용하여 XRootD 스토리지를 구축하는 방법을 익힙니다. 
   * 클라이언트(사용자)는 리다이렉트 서버 뿐만 아니라 각 디스크 서버들에 직접 접근이 가능해야 합니다. 
      * 예) ping
   * 클라이언트(사용자)는 리다이렉트 서버 뿐만 아니라 디스크 노드들의 호스트 이름(DNS 혹은 hosts 파일)를 알고 있어야 합니다.
   * 디스크 노드들은 데이터를 저장하기 위해 1개의 디스크를 가지고 있으며 이를 각 노드에 마운트하였습니다.


위 조건을 만족하지 않는 경우 이 구성방법으로 스토리지를 구축할 수 없습니다.

## 서버 설명
각 서버들은 다음과 같은 역할로 설정될 것입니다.
   *  group0X-mn : MN 서버는 XRootD의 Redirector로 활용합니다.
   *  group0X-wn : WN 서버들은 XRootD의 Server로 활용합니다.


클라이언트(혹은 사용자)는 4개 서버 중 어떤 서버를 사용하든 상관 없습니다.

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
1. XRootD 설정 파일을 올바른 위치(/etc/xrootd/로 복사합니다. 
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

#### XRootD 서버 체크
1. xrootd-fuse와 xrootd-client 패키지를 설치합니다.
```bash
yum install -y xrootd-fuse xrootd-client
```
2. 본인의 서버에서 자신의 xrootd 서버에 접근이 가능한지 확인합니다.
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
3. 위 방식으로 타 XRootD 서버(group0X-wn0Y')에 접근이 가능한지 체크합니다.
4. 위 방식으로 XRootD Redirect 서버(group0X-mn)에 접근이 가능한지 체크합니다.

#### xrdcp 테스트
Redirector로 데이터를 전송할 때 제대로 데이터가 전송되는지를 점검합니다.
1. 임시 파일을 만듭니다.
```bash 
dd if=/dev/urandom of=$(uuidgen) bs=100M count=1
ls -l
```
2. 생성된 파일을 MN 서버로 전송합니다.
```bash
xrdcp <파일이름> root://group0X-mn//data
```
3. 전송이 성공적으로 이루어졌는지 확인합니다.
```bash
xrdfs gropu0X-mn ls /data
```
4. 해당 파일이 어느 서버로 전송되었는지 확인합니다.
```bash
xrdfs group0X-mn locate /data/<filename>
```

#### XRootDFS 테스트
1. 위 테스트가 끝나면 모든 머신에서 다음과 같이 xrootdfs를 마운트 합니다.
```bash
sudo mkdir /xrootdfs
sudo xrootdfs -o rdr=xroot://group0X-mn:1094//data,uid=xrootd /xrootdfs
```
2. 그 후 디렉토리를 확인하여 모든 서버들의 정보가 올바로 표시되는지 확인합니다.
```bash
ls /xrootdfs
```
3. (선택사항) 위 xrootdfs 마운트를 부팅 후에도 적용되도록 설정할 수 있습니다.
   * /etc/fstab에 다음 내용을 추가하십시오.
```bash
xrootdfs	/xrootdfs	fuse	rdr=xroot://group09-mn:1094//data,uid=xrootd 0 0
```
   * 다음 명령어로 해당 디렉토리를 마운트합니다.
```bash
mount /xrootdfs
```
   * /etc/fstab에 입력된 정보는 서버가 기억하고 있기 때문에 별도의 옵션 없이 마운트가 가능합니다.
   
## 주의사항
   * Solution 디렉토리에 답안이 준비되어 있으나 실습 단계에서는 보고 따라 쳐주시기 바랍니다.
   * 설정 파일의 주석은 샵 기호(\#)로 할 수 있습니다.
   * 혹시 설정에 아무런 문제가 없는데 작동이 되지 않는다면 패키지가 불안정하게 설치되었을 가능성도 있습니다. 
      * yum reinstall를 통해 xrootd 와 xrootd-libs 등을 재설치하시면 문제가 해결됩니다.
   * 팀원 분들과 긴밀히 상의하시면서 작성하시기 바랍니다. 
   * 아래 실습 따라하기는 위 내용에 대한 답안을 포함하고 있습니다. 되도록 위 내용만 가지고 풀어보시기 바랍니다.
## 토론
   * XRootD Redirector에 파일을 저장하는 것과 XRootD Server에 저장하는 것은 무슨 차이가 있을까요?
   * 리다이렉트 서버 없이도 정상적으로 서비스가 가능할까요? 
    
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
5. /var/log/xrootd 와 /var/run/xrootd의 소유자를 xrootd로 변경합니다.
```bash
 chown -R xrootd.xrootd /var/log/xrootd
 chown -R xrootd.xrootd /var/run/xrootd
 ```
6. /etc/xrootd 디렉토리로 이동하여 xrootd-myconf.cfg 파일을 만듭니다. 
   * xrootd-clustered.cfg 파일을 참고할 수 있습니다만, 해당 파일 자체는 권한 설정의 문제로 작동을 하지 않습니다.
```bash
cd /etc/xrootd
sudo vim xrootd-myconf.cfg
```
7. /data 디렉토리를 만듭니다.
```bash
sudo mkdir /data
```
8. /data 디렉토리의 사용자와 그룹을 변경합니다.
   * -R 옵션은 하부 디렉토리를 전부 바꿀 때 사용합니다. /data에 하부 디렉토리가 없기 때문에 의미는 없습니다.
```bash
sudo chown -R xrootd.xrootd /data
```
9. myconf 설정 파일용 cmsd, xrootd 서비스를 시작합니다. 또한, 이후 부팅시에도 서비스가 시작되도록 활성화합니다.
```bash
sudo systemctl start cmsd@myconf.service
sudo systemctl enable cmsd@myconf.service
sudo systemctl start xrootd@myconf.service
sudo systemctl enable xrootd@myconf.service

```
</p>
</details>



