# Chapter1. 공인IP를 사용하는 환경에서의 XRootD 서버 구축
## 이 챕터의 목표
   * XRootD 서버를 설치할 수 있다.
   * XRootD 서버를 위한 방화벽을 설정할 수 있다.
   * 공인IP를 사용하는 XRootD 서버를 구축할 수 있다.

## 실습 개요
이번 실습을 통해 공인 IP를 사용하고 있는 것으로 가정한 4개의 서버를 이용하여 외부와 직접 통신을 할 수 있는
XRootD 서버를 구축합니다. 

## 서버 설명
각 서버들은 다음과 같은 역할로 설정될 것입니다.
   *  group0X-mn : MN 서버들은 XRootD의 Redirector로 활용합니다.
   *  group0X-wn : WN 서버들은 XRootD의 Server로 활용합니다.
## 주요 설정 파일 내용
   * group0X-mn
```bash
all.export /data
set xrdr=${redirector_hostname}
all.manager \$(xrdr) 3121
all.role manager
```
   * group0X-wn
```bash
all.export /data
set xrdr=${redirector_hostname}
all.manager \$(xrdr) 3121
all.role server
cms.space min 200m 500m
```

## 실습 
1. 각 조별 인원들을 본인이 담당한 서버에 접속합니다. 
1. XRootD의 패키지를 설치할 수 있는 YUM 저장소는 [XRootD 홈페이지](http://xrootd.org/dload.html)를 방문하시면 구할 수 있습니다.
   * 실제 업무에서는 EPEL 저장소를 사용하시면 됩니다만, 이 실습에서는 직접 YUM 저장소를 설치하여야 합니다.
1. 맡은 서버에 xrootd 패키지를 설치합니다.
1. xrootd 계정의 사용자ID 숫자(UID)와 그룹ID 숫자(GID)를 1094로 변경합니다.
1. 방화벽(firewalld) 서비스를 재시작하고 port 1094/tcp와 3121/tcp를 허용합니다.
1. XRootD 설정 파일을 작성합니다. 
   * 파일 내용은 위 설정 내용을 참고 바랍니다.
1. XRootD 설정 파일을 올바른 위치로 복사합니다. 
   * 파일명이 서비스 이름이 되기 때문에 주의하여 입력하시기 바랍니다.
1. XRootD가 사용할 데이터 디렉토리 공간 /data를 만듭니다.
   * *이 예제에서는 추가적인 디스크를 사용하지 않습니다.*
   * *Redirector는 만들어주지 않아도 상관 없습니다.*
1. 제대로 마운트 되었음을 확인하기 위하여 다음과 같이 파일을 미리 만들어둡니다.
```bash
sudo touch /data/${hostname}_tutorial_chapter1
```
1. 해당 디렉토리를 xrootd 유저가 사용할 수 있도록 사용자 권한을 부여합니다.
1. cmsd 서비스를 시작합니다.
1. xrootd 서비스를 시작합니다.
## 실습 Self Check

#### 공통 Step
1. xrootd-fuse와 xrootd-client 패키지를 설치합니다.
#### XRootD 서버측 점검
1. 각 XRootD 서버(group0X-wn) 담당자들은 본인의 서버에서 자신의 xrootd 서버에 접근이 가능한지 확인합니다.
   * 본인의 서버에서 /data파일에 만들어둔 파일이 보이면 성공입니다.
```bash
xrdfs group0X-wn0Y ls /data
```
혹은
```bash
xrdfs group0X-wn0Y 로 접속 후 
cd /data
ls 
```
를 입력하셔도 됩니다.
#### XRootD Redirector측 점검
1. 마찬가지로 redirector로 접근하여 모든 하위 XRootD 서버들의 파일이 보이는지를 점검합니다.
```bash
xrdfs group0X-mn ls /data
```


## 실습 안내
<details><summary>안내 보기</summary>

```python
print("hello world!")
```

</details>


## 주의사항
   * Solution 디렉토리에 답안이 준비되어 있으나 실습 단계에서는 보고 따라 쳐주시기 바랍니다.
   * 각 라인마다 주석(\#)을 통해 알게된 내용에 대해서 기입해주셔도 좋습니다.
   * 혹시 설정에 아무런 문제가 없는데 작동이 되지 않는다면 패키지가 불안정하게 설치되었을 가능성도 있습니다. yum reinstall를 통해 xrootd 와 xrootd-libs 등을 재설치하시면 문제가 해결됩니다.


