#!/usr/bin/env python
import os, sys, operator


files= sys.argv[1:]

words_dict={}
for novel in files :
        infile = open(novel)
        lines = infile.readlines()
        for line_dirty in lines :
                line = line_dirty.strip().translate(None, ".#/?:$}\"*").lower()
                words = line.split()
                if ( len(words)==0) : continue
                for word in words :
                        if word in words_dict :
                                words_dict[word] = words_dict[word]+1
                        else :
                                words_dict[word] = 1

sorted_wordcounter = sorted(words_dict.items(), key=operator.itemgetter(1))
sorted_wordcounter.reverse()
for word in sorted_wordcounter :
        print word
