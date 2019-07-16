# Chapter1
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
'''bash
all.export /data
set xrdr=${redirector_hostname}
all.manager \$(xrdr) 3121
all.role manager
'''
   * group0X-wn
'''bash
all.export /data
set xrdr=${redirector_hostname}
all.manager \$(xrdr) 3121
all.role server
cms.space min 200m 500m
'''

## 실습 
1. 각 조별 인원들을 본인이 담당한 서버에 접속합니다. 
1. XRootD의 패키지를 설치할 수 있는 YUM 저장소는 [XRootD 홈페이지](http://xrootd.org/dload.html)를 방문하시면 구할 수 있습니다.
   * 실제 업무에서는 EPEL 저장소를 사용하시면 됩니다만, 이 실습에서는 직접 YUM 저장소를 설치하여야 합니다.
1. 맡은 서버에 xrootd 패키지를 설치합니다.
1. xrootd 계정의 사용자ID 숫자(UID)와 그룹ID 숫자(GID)를 1094로 변경합니다.
1. 방화벽(firewalld) 서비스를 재시작하고 port 1094/tcp와 3121/tcp를 허용합니다.
1. XRootD 설정 파일을 작성합니다. 파일 내용은 위 설정 내용을 참고 바랍니다.

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


