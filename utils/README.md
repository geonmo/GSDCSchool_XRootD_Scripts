# GSDC School XRootD 스크립트 모음 페이지입니다.
## 다음 명령어로 해당 스크립트들을 복사할 수 있습니다.
```bash
yum install -y git
git clone https://github.com/geonmo/GSDCSchool_XRootD_Scripts.git
```

## setup_xrootd.sh
XRootD 서버 설치를 실패한 수강생 분들을 위해 스크립트를 지원해드립니다.

## make_blkdev.sh
이 프로그램은 Tutorial Chapter2에 사용됩니다. 파일 2개를 이용하여 가상의 디스크를 생성합니다.

## wordcounter.py

인자로 네이버 뉴스 데이터를 입력 받습니다. 

입력 받은 뉴스를 기반으로 뉴스건별로 해당 뉴스에 들어있는 한글 단어들을 카운트하여 보여줍니다.

해당 스크립트에서 **조사** 제거는 이루어지지 않습니다.
```bash
./wordcounter.py Article_economy_201901_201907.csv
20190731,데일리안,집,5
20190731,데일리안,네그로스,4
20190731,데일리안,봉사활동을,4
20190731,데일리안,및,3
20190731,데일리안,짓기,3
20190731,데일리안,중부,3
20190731,데일리안,지난,3
20190731,데일리안,섬에서,3
20190731,데일리안,필리핀,3
20190731,데일리안,글로벌,3
```
다음과 같이 사용하여 파일로 작성하도록 합시다.
```bash
./wordcounter.py Article_economy_201901_201907.csv > output.csv
```


## loadOutput.py
이 프로그램은 wordcounter.py의 결과물을 이용하여 데이터 중 일부를 추출하여 그림으로 그려주는 프로그램입니다.

플롯을 보는 프로그램이기 때문에 단독 실행하지 않고 python -i 명령어로 창을 띄워서 확인하시기 바랍니다.
```bash
python -i loadOutput.py
```


