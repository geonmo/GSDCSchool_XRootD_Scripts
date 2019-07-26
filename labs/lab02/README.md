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
   
## 환경설정

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




