#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
import matplotlib as mpl

mpl.rcParams['axes.unicode_minus'] = False


## 한글 폰트
path = "/home/gsdc/.fonts/NanumGothicCoding.ttf"
font_name = fm.FontProperties(fname=path, size=50).get_name()
print(font_name)
plt.rc('font', family=font_name)

data = pd.read_csv("output.csv", header=None, names=["date", "journal","keyword","count"])

data.head()

dg =data.groupby(["keyword"]).agg({"count":sum})
dg_sort = dg.sort_values(['count'],ascending=False)

dgg = dg_sort.reset_index()
#dgg_filtered = dgg[ ~dgg.keyword.isin(["있다.", "수","등","있는"])].head(20)
#print(dgg_filtered.head(20))

print("주요 키워드?")
print(dgg.head(20))
### 특정 단어를 

dgg[:20].plot(x="keyword",y="count")
plt.show()

