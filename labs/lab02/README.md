# Lab2. 클러스터를 이용한 분석 작업


## 이 챕터의 목표
   * 네이버 뉴스를 분석해보자.

## 랩 개요
이번 랩에서는 제공되는 네이버 뉴스 자료를 이용하여 여러분만의 분석 시스템을 활용해보도록 하겠습니다.

## 데이터 설명
   * 데이터는 Python 모듈 중 하나인 [KoreaNewsCrawler](https://github.com/lumyjuwon/KoreaNewsCrawler)를 사용하여 네이버 자료들을 수집하였습니다.
      * 크롤러의 특성상 시간이 많이 걸려 미리 준비된 자료를 사용하시면 됩니다.
   * 데이터의 위치는 다음과 같습니다.
   ```bash
   root://cms-xrdr.sdfarm.kr:2096//
   ```
   * 다음 6개의 데이터 파일들을 참고하시기 바랍니다.
   ```bash
/Article_IT_science_201901_201907.csv
/Article_economy_201901_201907.csv
/Article_living_culture_201901_201907.csv
/Article_opinion_201901_201907.csv
/Article_politics_201901_201907.csv
/Article_society_201901_201907.csv
/Article_world_201901_201907.csv
```
   * 데이터에 대한 세부 내용은 위 링크를 참고해주시기 바랍니다.
   
##  Lab01 구축 후 추가 환경설정

#### 1. 패키지 설치
모든 머신들에 python 분석 툴을 이용하여 간단한 분석 작업 프로그램을 설치합니다.
다음 명령어를 따라 입력해주십시오.
```bash
sudo yum install -y numpy python-pandas python-matplotlib
```
#### 2. 한글 폰트 설치
네이버 뉴스는 한글 뉴스들이기 때문에 최종적으로 그림을 그릴 때에는 한글 폰트가 필요합니다.

따라서, 모든 머신들에 다음과 같은 명령어로 한글 폰트를 설치하여 주시기 바랍니다.

여기서 사용하는 폰트는 [네이버 나눔고딕코딩 글꼴](https://github.com/naver/nanumfont)입니다.

자세한 설명은 해당 홈페이지를 참조바랍니다.

```bash
cd /tmp
wget https://github.com/naver/nanumfont/releases/download/VER2.5/NanumGothicCoding-2.5.zip
unzip NanumGothicCoding-2.5.zip
mkdir ~/.fonts
cp NanumGothicCoding*.ttf ~/.fonts
fc-cache -f -v
```
설치 후 다음 명령어로 폰트가 잘 설치되어 있는지 확인 바랍니다.
```bash
fc-list | grep Nanum

## 출력 ## 
/home/gsdc/.fonts/NanumGothicCoding-Bold.ttf: NanumGothicCoding,나눔고딕코딩:style=Bold
/home/gsdc/.fonts/NanumGothicCoding.ttf: NanumGothicCoding,나눔고딕코딩:style=Regular
```

위 방법으로 설치된 폰트는 해당 사용자만 사용이 가능합니다. 전체 사용자가 사용하도록 설정하시려면 **/usr/share/fonts** 디렉토리를 사용하시기 바랍니다.
#### 그래픽 환경 구성
그림 등의 그래픽적인 요소를 사용하기 위해서는 X-Windows 설정이 필요합니다.

다음 링크를 참고하여 X-Windows 환경 구축을 해주시기 바랍니다.
[윈도우 환경에서의 xming 설정](https://m.blog.naver.com/PostView.nhn?blogId=monocho&logNo=221114374493&proxyReferer=https%3A%2F%2Fwww.google.com%2F)
[OSX 환경을 위한 XQuartz](https://www.xquartz.org/)

또한, 반드시 ssh 접속을 하실 때 -Y 옵션을 추가하시기 바랍니다. (로컬 -> gcloud 뿐만 아니라 gcloud->mn or wn 접속 시에도)


## Lab 관련 기본사항 전달
   * 데이터 파일은 150MB~1.6GB까지 다양한 크기의 파일 6개로 구성되어 있습니다.
      * 배운 지식을 토대로 어떻게 배치할 것인지, 어떤 식으로 접근을 할 것인지 구상하고 적용해보세요. 더 좋은 방법이 있는지도 토의해보세요.
   * 해당 파일들을 1차 가공하기 위한 간단한 스크립트인[wordcounter.py](https://github.com/geonmo/GSDCSchool_XRootD_Scripts/blob/master/utils/wordcounter.py)를 제공해드립니다. 
      * 해당 스크립트를 통해 뉴스별(드린 데이터의 1줄이 1개의 뉴스기사)로 주요 단어들을 확인하실 수 있습니다.
   * wordcounter.py를 통해 출력된 결과물을 그대로 저장한 후 loadOuput.py로 이를 그림으로 보실 수 있습니다.
      * 해당 프로그램은 python Pandas를 통해 데이터를 분석합니다. 
         * 폰트 설정 등이 포함되어 있으며 groupby를 통한 데이터 선택과 그래프화하는 간단한 코드입니다. 참고용으로 보시면 됩니다.
<img width="559" alt="figure_economy" src="https://user-images.githubusercontent.com/4969463/61925863-14836500-afa9-11e9-85f1-1d995b33f413.PNG">
      

## Lab 개요
   * 위 기본사항을 참고하여 조별로 뉴스를 이용하여 독창적인 데이터 분석을 시도해보시기 바랍니다.
   * 어떠한 방법, 어떠한 툴을 쓰셔도 무방합니다.



