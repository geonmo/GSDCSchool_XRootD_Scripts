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
모든 머신들에 python 분석 툴을 이용하여 가장 간단한 가공 작업을 진행하고자 합니다.
다음 명령어를 따라 입력해주십시오.
```bash
sudo yum install -y numpy python-pandas
```


