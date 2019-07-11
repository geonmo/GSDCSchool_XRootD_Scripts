# GSDC School XRootD 스크립트 모음 페이지입니다.
## XRootD 서버 설치를 실패한 유저들을 위해 스크립트를 지원해드립니다.

## DownloadNovel.sh
소설을 다운로드 해주는 프로그램입니다.

스크립트의 실행 권한을 부여한 후 실행하면 소설을 다운로드 합니다.

다음 소설들이 다운로드 됩니다.
```bash
http://www.gutenberg.org/cache/epub/31547/pg31547.txt
http://www.gutenberg.org/cache/epub/41481/pg41481.txt
http://www.gutenberg.org/cache/epub/28617/pg28617.txt
http://www.gutenberg.org/cache/epub/29607/pg29607.txt
```

## wordcounter.py

인자로 입력된 파일에 들어있는 단어들을 띄어쓰기 기준으로 분류하여 정렬해줍니다.
```bash
./WordCounter.py pg31547.txt
('the', 723)
('to', 321)
('of', 301)
('and', 301)
('you', 237)
('a', 227)
('in', 191)
('it', 179)
('i', 174)
('he', 149)
```
