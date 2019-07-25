#!/usr/bin/env python
#-*- coding:utf-8 -*-
import os, sys, operator

class WordCounter:
    def __init__(self ):
        self.words_dict = {}
        self.words_total_sum = {}
    def load(self,news):
        self.words_dict = {}
        self.date = news[0]
        self.category = news[1]
        self.journal = news[2]
        self.title = news[3]
        words =  news[4].split()
        if ( len(words)==0) : return []
        for word in words :
            if word in self.words_dict:
                self.words_dict[word] = self.words_dict[word]+1
            else :
                self.words_dict[word] = 1
            """
            if word in self.words_total_sum:
                self.words_total_sum[word] = self.words_total_sum[word]+1
            else:
                self.words_total_sum[word] = 1
            """
    def printCounter(self,minCount=2 ):
        new_dict = dict( (k,v) for (k,v) in self.words_dict.iteritems() if v> minCount)
        sorted_words = sorted(new_dict.items(), key=operator.itemgetter(1))
        sorted_words.reverse()
        for word in sorted_words:
            print("%s,%s,%s,%d"%(self.date,self.journal,word[0], word[1]))
        return sorted_words
    """
    def printTotalSum(self, minCount=5):
        total_dict = dict( (k,v) for (k,v) in self.words_total_sum.iteritems() if v> minCount)
        total_words = sorted(total_dict.items(), key=operator.itemgetter(1))
        total_words.reverse()
        for tword in total_words:
            print("%s,%d"%(tword[0], tword[1]))
        return total_words
    """

if __name__ == "__main__":
    files= sys.argv[1:]
    for novel in files :
        with open(novel) as infile:
            news_tuples = []
            for news in infile.readlines():
                news_tuples.append(news.split(","))
    wc = WordCounter()
    for news_tuple in news_tuples:
        #print u"날짜: ", news_tuple[0]
        #print u"분야: ", news_tuple[1]
        #print u"언론사: ", news_tuple[2]
        #print u"제목: ", news_tuple[3]
        #print u"본문: ", news_tuple[4]
        #print u"기사 주소: ", news_tuple[5]
        wc.load(news_tuple)
        wc.printCounter()
    #print("\n\n\n===============\n\n\n")
    #wc.printTotalSum()

